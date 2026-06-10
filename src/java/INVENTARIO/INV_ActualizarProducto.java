package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

@WebServlet(name = "INV_ActualizarProducto", urlPatterns = {"/INV_ActualizarProducto"})
public class INV_ActualizarProducto extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        String cargo = (String) session.getAttribute("cargo");
        if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
                || cargo.equals("CONTRALOR")  || cargo.equals("JEFE"))) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String idProducto  = request.getParameter("idProducto");
        String descripcion = request.getParameter("descripcion");
        String unidad      = request.getParameter("unidad");

        if (idProducto == null || descripcion == null || descripcion.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar el nombre del producto.");
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Existencias_Dashboard.jsp");
            return;
        }

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip   = (String) session.getAttribute("ipDB");
        String url  = "" + ip;

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);

            PreparedStatement st = cn.prepareStatement(
                "UPDATE INV_PRODUCTO SET DESCRIPCION = ?, UNIDAD = ? WHERE ID_PRODUCTO = ?");
            st.setString(1, descripcion.trim());
            st.setString(2, (unidad != null && !unidad.trim().isEmpty()) ? unidad.trim() : null);
            st.setInt(3, Integer.parseInt(idProducto.trim()));
            st.executeUpdate();
            st.close();
            cn.close();

            session.setAttribute("msg_exito", "Producto actualizado correctamente.");
        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
            session.setAttribute("msg_error", "Error al actualizar el producto: " + ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Existencias_Dashboard.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Existencias_Dashboard.jsp");
    }
}
