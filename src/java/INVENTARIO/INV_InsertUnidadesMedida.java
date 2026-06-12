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

import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

/**
 *
 * @author Usuario
 */
@WebServlet(name = "INV_InsertUnidadesMedida", urlPatterns = {"/INV_InsertUnidadesMedida"})
public class INV_InsertUnidadesMedida extends HttpServlet {

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

        String unidad = request.getParameter("unidad");
        String descripcion = request.getParameter("descripcion");

        String estado = "A";

        if (session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        } else if (session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (cargo.equals("JEFE") || cargo.equals("ASISTENTE")) {
        } else {
            response.sendRedirect("sesionInvalida.jsp");
        }

        String idUnidad = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement("SELECT COUNT(*) FROM INV_UNIDAD_MEDIDA WHERE UPPER(UNIDAD) = UPPER(?) AND ESTADO = 'A'");
            st.setString(1, unidad);
            rs = st.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp?error=unidad_dup");
                return;
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

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(ID_UNIDAD_MEDIDA),0)+1 secuencia from INV_UNIDAD_MEDIDA";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                idUnidad = rs.getString(1);
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

        String insertUnidadesMedida = "INSERT INTO INV_UNIDAD_MEDIDA  (ID_UNIDAD_MEDIDA, UNIDAD, DESCRIPCION, ESTADO) "
                + "VALUES (?, ?,?, 'A')";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(insertUnidadesMedida);

            st.setString(1, idUnidad);
            st.setString(2, unidad);
            st.setString(3, descripcion);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("unidad Insertado Correctamente!!");
            } else {
                response.getWriter().println("Error al insertar la unidad.");
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

        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_InsertUnidadesMedida</title>");
            out.println("</head>");
            out.println("<body>");
            response.sendRedirect("../ProMaNet/Inventario/INV_Ingreso_Suministro2.jsp");
//            out.println("<h1>Servlet INV_InsertUnidadesMedida at " + request.getContextPath() + "</h1>");
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
