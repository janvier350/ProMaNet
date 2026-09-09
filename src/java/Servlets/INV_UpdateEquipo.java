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

 import java.sql.*;

 import java.util.Date;
     
import java.sql.Connection;
import java.sql.DriverManager;
  import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
/**
 *
 * @author Backup
 */
@WebServlet(name = "INV_UpdateEquipo", urlPatterns = {"/INV_UpdateEquipo"})
public class INV_UpdateEquipo extends HttpServlet {

 
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
               
             HttpSession session = request.getSession(true);
                
             String cargo = (String) session.getAttribute("cargo");
    //String idInvEquipo = request.getParameter("idInvEquipo");
             Date td = new Date();                                        
    String b = new String("");
    String hour = new String("");
    String hourFichero = new String("");
    SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
    SimpleDateFormat formatHourFichero = new SimpleDateFormat("hhmmss");
    SimpleDateFormat formatHour = new SimpleDateFormat("hh:mm:ss");
    b = format.format(td);
    hour = formatHour.format(td);
    hourFichero = formatHourFichero.format(td);
  
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String key ="";
    String url = new String(""+ip);
    
        String fecha = request.getParameter("fecha");
    String empresa = request.getParameter("empresa");
    String ubicacion = request.getParameter("ubicacion");
    String departamento = request.getParameter("departamento");
    String dispositivo = request.getParameter("dispositivo");
    String marca = request.getParameter("marca");
    String modelo = request.getParameter("modelo");
    String serial = request.getParameter("serial");
    String procesador = request.getParameter("procesador");
    String hdd = request.getParameter("hdd");
    String ram = request.getParameter("ram");
    String pantalla = request.getParameter("pantalla");
    String observaciones = request.getParameter("observaciones");
    String estado = request.getParameter("estado");
    String idusuario = request.getParameter("idusuario");
    String idInvEquipo = request.getParameter("idInvEquipo");
    String custodioBackup = request.getParameter("custodioBackup");

    String id_currier = request.getParameter("id_currier");
     System.out.println(estado);
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
         return;
        }

        String sql3="";
         String sql = "update INV_EQUIPOS "
                 + "set FECHACOMPRA = to_date(?, 'yyyy/mm/dd hh24:mi:ss'), UBICACIONOFICINA = ?, DEPARTAMENTO = ?, MARCA = ?, "
                 + "MODELO = ?, SERIAL = ?, PROCESADOR = ?, HDD = ?, RAM = ?, PANTALLA = ?, OBSERVACIONES = ?, "
                 + "ESTADO = ?, EMPRESA = ?, ID_CURRIER = ?, DISPOSITIVO = ?, FICHERO = ?, CUSTODIO_BACKUP = ? "
                 + "WHERE IDINVEQUIPO = ?";
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            st.setString(1, fecha + " " + hour);
            st.setString(2, ubicacion);
            st.setString(3, departamento);
            st.setString(4, marca);
            st.setString(5, modelo);
            st.setString(6, serial);
            st.setString(7, procesador);
            st.setString(8, hdd);
            st.setString(9, ram);
            st.setString(10, pantalla);
            st.setString(11, observaciones);
            st.setString(12, estado);
            st.setString(13, empresa);
            if (id_currier != null && !id_currier.trim().isEmpty()) {
                try { st.setInt(14, Integer.parseInt(id_currier.trim())); }
                catch (Exception ignore) { st.setNull(14, java.sql.Types.NUMERIC); }
            } else {
                st.setNull(14, java.sql.Types.NUMERIC);
            }
            st.setString(15, dispositivo);
            st.setString(16, key);
            if (custodioBackup != null && !custodioBackup.trim().isEmpty()) st.setString(17, custodioBackup.trim());
            else st.setNull(17, java.sql.Types.VARCHAR);
            st.setInt(18, Integer.parseInt(idInvEquipo));
            st.executeUpdate();
            cn.commit();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        if(estado.equals("A")){
                            System.out.println(sql3);

        }else {
                   
            sql3="UPDATE INV_ASIGNACION SET ESTADO ='I',FECHADEVOLUCION= "
            +" to_date('"+b+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss')  WHERE IDINVEQUIPO = "+idInvEquipo+" and estado ='A'";
            try{
                System.out.println(sql3);
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn3 = DriverManager.getConnection(url, user, pass);
                PreparedStatement st3 = cn3.prepareStatement(sql3);
                ResultSet rs3 = st3.executeQuery(); 
                cn3.commit();
                rs3.close();
                st3.close();
                cn3.close();
            }catch(Exception e){
                 e.printStackTrace();
            }   
        }
        
    
        try (PrintWriter out = response.getWriter()) {
     
    
            
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_UpdateEquipo</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<p>"+sql+" </p>");
            out.println("<p>"+sql3+" </p>");
            out.println("<h1>Servlet INV_UpdateEquipo at " + request.getContextPath() + "</h1>");
            out.println("</body>");
//            response.sendRedirect("Inventario/INV_Equipos.jsp");
            response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");
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
