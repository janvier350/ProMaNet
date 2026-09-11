/*
 * Actualizar una fecha de corte de anticipos existente.
 *
 * La pantalla anterior solo permitia INSERT (ADM_Asignar_Fecha_Corte_
 * Anticipos.jsp) -- si alguien se equivocaba en la fecha, no habia
 * forma de corregirla desde la UI y tocaba hacerlo por SQL. Este
 * servlet cubre esa brecha con el mismo control de acceso por permiso
 * (CONTROL_GESTIONAR, igual que el insert) y la misma validacion "una
 * sola fecha activa por mes" (excluyendo a si misma para no chocar con
 * su propio registro al editar dentro del mismo mes).
 */
package CONTROL;

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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "CTRL_Update_Fecha_Corte_Anticipo", urlPatterns = {"/CTRL_Update_Fecha_Corte_Anticipo"})
public class CTRL_Update_Fecha_Corte_Anticipo extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(true);
        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");
        String url = "" + ip;

        String idFechaCorte = request.getParameter("idFechaCorte");
        String corte = request.getParameter("corte");

        if (session.getAttribute("usuario") == null || session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        if (idFechaCorte == null || idFechaCorte.trim().isEmpty()
                || corte == null || corte.trim().isEmpty()) {
            response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp?mensaje=Datos incompletos");
            return;
        }

        Connection cn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            cn.setAutoCommit(false);

            // Validar que no exista OTRA fecha activa en el mismo mes/año
            // que la nueva -- se excluye a si misma (id distinto) para
            // permitir editar dentro del mismo mes sin conflicto.
            String sqlVerificarMes = "SELECT COUNT(*) FROM CTRL_FECHA_CORTE_ANTICIPO " +
                    "WHERE TO_CHAR(FECHA_CORTE, 'YYYY-MM') = TO_CHAR(TO_DATE(?, 'YYYY-MM-DD'), 'YYYY-MM') " +
                    "AND ESTADO = 'A' AND ID_FECHA_CORTE <> ?";
            st = cn.prepareStatement(sqlVerificarMes);
            st.setString(1, corte);
            st.setString(2, idFechaCorte);
            rs = st.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                cn.rollback();
                response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp?mensaje=Ya existe otra fecha de corte activa para ese mes.");
                return;
            }
            rs.close();
            st.close();

            String sqlUpdate = "UPDATE CTRL_FECHA_CORTE_ANTICIPO " +
                    "SET FECHA_CORTE = TO_DATE(?, 'YYYY-MM-DD') " +
                    "WHERE ID_FECHA_CORTE = ?";
            st = cn.prepareStatement(sqlUpdate);
            st.setString(1, corte);
            st.setString(2, idFechaCorte);
            int rows = st.executeUpdate();

            if (rows > 0) {
                cn.commit();
                try (PrintWriter out = response.getWriter()) {
                    out.println("<!DOCTYPE html><html><head><title>Procesando...</title></head><body>");
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Fecha de corte actualizada correctamente.');");
                    out.println("window.location.href = '../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp';");
                    out.println("</script></body></html>");
                }
            } else {
                cn.rollback();
                response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp?mensaje=No se encontro la fecha de corte a actualizar.");
            }
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            response.sendRedirect("../ProMaNet/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp?mensaje=Error al actualizar: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (st != null) st.close();
                if (cn != null) cn.close();
            } catch (SQLException e) { e.printStackTrace(); }
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
}
