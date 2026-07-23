package LEGAL;

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
import java.sql.Types;

@WebServlet(name = "LEG_ActualizarIP", urlPatterns = {"/LEG_ActualizarIP"})
public class LEG_ActualizarIP extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "LEGAL_ACCESO")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String idLegalIp = request.getParameter("idLegalIp");
        String accion = request.getParameter("accion");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if ("eliminar".equals(accion) || "restaurar".equals(accion)) {
                String nuevoEstado = "restaurar".equals(accion) ? "A" : "I";
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE LEGAL_IP SET ESTADO = ? WHERE ID_LEGAL_IP = ?")) {
                    st.setString(1, nuevoEstado);
                    st.setInt(2, Integer.parseInt(idLegalIp.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito",
                        "restaurar".equals(accion) ? "Investigacion Previa restaurada." : "Investigacion Previa eliminada.");
            } else {
                String procesado = request.getParameter("procesado");
                String victima = request.getParameter("victima");
                String proceso = request.getParameter("proceso");
                String idDelito = request.getParameter("idDelito");
                String fiscalia = request.getParameter("fiscalia");
                String ubicacion = request.getParameter("ubicacion");

                if (procesado == null || procesado.trim().isEmpty()
                        || victima == null || victima.trim().isEmpty()) {
                    session.setAttribute("msg_error", "Debe indicar al menos Procesado y Victima.");
                    response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
                    return;
                }

                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE LEGAL_IP SET PROCESADO = ?, VICTIMA = ?, PROCESO = ?, ID_DELITO = ?, " +
                        "FISCALIA = ?, UBICACION = ? WHERE ID_LEGAL_IP = ?")) {
                    st.setString(1, procesado.trim());
                    st.setString(2, victima.trim());
                    st.setString(3, proceso != null ? proceso.trim() : null);
                    if (idDelito != null && !idDelito.trim().isEmpty()) {
                        st.setInt(4, Integer.parseInt(idDelito.trim()));
                    } else {
                        st.setNull(4, Types.INTEGER);
                    }
                    st.setString(5, fiscalia != null ? fiscalia.trim() : null);
                    st.setString(6, ubicacion != null ? ubicacion.trim() : null);
                    st.setInt(7, Integer.parseInt(idLegalIp.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito", "Investigacion Previa actualizada.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al actualizar: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
    }
}
