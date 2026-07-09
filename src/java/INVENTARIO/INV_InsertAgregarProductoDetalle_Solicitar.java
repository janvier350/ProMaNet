/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package INVENTARIO;

import java.io.IOException;
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
@WebServlet(name = "INV_InsertAgregarProductoDetalle_Solicitar", urlPatterns = {"/INV_InsertAgregarProductoDetalle_Solicitar"})
public class INV_InsertAgregarProductoDetalle_Solicitar extends HttpServlet {

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

        String idSuministroIngresoCab = request.getParameter("idSuministroIngresoCab");
        String idProducto = request.getParameter("idProducto");
        String cantidad = request.getParameter("cantidad");

        String estado = "A";
        System.out.println(estado);

        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String id_suministro_ingreso_det = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(id_suministro_ingreso_det),0)+1 secuencia from INV_SUMINISTRO_INGRESO_DET";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                id_suministro_ingreso_det = rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        String sql2 = "INSERT INTO INV_SUMINISTRO_INGRESO_DET  (id_suministro_ingreso_det, ID_PRODUCTO, CANTIDAD, ID_SUMINISTRO_INGRESO_CAB) "
                + "VALUES (?, ?, ?,?)";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(sql2);

            st.setString(1, id_suministro_ingreso_det);
            st.setString(2, idProducto);
            st.setString(3, cantidad);
            st.setString(4, idSuministroIngresoCab);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                session.setAttribute("msg_exito", "Agregado a la lista correctamente.");
            } else {
                session.setAttribute("msg_error", "Error al insertar producto.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al insertar producto: " + e.getMessage());
        } finally {
            try {
                if (st != null) {
                    st.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("../ProMaNet/Inventario/INV_Solicitar_Suministro_Detalle.jsp?ID_SUMINISTRO_INGRESO_CAB=" + idSuministroIngresoCab);
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
