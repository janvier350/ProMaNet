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

@WebServlet(name = "MOV_InsertMotivo", urlPatterns = {"/MOV_InsertMotivo"})
public class MOV_InsertMotivo extends HttpServlet {

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
            session.setAttribute("msg_error", "Debe indicar una descripcion para el motivo.");
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement stDup = cn.prepareStatement(
                    "SELECT COUNT(*) FROM MOV_MOTIVO WHERE UPPER(TRIM(DESCRIPCION)) = UPPER(TRIM(?)) AND ESTADO = 'A'")) {
                stDup.setString(1, descripcion);
                try (ResultSet rsDup = stDup.executeQuery()) {
                    if (rsDup.next() && rsDup.getInt(1) > 0) {
                        session.setAttribute("msg_error", "Ya existe un motivo con esa descripcion.");
                        response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                        return;
                    }
                }
            }

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_MOTIVO),0)+1 FROM MOV_MOTIVO");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (?, ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, descripcion.trim());
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Motivo \"" + descripcion.trim() + "\" agregado correctamente.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al agregar el motivo: " + e.getMessage());
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
