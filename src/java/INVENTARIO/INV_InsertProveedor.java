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
/**
 *
 * @author Usuario
 */
@WebServlet(name = "INV_InsertProveedor", urlPatterns = {"/INV_InsertProveedor"})
public class INV_InsertProveedor extends HttpServlet {

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
            
            String identificacion = request.getParameter("identificacion");
            String razonSocial = request.getParameter("razonSocial");
            String direcccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");
            String correo = request.getParameter("correo");
            String contacto = request.getParameter("contacto");
            String estado = "A";
            
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
        
         String idProveedor = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;
        
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(ID_PROVEEDOR),0)+1 secuencia from INV_PROVEEDOR";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                idProveedor = rs.getString(1);
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
         
          String insertProveedor = "INSERT INTO INV_PROVEEDOR  (ID_PROVEEDOR,IDENTIFICACION, RAZON_SOCIAL, DIRECCION, TELEFONO, CORREO, CONTACTO, ESTADO) "
                    + "VALUES (?, ?,?, ?,?, ?,?, 'A')";
            try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(insertProveedor);

            st.setString(1, idProveedor);
            st.setString(2, identificacion);
             st.setString(3, razonSocial);
            st.setString(4, direcccion);
             st.setString(5, telefono);
            st.setString(6, correo);
             st.setString(7, contacto);
            
          
         
            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("Proveedor Insertado Correctamente!!");
            } else {
                response.getWriter().println("Error al insertar la proveedor.");
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
            out.println("<title>Servlet INV_InsertProveedor</title>");
            out.println("</head>");
            out.println("<body>");
            response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp");
//            out.println("<h1>Servlet INV_InsertProveedor at " + request.getContextPath() + "</h1>");
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
