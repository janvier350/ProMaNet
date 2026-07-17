/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pdf;

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
import java.sql.ResultSet;
import java.sql.*;

/**
 *
 * @author Backup
 */
@WebServlet(name = "reporteGasto", urlPatterns = {"/reporteGasto"})
public class reporteGasto extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(true);
//        variables para trabajar en el servlet
        String user = "RRHH";
        String pass = "__CLAVE_RRHH_NUBE__";
        String url = "jdbc:oracle:thin:@promanet_low?TNS_ADMIN=/opt/promanet/wallet";

        String ejecutivo, email, departamento, descripcion = "";
        String id = request.getParameter("id");
        String tot = request.getParameter("tot");

        String idCompa = (String) session.getAttribute("idCompa");
        String compania = (String) session.getAttribute("compania");
        String cargo = (String) session.getAttribute("cargo");
        String nombre = (String) session.getAttribute("nombre");
        String apellidos = (String) session.getAttribute("apellidos");
        String mes = request.getParameter("mes");

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
        String logotipo = "";

        if (idCompa.equals("1")) {
            logotipo = "buadnet2020";
        } else if (idCompa.equals("2")) {
            logotipo = "XpAudit";
        } else if (idCompa.equals("3")) {
            logotipo = "LatiSA";
        } else if (idCompa.equals("4")) {
            logotipo = "Arthurs";
        } else if (idCompa.equals("5")) {
            logotipo = "norte";
        } else if (idCompa.equals("6")) {
            logotipo = "CTSCONSTRUCTORES";
        }
//         logotipo ="CTSCONSTRUCTORES";
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet reporteGastos</title>");
            out.println("</head>");
            out.println("<body>");
            out.println(" <img src=\"image/" + logotipo + ".png\" alt=\"Esta es una descripcion alternativa de la imagen para cuando no se pueda mostrar\"   width=\"350\" height=\"150\" align=\"right\"/> ");

//            out.println("<h1>Servlet reporteGasto at " + request.getContextPath() + "</h1>");
//            out.println("<h2>Servlet reporteGasto at " + id+ compania+  "</h2>");
            out.println("<h4>Ejecutivo :  " + nombre + " " + apellidos + "</h4>");
            out.println("<h4>Compania :  " + compania + "</h4>");
            out.println("<h4>Cargo :  " + cargo + "</h4>");
            out.println("<h4>Mes de corte  :  " + mes + "</h4>");
//            out.println("<h4>Total Reporte :  " + tot + "</h4>");
            out.println("<h2> REPORTE DE GASTOS </h2>");
            String ali = "";
            String movi = "";
            try {

                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sql = "select TO_CHAR(SUM(totalim),'FM999G990D00'), TO_CHAR(SUM(totmovi),'FM999G990D00') from repgasdet where idrepgascab = " + id + "order by idrepgascab";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();
                while (rs.next()) {
                    ali = rs.getString(1);
                    movi = rs.getString(2);
//                 out.println("<td>"+ali+"</td>");
//                 out.println("<td>"+movi+"</td>");
//                out.println("<tr>");
//                out.println("<td>"+id+"</td>");
//                out.println("<td>"+cargo+"</td>");
//                out.println("<td>"+nombre+"</td>");
//                out.println("<td>"+apellidos+"</td>");
//                out.println("<td>"+mes+"</td>");
//                out.println("</tr>");

                }
                rs.close();
                st.close();
                cn.close();
//            document.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

//              select b.IDREPGASDET, a.FECHA, TO_CHAR(b.TOTALIM,'FM999G990D00'), b.TRABREALIZADO, TO_CHAR(b.TOTMOVI,'FM999G990D00'),b.FECHA, c.CLIENTE from repgascab a,repgasdet b, cliente c where a.idrepgascab = b.idrepgascab and a.idrepgascab=" + idCab +" and b.IDCLIENTE=c.IDCLIENTE order by b.FECHA
            out.println("<table border =1 >");
            out.println("<thead>");
            out.println("<tr>");
            out.println("<th> FECHA </th>");
            out.println("<th> ALIMENTACION </th>");
            out.println("<th>MOVILIZACION </th>");
            out.println("<th>CLIENTE</th>");
            out.println("<th> OBSERVACION </th>");

            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");
            try {
                String fecha, alimentacion, trasnporte, clienteRp, observacionRp = "";

                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn2 = DriverManager.getConnection(url, user, pass);
                String sql = "select b.IDREPGASDET, a.FECHA, TO_CHAR(b.TOTALIM,'FM999G990D00'), b.TRABREALIZADO, TO_CHAR(b.TOTMOVI,'FM999G990D00'),b.FECHA, c.CLIENTE from repgascab a,repgasdet b, cliente c where a.idrepgascab = b.idrepgascab and a.idrepgascab=" + id + " and b.IDCLIENTE=c.IDCLIENTE order by b.FECHA";
                PreparedStatement st2 = cn2.prepareStatement(sql);
                ResultSet rs2 = st2.executeQuery();
                while (rs2.next()) {
                    fecha = rs2.getString(6);
                    alimentacion = rs2.getString(3);
                    trasnporte = rs2.getString(5);
                    clienteRp = rs2.getString(7);
                    observacionRp = rs2.getString(4);
//                 
//                 out.println("<td>"+ali+"</td>");
//                 out.println("<td>"+movi+"</td>");
//               
                    out.println("<tr>");
                    out.println("<td> <span>" + fecha + "</span></td>");
                    out.println("<td>    " + alimentacion + "</td>");
                    out.println("<td>" + trasnporte + "</td>");
                    out.println("<td>" + clienteRp + "</td>");
                    out.println("<td>" + observacionRp + "</td>");
                    out.println("</tr>");

                }
                rs2.close();
                st2.close();
                cn2.close();
//            document.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            out.println("</tbody>");
            out.println("</table>");

            out.println("<h3>                                   Alimentacion :  $ " + ali + "</h3>");
            out.println("<h3>                                Movilizacion :    $  " + movi + "</h3>");
            out.println("<h3>                                Total reporte :   $ " + tot + "</h3>");
            out.println("<br>");
            out.println("<h4>Revisado por ___________________  Elaborado por  : ______________________ </h4>");

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
