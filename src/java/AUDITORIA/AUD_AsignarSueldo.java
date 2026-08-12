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

// Asignar sueldo de un ejecutivo de Auditoria (base para el tope de
// anticipo). Restringido a ese departamento: el UPDATE solo afecta
// filas cuyo ID_ADM_DEPARTAMENTO sea Auditoria, para que el gestor de
// este modulo no pueda tocar el sueldo de gente de otros departamentos
// aunque conozca su IDUSUARIO.
@WebServlet(name = "AUD_AsignarSueldo", urlPatterns = {"/AUD_AsignarSueldo"})
public class AUD_AsignarSueldo extends HttpServlet {

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

        String idEjecutivo = request.getParameter("idEjecutivo");
        double sueldo;
        try {
            sueldo = Double.parseDouble(request.getParameter("sueldo"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Sueldo invalido");
            return;
        }
        if (idEjecutivo == null || sueldo < 0) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE USUARIO u SET SUELDO = ? WHERE IDUSUARIO = ? " +
                    "AND (" +
                    "  EXISTS (SELECT 1 FROM ADM_DEPARTAMENTO d JOIN APP_DEPARTAMENTO_PERMISO dp ON UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO) " +
                    "          JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO " +
                    "          WHERE d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO AND p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G') " +
                    "  OR EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO " +
                    "             WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up.TIPO = 'G' AND up.IDUSUARIO = u.IDUSUARIO) " +
                    ") " +
                    "AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up2 JOIN APP_PERMISO p2 ON p2.ID_PERMISO = up2.ID_PERMISO " +
                    "                WHERE p2.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up2.TIPO = 'D' AND up2.IDUSUARIO = u.IDUSUARIO)")) {
                st.setDouble(1, sueldo);
                st.setString(2, idEjecutivo);
                int filas = st.executeUpdate();
                if (filas == 0) {
                    response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ese ejecutivo no tiene acceso al modulo de Anticipos Auditoria");
                    return;
                }
            }

            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?msj=Sueldo actualizado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Error al actualizar el sueldo");
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
