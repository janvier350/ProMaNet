package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

// Registra un mantenimiento de un equipo (limpieza y revision). Lo pueden hacer los usuarios con
// INVENTARIO_MANTENIMIENTO_GESTIONAR (Tecnologia, incluidos los pasantes).
// Si llega "periodicidad" (3,4,6,12) se fija para ese equipo; "auto" la deja automatica.
@WebServlet(name = "INV_RegistrarMantenimiento", urlPatterns = {"/INV_RegistrarMantenimiento"})
public class INV_RegistrarMantenimiento extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String base = request.getContextPath() + "/Inventario/INV_Mantenimientos.jsp";

        int idEquipo;
        LocalDate fecha;
        try {
            idEquipo = Integer.parseInt(request.getParameter("idEquipo").trim());
            fecha = LocalDate.parse(request.getParameter("fecha").trim());
        } catch (Exception e) {
            response.sendRedirect(base + "?error=" + enc("Datos invalidos"));
            return;
        }
        if (fecha.isAfter(LocalDate.now())) {
            response.sendRedirect(base + "?error=" + enc("La fecha del mantenimiento no puede ser futura"));
            return;
        }
        if (fecha.isBefore(LocalDate.now().minusYears(5))) {
            response.sendRedirect(base + "?error=" + enc("La fecha del mantenimiento es demasiado antigua"));
            return;
        }
        String tipo = "CORRECTIVO".equals(request.getParameter("tipo")) ? "CORRECTIVO" : "PREVENTIVO";
        String[] acts = request.getParameterValues("actividades");
        String actividades = acts == null ? null : String.join(", ", acts);
        if (actividades != null && actividades.length() > 400) actividades = actividades.substring(0, 400);
        String obs = request.getParameter("observaciones");
        obs = (obs == null || obs.trim().isEmpty()) ? null : (obs.trim().length() > 500 ? obs.trim().substring(0, 500) : obs.trim());

        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}
        int idTecnico = idGestor;
        try {
            String t = request.getParameter("idTecnico");
            if (t != null && !t.trim().isEmpty()) idTecnico = Integer.parseInt(t.trim());
        } catch (Exception ignore) { }

        // periodicidad: "" o "auto" = no tocar/dejar automatica segun accion; numero = fijar
        String per = request.getParameter("periodicidad");
        Integer periodo = null; boolean cambiarPeriodo = false;
        if (per != null && !per.trim().isEmpty()) {
            if ("auto".equalsIgnoreCase(per.trim())) cambiarPeriodo = true;
            else {
                try {
                    int v = Integer.parseInt(per.trim());
                    if (v >= 1 && v <= 36) { periodo = v; cambiarPeriodo = true; }
                } catch (Exception ignore) { }
            }
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            String desc = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(DISPOSITIVO,'Equipo') || ' ' || NVL(MARCA,'') || ' ' || NVL(MODELO,'') FROM INV_EQUIPOS WHERE IDINVEQUIPO = ? AND ESTADO_AI = 'A'")) {
                st.setInt(1, idEquipo);
                try (ResultSet rs = st.executeQuery()) { if (rs.next()) desc = rs.getString(1).trim(); }
            }
            if (desc == null) {
                cn.rollback();
                response.sendRedirect(base + "?error=" + enc("Equipo no encontrado"));
                return;
            }

            int id = 0;
            for (int intento = 1; id == 0; intento++) {
                int nuevo = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_MANTENIMIENTO),0)+1 FROM INV_MANTENIMIENTO");
                     ResultSet rs = st.executeQuery()) { if (rs.next()) nuevo = rs.getInt(1); }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO INV_MANTENIMIENTO (ID_MANTENIMIENTO, IDINVEQUIPO, FECHA_MANT, TIPO, ACTIVIDADES, OBSERVACIONES, " +
                        "ID_TECNICO, ID_USUARIO_REGISTRA, FECHA_REGISTRO, ESTADO) VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, 'A')")) {
                    st.setInt(1, nuevo);
                    st.setInt(2, idEquipo);
                    st.setDate(3, Date.valueOf(fecha));
                    st.setString(4, tipo);
                    if (actividades != null) st.setString(5, actividades); else st.setNull(5, java.sql.Types.VARCHAR);
                    if (obs != null) st.setString(6, obs); else st.setNull(6, java.sql.Types.VARCHAR);
                    st.setInt(7, idTecnico);
                    st.setInt(8, idGestor);
                    st.executeUpdate();
                    id = nuevo;
                } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                    if (intento >= 3) throw dup;
                }
            }
            if (cambiarPeriodo) {
                try (PreparedStatement st = cn.prepareStatement("UPDATE INV_EQUIPOS SET MANT_PERIODICIDAD_MESES = ? WHERE IDINVEQUIPO = ?")) {
                    if (periodo != null) st.setInt(1, periodo); else st.setNull(1, java.sql.Types.NUMERIC);
                    st.setInt(2, idEquipo);
                    st.executeUpdate();
                }
            }
            cn.commit();
            COMUN.LogActividad.registrar(request, "INVENTARIO", "CREAR",
                    "Registro mantenimiento " + tipo.toLowerCase() + " #" + id + " del equipo #" + idEquipo + " (" + desc + ") del " + fecha);
            response.sendRedirect(base + "?msj=" + enc("Mantenimiento registrado: " + desc));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            String det = e.getMessage() == null ? "" : e.getMessage().replaceAll("[\\r\\n]+", " ").trim();
            if (det.length() > 120) det = det.substring(0, 120);
            response.sendRedirect(base + "?error=" + enc("Error al registrar el mantenimiento: " + det));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Mantenimientos.jsp");
    }
}
