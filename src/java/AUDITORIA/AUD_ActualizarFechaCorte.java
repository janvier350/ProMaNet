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

// Actualiza una fecha de corte de anticipos de Auditoria existente
// (mismo patron que AUD_InsertarFechaCorte, mismo permiso, misma
// validacion "una sola fecha activa por mes" excluyendose a si misma
// para poder editar dentro del mismo mes sin chocar con su propio
// registro).
@WebServlet(name = "AUD_ActualizarFechaCorte", urlPatterns = {"/AUD_ActualizarFechaCorte"})
public class AUD_ActualizarFechaCorte extends HttpServlet {

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

        String idFechaCorte = request.getParameter("idFechaCorte");
        String corte = request.getParameter("corte");
        if (idFechaCorte == null || idFechaCorte.trim().isEmpty()
                || corte == null || corte.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // Solo una fecha de corte activa por mes -- excluye a si misma
            // por ID para no chocar cuando se edita dentro del mismo mes.
            try (PreparedStatement stVerificar = cn.prepareStatement(
                    "SELECT COUNT(*) FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE TO_CHAR(FECHA_CORTE, 'YYYY-MM') = TO_CHAR(TO_DATE(?, 'YYYY-MM-DD'), 'YYYY-MM') " +
                    "AND ESTADO = 'A' AND ID_FECHA_CORTE <> ?")) {
                stVerificar.setString(1, corte);
                stVerificar.setString(2, idFechaCorte);
                try (ResultSet rsVerificar = stVerificar.executeQuery()) {
                    if (rsVerificar.next() && rsVerificar.getInt(1) > 0) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ya existe otra fecha de corte activa para ese mes");
                        return;
                    }
                }
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE AUD_FECHA_CORTE_ANTICIPO SET FECHA_CORTE = TO_DATE(?, 'YYYY-MM-DD') " +
                    "WHERE ID_FECHA_CORTE = ?")) {
                st.setString(1, corte);
                st.setString(2, idFechaCorte);
                int rows = st.executeUpdate();
                if (rows == 0) {
                    cn.rollback();
                    response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=No se encontro la fecha de corte a actualizar");
                    return;
                }
            }

            cn.commit();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?msj=Fecha de corte actualizada correctamente");
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Error al actualizar la fecha de corte");
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
