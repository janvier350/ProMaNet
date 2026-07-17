/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import static java.lang.System.console;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.Arrays;
//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.sql.*;
//import jdk.vm.ci.amd64.AMD64;
//import sun.rmi.server.Dispatcher;

/**
 *
 * @author Usuario
 */
@WebServlet(name = "FormulariosServlet", urlPatterns = {"/FormulariosServlet"})
public class FormulariosServlet extends HttpServlet {

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

        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "AGENDA_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        PrintWriter out = response.getWriter();

        String idRegistroAgenda = request.getParameter("idRegistroAgenda");

        String[] colega = request.getParameterValues("lista_input");
        String departamento = request.getParameter("cbm_anio");
        String nombres = "nombre1";
        String apellidos = "Apellidos1";
        String estado = "A";

        String user = "RRHH";
        String pass = "__CLAVE_RRHH_NUBE__";
        String url = "jdbc:oracle:thin:@promanet_low?TNS_ADMIN=/opt/promanet/wallet";
        out.println("Lo que quieras escribir");
        try {
            /* TODO output your page here. You may use following sample code. */
            // log(" "+colega.length);
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet FormulariosServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet FormulariosServlet at " + request.getContextPath() + "</h1>");

            out.println("<p> Cabecera de Agenda:   " + idRegistroAgenda + "</p>");

            int idAgendaDetalle = 0;
            for (int i = 0; i < colega.length; i++) {
//                    out.print("<li>" +colega[i]+"</li>");

                try {

                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);
                    String sql = "select nvl(max(ID_ADM_DET_AGENDA),0)+1 secuencia from ADM_DET_AGENDA";
                    PreparedStatement st = cn.prepareStatement(sql);
                    ResultSet rs = st.executeQuery();
                    while (rs.next()) {
                        idAgendaDetalle = rs.getInt(1);      //optener la seceucia de detalle
                        out.print("<li> detalle agenda : " + idAgendaDetalle + colega[i] + "</li>");
                    }
                    rs.close();
                    st.close();
                    cn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }

//          buscar nombres y apellidos de colegas y departamento
                String colegaNomApe = "select apellidos, nombre from usuario where  idusuario = " + colega[i] + "";

                try {
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn3 = DriverManager.getConnection(url, user, pass);
                    PreparedStatement st3 = cn3.prepareStatement(colegaNomApe);
                    ResultSet rs3 = st3.executeQuery();
                    while (rs3.next()) {
                        nombres = rs3.getString(2);
                        apellidos = rs3.getString(1);

                    }
                    rs3.close();
                    st3.close();
                    cn3.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }

                String Departamento = "select departamento from adm_departamento where id_departamento  = " + departamento + "  ";

                try {
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn3 = DriverManager.getConnection(url, user, pass);
                    PreparedStatement st3 = cn3.prepareStatement(Departamento);
                    ResultSet rs3 = st3.executeQuery();
                    while (rs3.next()) {

                        departamento = rs3.getString(1);

                    }
                    rs3.close();
                    st3.close();
                    cn3.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }

                //insertar en detalle de agenda
                String insertarDetalleAgenda = "insert into ADM_DET_AGENDA values"
                        + "(" + idAgendaDetalle + "," + idRegistroAgenda + "," + colega[i] + ",'" + estado + "','" + apellidos + "','" + nombres + "','" + departamento + "')";
                out.print("<li>" + insertarDetalleAgenda + "</li>");
                try {
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn2 = DriverManager.getConnection(url, user, pass);
                    PreparedStatement st2 = cn2.prepareStatement(insertarDetalleAgenda);
                    ResultSet rs2 = st2.executeQuery();
                    cn2.commit();
                    rs2.close();
                    st2.close();
                    cn2.close();

                    out.print(" alert('terminado');");
                } catch (Exception e) {
                    e.printStackTrace();
                }

            }
            response.sendRedirect("Agenda.jsp");

            out.println("</body>");
            out.println("</html>");
        } finally {
            out.close();

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
