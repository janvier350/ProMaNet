package Servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;

// Actualiza SOPORTE y PRIORIDAD de un ticket.
//
// Antes esto construia el UPDATE concatenando el texto libre del
// usuario a la query ("set SOPORTE = '"+soporte+"'") -- un apostrofe
// en el texto rompia el update, y era un vector claro de SQL injection.
// Se pasa a PreparedStatement con bind, y el chequeo por cargo
// hardcode se reemplaza por el permiso SOPORTES_ATENDER (que es el
// que tiene sentido para esta accion). Se registra en LOG_ACTIVIDAD.
@WebServlet(name = "SOP_EditarSolicitud", urlPatterns = {"/SOP_EditarSolicitud"})
public class SOP_EditarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) {
            response.sendRedirect("sesionInvalida.jsp"); return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String prioridad   = request.getParameter("prioridadEditar");
        String soporte     = request.getParameter("soporteEditar");

        if (idSolicitud == null || idSolicitud.trim().isEmpty()) {
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Falta idSolicitud");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE SOP_SOPORTE_CAB SET SOPORTE = ?, PRIORIDAD = ? WHERE IDSOPORTE = ?")) {
                st.setString(1, soporte);
                st.setString(2, prioridad);
                st.setInt(3, Integer.parseInt(idSolicitud.trim()));
                st.executeUpdate();
            }
            cn.commit();

            COMUN.LogActividad.registrar(request, "SOPORTES", "ACTUALIZAR",
                    "Edito ticket #" + idSolicitud + " (prioridad " + prioridad + ")");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Error al actualizar");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?msj=Ticket actualizado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
