/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package TODO;

import static Servlets.generarReporteGastosMes.pass;
import static Servlets.generarReporteGastosMes.url;
import static Servlets.generarReporteGastosMes.user;
import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import static java.lang.System.out;

 import java.sql.*;


import java.sql.Connection;
import java.sql.DriverManager;
  import java.sql.ResultSet;

/**
 *
 * @author Backup
 */
@WebServlet(name = "TODO_insertTareaCab", urlPatterns = {"/TODO_insertTareaCab"})
public class TODO_insertTareaCab extends HttpServlet {

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
      
        String sql ="";
       
         int secuenciaCab =0;
         
         String tarea = request.getParameter("tarea");
         String descripcion = request.getParameter("descripcion");
         String idDepartamento = request.getParameter("idDepartamento");
         String estado = "A";
         
             if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
        
                       //        insertar trabajo
sql ="INSERT INTO TODO_CAB_TAREAS  VALUES ("+secuencia(secuenciaCab)+","+idDepartamento+",'" +tarea+"','"+descripcion+"','"+estado+"')";
                   out.println("<p>sql: " + sql + "</p>");    
                    try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn2 = DriverManager.getConnection(url, user, pass);
                        PreparedStatement st2 = cn2.prepareStatement(sql);
                        ResultSet rs2 = st2.executeQuery(); 
                        cn2.commit();
                        rs2.close();
                        st2.close();
                        cn2.close();
                    }catch(Exception e){
                         e.printStackTrace();
                    }
                    
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet TODO_insertTareaCab</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet TODO_insertTareaCab at " + request.getContextPath() + "</h1>");
              response.sendRedirect("Proyectos/PRO_NUEVA_TAREA.jsp");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    private  int secuencia(int secuencia) {      
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sqliDdET = "select nvl(max(ID_TODO_CAB_TAREAS),0)+1 secuencia from TODO_CAB_TAREAS";
            PreparedStatement st = cn.prepareStatement(sqliDdET);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                secuencia = rs.getInt(1); 
             }  
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        return secuencia;
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
