/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

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
 * @author developer
 */
@WebServlet(urlPatterns = {"/INV_InsertSoporteGenerado"})
public class INV_InsertSoporteGenerado extends HttpServlet {

 
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
        url = new String("" + ip);

        String sql = "";

        int secuenciaCab = 0;

        String idUsuario = request.getParameter("idEjecutivo_soporteGenerado");
        String idEquipo = request.getParameter("idEquipo");

        String prioridad = request.getParameter("prioridad_soporteGenerado");
        String soporte = request.getParameter("soporteGenerado");
        String reporte = "SIN REPORTE";
        String estado = "PENDIENTE";

        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR") || cargo.equals("ASISTENTE") || cargo.equals("PASANTE") || cargo.equals("CONTRALOR") || cargo.equals("JEFE")) {

        } else {
            response.sendRedirect("sesionInvalida.jsp");
        }

        //consulta idinvEquipo
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn4 = DriverManager.getConnection(url, user, pass);
            //                                                                              String empresa = "select * from compania where estado = 'a'  order by 2";
            String usuarios = "select a.idinvequipo from inv_equipos a left join inv_asignacion b on a.idinvequipo = b.idinvequipo where b.idusuario = " + idUsuario + " and b.estado = 'A'";
            PreparedStatement st4 = cn4.prepareStatement(usuarios);
            ResultSet rs4 = st4.executeQuery();
            while (rs4.next()) {
                idEquipo =  rs4.getString(1);
                        
            }
            rs4.close();
            st4.close();
            cn4.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

//        insertar SOPORTE
        sql = "INSERT INTO SOP_SOPORTE_CAB  VALUES (" + secuencia(secuenciaCab) + "," + idUsuario + "," + idEquipo + ",sysdate,'" + soporte + "','" + prioridad + "','" + estado + "','" + reporte + "',sysdate, 'N/A')";
        out.println("<p>sql: " + sql + "</p>");
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st2 = cn2.prepareStatement(sql);
            ResultSet rs2 = st2.executeQuery();
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_InsertSoporteGenerado</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet INV_InsertSoporteGenerado at " + request.getContextPath() + "</h1>");
            response.sendRedirect("Proyectos/PRO_Dashboard.jsp");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
      private int secuencia(int secuencia) {
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sqliDdET = "select nvl(max(IDSOPORTE),0)+1 secuencia from SOP_SOPORTE_CAB";
            PreparedStatement st = cn.prepareStatement(sqliDdET);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                secuencia = rs.getInt(1);
            }
            rs.close();
            st.close();
            cn.close();
        } catch (Exception e) {
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
