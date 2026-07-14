package MOVILIZACION;

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

@WebServlet(name = "MOV_EliminarSolicitud", urlPatterns = {"/MOV_EliminarSolicitud"})
public class MOV_EliminarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String idUsuarioSesion = (String) session.getAttribute("cod");
        boolean puedeGestionar = PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR");

        if (idSolicitud == null) {
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String estado = null, idDueno = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ESTADO, IDUSUARIO FROM MOV_SOLICITUD WHERE ID_MOV_SOLICITUD = ?")) {
                st.setInt(1, Integer.parseInt(idSolicitud));
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) { estado = rs.getString(1); idDueno = rs.getString(2); }
                }
            }

            boolean esDueno = idUsuarioSesion.equals(idDueno);
            // Smoran puede eliminar cualquier solicitud. El dueno solo
            // puede eliminar las suyas mientras no esten aprobadas o ya
            // movilizadas (esos casos hay que pedirselos a Smoran).
            boolean puedeEliminar = puedeGestionar
                    || (esDueno && ("PENDIENTE".equals(estado) || "RECHAZADA".equals(estado) || "CANCELADA".equals(estado)));

            if (estado == null || !puedeEliminar) {
                response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
                return;
            }

            try (PreparedStatement stDel = cn.prepareStatement(
                    "DELETE FROM MOV_SOLICITUD WHERE ID_MOV_SOLICITUD = ?")) {
                stDel.setInt(1, Integer.parseInt(idSolicitud));
                stDel.executeUpdate();
            }

            session.setAttribute("msg_exito", "Solicitud eliminada.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al eliminar la solicitud: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
    }
}
