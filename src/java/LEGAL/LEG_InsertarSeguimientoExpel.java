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

@WebServlet(name = "LEG_InsertarSeguimientoExpel", urlPatterns = {"/LEG_InsertarSeguimientoExpel"})
public class LEG_InsertarSeguimientoExpel extends HttpServlet {

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
        String descripcion  = request.getParameter("descripcion");
        String idUsuario    = (String) session.getAttribute("cod");

        if (idLegalExpel == null || descripcion == null || descripcion.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar el detalle del seguimiento.");
            response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_SEGUIMIENTO),0)+1 FROM LEGAL_EXPEL_SEGUIMIENTO");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO LEGAL_EXPEL_SEGUIMIENTO (ID_SEGUIMIENTO, ID_LEGAL_EXPEL, DESCRIPCION, ID_USUARIO_CREA) " +
                    "VALUES (?, ?, ?, ?)")) {
                st.setInt(1, idNuevo);
                st.setInt(2, Integer.parseInt(idLegalExpel.trim()));
                st.setString(3, descripcion.trim());
                st.setInt(4, Integer.parseInt(idUsuario.trim()));
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Seguimiento registrado.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al registrar el seguimiento: " + e.getMessage());
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
