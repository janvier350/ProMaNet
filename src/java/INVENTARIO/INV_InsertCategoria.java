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

import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
/**
 *
 * @author Backup
 */
@WebServlet(name = "INV_InsertCategoria", urlPatterns = {"/INV_InsertCategoria"})
public class INV_InsertCategoria extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
          HttpSession session = request.getSession(true);
                
          String cargo = (String) session.getAttribute("cargo");
        
            String user = (String) session.getAttribute("userDB");
            String pass = (String) session.getAttribute("passDB");
            String ip = (String) session.getAttribute("ipDB");
            String key ="";
            String url = new String(""+ip);
            
            String categoria = request.getParameter("categoria");
            String estado = "A";
             System.out.println(categoria);
             
              if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
        
        String idCategoria = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(INV_ID_CATEGORIA),0)+1 secuencia from INV_CATEGORIA";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                idCategoria = rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (st != null) st.close();
                if (cn != null) cn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        System.out.println(categoria);
        System.out.println(idCategoria);
        System.out.println(estado);
        
        
        String sql2 = "INSERT INTO INV_CATEGORIA  (INV_ID_CATEGORIA,DESCRIPCION,ESTADO) "
                    + "VALUES (?, ?, 'A')";
        
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(sql2);

            st.setString(1, idCategoria);
            st.setString(2, categoria);
            
          
         
            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("Categoría Insertado Correctamente!!");
            } else {
                response.getWriter().println("Error al insertar la categoría.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (st != null) st.close();
                if (cn != null) cn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_InsertCategoria</title>");
            out.println("</head>");
            out.println("<body>");
//            out.println("<h1>Servlet INV_InsertCategoria at " + request.getContextPath() + "</h1>");
            response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro_detalle.jsp");
            response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");
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
