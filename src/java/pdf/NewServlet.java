/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pdf;

import com.itextpdf.text.Document;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
//import com.lowagie.text.Document;
//import com.lowagie.text.Paragraph;
//import com.lowagie.text.pdf.PdfWriter;
import java.io.IOException;
import java.io.PrintWriter;
//import javax.servlet.ServletException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import static java.lang.System.out;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.*;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Backup
 */
@WebServlet(name = "NewServlet", urlPatterns = {"/NewServlet"})
public class NewServlet extends HttpServlet {

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
//        response.setContentType("application/pdf");
        response.setContentType("text/html;charset=UTF-8");
        String user = "RRHH";
        String pass = "__CLAVE_RRHH_NUBE__";
        String url = "jdbc:oracle:thin:@promanet_low?TNS_ADMIN=/opt/promanet/wallet";

        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Generar PDF itext-2.1.7</title>");
            out.println("</head>");

            out.println("<body>");
//            out.println("<h1>Lista de Ejecutivos " + request.getContextPath();+ "</h1>");
            out.println("<h1>Lista de Ejecutivos </h1>");
            out.println("<table>");
            out.println("<thead>");
            out.println("<tr>");
            out.println("<th> ID </th>");
            out.println("<th> EJECUTIVO </th>");
            out.println("<th>E-MAIL </th>");
            out.println("<th>COMPANIA</th>");
            out.println("<th> DEPARTAMENTO </th>");
            out.println("<th> DESCRIPCION </th>");
            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");
            try {
//                      Document document = new Document();
//                      PdfWriter.getInstance(document, out);
//                      document.open();
//                      
//                      document.add(new Paragraph("LISTA DE USUARIOS"));
//                      document.add(new Paragraph("  "));
//                      document.add(new Paragraph("No.   EJECUTIVO   CORREO  COMPANIA  DEPARTAMENTO   DESCRIPCION"));
//                      
                String id, ejecutivo, email, compania, departamento, descripcion = "";
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sqlUsuario = "select a.idusuario, a.nombre | | a.apellidos, a.email,  b.compania,c.departamento, c.descripcion\n"
                        + "from usuario a, compania b, adm_departamento c\n"
                        + "where a.estado = 'a' \n"
                        + "and a.idcompania = b.idcompania \n"
                        + "and a.id_adm_departamento = c.id_departamento order by 2";
                PreparedStatement st = cn.prepareStatement(sqlUsuario);
                ResultSet rs = st.executeQuery();
                while (rs.next()) {
                    id = rs.getString(1);
                    ejecutivo = rs.getString(2);
                    email = rs.getString(3);
                    compania = rs.getString(4);
                    departamento = rs.getString(5);
                    descripcion = rs.getString(6);
                    out.println("<tr>");
                    out.println("<td>" + id + "</td>");
                    out.println("<td>" + ejecutivo + "</td>");
                    out.println("<td>" + email + "</td>");
                    out.println("<td>" + compania + "</td>");
                    out.println("<td>" + departamento + "</td>");
                    out.println("<td>" + descripcion + "</td>");
                    out.println("</tr>");
//                out.println(nombres);
//                out.print("</td>");
//                  document.add(new Paragraph(rs.getInt(1)+"     "+rs.getString(2)+"     "+rs.getString(3)+"     "+rs.getString(4)+"     "+rs.getString(5)+"     "+rs.getString(6)));       
                }
                rs.close();
                st.close();
                cn.close();
//            document.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            out.println("</tbody>");
            out.println("</table>");
            out.println("</body>");
            out.println("</html>");

        }

//                  termina el 1 try
//             finally{}     
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
