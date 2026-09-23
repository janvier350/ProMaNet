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

// Aprobar/rechazar una solicitud de vacaciones a nivel Administracion.
// La aprobacion de Administracion (SMORAN) es el ultimo paso del
// tramite -- no hay una recepcion aparte del documento firmado. Ambas
// acciones requieren VACACIONES_GESTIONAR (concedido hoy a SMORAN).
@WebServlet(name = "VAC_GestionarSolicitudAdmin", urlPatterns = {"/VAC_GestionarSolicitudAdmin"})
public class VAC_GestionarSolicitudAdmin extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        int miId;
        try {
            miId = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String accion = request.getParameter("accion"); // APROBAR / RECHAZAR
        String comentario = request.getParameter("comentario");
        // Administracion ajusta DIAS HABILES aprobados (unidad natural
        // para pensar "le doy 3 dias de vacaciones", no 4.09). Con el
        // factor se calcula el equivalente que se guarda en DIAS_APROBADOS.
        String pDiasHabilesAprobados = request.getParameter("diasHabilesAprobados");

        if (idSolicitud == null || accion == null
                || (!"APROBAR".equals(accion) && !"RECHAZAR".equals(accion))) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Datos incompletos");
            return;
        }
        if ("RECHAZAR".equals(accion) && (comentario == null || comentario.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Debes indicar el motivo del rechazo");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String estadoActual = null;
            int diasHabilesSolicitados = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ESTADO, NVL(DIAS_HABILES_SOLICITADOS,0) FROM VAC_SOLICITUD WHERE ID_SOLICITUD = ?")) {
                st.setString(1, idSolicitud);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        estadoActual = rs.getString(1);
                        diasHabilesSolicitados = rs.getInt(2);
                    }
                }
            }

            // APROBAR / RECHAZAR
            if (!"PENDIENTE_ADMIN".equals(estadoActual)) {
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Esa solicitud ya no esta pendiente de Administracion");
                return;
            }

            if ("RECHAZAR".equals(accion)) {
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE VAC_SOLICITUD SET ESTADO = 'RECHAZADO_ADMIN', ID_USUARIO_APRUEBA_ADMIN = ?, " +
                        "FECHA_APROBACION_ADMIN = SYSDATE, COMENTARIO_ADMIN = ? WHERE ID_SOLICITUD = ?")) {
                    st.setInt(1, miId);
                    st.setString(2, comentario);
                    st.setString(3, idSolicitud);
                    st.executeUpdate();
                }
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?msj=Solicitud rechazada");
                return;
            }

            // APROBAR: por defecto se aprueban los mismos DIAS HABILES
            // solicitados, pero Administracion puede recortar el numero
            // (nunca aumentarlo -- si quisiera dar mas, el empleado tiene
            // que hacer otra solicitud). Se guarda tanto DIAS_HABILES_APROBADOS
            // como su equivalente en DIAS_APROBADOS (habiles x 1.3636).
            int diasHabilesAprobados = diasHabilesSolicitados;
            try {
                if (pDiasHabilesAprobados != null && !pDiasHabilesAprobados.trim().isEmpty()) {
                    diasHabilesAprobados = Integer.parseInt(pDiasHabilesAprobados.trim());
                }
            } catch (Exception ignore) {}
            if (diasHabilesAprobados <= 0 || diasHabilesAprobados > diasHabilesSolicitados) {
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Los dias habiles aprobados deben ser mayores a 0 y no superar los solicitados (" + diasHabilesSolicitados + ")");
                return;
            }
            java.math.BigDecimal diasAprobadosEq = VAC_CalculoDias.equivalentes(diasHabilesAprobados);

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE VAC_SOLICITUD SET ESTADO = 'APROBADO', ID_USUARIO_APRUEBA_ADMIN = ?, " +
                    "FECHA_APROBACION_ADMIN = SYSDATE, DIAS_APROBADOS = ?, DIAS_HABILES_APROBADOS = ?, " +
                    "COMENTARIO_ADMIN = ? WHERE ID_SOLICITUD = ?")) {
                st.setInt(1, miId);
                st.setBigDecimal(2, diasAprobadosEq);
                st.setInt(3, diasHabilesAprobados);
                st.setString(4, comentario);
                st.setString(5, idSolicitud);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?msj=Solicitud aprobada");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Error al procesar la solicitud");
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
