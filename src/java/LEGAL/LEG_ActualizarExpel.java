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

@WebServlet(name = "LEG_ActualizarExpel", urlPatterns = {"/LEG_ActualizarExpel"})
public class LEG_ActualizarExpel extends HttpServlet {

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
        String idLegalExpel = request.getParameter("idLegalExpel");
        String accion = request.getParameter("accion");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if ("eliminar".equals(accion) || "restaurar".equals(accion)) {
                String nuevoEstado = "restaurar".equals(accion) ? "A" : "I";
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE LEGAL_EXPEL SET ESTADO = ? WHERE ID_LEGAL_EXPEL = ?")) {
                    st.setString(1, nuevoEstado);
                    st.setInt(2, Integer.parseInt(idLegalExpel.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito",
                        "restaurar".equals(accion) ? "EXPEL restaurado." : "EXPEL eliminado.");
            } else {
                String actor = request.getParameter("actor");
                String demandado = request.getParameter("demandado");
                String juicio = request.getParameter("juicio");
                String idMateria = request.getParameter("idMateria");
                String idTipoAccion = request.getParameter("idTipoAccion");
                String asunto = request.getParameter("asunto");
                String lugar = request.getParameter("lugar");

                if (actor == null || actor.trim().isEmpty()
                        || demandado == null || demandado.trim().isEmpty()) {
                    session.setAttribute("msg_error", "Debe indicar al menos Actor y Demandado.");
                    response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
                    return;
                }

                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE LEGAL_EXPEL SET ACTOR = ?, DEMANDADO = ?, JUICIO = ?, ID_MATERIA = ?, " +
                        "ID_TIPO_ACCION = ?, ASUNTO = ?, LUGAR = ? WHERE ID_LEGAL_EXPEL = ?")) {
                    st.setString(1, actor.trim());
                    st.setString(2, demandado.trim());
                    st.setString(3, juicio != null ? juicio.trim() : null);
                    if (idMateria != null && !idMateria.trim().isEmpty()) {
                        st.setInt(4, Integer.parseInt(idMateria.trim()));
                    } else {
                        st.setNull(4, Types.INTEGER);
                    }
                    if (idTipoAccion != null && !idTipoAccion.trim().isEmpty()) {
                        st.setInt(5, Integer.parseInt(idTipoAccion.trim()));
                    } else {
                        st.setNull(5, Types.INTEGER);
                    }
                    st.setString(6, asunto != null ? asunto.trim() : null);
                    st.setString(7, lugar != null ? lugar.trim() : null);
                    st.setInt(8, Integer.parseInt(idLegalExpel.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito", "EXPEL actualizado.");
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
