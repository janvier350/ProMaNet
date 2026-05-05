/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package INVENTARIO;

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
 * @author Usuario
 */
@WebServlet(name = "INV_Insert_Ingreso_Suministro_Cab", urlPatterns = {"/INV_Insert_Ingreso_Suministro_Cab"})
public class INV_Insert_Ingreso_Suministro_Cab extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(true);
        String usuario = (String) session.getAttribute("usuario");
        String cargo = (String) session.getAttribute("cargo");
        String codigo = (String) session.getAttribute("cod");

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");
        String key = "";
        String url = new String("" + ip);

        String fechaCompra = request.getParameter("fechaCompra");
        String fechaPedido = request.getParameter("fechaPedido");
        String fechaRecibido = request.getParameter("fechaRecibido");
        String idProveedor = request.getParameter("idProveedor");
        String numero_factura = request.getParameter("numero_factura");

        String estado = "A";

        out.println(fechaCompra);
        out.println(fechaPedido);
        out.println(fechaRecibido);
        out.println(idProveedor);
        out.println(numero_factura);
        out.println(codigo);

        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("../sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("../sesionExpirada.jsp");
            return;
        }
        if (cargo.equals("ADMINISTRADOR") || cargo.equals("ADMINISTRACION") || cargo.equals("CONTRALOR")|| cargo.equals("JEFE")) {
        } else {
            response.sendRedirect("../sesionInvalida.jsp");
            return;
        }
        String ID_SUMINISTRO_INGRESO_CAB = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(ID_SUMINISTRO_INGRESO_CAB),0)+1 secuencia from INV_SUMINISTRO_INGRESO_CAB";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                ID_SUMINISTRO_INGRESO_CAB = rs.getString(1);
              
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

        String insert_INGRESO_SUMINISTRO_CAB = "INSERT INTO INV_SUMINISTRO_INGRESO_CAB  (ID_SUMINISTRO_INGRESO_CAB, ID_USUARIO, FECHA_COMPRA,FECHA_PEDIDO, FECHA_RECIBIDO, ESTADO, ID_INV_PROVEEDOR, NUMERO_FACTURA) "
                + "VALUES (?,?,TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?,?,?)";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(insert_INGRESO_SUMINISTRO_CAB);

            st.setString(1, ID_SUMINISTRO_INGRESO_CAB);
            st.setString(2, codigo);
            st.setString(3, fechaCompra);
            st.setString(4, fechaPedido);
            st.setString(5, fechaRecibido);
            st.setString(6, estado);
            st.setString(7, idProveedor);
            st.setString(8, numero_factura);
            out.println(insert_INGRESO_SUMINISTRO_CAB);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("unidad Insertado Correctamente!!");
                response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro_Detalle.jsp?ID_SUMINISTRO_INGRESO_CAB=" + ID_SUMINISTRO_INGRESO_CAB);
//                            response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp?ID_SUMINISTRO_INGRESO_CAB=" + ID_SUMINISTRO_INGRESO_CAB);
//   response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro_Detalle.jsp?ID_SUMINISTRO_INGRESO_CAB=" + ID_SUMINISTRO_INGRESO_CAB);

            } else {
                response.getWriter().println("Error al insertar la ingreso.");
            }
        } catch (Exception e) {
            e.printStackTrace();
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
