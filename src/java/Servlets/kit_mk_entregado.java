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

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
/**
 *
 * @author Usuario
 */
@WebServlet(name = "kit_mk_entregado", urlPatterns = {"/kit_mk_entregado"})
public class kit_mk_entregado extends HttpServlet {

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
        
        String idNotificacion = request.getParameter("idNotificacion");
          String departamento = (String) session.getAttribute("departamento");
            String usuario = (String) session.getAttribute("usuario");
            String apellidos = (String) session.getAttribute("apellidos");
//        
//            String estado = "ENTREGADO -   "+usuario;
//             if(session.getAttribute("usuario")==null){
//             response.sendRedirect("sesionExpirada.jsp");
//             return;
//             }else if (session.isNew()){
//             response.sendRedirect("sesionExpirada.jsp");
//             return;
//             }
//             
//               if(departamento.equals("TECNOLOGÍA")){
//        }else{
//         response.sendRedirect("sesionInvalida.jsp");
//        }
//               
//                String sql = "update ADM_NOTIFICACIONES set ESTADO = "+estado+"  WHERE IDNOTIFICACIONES  = "+idNotificacion;
//                 
//                  System.out.println(sql);
//        try{
//            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
//            Connection cn = DriverManager.getConnection(url, user, pass);
//            PreparedStatement st = cn.prepareStatement(sql);
//            ResultSet rs = st.executeQuery(); 
//             System.out.println(sql);
//            cn.commit();
//            rs.close();
//            st.close();
//            cn.close();
//        }catch(Exception e){
//             e.printStackTrace();
//        }
String estado = "ENTREGADO - " + usuario;

//if (session.getAttribute("usuario") == null) {
//    response.sendRedirect("sesionExpirada.jsp");
//    return;
//} else if (session.isNew()) {
//    response.sendRedirect("sesionExpirada.jsp");
//    return;
//}

if(apellidos.equals("Varas Herrera")||departamento.equals("MARKETING")||cargo.equals("CONTRALOR")){
    
}else{
    response.sendRedirect("sesionInvalida.jsp");
    return;
}

String sql = "UPDATE ADM_NOTIFICACIONES SET KIT_MK = ? WHERE IDNOTIFICACIONES = ?";

System.out.println("Consulta SQL: " + sql);

try {
    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
    Connection cn = DriverManager.getConnection(url, user, pass);
    
    PreparedStatement st = cn.prepareStatement(sql);
    st.setString(1, estado); // Se asigna el estado con comillas automáticamente
    st.setString(2, idNotificacion); // Se asigna el ID de notificación

    int filasActualizadas = st.executeUpdate(); // Se usa executeUpdate() para UPDATE

    if (filasActualizadas > 0) {
        System.out.println("Estado actualizado correctamente.");
    } else {
        System.out.println("No se encontró la notificación con el ID: " + idNotificacion);
    }

    cn.commit();
    st.close();
    cn.close();
} catch (Exception e) {
    e.printStackTrace();
}

        
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet kit_mk_entregado</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet kit_mk_entregado at " + request.getContextPath() + "</h1>");
            out.println("</body>");
         
              response.sendRedirect("../ProMaNet/Proyectos/PRO_Dashboard.jsp");
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
