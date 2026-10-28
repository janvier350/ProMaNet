package VACACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.time.LocalDate;

// Registra o edita un PERMISO por horas de un empleado (lo carga
// Talento Humano / quien tiene VACACIONES_CONFIGURAR).
//
// Reglas de descargo a vacaciones:
//   PERSONAL con 8 horas      -> descarga 1 dia (1 habil x 15/11 = 1.36)
//   PERSONAL de 1 a 7 horas   -> no descarga
//   ESTUDIO / SALUD / OTROS   -> no descarga (aunque sean 8 horas)
// Cuando descarga, se crea (o actualiza) un AJUSTE en VAC_HISTORICO_AJUSTE
// enlazado al permiso, de modo que el saldo se calcula igual que siempre.
// Si al editar deja de cumplir la regla, el ajuste se elimina.
@WebServlet(name = "VAC_GuardarPermiso", urlPatterns = {"/VAC_GuardarPermiso"})
public class VAC_GuardarPermiso extends HttpServlet {

    private static final BigDecimal HORAS_DIA = new BigDecimal("8");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        request.setCharacterEncoding("UTF-8");

        String idEmpleadoP = request.getParameter("idEmpleado");
        String base = request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleadoP;

        int idEmpleado;
        Integer idPermiso = null;
        LocalDate fecha;
        BigDecimal horas;
        try {
            idEmpleado = Integer.parseInt(idEmpleadoP.trim());
            String ip = request.getParameter("idPermiso");
            if (ip != null && !ip.trim().isEmpty()) idPermiso = Integer.parseInt(ip.trim());
            fecha = LocalDate.parse(request.getParameter("fecha").trim());
            horas = new BigDecimal(request.getParameter("horas").trim()).setScale(2, java.math.RoundingMode.HALF_UP);
        } catch (Exception e) {
            response.sendRedirect(base + "&error=" + enc("Datos del permiso invalidos"));
            return;
        }
        String motivo = request.getParameter("motivo") == null ? "" : request.getParameter("motivo").trim().toUpperCase();
        if (!motivo.equals("PERSONAL") && !motivo.equals("ESTUDIO") && !motivo.equals("SALUD") && !motivo.equals("OTROS")) {
            response.sendRedirect(base + "&error=" + enc("Motivo invalido"));
            return;
        }
        if (horas.signum() <= 0 || horas.compareTo(HORAS_DIA) > 0) {
            response.sendRedirect(base + "&error=" + enc("Las horas deben estar entre 0.25 y 8"));
            return;
        }
        DayOfWeek dow = fecha.getDayOfWeek();
        if (dow == DayOfWeek.SATURDAY || dow == DayOfWeek.SUNDAY) {
            response.sendRedirect(base + "&error=" + enc("La fecha del permiso debe ser un dia habil (lunes a viernes)"));
            return;
        }
        String detalle = request.getParameter("detalle");
        detalle = (detalle == null || detalle.trim().isEmpty()) ? null : detalle.trim();
        if (detalle != null && detalle.length() > 300) detalle = detalle.substring(0, 300);

        boolean descarga = motivo.equals("PERSONAL") && horas.compareTo(HORAS_DIA) >= 0;
        BigDecimal diasDescarga = descarga ? VAC_CalculoDias.equivalentes(1) : null;

        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // 1. Permiso existente (edicion): debe ser del mismo empleado.
            Integer ajusteViejo = null;
            if (idPermiso != null) {
                boolean existe = false;
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT ID_AJUSTE FROM VAC_PERMISO WHERE ID_PERMISO = ? AND ID_USUARIO = ?")) {
                    st.setInt(1, idPermiso);
                    st.setInt(2, idEmpleado);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            existe = true;
                            int v = rs.getInt(1);
                            if (!rs.wasNull()) ajusteViejo = v;
                        }
                    }
                }
                if (!existe) {
                    cn.rollback();
                    response.sendRedirect(base + "&error=" + enc("Permiso no encontrado"));
                    return;
                }
            }

            // 2. Maximo 8 horas por dia entre todos los permisos del empleado.
            BigDecimal yaEseDia = BigDecimal.ZERO;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(SUM(HORAS),0) FROM VAC_PERMISO WHERE ID_USUARIO = ? AND TRUNC(FECHA) = ?"
                    + (idPermiso != null ? " AND ID_PERMISO <> ?" : ""))) {
                st.setInt(1, idEmpleado);
                st.setDate(2, Date.valueOf(fecha));
                if (idPermiso != null) st.setInt(3, idPermiso);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) yaEseDia = rs.getBigDecimal(1);
                }
            }
            if (yaEseDia.add(horas).compareTo(HORAS_DIA) > 0) {
                cn.rollback();
                response.sendRedirect(base + "&error=" + enc("Ese dia ya tiene " + yaEseDia.stripTrailingZeros().toPlainString()
                        + " h de permiso; no se pueden superar 8 horas por dia"));
                return;
            }

            // 3. Si descarga: periodo al que corresponde la fecha.
            Integer numPeriodo = null;
            if (descarga) {
                LocalDate ingreso = null;
                try (PreparedStatement st = cn.prepareStatement("SELECT FECHA_INGRESO FROM VAC_CONFIG_USUARIO WHERE ID_USUARIO = ?")) {
                    st.setInt(1, idEmpleado);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next() && rs.getDate(1) != null) ingreso = rs.getDate(1).toLocalDate();
                    }
                }
                if (ingreso == null) {
                    cn.rollback();
                    response.sendRedirect(base + "&error=" + enc("El empleado no tiene fecha de ingreso configurada: no se puede descargar a vacaciones"));
                    return;
                }
                if (fecha.isBefore(ingreso)) {
                    cn.rollback();
                    response.sendRedirect(base + "&error=" + enc("La fecha del permiso es anterior a la fecha de ingreso del empleado"));
                    return;
                }
                int n = 1;
                while (!fecha.isBefore(ingreso.plusYears(n))) n++;
                numPeriodo = n;
            }

            // 4. Guardar el permiso.
            int idP;
            if (idPermiso != null) {
                idP = idPermiso;
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE VAC_PERMISO SET FECHA = ?, HORAS = ?, MOTIVO = ?, DETALLE = ?, DESCARGA_VACACIONES = ?, " +
                        "DIAS_DESCARGADOS = ?, NUM_PERIODO = ?, ID_USUARIO_REGISTRA = ? WHERE ID_PERMISO = ?")) {
                    st.setDate(1, Date.valueOf(fecha));
                    st.setBigDecimal(2, horas);
                    st.setString(3, motivo);
                    if (detalle != null) st.setString(4, detalle); else st.setNull(4, java.sql.Types.VARCHAR);
                    st.setString(5, descarga ? "S" : "N");
                    if (descarga) st.setBigDecimal(6, diasDescarga); else st.setNull(6, java.sql.Types.NUMERIC);
                    if (numPeriodo != null) st.setInt(7, numPeriodo); else st.setNull(7, java.sql.Types.NUMERIC);
                    st.setInt(8, idGestor);
                    st.setInt(9, idP);
                    st.executeUpdate();
                }
            } else {
                idP = insertarPermiso(cn, idEmpleado, fecha, horas, motivo, detalle, descarga, diasDescarga, numPeriodo, idGestor);
            }

            // 5. Ajuste enlazado.
            String obs = "PERMISO " + motivo + " #" + idP + " (" + horas.stripTrailingZeros().toPlainString() + " h)"
                    + (detalle != null ? " - " + detalle : "");
            if (obs.length() > 500) obs = obs.substring(0, 500);
            Integer ajusteNuevo = null;
            if (descarga) {
                if (ajusteViejo != null) {
                    try (PreparedStatement st = cn.prepareStatement(
                            "UPDATE VAC_HISTORICO_AJUSTE SET NUM_PERIODO = ?, DIAS_GOZADOS = ?, FECHA_DESDE = ?, FECHA_HASTA = ?, " +
                            "OBSERVACIONES = ?, ID_USUARIO_REGISTRA = ?, FECHA_REGISTRO = SYSDATE WHERE ID_AJUSTE = ? AND ID_USUARIO = ?")) {
                        st.setInt(1, numPeriodo);
                        st.setBigDecimal(2, diasDescarga);
                        st.setDate(3, Date.valueOf(fecha));
                        st.setDate(4, Date.valueOf(fecha));
                        st.setString(5, obs);
                        st.setInt(6, idGestor);
                        st.setInt(7, ajusteViejo);
                        st.setInt(8, idEmpleado);
                        st.executeUpdate();
                    }
                    ajusteNuevo = ajusteViejo;
                } else {
                    ajusteNuevo = insertarAjuste(cn, idEmpleado, numPeriodo, diasDescarga, fecha, obs, idGestor, idP);
                }
            } else if (ajusteViejo != null) {
                try (PreparedStatement st = cn.prepareStatement("DELETE FROM VAC_HISTORICO_AJUSTE WHERE ID_AJUSTE = ? AND ID_USUARIO = ?")) {
                    st.setInt(1, ajusteViejo);
                    st.setInt(2, idEmpleado);
                    st.executeUpdate();
                }
            }
            try (PreparedStatement st = cn.prepareStatement("UPDATE VAC_PERMISO SET ID_AJUSTE = ? WHERE ID_PERMISO = ?")) {
                if (ajusteNuevo != null) st.setInt(1, ajusteNuevo); else st.setNull(1, java.sql.Types.NUMERIC);
                st.setInt(2, idP);
                st.executeUpdate();
            }

            cn.commit();
            COMUN.LogActividad.registrar(request, "VACACIONES", idPermiso != null ? "EDITAR" : "CREAR",
                    (idPermiso != null ? "Edito" : "Registro") + " permiso #" + idP + " del usuario #" + idEmpleado + ": " + fecha + ", "
                    + horas.stripTrailingZeros().toPlainString() + " h, " + motivo
                    + (descarga ? ", descarga " + diasDescarga + " dias a vacaciones (periodo " + numPeriodo + ")" : ", sin descargo"));
            response.sendRedirect(base + "&msj=" + enc("Permiso " + (idPermiso != null ? "actualizado" : "registrado")
                    + (descarga ? ": se descargaron " + diasDescarga + " dias de vacaciones (periodo " + numPeriodo + ")" : " (sin descargo a vacaciones)")));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            String det = e.getMessage() == null ? "" : e.getMessage().replaceAll("[\\r\\n]+", " ").trim();
            if (det.length() > 120) det = det.substring(0, 120);
            response.sendRedirect(base + "&error=" + enc("Error al guardar el permiso" + (det.isEmpty() ? "" : ": " + det)
                    + (det.contains("ORA-00942") || det.contains("ORA-00904") ? " (falta ejecutar el script 042_vacaciones_permisos.sql)" : "")));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    private static int insertarPermiso(Connection cn, int idEmpleado, LocalDate fecha, BigDecimal horas, String motivo, String detalle,
                                       boolean descarga, BigDecimal dias, Integer periodo, int idGestor) throws Exception {
        for (int intento = 1; ; intento++) {
            int id = 1;
            try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_PERMISO),0)+1 FROM VAC_PERMISO");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) id = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO VAC_PERMISO (ID_PERMISO, ID_USUARIO, FECHA, HORAS, MOTIVO, DETALLE, DESCARGA_VACACIONES, " +
                    "DIAS_DESCARGADOS, NUM_PERIODO, ID_USUARIO_REGISTRA, FECHA_REGISTRO) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE)")) {
                st.setInt(1, id);
                st.setInt(2, idEmpleado);
                st.setDate(3, Date.valueOf(fecha));
                st.setBigDecimal(4, horas);
                st.setString(5, motivo);
                if (detalle != null) st.setString(6, detalle); else st.setNull(6, java.sql.Types.VARCHAR);
                st.setString(7, descarga ? "S" : "N");
                if (descarga) st.setBigDecimal(8, dias); else st.setNull(8, java.sql.Types.NUMERIC);
                if (periodo != null) st.setInt(9, periodo); else st.setNull(9, java.sql.Types.NUMERIC);
                st.setInt(10, idGestor);
                st.executeUpdate();
                return id;
            } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                if (intento >= 3) throw dup;
            }
        }
    }

    private static int insertarAjuste(Connection cn, int idEmpleado, int periodo, BigDecimal dias, LocalDate fecha, String obs,
                                      int idGestor, int idPermiso) throws Exception {
        for (int intento = 1; ; intento++) {
            int id = 1;
            try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_AJUSTE),0)+1 FROM VAC_HISTORICO_AJUSTE");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) id = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO VAC_HISTORICO_AJUSTE (ID_AJUSTE, ID_USUARIO, NUM_PERIODO, DIAS_GOZADOS, FECHA_DESDE, FECHA_HASTA, " +
                    "OBSERVACIONES, ID_USUARIO_REGISTRA, FECHA_REGISTRO, ID_PERMISO) VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, ?)")) {
                st.setInt(1, id);
                st.setInt(2, idEmpleado);
                st.setInt(3, periodo);
                st.setBigDecimal(4, dias);
                st.setDate(5, Date.valueOf(fecha));
                st.setDate(6, Date.valueOf(fecha));
                st.setString(7, obs);
                st.setInt(8, idGestor);
                st.setInt(9, idPermiso);
                st.executeUpdate();
                return id;
            } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                if (intento >= 3) throw dup;
            }
        }
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
