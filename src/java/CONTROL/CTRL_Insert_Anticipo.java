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
 * @author janvier
 */
@WebServlet(name = "CTRL_Insert_Anticipo", urlPatterns = {"/CTRL_Insert_Anticipo"})
public class CTRL_Insert_Anticipo extends HttpServlet {

   
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
        
        // idUsuario e idDepartamento se toman de la sesion, no del
        // formulario: si no, cualquiera con acceso a Anticipos podria
        // registrar una solicitud a nombre de otro usuario.
        String idUsuario = (String) session.getAttribute("cod");
        String sueldo = request.getParameter("sueldo");
        String anticipo = request.getParameter("anticipo");
        String idDepartamento = (String) session.getAttribute("idDepartamento");
        String estado = "PENDIENTE";

        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "CONTROL_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

      Connection cn = null;
PreparedStatement st = null;
ResultSet rs = null;
String idCtrlAnticipo = "";
int totalAnticipos = 0;

try {
    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
    cn = DriverManager.getConnection(url, user, pass);
    cn.setAutoCommit(false); // Para controlar nosotros el commit

    // 1. VALIDACIÓN: Contar anticipos actuales
    String sqlContar = "SELECT COUNT(*) FROM CTRL_ANTICIPOS WHERE ID_USUARIO = ? AND ESTADO = 'PENDIENTE'";
    st = cn.prepareStatement(sqlContar);
    st.setString(1, idUsuario);
    rs = st.executeQuery();
    
    if (rs.next()) {
        totalAnticipos = rs.getInt(1);
    }
    
    // Cerramos el primer ResultSet y Statement para reutilizarlos
    rs.close();
    st.close();

    // Si ya tiene 1 o más (límite alcanzado)
    if (totalAnticipos >= 1) { 
        response.setContentType("text/html");
        response.getWriter().println("<script>alert('Límite de anticipos alcanzado.'); location='../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp';</script>");
        return; 
    }

    // 2. SECUENCIA: Obtener el siguiente ID
    String sqlSecuencia = "SELECT NVL(MAX(ID_CTRL_ANTICIPO), 0) + 1 FROM CTRL_ANTICIPOS";
    st = cn.prepareStatement(sqlSecuencia);
    rs = st.executeQuery();
    if (rs.next()) {
        idCtrlAnticipo = rs.getString(1);
    }
    rs.close();
    st.close();

    // 3. INSERT: Registrar la solicitud
    String sqlInsert = "INSERT INTO CTRL_ANTICIPOS (ID_CTRL_ANTICIPO, ID_USUARIO, SUELDO, FECHA_SOLICITUD, ANTICIPO, ID_DEPARTAMENTO, ESTADO) VALUES (?, ?, ?, SYSDATE, ?, ?, ?)";
    st = cn.prepareStatement(sqlInsert);
    st.setString(1, idCtrlAnticipo);
    st.setString(2, idUsuario);
    st.setString(3, sueldo);
    st.setString(4, anticipo);
    st.setString(5, idDepartamento);
    st.setString(6, estado);

    int rowsAffected = st.executeUpdate();
    
    if (rowsAffected > 0) {
        cn.commit(); // Guardamos cambios
        response.getWriter().println("Agregado Correctamente!!");
    } else {
        cn.rollback();
        response.getWriter().println("Error al insertar.");
    }

} catch (Exception e) {
    if (cn != null) try { cn.rollback(); } catch (SQLException ex) {}
    e.printStackTrace();
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
            out.println("<title>Servlet CTRL_Insert_Anticipo</title>");
            out.println("</head>");
            out.println("<body>");
            response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp");

            //out.println("<h1>Servlet CTRL_Insert_Anticipo at " + request.getContextPath() + "</h1>");
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
