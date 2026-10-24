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
import java.sql.PreparedStatement;
import java.sql.ResultSet;

// Carga o edita un consumo historico de vacaciones (anterior a este
// modulo) para un periodo especifico de un empleado. Es lo que permite
// que el saldo calculado por VAC_CalculoSaldo arranque correcto en vez
// de asumir que nadie ha tomado vacaciones nunca. Si viene idAjuste,
// actualiza ese registro (verificando que sea del mismo empleado);
// si no, inserta uno nuevo.
@WebServlet(name = "VAC_GuardarAjusteHistorico", urlPatterns = {"/VAC_GuardarAjusteHistorico"})
public class VAC_GuardarAjusteHistorico extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idEmpleado = request.getParameter("idEmpleado");
        String idAjuste = request.getParameter("idAjuste"); // vacio/null = registro nuevo
        String numPeriodo = request.getParameter("numPeriodo");
        String diasGozados = request.getParameter("diasGozados");
        String fechaDesde = request.getParameter("fechaDesde"); // opcional, YYYY-MM-DD
        String fechaHasta = request.getParameter("fechaHasta"); // opcional, YYYY-MM-DD
        String observaciones = request.getParameter("observaciones");
        boolean esEdicion = idAjuste != null && !idAjuste.trim().isEmpty();

        if (idEmpleado == null || numPeriodo == null || diasGozados == null
                || numPeriodo.trim().isEmpty() || diasGozados.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Datos incompletos");
            return;
        }

        // Metodo de calculo vigente: con fechas desde/hasta y calcAuto marcado,
        // los dias descontados NO se toman del formulario sino que se calculan
        // igual que en una solicitud: dias habiles (L-V) x 15/11 (1.3636),
        // 2 decimales (ver VAC_CalculoDias). Sin fechas, o con el calculo
        // manual, se usa el valor ingresado (historial previo sin fechas).
        String base = request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado;
        boolean tieneFechas = fechaDesde != null && !fechaDesde.trim().isEmpty()
                && fechaHasta != null && !fechaHasta.trim().isEmpty();
        if (tieneFechas) {
            java.time.LocalDate d1, d2;
            try {
                d1 = java.time.LocalDate.parse(fechaDesde.trim());
                d2 = java.time.LocalDate.parse(fechaHasta.trim());
            } catch (Exception e) {
                response.sendRedirect(base + "&error=Fechas invalidas");
                return;
            }
            if (d2.isBefore(d1)) {
                response.sendRedirect(base + "&error=La fecha hasta no puede ser anterior a la fecha desde");
                return;
            }
            if ("on".equals(request.getParameter("calcAuto"))) {
                int habiles = VAC_CalculoDias.contarDiasHabiles(d1, d2);
                if (habiles == 0) {
                    response.sendRedirect(base + "&error=El rango no contiene dias habiles (lunes a viernes). Desmarca el calculo automatico para ingresar los dias manualmente");
                    return;
                }
                diasGozados = VAC_CalculoDias.equivalentes(habiles).toPlainString();
            }
        } else if ((fechaDesde != null && !fechaDesde.trim().isEmpty()) != (fechaHasta != null && !fechaHasta.trim().isEmpty())) {
            response.sendRedirect(base + "&error=Indica ambas fechas (desde y hasta) o ninguna");
            return;
        }

        // Sin calculo por fechas, el valor ingresado se interpreta segun "unidad":
        //   HABILES -> son dias habiles tomados; se convierten x 15/11 (ej. 1 -> 1.36)
        //   EQUIV   -> ya son dias equivalentes (historial calculado a mano); se guarda tal cual
        // Si el formulario no envia unidad (version anterior) se asume EQUIV.
        boolean calculadoPorFechas = tieneFechas && "on".equals(request.getParameter("calcAuto"));
        if (!calculadoPorFechas && "HABILES".equals(request.getParameter("unidad"))) {
            try {
                java.math.BigDecimal habilesIng = new java.math.BigDecimal(diasGozados.trim());
                if (habilesIng.signum() <= 0) throw new NumberFormatException();
                diasGozados = habilesIng.multiply(VAC_CalculoDias.FACTOR_PROPORCIONALIDAD)
                        .setScale(2, java.math.RoundingMode.HALF_UP).toPlainString();
            } catch (Exception e) {
                response.sendRedirect(base + "&error=Dias invalidos");
                return;
            }
        }
        try {
            if (new java.math.BigDecimal(diasGozados.trim()).compareTo(new java.math.BigDecimal("30")) > 0) {
                response.sendRedirect(base + "&error=Los dias del ajuste no pueden superar 30");
                return;
            }
        } catch (Exception e) {
            response.sendRedirect(base + "&error=Dias invalidos");
            return;
        }

        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if (esEdicion) {
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE VAC_HISTORICO_AJUSTE SET NUM_PERIODO = ?, DIAS_GOZADOS = ?, " +
                        "FECHA_DESDE = TO_DATE(?, 'YYYY-MM-DD'), FECHA_HASTA = TO_DATE(?, 'YYYY-MM-DD'), " +
                        "OBSERVACIONES = ?, ID_USUARIO_REGISTRA = ?, FECHA_REGISTRO = SYSDATE " +
                        "WHERE ID_AJUSTE = ? AND ID_USUARIO = ?")) {
                    st.setString(1, numPeriodo);
                    st.setString(2, diasGozados);
                    if (fechaDesde != null && !fechaDesde.trim().isEmpty()) st.setString(3, fechaDesde); else st.setNull(3, java.sql.Types.DATE);
                    if (fechaHasta != null && !fechaHasta.trim().isEmpty()) st.setString(4, fechaHasta); else st.setNull(4, java.sql.Types.DATE);
                    st.setString(5, observaciones);
                    st.setInt(6, idGestor);
                    st.setString(7, idAjuste);
                    st.setString(8, idEmpleado);
                    st.executeUpdate();
                }
                COMUN.LogActividad.registrar(request, "VACACIONES", "EDITAR",
                        "Edito ajuste historico #" + idAjuste + " del usuario #" + idEmpleado + ": " + diasGozados + " dias (periodo " + numPeriodo + ")");
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&msj=Ajuste actualizado correctamente");
                return;
            }

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(ID_AJUSTE),0)+1 FROM VAC_HISTORICO_AJUSTE");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idNuevo = rsSec.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO VAC_HISTORICO_AJUSTE (ID_AJUSTE, ID_USUARIO, NUM_PERIODO, DIAS_GOZADOS, " +
                    "FECHA_DESDE, FECHA_HASTA, OBSERVACIONES, ID_USUARIO_REGISTRA, FECHA_REGISTRO) " +
                    "VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, SYSDATE)")) {
                st.setInt(1, idNuevo);
                st.setString(2, idEmpleado);
                st.setString(3, numPeriodo);
                st.setString(4, diasGozados);
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) st.setString(5, fechaDesde); else st.setNull(5, java.sql.Types.DATE);
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) st.setString(6, fechaHasta); else st.setNull(6, java.sql.Types.DATE);
                st.setString(7, observaciones);
                st.setInt(8, idGestor);
                st.executeUpdate();
            }

            COMUN.LogActividad.registrar(request, "VACACIONES", "CREAR",
                    "Registro ajuste historico del usuario #" + idEmpleado + ": " + diasGozados + " dias (periodo " + numPeriodo + ")");
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&msj=Ajuste registrado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Error al registrar el ajuste");
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
