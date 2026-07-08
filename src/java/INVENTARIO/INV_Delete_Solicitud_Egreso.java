package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

@WebServlet(name = "INV_Delete_Solicitud_Egreso", urlPatterns = {"/INV_Delete_Solicitud_Egreso"})
public class INV_Delete_Solicitud_Egreso extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        String cargo = (String) session.getAttribute("cargo");
        if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
                || cargo.equals("ASISTENTE")  || cargo.equals("PASANTE")
                || cargo.equals("CONTRALOR")  || cargo.equals("JEFE")
                || cargo.equals("ANALISTA"))) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String idDepartamento = (String) session.getAttribute("idDepartamento");
        String idCabParam = request.getParameter("idCab");

        if (idCabParam == null || idCabParam.replaceAll("[^0-9]", "").isEmpty()
                || idDepartamento == null || idDepartamento.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Historial_Solicitudes_Departamento.jsp");
            return;
        }
        int idCab = Integer.parseInt(idCabParam.replaceAll("[^0-9]", ""));

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip   = (String) session.getAttribute("ipDB");
        String url  = "" + ip;

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            cn.setAutoCommit(false);

            /* Verificar que la solicitud existe, es del mismo departamento y sigue pendiente */
            PreparedStatement stCheck = cn.prepareStatement(
                "SELECT ESTADO_SOLICITUD FROM INV_SUMINISTRO_EGRESO_CAB " +
                "WHERE ID_SUMINISTRO_EGRESO_CAB = ? AND ID_DEPARTAMENTO = ?");
            stCheck.setInt(1, idCab);
            stCheck.setInt(2, Integer.parseInt(idDepartamento.trim()));
            ResultSet rsCheck = stCheck.executeQuery();
            boolean esPendiente = rsCheck.next() && "PENDIENTE".equals(rsCheck.getString(1));
            rsCheck.close(); stCheck.close();

            if (!esPendiente) {
                cn.rollback(); cn.close();
                session.setAttribute("msg_error", "La solicitud no existe o ya fue despachada.");
                response.sendRedirect(request.getContextPath() + "/Inventario/INV_Historial_Solicitudes_Departamento.jsp");
                return;
            }

            PreparedStatement stDelDet = cn.prepareStatement(
                "DELETE FROM INV_SUMINISTRO_EGRESO_DET WHERE ID_SUMINISTRO_EGRESO_CAB = ?");
            stDelDet.setInt(1, idCab);
            stDelDet.executeUpdate();
            stDelDet.close();

            PreparedStatement stDelCab = cn.prepareStatement(
                "DELETE FROM INV_SUMINISTRO_EGRESO_CAB WHERE ID_SUMINISTRO_EGRESO_CAB = ?");
            stDelCab.setInt(1, idCab);
            stDelCab.executeUpdate();
            stDelCab.close();

            cn.commit();
            cn.close();

            session.setAttribute("msg_exito", "Solicitud #" + idCab + " eliminada correctamente.");
        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (cn != null) { cn.rollback(); cn.close(); } } catch (Exception e2) {}
            session.setAttribute("msg_error", "Error al eliminar la solicitud: " + ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Historial_Solicitudes_Departamento.jsp");
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
