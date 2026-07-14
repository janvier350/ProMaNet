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

@WebServlet(name = "MOV_InsertDestino", urlPatterns = {"/MOV_InsertDestino"})
public class MOV_InsertDestino extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String descripcion = request.getParameter("descripcion");
        if (descripcion == null || descripcion.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar una descripcion para el destino.");
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_DESTINO),0)+1 FROM MOV_DESTINO");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO MOV_DESTINO (ID_DESTINO, DESCRIPCION) VALUES (?, ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, descripcion.trim());
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Destino \"" + descripcion.trim() + "\" agregado correctamente.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al agregar el destino: " + e.getMessage());
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
