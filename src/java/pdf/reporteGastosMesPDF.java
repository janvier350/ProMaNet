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
import static java.lang.System.out;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author Backup
 */
@WebServlet(name = "reporteGastosMesPDF", urlPatterns = {"/reporteGastosMesPDF"})
public class reporteGastosMesPDF extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(true);

        String idCompa = (String) session.getAttribute("idCompa");
        String compania = (String) session.getAttribute("compania");
        String cargo = (String) session.getAttribute("cargo");
        String nombre = (String) session.getAttribute("nombre");
        String apellidos = (String) session.getAttribute("apellidos");
        String codigo = (String) session.getAttribute("cod");

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");

        String transportePDF = request.getParameter("transpor");
        String alimentacionPDF = request.getParameter("alimPDF");
        String mes = request.getParameter("mes");

        String url = new String("" + ip);

        String fecha = "";
        double total = 0;

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

        try (PrintWriter out = response.getWriter()) {

            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet reporteGastosMesPDF</title>");
            out.println("</head>");
            out.println("<body>");

            out.println("<link href=\"//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css\" rel=\"stylesheet\" id=\"bootstrap-css\">");
            out.println("<script src=\"//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js\"></script>");
            out.println("<script src=\"//code.jquery.com/jquery-1.11.1.min.js\"></script>");
            out.println("</head>");
            out.println("<body class=\"container table\">");

            out.println(" <img src=\"image/" + logotipo + ".png\" alt=\"Esta es una descripcion alternativa de la imagen para cuando no se pueda mostrar\"   width=\"350\" height=\"150\" align=\"right\"/> ");

            out.println("<h2> REPORTE DE GASTOS MES</h2>");

            out.println("<h5> <strong> Ejecutivo: " + nombre + " " + apellidos + " </strong></h5>");
            out.println("<h5> Compania: " + compania + "</h5>");
            out.println("<h5>    Cargo: " + cargo + "</h5>");

            String ali = "";
            String movi = "";
            String idrepgascab = "";
            try {

                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sql = "SELECT idrepgascab, idusuario, fecha, total, aprobado FROM rep_gascab WHERE idusuario = " + codigo + " AND EXTRACT(MONTH FROM fecha) = " + mes + "";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();
                while (rs.next()) {
                    total = rs.getDouble(4);
                    fecha = rs.getString(3);
                    idrepgascab = rs.getString(1);

                }
                rs.close();
                st.close();
                cn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            out.println("<div class=\"container\">");
            out.println("<div class=\"row\">");
            out.println("<div class=\"col-md-12\">");
            out.println("<div class=\"alert alert-success\" style=\"display:none;\">");
            out.println("<span class=\"glyphicon glyphicon-ok\"></span> Drag table row and change Order</div>");
            out.println("<table class=\"table\">");
//              out.println("<table border =2 >");  
            out.println("<thead>");
            out.println("<tr>");
//                  out.println("<th> FECHA </th>"); 
//                   out.println("<th> DÍA </th>"); 
//                   out.println("<th> ALIMENTACIÓN </th>"); 
//                    out.println("<th>MOVILIZACIÓN </th>"); 
//                    out.println("<th>UBICACIÓN</th>");
//                 out.println("<th> OBSERVACIÓN </th>"); 
            out.println("<th style='width: 10%; min-width: 50px;'> FECHA </th>");
            out.println("<th style='width: 10%; min-width: 50px;'> DÍA </th>");
            out.println("<th style='width: 10%; min-width: 50px;'> ALIMENT </th>");
            out.println("<th style='width: 10%; min-width: 50px;'> MOVILIZ </th>");
            out.println("<th style='width: 10%; min-width: 50px;'> UBICACIÓN </th>");
            out.println("<th style='width: 10%; min-width: 50px;'> OBSERVACIÓN </th>");

            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");
            out.println("</div>");

            try {
                String fechaDet, alimentacion, trasnporte, clienteRp, observacionRp, dia = "";

                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn2 = DriverManager.getConnection(url, user, pass);
                String sql = "SELECT a.idrepgasdet, a.idcliente,to_char(A.fecha, 'DD/MON/YYYY'), a.VALOR,a.trabrealizado,a.totalim, a.totmovi, a.idrepgascab , TO_CHAR(a.fecha, 'Day', 'NLS_DATE_LANGUAGE=SPANISH') AS dia_semana , c.cliente FROM rep_gasdet a, rep_gascab b, cliente c WHERE a.idrepgascab = " + idrepgascab + " and b.idrepgascab = a.idrepgascab and a.idcliente = c.idcliente AND EXTRACT(MONTH FROM a.fecha) = " + mes + " order by 3";
                PreparedStatement st2 = cn2.prepareStatement(sql);
                ResultSet rs2 = st2.executeQuery();
                while (rs2.next()) {
                    fechaDet = rs2.getString(3);
                    alimentacion = rs2.getString(6);
                    trasnporte = rs2.getString(7);
                    clienteRp = rs2.getString(10);
                    observacionRp = rs2.getString(5);
                    dia = rs2.getString(9);
//                 
//                 out.println("<td>"+ali+"</td>");
//                 out.println("<td>"+movi+"</td>");
//               
                    out.println("<tr>");
//                out.println("<td> <span>" +fechaDet+"</span></td>");
//                out.println("<td> <span>" +dia+"</span></td>");
//                out.println("<td>    "+alimentacion+"</td>");
//                out.println("<td>"+trasnporte+"</td>");
//                out.println("<td>"+clienteRp+"</td>");
//                out.println("<td>"+observacionRp+"</td>");

                    out.println("<td style='font-size: smaller; width: 10%; min-width: 50px;'>" + fechaDet + "</td>");
                    out.println("<td style='font-size: smaller; width: 10%; min-width: 50px;'>" + dia + "</td>");
                    out.println("<td style='font-size: smaller; width: 10%; min-width: 50px;'>" + alimentacion + "</td>");
                    out.println("<td style='font-size: smaller; width: 10%; min-width: 50px;'>" + trasnporte + "</td>");
                    out.println("<td style='font-size: smaller; width: 10%; min-width: 50px;'>" + clienteRp + "</td>");
                    out.println("<td style='font-size: smaller; width: 20%; min-width: 100px;'>" + observacionRp + "</td>");
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

            out.println("<hr class=\"horizontal dark\">");

//                out.println("<h3>                                   Alimentación :  $ " +  alimentacionPDF+ "</h3>");
//              out.println("<h3>                                Movilización :    $  " +  transportePDF+ "</h3>");
//             out.println("<h3>                                Total reporte :   $ " +  total+ "</h3>");
//              out.println("<br>");   
            out.println("<h5>                                   Alimentación: $ " + alimentacionPDF + "</h5>");
            out.println("<h5>                                   Movilización : $ " + transportePDF + "</h5>");
            out.println("<h5 style = \"color:Red\">    <strong>                              Total reporte : $ " + total + " </strong></h5>");
            out.println("<br>");
            out.println("<h4>Revisado por ___________________  Elaborado por  : ______________________ </h4>");

//            out.println("<h1>Servlet reporteGastosMesPDF at " + request.getContextPath() + "</h1>");
            out.println("</div>");
            out.println("</div>");
            out.println("</div>");
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
