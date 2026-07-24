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
import java.sql.ResultSet;

@WebServlet(name = "LEG_InsertarExpel", urlPatterns = {"/LEG_InsertarExpel"})
public class LEG_InsertarExpel extends HttpServlet {

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
        String actor         = request.getParameter("actor");
        String demandado     = request.getParameter("demandado");
        String juicio        = request.getParameter("juicio");
        String idMateria     = request.getParameter("idMateria");
        String idTipoAccion  = request.getParameter("idTipoAccion");
        String asunto        = request.getParameter("asunto");
        String lugar         = request.getParameter("lugar");
        String idUsuario     = (String) session.getAttribute("cod");

        if (actor == null || actor.trim().isEmpty()
                || demandado == null || demandado.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar al menos Actor y Demandado.");
            response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_LEGAL_EXPEL),0)+1 FROM LEGAL_EXPEL");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO LEGAL_EXPEL (ID_LEGAL_EXPEL, ACTOR, DEMANDADO, JUICIO, ID_MATERIA, " +
                    "ID_TIPO_ACCION, ASUNTO, LUGAR, ID_USUARIO_CREA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, actor.trim());
                st.setString(3, demandado.trim());
                st.setString(4, juicio != null ? juicio.trim() : null);
                if (idMateria != null && !idMateria.trim().isEmpty()) {
                    st.setInt(5, Integer.parseInt(idMateria.trim()));
                } else {
                    st.setNull(5, java.sql.Types.INTEGER);
                }
                if (idTipoAccion != null && !idTipoAccion.trim().isEmpty()) {
                    st.setInt(6, Integer.parseInt(idTipoAccion.trim()));
                } else {
                    st.setNull(6, java.sql.Types.INTEGER);
                }
                st.setString(7, asunto != null ? asunto.trim() : null);
                st.setString(8, lugar != null ? lugar.trim() : null);
                st.setInt(9, Integer.parseInt(idUsuario.trim()));
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "EXPEL #" + idNuevo + " registrado.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al registrar: " + e.getMessage());
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
