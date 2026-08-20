package VACACIONES;

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

// Elimina un ajuste historico de vacaciones cargado por error. Solo
// borra registros de VAC_HISTORICO_AJUSTE (consumo previo a este
// modulo) -- nunca solicitudes reales del flujo (VAC_SOLICITUD).
@WebServlet(name = "VAC_EliminarAjusteHistorico", urlPatterns = {"/VAC_EliminarAjusteHistorico"})
public class VAC_EliminarAjusteHistorico extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idEmpleado = request.getParameter("idEmpleado");
        String idAjuste = request.getParameter("idAjuste");

        if (idEmpleado == null || idAjuste == null || idAjuste.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement st = cn.prepareStatement(
                    "DELETE FROM VAC_HISTORICO_AJUSTE WHERE ID_AJUSTE = ? AND ID_USUARIO = ?")) {
                st.setString(1, idAjuste);
                st.setString(2, idEmpleado);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&msj=Ajuste eliminado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Error al eliminar el ajuste");
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
