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

@WebServlet(name = "MOV_CancelarSolicitud", urlPatterns = {"/MOV_CancelarSolicitud"})
public class MOV_CancelarSolicitud extends HttpServlet {

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
            boolean puedeCancelar = (puedeGestionar && ("PENDIENTE".equals(estado) || "APROBADA".equals(estado)))
                    || (esDueno && "PENDIENTE".equals(estado));

            if (estado == null || !puedeCancelar) {
                response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
                return;
            }

            try (PreparedStatement stUpd = cn.prepareStatement(
                    "UPDATE MOV_SOLICITUD SET ESTADO = 'CANCELADA' WHERE ID_MOV_SOLICITUD = ?")) {
                stUpd.setInt(1, Integer.parseInt(idSolicitud));
                stUpd.executeUpdate();
            }

            session.setAttribute("msg_exito", "Solicitud cancelada.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al cancelar la solicitud: " + e.getMessage());
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
