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

@WebServlet(name = "LEG_InsertarIP", urlPatterns = {"/LEG_InsertarIP"})
public class LEG_InsertarIP extends HttpServlet {

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
        String procesado = request.getParameter("procesado");
        String victima   = request.getParameter("victima");
        String proceso   = request.getParameter("proceso");
        String idDelito  = request.getParameter("idDelito");
        String fiscalia  = request.getParameter("fiscalia");
        String ubicacion = request.getParameter("ubicacion");
        String idUsuario = (String) session.getAttribute("cod");

        if (procesado == null || procesado.trim().isEmpty()
                || victima == null || victima.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar al menos Procesado y Victima.");
            response.sendRedirect(request.getContextPath() + "/Legal/LEG_ControlSeguimiento.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_LEGAL_IP),0)+1 FROM LEGAL_IP");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO LEGAL_IP (ID_LEGAL_IP, PROCESADO, VICTIMA, PROCESO, ID_DELITO, " +
                    "FISCALIA, UBICACION, ID_USUARIO_CREA) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, procesado.trim());
                st.setString(3, victima.trim());
                st.setString(4, proceso != null ? proceso.trim() : null);
                if (idDelito != null && !idDelito.trim().isEmpty()) {
                    st.setInt(5, Integer.parseInt(idDelito.trim()));
                } else {
                    st.setNull(5, java.sql.Types.INTEGER);
                }
                st.setString(6, fiscalia != null ? fiscalia.trim() : null);
                st.setString(7, ubicacion != null ? ubicacion.trim() : null);
                st.setInt(8, Integer.parseInt(idUsuario.trim()));
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Investigacion Previa #" + idNuevo + " registrada.");
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
