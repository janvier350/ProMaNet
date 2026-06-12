/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package INVENTARIO;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author Backup
 */
@WebServlet(name = "INV_InsertProducto", urlPatterns = {"/INV_InsertProducto"})
public class INV_InsertProducto extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(true);

        String cargo = (String) session.getAttribute("cargo");

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");
        String key = "";
        String url = new String("" + ip);

        String idCategoria = request.getParameter("idCategoria");
        String descripcion = request.getParameter("descripcion");
//            String idUnidad = request.getParameter("id_unidad");


        String unidadSeleccionada = request.getParameter("id_unidad");
         String[] valores = unidadSeleccionada.split(",");
         String valor1 ="";
String valor2="";

        if (unidadSeleccionada != null && !unidadSeleccionada.isEmpty()) {
           
            String idUnidad = valores[0];  // Obtienes rs.getString(1)
            String descripcionUnidad = valores[1];  // Obtienes rs.getString(3)

            // Debugging en consola
            System.out.println("ID Unidad: " + idUnidad);
            System.out.println("Descripción Unidad: " + descripcionUnidad);
valor1 = idUnidad;
valor2 = descripcionUnidad;
            // Aquí procesas los valores como necesites
        } else {
            System.out.println("No se seleccionó ninguna unidad.");
        }

//             System.out.println(descripcion);
        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (cargo.equals("JEFE") || cargo.equals("ASISTENTE")) {
        } else {
            response.sendRedirect("sesionInvalida.jsp");
        }

        String id_producto = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement("SELECT COUNT(*) FROM INV_PRODUCTO WHERE UPPER(DESCRIPCION) = UPPER(?)");
            st.setString(1, descripcion);
            rs = st.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp?error=producto_dup");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(ID_PRODUCTO),0)+1 secuencia from INV_PRODUCTO";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                id_producto = rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        System.out.println(idCategoria);

        String sql2 = "INSERT INTO INV_PRODUCTO  (ID_PRODUCTO,INV_ID_CATEGORIA,DESCRIPCION, UNIDAD, ID_UNIDAD) "
                + "VALUES (?, ?, ?,?,?)";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(sql2);

            st.setString(1, id_producto);
            st.setString(2, idCategoria);
            st.setString(3, descripcion);
            st.setString(4, valor2);
            st.setString(5, valor1);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("Producto registrado correctamente!!");
            } else {
                response.getWriter().println("Error al insertar la Producto.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

//         agregar a tabla de existencia 
        String idExistencia = "";
        String existencia = "0";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(ID_SUMINISTRO_EXISTENCIA),0)+1 secuencia from INV_SUMINISTRO_EXISTENCIA";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                idExistencia = rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        String sqlExistencia = "INSERT INTO INV_SUMINISTRO_EXISTENCIA  (ID_SUMINISTRO_EXISTENCIA, ID_PRODUCTO, EXISTENCIA) "
                + "VALUES (?, ?, ?)";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(sqlExistencia);

            st.setString(1, idExistencia);
            st.setString(2, id_producto);
            st.setString(3, existencia);
            System.out.println(sqlExistencia);
            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("Existencia inicializada registrado correctamente!!");
            } else {
                response.getWriter().println("Error al insertar la Producto.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

//        fin agregar tabla existencia 
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_InsertProducto</title>");
            out.println("</head>");
            out.println("<body>");
            response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp");
//            out.println("<h1>Servlet INV_InsertProducto at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
