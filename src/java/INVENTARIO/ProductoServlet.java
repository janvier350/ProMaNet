/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package INVENTARIO;

import static Servlets.generarReporteGastosMes.pass;
import static Servlets.generarReporteGastosMes.url;
import static Servlets.generarReporteGastosMes.user;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import jakarta.servlet.annotation.WebServlet;
import static java.lang.System.out;

/**
 *
 * @author Backup
 */
public class ProductoServlet extends HttpServlet {

    private static class Producto {

        String nombre;
        double precio;

        Producto(String nombre, double precio) {
            this.nombre = nombre;
            this.precio = precio;
        }

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
            Connection cn = null;
            PreparedStatement st = null;
            ResultSet rs = null;

            List<JSONObject> productos = new ArrayList<>();

            String idCategoria = request.getParameter("idCategoria");
            String descripcion = request.getParameter("descripcion");
            String idUnidad = request.getParameter("id_unidad");
            out.println("Lo que quieras escribir");
            String sql4 = "SELECT a.id_producto as precio, b.descripcion as nombre, b.unidad,  a.existencia,  b.inv_id_categoria, c.descripcion AS categoria FROM  inv_suministro_existencia a JOIN  inv_producto b ON a.id_producto = b.id_producto JOIN  inv_categoria c ON b.inv_id_categoria = c.inv_id_categoria";

            try {
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn4 = DriverManager.getConnection(url, user, pass);
                PreparedStatement st4 = cn4.prepareStatement(sql4);
                ResultSet rs4 = st4.executeQuery();
                while (rs4.next()) {

                    JSONObject producto = new JSONObject();
                    producto.put("nombre", rs.getString("nombre"));
                    producto.put("precio", rs.getDouble("precio"));
                    productos.add(producto);

                }
                rs4.close();
                st4.close();
                cn4.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(new JSONArray(productos).toString());

            try (PrintWriter out = response.getWriter()) {
                /* TODO output your page here. You may use following sample code. */
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Servlet ProductoServlet</title>");
                out.println("</head>");
                out.println("<body>");
                out.println("<h1>Servlet ProductoServlet at " + request.getContextPath() + "</h1>");
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
        protected void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
           
        }

        /**
         * Handles the HTTP <code>POST</code> method.
         *
         * @param request servlet request
         * @param response servlet response
         * @throws ServletException if a servlet-specific error occurs
         * @throws IOException if an I/O error occurs
         */
        protected void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            processRequest(request, response);

            // Simular datos desde una base de datos
            List<Producto> productos = new ArrayList<>();
            productos.add(new Producto("Producto 1", 10.50));
            productos.add(new Producto("Producto 2", 15.00));
            productos.add(new Producto("Producto 3", 7.99));

            // Construir JSON usando org.json
            JSONArray jsonArray = new JSONArray();
            for (Producto producto : productos) {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("nombre", producto.nombre);
                jsonObject.put("precio", producto.precio);
                jsonArray.put(jsonObject);
            }

            // Configurar respuesta
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(jsonArray.toString());
            out.flush();
        }
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
