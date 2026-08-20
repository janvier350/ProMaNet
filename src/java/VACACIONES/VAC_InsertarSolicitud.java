package VACACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

// Registra una solicitud de vacaciones del propio usuario. Queda en
// PENDIENTE_JEFE -- la aprobacion de jefe directo / Administracion /
// recepcion son pantallas de una fase posterior; esta solo crea la
// solicitud con todas las validaciones de negocio.
@WebServlet(name = "VAC_InsertarSolicitud", urlPatterns = {"/VAC_InsertarSolicitud"})
public class VAC_InsertarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_SOLICITAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        int idUsuario;
        try {
            idUsuario = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String pFechaDesde = request.getParameter("fechaDesde");
        String pFechaHasta = request.getParameter("fechaHasta");
        boolean anticipada = "on".equals(request.getParameter("anticipada")) || "true".equals(request.getParameter("anticipada"));
        String justificacionAnticipo = request.getParameter("justificacionAnticipo");

        if (anticipada && (justificacionAnticipo == null || justificacionAnticipo.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=Debes indicar la justificacion de la solicitud anticipada");
            return;
        }

        LocalDate desde, hasta;
        try {
            desde = LocalDate.parse(pFechaDesde);
            hasta = LocalDate.parse(pFechaHasta);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=Fechas invalidas");
            return;
        }

        if (hasta.isBefore(desde)) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=La fecha hasta no puede ser anterior a la fecha desde");
            return;
        }
        if (desde.isBefore(LocalDate.now())) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=No puedes solicitar vacaciones con fecha desde en el pasado");
            return;
        }

        // IMPORTANTE: si el regreso (fecha hasta) cae viernes o sabado, el
        // fin de semana queda "gratis" fuera del descuento -- se obliga a
        // extender hasta el domingo. Confirmado por el usuario para
        // viernes; se aplica el mismo criterio a sabado por el mismo
        // motivo (dejaria el domingo suelto).
        DayOfWeek diaHasta = hasta.getDayOfWeek();
        if (diaHasta == DayOfWeek.FRIDAY || diaHasta == DayOfWeek.SATURDAY) {
            LocalDate domingoSugerido = hasta.with(java.time.temporal.TemporalAdjusters.next(DayOfWeek.SUNDAY));
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error="
                    + "No puedes terminar el periodo en " + (diaHasta == DayOfWeek.FRIDAY ? "viernes" : "sabado")
                    + ": debes incluir el fin de semana completo. Extiende la fecha hasta al domingo "
                    + domingoSugerido.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            return;
        }

        int diasSolicitados = (int) (ChronoUnit.DAYS.between(desde, hasta) + 1);
        LocalDate reincorporacion = hasta.plusDays(1);

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // 1. Jefe directo asignado.
            Integer idJefe = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ID_JEFE_DIRECTO FROM VAC_CONFIG_USUARIO WHERE ID_USUARIO = ?")) {
                st.setInt(1, idUsuario);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        int v = rs.getInt(1);
                        if (!rs.wasNull()) idJefe = v;
                    }
                }
            }
            if (idJefe == null) {
                cn.rollback();
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=No tienes un jefe directo asignado, contacta a Talento Humano");
                return;
            }

            // 2. No solaparse con otra solicitud propia activa.
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(*) FROM VAC_SOLICITUD WHERE ID_USUARIO = ? " +
                    "AND ESTADO NOT IN ('RECHAZADO_JEFE','RECHAZADO_ADMIN','CANCELADO') " +
                    "AND FECHA_DESDE <= ? AND FECHA_HASTA >= ?")) {
                st.setInt(1, idUsuario);
                st.setDate(2, Date.valueOf(hasta));
                st.setDate(3, Date.valueOf(desde));
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=Ya tienes una solicitud registrada que se solapa con ese rango de fechas");
                        return;
                    }
                }
            }

            // 3. Saldo disponible: se busca el periodo mas antiguo que
            // alcance a cubrir TODOS los dias solicitados de una vez
            // (igual que el formato del documento impreso, que solo tiene
            // espacio para un periodo por solicitud).
            //
            // Si es ANTICIPADA, no se exige que el periodo ya este
            // cumplido -- se adelanta contra el siguiente periodo en la
            // linea (el que sigue al ultimo ya cumplido, o el periodo 1
            // si todavia no cumple ni un año), tope maximo lo que ese
            // periodo acumularia normalmente, para no adelantar mas de lo
            // que el empleado alcanzaria a ganarse en un año.
            VAC_CalculoSaldo.Periodo periodoElegido = null;
            if (anticipada) {
                VAC_CalculoSaldo.Periodo periodoAnticipo = VAC_CalculoSaldo.calcularPeriodoAnticipo(cn, idUsuario);
                if (periodoAnticipo == null) {
                    cn.rollback();
                    response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=No tienes fecha de ingreso configurada, contacta a Talento Humano");
                    return;
                }
                if (periodoAnticipo.diasDisponibles < diasSolicitados) {
                    cn.rollback();
                    response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=El adelanto no puede superar los dias que ganarias en ese periodo (maximo: " + periodoAnticipo.diasDisponibles + " dias, solicitaste " + diasSolicitados + ")");
                    return;
                }
                periodoElegido = periodoAnticipo;
            } else {
                VAC_CalculoSaldo.Saldo saldo = VAC_CalculoSaldo.calcular(cn, idUsuario);
                int maxDisponibleUnPeriodo = 0;
                for (VAC_CalculoSaldo.Periodo p : saldo.periodos) {
                    if (p.diasDisponibles > maxDisponibleUnPeriodo) maxDisponibleUnPeriodo = p.diasDisponibles;
                    if (p.diasDisponibles >= diasSolicitados) { periodoElegido = p; break; }
                }
                if (periodoElegido == null) {
                    cn.rollback();
                    response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=No tienes suficientes dias disponibles en un solo periodo (maximo disponible: " + maxDisponibleUnPeriodo + " dias, solicitaste " + diasSolicitados + "). Si es un adelanto acordado con Administracion, marca la casilla de solicitud anticipada.");
                    return;
                }
            }

            // 4. Insertar.
            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(ID_SOLICITUD),0)+1 FROM VAC_SOLICITUD");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idNuevo = rsSec.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO VAC_SOLICITUD (ID_SOLICITUD, ID_USUARIO, ID_JEFE_DIRECTO, NUM_PERIODO, " +
                    "FECHA_DESDE, FECHA_HASTA, FECHA_REINCORPORACION, DIAS_SOLICITADOS, ESTADO, " +
                    "ANTICIPADA, JUSTIFICACION_ANTICIPO) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE_JEFE', ?, ?)")) {
                st.setInt(1, idNuevo);
                st.setInt(2, idUsuario);
                st.setInt(3, idJefe);
                st.setInt(4, periodoElegido.numero);
                st.setDate(5, Date.valueOf(desde));
                st.setDate(6, Date.valueOf(hasta));
                st.setDate(7, Date.valueOf(reincorporacion));
                st.setInt(8, diasSolicitados);
                st.setString(9, anticipada ? "S" : "N");
                if (anticipada) st.setString(10, justificacionAnticipo.trim()); else st.setNull(10, java.sql.Types.VARCHAR);
                st.executeUpdate();
            }

            cn.commit();
            String msjOk = anticipada
                    ? "Solicitud anticipada registrada, queda pendiente de aprobacion de tu jefe directo"
                    : "Solicitud registrada, queda pendiente de aprobacion de tu jefe directo";
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?msj=" + msjOk);
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_MiSaldo.jsp?error=Error al registrar la solicitud");
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
