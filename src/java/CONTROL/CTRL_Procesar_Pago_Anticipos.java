/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package CONTROL;

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
 * @author developer
 */
@WebServlet(name = "CTRL_Procesar_Pago_Anticipos", urlPatterns = {"/CTRL_Procesar_Pago_Anticipos"})
public class CTRL_Procesar_Pago_Anticipos extends HttpServlet {

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(true);

        String cargo = (String) session.getAttribute("cargo");
        if (session.getAttribute("usuario") == null || session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR") || cargo.equals("ASISTENTE")
                || cargo.equals("PASANTE") || cargo.equals("CONTRALOR") || cargo.equals("JEFE"))) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");
        String key = "";
        String url = new String("" + ip);
        
        Connection cn = null;
PreparedStatement st = null;
ResultSet rs = null;

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
    cn = DriverManager.getConnection(url, user, pass);

        // Sentencia para actualizar todos los pendientes del mes actual
        String sql = "UPDATE CTRL_ANTICIPOS " +
                     "SET ESTADO = 'PAGADO' " +
                     "WHERE TRUNC(FECHA_SOLICITUD, 'MM') = TRUNC(SYSDATE, 'MM') " +
                     "AND ESTADO = 'PENDIENTE'";

        st = cn.prepareStatement(sql);
        int filasAfectadas = st.executeUpdate();

        // Redireccionar con un mensaje de éxito (opcional)
        response.getWriter().println("Agregado Correctamente!!");

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("tu_pagina_principal.jsp?error=sql");
    } finally {
    // CERRAMOS TODO AL FINAL, UNA SOLA VEZ
    try {
        if (rs != null) rs.close();
        if (st != null) st.close();
        if (cn != null) cn.close();
    } catch (SQLException e) { e.printStackTrace(); }
}
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CTRL_Procesar_Pago_Anticipos</title>");
            out.println("</head>");
            out.println("<body>");
            response.sendRedirect("../ProMaNet/Control/ADM_Dashboard.jsp");
//            out.println("<h1>Servlet CTRL_Procesar_Pago_Anticipos at " + request.getContextPath() + "</h1>");
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
