package AUDITORIA;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "AUD_EditarAnticipo", urlPatterns = {"/AUD_EditarAnticipo"})
public class AUD_EditarAnticipo extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idAnticipo = request.getParameter("idAnticipo");
        double nuevoMonto;
        try {
            nuevoMonto = Double.parseDouble(request.getParameter("anticipo"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Monto invalido");
            return;
        }
        if (idAnticipo == null || nuevoMonto <= 0) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            // Plazo vigente.
            try (PreparedStatement stCorte = cn.prepareStatement(
                    "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1");
                 ResultSet rsCorte = stCorte.executeQuery()) {
                if (rsCorte.next()) {
                    java.sql.Date fechaCorte = rsCorte.getDate(1);
                    if (fechaCorte != null && new java.util.Date().after(fechaCorte)) {
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=El plazo para editar anticipos ya vencio");
                        return;
                    }
                }
            }

            double sueldoActual = 0;
            try (PreparedStatement stCheck = cn.prepareStatement(
                    "SELECT SUELDO FROM AUD_ANTICIPOS WHERE ID_AUD_ANTICIPO = ?")) {
                stCheck.setString(1, idAnticipo);
                try (ResultSet rsCheck = stCheck.executeQuery()) {
                    if (!rsCheck.next()) {
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Solicitud no encontrada");
                        return;
                    }
                    sueldoActual = rsCheck.getDouble(1);
                }
            }

            double limite = sueldoActual * 0.50;
            if (nuevoMonto > limite) {
                response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=El monto excede el 50% del sueldo ($" + limite + ")");
                return;
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE AUD_ANTICIPOS SET ANTICIPO = ? WHERE ID_AUD_ANTICIPO = ?")) {
                st.setDouble(1, nuevoMonto);
                st.setString(2, idAnticipo);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?msj=Anticipo actualizado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Error al actualizar");
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
