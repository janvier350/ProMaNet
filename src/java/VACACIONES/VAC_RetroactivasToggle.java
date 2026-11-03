package VACACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

// Abre o cierra la ventana para que los usuarios registren vacaciones ya
// gozadas. Lo opera Administracion/RRHH (VACACIONES_GESTIONAR) o quien
// mantiene la configuracion (VACACIONES_CONFIGURAR).
//   accion=ABRIR  + fechaLimite (hoy..hoy+30 dias) + motivo opcional
//   accion=CERRAR
// Abrir cierra primero cualquier ventana vigente: solo hay una a la vez.
@WebServlet(name = "VAC_RetroactivasToggle", urlPatterns = {"/VAC_RetroactivasToggle"})
public class VAC_RetroactivasToggle extends HttpServlet {

    private static final int MAX_DIAS_VENTANA = 30;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_GESTIONAR")
                && !PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
        String base = request.getContextPath() + "/Vacaciones/VAC_Dashboard.jsp";
        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        String accion = request.getParameter("accion");
        Integer idGrupo = null;
        try {
            String g = request.getParameter("idGrupo");
            if (g != null && !g.trim().isEmpty()) idGrupo = Integer.parseInt(g.trim());
        } catch (Exception e) {
            response.sendRedirect(base + "?error=" + enc("Grupo invalido"));
            return;
        }
        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            // La ventana es por grupo de gestion: solo para un grupo que el usuario gestiona.
            if (idGrupo == null || !VAC_Alcance.puedeSobreGrupo(session, cn, idGrupo)) {
                response.sendRedirect(base + "?error=" + enc("No gestionas ese grupo"));
                return;
            }

            if ("ABRIR".equals(accion)) {
                LocalDate limite;
                try {
                    limite = LocalDate.parse(request.getParameter("fechaLimite"));
                } catch (Exception e) {
                    response.sendRedirect(base + "?error=" + enc("Fecha limite invalida"));
                    return;
                }
                LocalDate hoy = LocalDate.now();
                if (limite.isBefore(hoy) || limite.isAfter(hoy.plusDays(MAX_DIAS_VENTANA))) {
                    response.sendRedirect(base + "?error=" + enc("La fecha limite debe estar entre hoy y " + MAX_DIAS_VENTANA + " dias"));
                    return;
                }
                String motivo = request.getParameter("motivo");
                if (motivo != null && motivo.length() > 300) motivo = motivo.substring(0, 300);

                cerrarVigentes(cn, idGestor, idGrupo);
                int idNuevo = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_VENTANA),0)+1 FROM VAC_RETRO_VENTANA");
                     ResultSet rs = st.executeQuery()) {
                    if (rs.next()) idNuevo = rs.getInt(1);
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO VAC_RETRO_VENTANA (ID_VENTANA, FECHA_APERTURA, FECHA_LIMITE, ACTIVA, MOTIVO, ID_USUARIO_ABRE, ID_GRUPO) " +
                        "VALUES (?, SYSDATE, TO_DATE(?, 'YYYY-MM-DD'), 'S', ?, ?, ?)")) {
                    st.setInt(1, idNuevo);
                    st.setString(2, limite.toString());
                    if (motivo != null && !motivo.trim().isEmpty()) st.setString(3, motivo.trim()); else st.setNull(3, java.sql.Types.VARCHAR);
                    st.setInt(4, idGestor);
                    st.setInt(5, idGrupo);
                    st.executeUpdate();
                }
                cn.commit();
                COMUN.LogActividad.registrar(request, "VACACIONES", "EDITAR",
                        "Habilito el registro de vacaciones ya gozadas (grupo #" + idGrupo + ") hasta " + limite);
                response.sendRedirect(base + "?msj=" + enc("Registro de vacaciones pasadas habilitado hasta " + limite));
            } else if ("CERRAR".equals(accion)) {
                int n = cerrarVigentes(cn, idGestor, idGrupo);
                cn.commit();
                COMUN.LogActividad.registrar(request, "VACACIONES", "EDITAR",
                        "Cerro el registro de vacaciones ya gozadas (grupo #" + idGrupo + ", modo normal)");
                response.sendRedirect(base + "?msj=" + enc(n > 0 ? "Registro de vacaciones pasadas deshabilitado: modo normal" : "No habia ninguna ventana abierta"));
            } else {
                response.sendRedirect(base + "?error=" + enc("Accion invalida"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(base + "?error=" + enc("Error al actualizar la configuracion (verifica que el script 040 este ejecutado)"));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    // Cierra las ventanas abiertas de ESE grupo (y las antiguas sin grupo, que valian para todos).
    private static int cerrarVigentes(Connection cn, int idGestor, int idGrupo) throws Exception {
        try (PreparedStatement st = cn.prepareStatement(
                "UPDATE VAC_RETRO_VENTANA SET ACTIVA = 'N', FECHA_CIERRE = SYSDATE, ID_USUARIO_CIERRE = ? " +
                "WHERE ACTIVA = 'S' AND (ID_GRUPO = ? OR ID_GRUPO IS NULL)")) {
            st.setInt(1, idGestor);
            st.setInt(2, idGrupo);
            return st.executeUpdate();
        }
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
