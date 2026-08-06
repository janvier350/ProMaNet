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
                    "UPDATE USUARIO SET SUELDO = ? WHERE IDUSUARIO = ? AND ID_ADM_DEPARTAMENTO = " +
                    "(SELECT ID_DEPARTAMENTO FROM ADM_DEPARTAMENTO WHERE UPPER(DEPARTAMENTO) = 'AUDITORÍA')")) {
                st.setDouble(1, sueldo);
                st.setString(2, idEjecutivo);
                int filas = st.executeUpdate();
                if (filas == 0) {
                    response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ese ejecutivo no pertenece a Auditoria");
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
