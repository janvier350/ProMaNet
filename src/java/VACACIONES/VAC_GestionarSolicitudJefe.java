package VACACIONES;

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

// Aprobar/rechazar una solicitud de vacaciones a nivel de jefe
// directo. No requiere un permiso especial: ser jefe directo de
// alguien es un dato (VAC_SOLICITUD.ID_JEFE_DIRECTO), no un rol, asi
// que cualquier usuario logueado puede gestionar SOLO las solicitudes
// donde el es efectivamente el jefe asignado -- eso se valida siempre
// del lado servidor, nunca se confia en lo que mande el formulario.
@WebServlet(name = "VAC_GestionarSolicitudJefe", urlPatterns = {"/VAC_GestionarSolicitudJefe"})
public class VAC_GestionarSolicitudJefe extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
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

        if (idSolicitud == null || accion == null
                || (!"APROBAR".equals(accion) && !"RECHAZAR".equals(accion))) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesJefe.jsp?error=Datos incompletos");
            return;
        }
        if ("RECHAZAR".equals(accion) && (comentario == null || comentario.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesJefe.jsp?error=Debes indicar el motivo del rechazo");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            // Verificar que la solicitud es realmente mia como jefe y sigue pendiente.
            int idJefeReal = -1;
            String estadoActual = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ID_JEFE_DIRECTO, ESTADO FROM VAC_SOLICITUD WHERE ID_SOLICITUD = ?")) {
                st.setString(1, idSolicitud);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        idJefeReal = rs.getInt(1);
                        estadoActual = rs.getString(2);
                    }
                }
            }
            if (idJefeReal != miId || !"PENDIENTE_JEFE".equals(estadoActual)) {
                response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesJefe.jsp?error=Esa solicitud ya no esta pendiente de tu aprobacion");
                return;
            }

            String nuevoEstado = "APROBAR".equals(accion) ? "PENDIENTE_ADMIN" : "RECHAZADO_JEFE";
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE VAC_SOLICITUD SET ESTADO = ?, ID_USUARIO_APRUEBA_JEFE = ?, " +
                    "FECHA_APROBACION_JEFE = SYSDATE, COMENTARIO_JEFE = ? WHERE ID_SOLICITUD = ?")) {
                st.setString(1, nuevoEstado);
                st.setInt(2, miId);
                st.setString(3, comentario);
                st.setString(4, idSolicitud);
                st.executeUpdate();
            }

            String msj = "APROBAR".equals(accion)
                    ? "Solicitud aprobada, queda pendiente de Administracion"
                    : "Solicitud rechazada";
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesJefe.jsp?msj=" + msj);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_AprobacionesJefe.jsp?error=Error al procesar la solicitud");
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
