package Servlets;

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
import java.text.SimpleDateFormat;
import java.util.Date;
import java.sql.Connection;
import java.sql.DriverManager;
  import java.sql.ResultSet;

@WebServlet(name = "InsertNuevoEquipo", urlPatterns = {"/InsertNuevoEquipo"})
public class InsertNuevoEquipo extends HttpServlet {

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
         String departamentoSesion = (String) session.getAttribute("departamento");

             
        url = new String(""+ip);
        
            String sql ="";
       
         int secuenciaCab =0;
        

        if (session.getAttribute("usuario") == null || session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
            response.sendRedirect("../sesionInvalida.jsp");
            return;
        }
        //validar departamento: solo TECNOLOGIA registra equipos nuevos
        // (SUPERADMIN_ACCESO_TOTAL se salta esta restriccion tambien).
        boolean esSuperAdmin = COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL");
        if (!esSuperAdmin && (departamentoSesion == null || !departamentoSesion.equals("TECNOLOGÍA"))) {
            response.sendRedirect("../sesionInvalida.jsp");
            return;
        }

        // Leer y validar parámetros
        String fechaini = request.getParameter("fecha");
        String empresa = request.getParameter("empresa");
        String ubicacionoficina = request.getParameter("ubicacionoficina");
        String departamento = request.getParameter("departamento");
        String marca = request.getParameter("marca");
        String modelo = request.getParameter("modelo");
        String serial = request.getParameter("serial");
        String procesador = request.getParameter("procesador");
        String hdd = request.getParameter("hdd");
        String ram = request.getParameter("ram");
        String pantalla = request.getParameter("pantalla");
        String observaciones = request.getParameter("observacion");
        
        String dispositivo = request.getParameter("dispositivo");
        
        String id_currier = request.getParameter("id_currier");
        
        out.println(fechaini);
          out.println(ubicacionoficina);
            out.println(cargo);
        // Validar si el dispositivo es nulo antes de usarlo
        String estado = "I"; // Estado predeterminado en caso de ser nulo
        if (dispositivo != null && dispositivo.equals("Laptop")) {
            estado = "D";
        }

        String idEquipo = "";
        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            String sqlSecuencia = "select nvl(max(IDINVEQUIPO),0)+1 secuencia from INV_EQUIPOS";
            st = cn.prepareStatement(sqlSecuencia);
            rs = st.executeQuery();
            if (rs.next()) {
                idEquipo = rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (st != null) st.close();
                if (cn != null) cn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        String sql2 = "INSERT INTO INV_EQUIPOS (IDINVEQUIPO, FECHACOMPRA, UBICACIONOFICINA, DEPARTAMENTO, MARCA, MODELO, SERIAL, PROCESADOR, HDD, RAM, PANTALLA, OBSERVACIONES, ESTADO, EMPRESA, DISPOSITIVO, ESTADO_AI, FICHERO,ID_CURRIER) "
                    + "VALUES (?, to_date(?, 'YYYY-MM-DD HH24:MI:SS'), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'A', ?, ?)";

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            st = cn.prepareStatement(sql2);

            st.setString(1, idEquipo);
            st.setString(2, fechaini + " " + new SimpleDateFormat("HH:mm:ss").format(new Date()));
            st.setString(3, ubicacionoficina);
            st.setString(4, departamento);
            st.setString(5, marca);
            st.setString(6, modelo);
            st.setString(7, serial);
            st.setString(8, procesador);
            st.setString(9, hdd);
            st.setString(10, ram);
            st.setString(11, pantalla);
            st.setString(12, observaciones);
            st.setString(13, estado);
            st.setString(14, empresa);
            st.setString(15, dispositivo);
            st.setString(16, ""); // Assuming key is empty for now
            st.setString(17,id_currier);

            int rowsAffected = st.executeUpdate();
            cn.commit();

            if (rowsAffected > 0) {
                response.getWriter().println("Equipo Insertado Correctamente!!");
            } else {
                response.getWriter().println("Error al insertar el equipo.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (st != null) st.close();
                if (cn != null) cn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet InsertNuevoEquipo</title>");            
            out.println("</head>");
            out.println("<body>");
//            out.println("<h1>Servlet InsertNuevoEquipo at " + request.getContextPath() + "</h1>");
          
             out.println("<h1> " + fechaini + "</h1>");
              out.println("<h1> " + ubicacionoficina + "</h1>");
             response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
