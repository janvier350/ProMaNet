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

// Aprobar/rechazar una solicitud de vacaciones a nivel Administracion,
// y marcar como recibido el documento ya firmado (cierre final del
// tramite). Ambas acciones requieren VACACIONES_GESTIONAR (concedido
// hoy a SMORAN).
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
        String accion = request.getParameter("accion"); // APROBAR / RECHAZAR / RECIBIR
        String comentario = request.getParameter("comentario");
        String pDiasAprobados = request.getParameter("diasAprobados");

        if (idSolicitud == null || accion == null
                || (!"APROBAR".equals(accion) && !"RECHAZAR".equals(accion) && !"RECIBIR".equals(accion))) {
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
            int diasSolicitados = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ESTADO, DIAS_SOLICITADOS FROM VAC_SOLICITUD WHERE ID_SOLICITUD = ?")) {
                st.setString(1, idSolicitud);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        estadoActual = rs.getString(1);
                        diasSolicitados = rs.getInt(2);
                    }
                }
            }

            if ("RECIBIR".equals(accion)) {
                if (!"APROBADO".equals(estadoActual)) {
                    response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Esa solicitud no esta en estado Aprobado");
                    return;
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE VAC_SOLICITUD SET ESTADO = 'RECIBIDO', ID_USUARIO_RECIBE = ?, FECHA_RECEPCION = SYSDATE " +
                        "WHERE ID_SOLICITUD = ?")) {
                    st.setInt(1, miId);
                    st.setString(2, idSolicitud);
                    st.executeUpdate();
                }
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?msj=Documento marcado como recibido");
                return;
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

            // APROBAR: por defecto se aprueban los mismos dias solicitados,
            // pero Administracion puede ajustar el numero.
            int diasAprobados = diasSolicitados;
            try {
                if (pDiasAprobados != null && !pDiasAprobados.trim().isEmpty()) {
                    diasAprobados = Integer.parseInt(pDiasAprobados.trim());
                }
            } catch (Exception ignore) {}
            if (diasAprobados <= 0 || diasAprobados > diasSolicitados) {
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?error=Los dias aprobados deben ser mayores a 0 y no superar los solicitados (" + diasSolicitados + ")");
                return;
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE VAC_SOLICITUD SET ESTADO = 'APROBADO', ID_USUARIO_APRUEBA_ADMIN = ?, " +
                    "FECHA_APROBACION_ADMIN = SYSDATE, DIAS_APROBADOS = ?, COMENTARIO_ADMIN = ? WHERE ID_SOLICITUD = ?")) {
                st.setInt(1, miId);
                st.setInt(2, diasAprobados);
                st.setString(3, comentario);
                st.setString(4, idSolicitud);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesAdmin.jsp?msj=Solicitud aprobada, pendiente de entrega del documento firmado");
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
