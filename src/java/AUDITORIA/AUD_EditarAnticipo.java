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

// Editar el monto de una solicitud PENDIENTE de Anticipos Auditoria.
// Pueden hacerlo:
//  - el gestor (ANTICIPOS_AUD_GESTIONAR), sobre cualquier solicitud;
//  - el propio ejecutivo (ANTICIPOS_AUD_ACCESO), solo sobre SUS solicitudes.
// En ambos casos aplican las mismas reglas: plazo vigente, anticipo no
// pagado y tope del 50% del sueldo registrado en la solicitud.
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
        boolean esGestor = PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR");
        boolean esEjecutivo = PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO");
        if (!esGestor && !esEjecutivo) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
        int miId = -1;
        try { miId = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        // A que pantalla volver: la del ejecutivo si edito desde "Mis
        // solicitudes"; si no, el panel de gestion.
        String volver = request.getContextPath() + (
                "mis".equals(request.getParameter("volver")) && esEjecutivo
                ? "/Auditoria/AUD_SolicitarAnticipo.jsp"
                : (esGestor ? "/Auditoria/AUD_Dashboard.jsp" : "/Auditoria/AUD_SolicitarAnticipo.jsp"));

        String idAnticipo = request.getParameter("idAnticipo");
        double nuevoMonto;
        try {
            nuevoMonto = Double.parseDouble(request.getParameter("anticipo"));
        } catch (Exception e) {
            response.sendRedirect(volver + "?error=Monto invalido");
            return;
        }
        if (idAnticipo == null || nuevoMonto <= 0) {
            response.sendRedirect(volver + "?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            // Plazo vigente. El dia de corte SI cuenta como habil -- se
            // compara solo por fecha (sin hora), igual que en el resto del
            // modulo.
            try (PreparedStatement stCorte = cn.prepareStatement(
                    "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1");
                 ResultSet rsCorte = stCorte.executeQuery()) {
                if (rsCorte.next()) {
                    java.sql.Date fechaCorte = rsCorte.getDate(1);
                    if (fechaCorte != null) {
                        java.util.Calendar cH = java.util.Calendar.getInstance();
                        cH.set(java.util.Calendar.HOUR_OF_DAY, 0);
                        cH.set(java.util.Calendar.MINUTE, 0);
                        cH.set(java.util.Calendar.SECOND, 0);
                        cH.set(java.util.Calendar.MILLISECOND, 0);
                        if (cH.getTime().after(fechaCorte)) {
                            response.sendRedirect(volver + "?error=El plazo para editar anticipos ya vencio");
                            return;
                        }
                    }
                }
            }

            // Un anticipo PAGADO no se puede editar -- la UI oculta el
            // boton pero esto bloquea intentos directos por URL.
            double sueldoActual = 0;
            int duenio = -1;
            try (PreparedStatement stCheck = cn.prepareStatement(
                    "SELECT SUELDO, ESTADO, ID_USUARIO FROM AUD_ANTICIPOS WHERE ID_AUD_ANTICIPO = ?")) {
                stCheck.setString(1, idAnticipo);
                try (ResultSet rsCheck = stCheck.executeQuery()) {
                    // Un ejecutivo (no gestor) solo puede tocar sus propias
                    // solicitudes; las ajenas se tratan como inexistentes.
                    if (!rsCheck.next() || (!esGestor && rsCheck.getInt(3) != miId)) {
                        response.sendRedirect(volver + "?error=Solicitud no encontrada");
                        return;
                    }
                    duenio = rsCheck.getInt(3);
                    sueldoActual = rsCheck.getDouble(1);
                    if ("PAGADO".equalsIgnoreCase(rsCheck.getString(2))) {
                        response.sendRedirect(volver + "?error=No se puede editar: el anticipo ya fue pagado");
                        return;
                    }
                }
            }

            double limite = sueldoActual * 0.50;
            if (nuevoMonto > limite) {
                response.sendRedirect(volver + "?error=El monto excede el 50% del sueldo ($" + limite + ")");
                return;
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE AUD_ANTICIPOS SET ANTICIPO = ? WHERE ID_AUD_ANTICIPO = ?")) {
                st.setDouble(1, nuevoMonto);
                st.setString(2, idAnticipo);
                st.executeUpdate();
            }

            COMUN.LogActividad.registrar(request, "ANTICIPOS", "EDITAR",
                    "Edito el monto de la solicitud #" + idAnticipo + " (usuario #" + duenio + ") a $"
                    + String.format(java.util.Locale.US, "%.2f", nuevoMonto));

            response.sendRedirect(volver + "?msj=Anticipo actualizado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(volver + "?error=Error al actualizar");
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
