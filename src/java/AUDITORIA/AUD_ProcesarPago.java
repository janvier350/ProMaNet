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

// Marca como PAGADO todo lo PENDIENTE del mes en curso. Como
// AUD_ANTICIPOS solo contiene solicitudes de Auditoria (nadie mas
// puede insertar en esta tabla), no hace falta filtrar por
// departamento aqui.
@WebServlet(name = "AUD_ProcesarPago", urlPatterns = {"/AUD_ProcesarPago"})
public class AUD_ProcesarPago extends HttpServlet {

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

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE AUD_ANTICIPOS SET ESTADO = 'PAGADO' " +
                    "WHERE TRUNC(FECHA_SOLICITUD, 'MM') = TRUNC(SYSDATE, 'MM') AND ESTADO = 'PENDIENTE'")) {
                st.executeUpdate();
            }

            response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?msj=Anticipos marcados como pagados");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?error=Error al procesar el pago");
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
