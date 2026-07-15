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
@WebServlet(name = "CTRL_Editar_Anticipo", urlPatterns = {"/CTRL_Editar_Anticipo"})
public class CTRL_Editar_Anticipo extends HttpServlet {

   
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(true);
        String cargo = (String) session.getAttribute("cargo");
        if (session.getAttribute("usuario") == null || session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String url = (String) session.getAttribute("ipDB");

        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null; // Variable declarada aquí

        // Captura de parámetros
        String idAnticipo = request.getParameter("id_ctrl_anticipo");
        String montoStr = request.getParameter("nuevoAnticipo");
        
        if (idAnticipo == null || montoStr == null) {
            response.sendRedirect("Control/ADM_Solicitar_Anticipo?error=Datos incompletos");
            return;
        }

        double nuevoMonto = Double.parseDouble(montoStr);
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            cn = DriverManager.getConnection(url, user, pass);

            // 0. Validar que el plazo de anticipos siga vigente
            String sqlCorte = "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM CTRL_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1";
            try (PreparedStatement stCorte = cn.prepareStatement(sqlCorte);
                 ResultSet rsCorte = stCorte.executeQuery()) {
                if (rsCorte.next()) {
                    java.sql.Date fechaCorte = rsCorte.getDate(1);
                    if (fechaCorte != null && new java.util.Date().after(fechaCorte)) {
                        response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp?error=El plazo para editar anticipos ya vencio");
                        return;
                    }
                }
            }

            // 1. Validar el sueldo actual
            String sqlCheck = "SELECT sueldo FROM ctrl_anticipos WHERE id_ctrl_anticipo = ?";
            st = cn.prepareStatement(sqlCheck);
            st.setString(1, idAnticipo);
            rs = st.executeQuery(); // USAMOS LA VARIABLE YA DECLARADA (sin el 'ResultSet')

            if (rs.next()) {
                double sueldoActual = rs.getDouble("sueldo");
                double limiteMonto = sueldoActual * 0.50;

                // VALIDACIÓN: No mayor al 50%
                if (nuevoMonto > limiteMonto) {
                    response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp?error=El monto excede el 50% del sueldo ($" + limiteMonto + ")");
                    return;
                }

                // 2. Proceder con el UPDATE
                String sqlUpdate = "UPDATE ctrl_anticipos SET anticipo = ? WHERE id_ctrl_anticipo = ?";
                PreparedStatement pstmtUpdate = cn.prepareStatement(sqlUpdate);
                pstmtUpdate.setDouble(1, nuevoMonto);
                pstmtUpdate.setString(2, idAnticipo);
                
                int filasAfectadas = pstmtUpdate.executeUpdate();
                pstmtUpdate.close();

                if (filasAfectadas > 0) {
                    response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp?msj=Anticipo actualizado correctamente");
                    //response.sendRedirect("Control/ADM_Solicitar_Anticipo?msj=Anticipo actualizado correctamente");
                } else {
                    response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp?msj=No se pudo actualizar el registro");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../ProMaNet/Control/ADM_Solicitar_Anticipo.jsp");
        } finally {
            // Cierre seguro de recursos
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
            out.println("<title>Servlet CTRL_Editar_Anticipo</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CTRL_Editar_Anticipo at " + request.getContextPath() + "</h1>");
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
