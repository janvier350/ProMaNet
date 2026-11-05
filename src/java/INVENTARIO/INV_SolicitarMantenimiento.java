package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

// El usuario pide el mantenimiento de SU equipo desde el aviso: se crea un ticket de soporte
// (prioridad Baja) que empieza con la marca [MANTENIMIENTO]. Al cerrarlo como ATENDIDO,
// InsertReporteTecnico registra el mantenimiento en el historial del equipo.
// Solo se puede pedir para un equipo asignado al propio usuario y si no hay ya un ticket abierto.
@WebServlet(name = "INV_SolicitarMantenimiento", urlPatterns = {"/INV_SolicitarMantenimiento"})
public class INV_SolicitarMantenimiento extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        String base = request.getContextPath() + "/Proyectos/PRO_Dashboard.jsp";
        int idUsuario, idEquipo;
        try {
            idUsuario = Integer.parseInt(((String) session.getAttribute("cod")).trim());
            idEquipo = Integer.parseInt(request.getParameter("idEquipo").trim());
        } catch (Exception e) {
            response.sendRedirect(base + "?error=" + enc("Datos invalidos"));
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // 1. El equipo debe estar asignado a este usuario.
            String desc = null, serial = null, ultimo = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(e.DISPOSITIVO,'Equipo') || ' ' || NVL(e.MARCA,'') || ' ' || NVL(e.MODELO,''), NVL(e.SERIAL,'-'), " +
                    "(SELECT TO_CHAR(MAX(m.FECHA_MANT),'DD/MM/YYYY') FROM INV_MANTENIMIENTO m WHERE m.IDINVEQUIPO = e.IDINVEQUIPO AND m.ESTADO = 'A' AND m.TIPO = 'PREVENTIVO') " +
                    "FROM INV_EQUIPOS e WHERE e.IDINVEQUIPO = ? AND e.ESTADO_AI = 'A' " +
                    "AND EXISTS (SELECT 1 FROM INV_ASIGNACION a WHERE a.IDINVEQUIPO = e.IDINVEQUIPO AND a.IDUSUARIO = ? AND a.ESTADO = 'A')")) {
                st.setInt(1, idEquipo);
                st.setInt(2, idUsuario);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) { desc = rs.getString(1).trim(); serial = rs.getString(2); ultimo = rs.getString(3); }
                }
            }
            if (desc == null) {
                cn.rollback();
                response.sendRedirect(base + "?error=" + enc("Ese equipo no esta asignado a tu usuario"));
                return;
            }

            // 2. Sin duplicados: si ya hay un ticket de mantenimiento abierto, se informa.
            Integer abierto = INV_MantenimientoHelper.ticketsAbiertos(cn).get(idEquipo);
            if (abierto != null) {
                cn.rollback();
                response.sendRedirect(base + "?msj=" + enc("Ya hay una solicitud de mantenimiento abierta para ese equipo (ticket #" + abierto + ")"));
                return;
            }

            // 3. Crear el ticket (mismo patron que insertSoporte, con reintento ante colision de ID).
            String texto = INV_MantenimientoHelper.MARCA_TICKET + " Mantenimiento preventivo (limpieza y revision) de: " + desc
                    + " (S/N " + serial + "). Ultimo mantenimiento: " + (ultimo != null ? ultimo : "sin registro")
                    + ". Solicitado por el usuario desde el aviso de mantenimiento.";
            int idNuevo = -1;
            for (int intento = 1; idNuevo < 0; intento++) {
                int candidato = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(IDSOPORTE),0)+1 FROM SOP_SOPORTE_CAB");
                     ResultSet rs = st.executeQuery()) { if (rs.next()) candidato = rs.getInt(1); }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO SOP_SOPORTE_CAB (IDSOPORTE, IDUSUARIO, IDEQUIPO, FECHA_SOLICITUD, SOPORTE, PRIORIDAD, ESTADO, REPORTE, FECHA_REPORTE, TECNICO) " +
                        "VALUES (?, ?, ?, SYSDATE, ?, 'Baja', 'PENDIENTE', 'SIN REPORTE', SYSDATE, 'N/A')")) {
                    st.setInt(1, candidato);
                    st.setInt(2, idUsuario);
                    st.setInt(3, idEquipo);
                    st.setString(4, texto);
                    st.executeUpdate();
                    idNuevo = candidato;
                } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                    if (intento >= 3) throw dup;
                }
            }
            cn.commit();
            COMUN.LogActividad.registrar(request, "SOPORTES", "CREAR",
                    "Solicito mantenimiento del equipo #" + idEquipo + " (" + desc + ") -> ticket #" + idNuevo);
            response.sendRedirect(base + "?msj=" + enc("Solicitud de mantenimiento enviada (ticket #" + idNuevo + "). Sistemas se pondra en contacto contigo."));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(base + "?error=" + enc("No se pudo crear la solicitud de mantenimiento"));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Proyectos/PRO_Dashboard.jsp");
    }
}
