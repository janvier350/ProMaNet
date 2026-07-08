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
@WebServlet(name = "CTRL_Insert_Fecha_Corte_Anticipo", urlPatterns = {"/CTRL_Insert_Fecha_Corte_Anticipo"})
public class CTRL_Insert_Fecha_Corte_Anticipo extends HttpServlet {

  
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
         HttpSession session = request.getSession(true);
String cargo = (String) session.getAttribute("cargo");
String user = (String) session.getAttribute("userDB");
String pass = (String) session.getAttribute("passDB");
String ip = (String) session.getAttribute("ipDB");
 String url = new String("" + ip);

String idUsuario = request.getParameter("idUsuario");
String corte = request.getParameter("corte");
String estado = "A";

if (session.getAttribute("usuario") == null || session.isNew()) {
    response.sendRedirect("sesionExpirada.jsp");
    return;
}
if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR") || cargo.equals("ASISTENTE")
        || cargo.equals("PASANTE") || cargo.equals("CONTRALOR") || cargo.equals("JEFE"))) {
    response.sendRedirect("sesionInvalida.jsp");
    return;
}

// Validar que la fecha no sea nula o vacía
if (corte == null || corte.trim().isEmpty()) {
    response.sendRedirect("error.jsp?mensaje=La fecha de corte es requerida");
    return;
}

Connection cn = null;
PreparedStatement st = null;
ResultSet rs = null;

try {
    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
    cn = DriverManager.getConnection(url, user, pass);
    cn.setAutoCommit(false);

    // 1. VALIDACIÓN: Verificar si ya existe una fecha de corte en el mismo mes y año
    String sqlVerificarMes = "SELECT COUNT(*) FROM CTRL_FECHA_CORTE_ANTICIPO " +
                              "WHERE TO_CHAR(FECHA_CORTE, 'YYYY-MM') = TO_CHAR(TO_DATE(?, 'YYYY-MM-DD'), 'YYYY-MM') " +
                              "AND ESTADO = 'A'";
    st = cn.prepareStatement(sqlVerificarMes);
    st.setString(1, corte);
    rs = st.executeQuery();
    
    if (rs.next()) {
        int count = rs.getInt(1);
        if (count > 0) {
            cn.rollback();
            response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp?mensaje=Ya existe una fecha de corte activa para este mes. Solo se permite una por mes.");
            return;
        }
    }
    rs.close();
    st.close();

    // 2. Obtener el siguiente ID
    String sqlSecuencia = "SELECT NVL(MAX(ID_FECHA_CORTE), 0) + 1 FROM CTRL_FECHA_CORTE_ANTICIPO";
    st = cn.prepareStatement(sqlSecuencia);
    rs = st.executeQuery();
    
    String idFechaCorte = "1";
    if (rs.next()) {
        idFechaCorte = rs.getString(1);
    }
    rs.close();
    st.close();

    // 3. Insertar la nueva fecha de corte
    String sqlInsert = "INSERT INTO CTRL_FECHA_CORTE_ANTICIPO (ID_FECHA_CORTE, FECHA_CORTE, ESTADO, ID_USUARIO) " +
                       "VALUES (?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?)";
    st = cn.prepareStatement(sqlInsert);
    st.setString(1, idFechaCorte);
    st.setString(2, corte);
    st.setString(3, estado);
    st.setString(4, idUsuario);

    int rowsAffected = st.executeUpdate();

  if (rowsAffected > 0) {
    cn.commit();
    
    String mensaje = "Fecha de corte agregada correctamente para el mes " + corte.substring(0, 7);
    
    // IMPORTANTE: No usar response.sendRedirect aquí
    response.setContentType("text/html;charset=UTF-8");
    try (PrintWriter out = response.getWriter()) {
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Procesando...</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<script type='text/javascript'>");
        out.println("alert('" + mensaje + "');");
        out.println("window.location.href = '../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp';");
        out.println("</script>");
        out.println("</body>");
        out.println("</html>");
    }
    
} else {
    cn.rollback();
    response.sendRedirect("error.jsp?mensaje=Error al insertar fecha de corte");
}

} catch (Exception e) {
    if (cn != null) try { cn.rollback(); } catch (SQLException ex) {}
    e.printStackTrace();
    response.sendRedirect("error.jsp?mensaje=Error: " + e.getMessage());
} finally {
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
            out.println("<title>Servlet CTRL_Insert_Fecha_Corte_Anticipo</title>");
            out.println("</head>");
            out.println("<body>");
                        response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp");

//            out.println("<h1>Servlet CTRL_Insert_Fecha_Corte_Anticipo at " + request.getContextPath() + "</h1>");
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
