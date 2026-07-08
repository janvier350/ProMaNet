/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Servlets;


import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import static java.lang.System.out;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

 import java.sql.*;


import java.sql.Connection;
import java.sql.DriverManager;
  import java.sql.ResultSet;

/**
 *
 * @author Backup
 */
@WebServlet(name = "eliminarReporteDiario", urlPatterns = {"/eliminarReporteDiario"})
public class eliminarReporteDiario extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
                HttpSession session = request.getSession(true);
                
                String codigo = (String) session.getAttribute("cod");
                String cargo = (String) session.getAttribute("cargo");
                String user = (String) session.getAttribute("userDB");
                String pass = (String) session.getAttribute("passDB");
                String ip = (String) session.getAttribute("ipDB");
                String url = (String) session.getAttribute("url");
                url = new String(""+ip);
                String idCab = request.getParameter("idCab");
                 String idDet = request.getParameter("idDet");

                 if (session.getAttribute("usuario") == null || session.isNew()) {
                     response.sendRedirect("sesionExpirada.jsp");
                     return;
                 }
                 if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR") || cargo.equals("ASISTENTE")
                         || cargo.equals("PASANTE") || cargo.equals("CONTRALOR") || cargo.equals("JEFE"))) {
                     response.sendRedirect("sesionInvalida.jsp");
                     return;
                 }
//                 String idCab = request.getParameter(" idCab");

               System. out. println (idCab);
                System. out. println (idDet);
                String sql = "DELETE FROM REP_GASDET where IDREPGASDET="+idDet;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        //           suma alimentacion y movilizacion     
            
        
        
           double suma2 =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql2 = "select sum(VALOR) from REP_GASDET WHERE IDREPGASCAB = "+idCab+" AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE) " ;
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 suma2 = rs.getDouble(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        String sql3 = "update REP_GASCAB set TOTAL ="+suma2+" WHERE IDREPGASCAB = "+idCab;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql3);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
                
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet eliminarReporteDiario</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet eliminarReporteDiario at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            response.sendRedirect("ReporteGastos/ReporteGastosIndivi.jsp");
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
