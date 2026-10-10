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

// "Elimina" (soft) un ticket marcandolo con ESTADO = 'CANCELADO_USR'.
// Antes exigia uno de 6 cargos hardcoded; ahora requiere permiso
// granular SOPORTES_ELIMINAR -- asi se puede dar a quien se quiera
// sin depender del cargo del titulo. Tambien se pasa a PreparedStatement
// (eliminaba el bug de SQL injection sobre el estado) y se registra
// la operacion en LOG_ACTIVIDAD.
@WebServlet(name = "SOP_EliminarSolicitud", urlPatterns = {"/SOP_EliminarSolicitud"})
public class SOP_EliminarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ELIMINAR")) {
            response.sendRedirect("sesionInvalida.jsp"); return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        if (idSolicitud == null || idSolicitud.trim().isEmpty()) {
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Falta idSolicitud");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE SOP_SOPORTE_CAB SET ESTADO = 'CANCELADO_USR' WHERE IDSOPORTE = ?")) {
                st.setInt(1, Integer.parseInt(idSolicitud.trim()));
                st.executeUpdate();
            }
            cn.commit();

            COMUN.LogActividad.registrar(request, "SOPORTES", "ELIMINAR",
                    "Cancelo ticket #" + idSolicitud);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Error al cancelar");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?msj=Ticket cancelado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
