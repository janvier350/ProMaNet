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

import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import jakarta.servlet.http.HttpSession;
import static java.lang.System.out;

/**
 *
 * @author Usuario
 */
@WebServlet(name = "INV_Delete_Suministro_Cab", urlPatterns = {"/INV_Delete_Suministro_Cab"})
public class INV_Delete_Suministro_Cab extends HttpServlet {


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

        String ID_SUMINISTRO_INGRESO_CAB = request.getParameter("ID_SUMINISTRO_INGRESO_CAB");
        
           if (session.getAttribute("usuario") == null) {
            response.sendRedirect("../sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("../sesionExpirada.jsp");
            return;
        }
        if (cargo.equals("JEFE") || cargo.equals("ADMINISTRADOR")|| cargo.equals("ADMINISTRACION")) {
        } else {
            response.sendRedirect("../sesionInvalida.jsp");
        }
        
        Connection cn = null;
        PreparedStatement st = null;

        

   try {
            // Conexión a la base de datos
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);

            // SQL para eliminar el producto
            String sqlDelete = "DELETE FROM INV_SUMINISTRO_INGRESO_CAB WHERE ID_SUMINISTRO_INGRESO_CAB = ?";

            st = cn.prepareStatement(sqlDelete);
            st.setString(1, ID_SUMINISTRO_INGRESO_CAB);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            // Respuesta al cliente
            try (PrintWriter out = response.getWriter()) {
                if (rowsAffected > 0) {
//                    response.sendRedirect("../ProMaNet/Inventario/INV_Inventarios.jsp");
                     response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp");

                } else {
                    out.println("<script>alert('No se encontró el producto con ID: " + ID_SUMINISTRO_INGRESO_CAB + "');</script>");
                    out.println("<script>window.location.href='../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp';</script>");
                }
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
