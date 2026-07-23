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
import org.json.JSONObject;

// Quick-add de delitos desde el modal de Investigacion Previa (AJAX),
// para no perder lo que el usuario ya escribio en el formulario principal.
@WebServlet(name = "LEG_InsertarDelito", urlPatterns = {"/LEG_InsertarDelito"})
public class LEG_InsertarDelito extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        JSONObject out = new JSONObject();

        if (session == null || session.getAttribute("usuario") == null
                || !PermisoHelper.tiene(session, "LEGAL_ACCESO")) {
            out.put("ok", false).put("mensaje", "Sesion invalida.");
            response.getWriter().write(out.toString());
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String descripcion = request.getParameter("descripcion");
        if (descripcion == null || descripcion.trim().isEmpty()) {
            out.put("ok", false).put("mensaje", "Debe indicar el nombre del delito.");
            response.getWriter().write(out.toString());
            return;
        }
        descripcion = descripcion.trim().toUpperCase();

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement stDup = cn.prepareStatement(
                    "SELECT ID_DELITO FROM LEGAL_DELITO WHERE UPPER(DESCRIPCION) = ? AND ESTADO = 'A'")) {
                stDup.setString(1, descripcion);
                try (ResultSet rsDup = stDup.executeQuery()) {
                    if (rsDup.next()) {
                        out.put("ok", true).put("id", rsDup.getInt(1)).put("descripcion", descripcion);
                        response.getWriter().write(out.toString());
                        return;
                    }
                }
            }

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_DELITO),0)+1 FROM LEGAL_DELITO");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO LEGAL_DELITO (ID_DELITO, DESCRIPCION) VALUES (?, ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, descripcion);
                st.executeUpdate();
            }

            out.put("ok", true).put("id", idNuevo).put("descripcion", descripcion);
        } catch (Exception e) {
            e.printStackTrace();
            out.put("ok", false).put("mensaje", "Error al guardar: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.getWriter().write(out.toString());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
