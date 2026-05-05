/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Servlets;

import jakarta.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;
//import javax.servlet.ServletException;
import static Servlets.Sql.getFila;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author jquinde
 */
@WebServlet(name = "AddPhotoServlet", urlPatterns = {"/addphoto"})
public class AddPhotoServlet extends HttpServlet {

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
        PrintWriter out = response.getWriter();
        try {
            String fechaini = request.getParameter("fecha");
            String ubicacionoficina = request.getParameter("ubicacion");
            String departamento = request.getParameter("departamento");
            String marca = request.getParameter("marca");
            String modelo = request.getParameter("modelo");
            String serial = request.getParameter("serial");
            String procesador = request.getParameter("procesador");
            String hdd = request.getParameter("hdd");
            String ram = request.getParameter("ram");
            String pantalla = request.getParameter("pantalla");
            String observaciones = request.getParameter("observaciones");
            String empresa = request.getParameter("empresa");
            String dispositivo = request.getParameter("dispositivo");
            
            var idEquipo ="";
            
            String[] idEqui = Sql.getFila("select * from INV_EQUIPOS");
            if(idEqui == null){
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Error</title>");            
                out.println("</head>");
                out.println("<body>");
                out.println("<h1>error </h1>");
                out.println("</body>");
                out.println("</html>");
            }else {
                idEquipo= idEqui[0];
            }
            
            String esta ="";
            if(dispositivo.equals("Laptop")){
                esta ="D";
            }else{
                esta ="I";
            }
//            String sql2="insert into INV_EQUIPOS (IDINVEQUIPO, FECHACOMPRA,UBICACIONOFICINA,DEPARTAMENTO,MARCA,MODELO,SERIAL,PROCESADOR,HDD,RAM, PANTALLA,OBSERVACIONES,ESTADO,EMPRESA, DISPOSITIVO,ESTADO_AI,FICHERO) "
//                    + "VALUES ("+idEquipo
//                    +", to_date('"+fechaini+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'),"
//                    +"'"+ubicacionoficina+"','"+departamento+"','"+marca+"','"+modelo+"','"+serial+"','"+procesador+"','"+hdd+"','"+ram+"','"+pantalla+"','"+observaciones+"','"+esta+"','"+empresa+"','"+dispositivo+"','A','')";
//            String INV_EQUIPOS = Sql.ejecuta(""+sql2);
            
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AddPhotoServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddPhotoServlet at "+idEquipo+"</h1>");
            out.println("</body>");
            out.println("</html>");
        } catch(Exception ex) {
            out.println( "Error --> " + ex.getMessage());
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
