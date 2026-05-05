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
/**
 *
 * @author Usuario
 */
@WebServlet(name = "INV_Terminar_Ingreso", urlPatterns = {"/INV_Terminar_Ingreso"})
public class INV_Terminar_Ingreso extends HttpServlet {

    
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

        String idSuministroIngresoCab = "39";
//                = request.getParameter("idSuministroIngresoCab");
        
        String estado = "C";
        
         if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
        
        // Verifica que idSuministroIngresoCab no sea null o esté vacío
if (idSuministroIngresoCab == null || idSuministroIngresoCab.trim().isEmpty()) {
    response.sendRedirect("error.jsp"); // Redirige a una página de error
    return;
}

// Construye la consulta SQL
String sql = "UPDATE INV_SUMINISTRO_INGRESO_CAB SET ESTADO = ? WHERE ID_SUMINISTRO_INGRESO_CAB = ?";
System.out.println(sql);

try (Connection conn = DriverManager.getConnection(url, user, pass);
     PreparedStatement pstmt = conn.prepareStatement(sql)) {
    
    pstmt.setString(1, estado);
    pstmt.setInt(2, Integer.parseInt(idSuministroIngresoCab));
    
    int rowsUpdated = pstmt.executeUpdate();
    if (rowsUpdated > 0) {
        System.out.println("Update successful!");
    } else {
        System.out.println("No rows updated.");
    }
    
} catch (Exception e) {
    e.printStackTrace();
    // Maneja la excepción adecuadamente
}

                  
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_Terminar_Ingreso</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet INV_Terminar_Ingreso at " + request.getContextPath() + "</h1>");
            out.println("</body>");
                         response.sendRedirect("Inventario/INV_Ingreso_Suministro2.jsp");

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
