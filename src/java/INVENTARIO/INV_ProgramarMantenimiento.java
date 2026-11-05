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
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

// Programacion de mantenimientos (INVENTARIO_MANTENIMIENTO_GESTIONAR). Guarda en INV_EQUIPOS.MANT_PROGRAMADO la
// fecha en que Tecnologia planea dar el mantenimiento; el aviso al usuario sale 15 dias antes de ESA fecha.
//   accion=INDIVIDUAL idEquipo fecha     -> programa un equipo
//   accion=QUITAR     idEquipo           -> quita la programacion
//   accion=MASIVA     fechaInicio porDia [oficina]
//        Reparte de golpe la primera ronda: los equipos VENCIDOS (o nunca mantenidos) que aun no tienen fecha,
//        agrupados por oficina y por usuario (el tecnico visita una oficina en dias seguidos), porDia equipos
//        por dia habil (lunes a viernes) desde fechaInicio.
@WebServlet(name = "INV_ProgramarMantenimiento", urlPatterns = {"/INV_ProgramarMantenimiento"})
public class INV_ProgramarMantenimiento extends HttpServlet {

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
        String accion = request.getParameter("accion");
        LocalDate hoy = LocalDate.now();

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);
            String msj;

            if ("INDIVIDUAL".equals(accion) || "QUITAR".equals(accion)) {
                int idEquipo = Integer.parseInt(request.getParameter("idEquipo").trim());
                LocalDate fecha = null;
                if ("INDIVIDUAL".equals(accion)) {
                    fecha = LocalDate.parse(request.getParameter("fecha").trim());
                    if (fecha.isBefore(hoy)) {
                        cn.rollback();
                        response.sendRedirect(base + "?error=" + enc("La fecha programada no puede ser pasada"));
                        return;
                    }
                }
                try (PreparedStatement st = cn.prepareStatement("UPDATE INV_EQUIPOS SET MANT_PROGRAMADO = ? WHERE IDINVEQUIPO = ?")) {
                    if (fecha != null) st.setDate(1, Date.valueOf(fecha)); else st.setNull(1, java.sql.Types.DATE);
                    st.setInt(2, idEquipo);
                    st.executeUpdate();
                }
                cn.commit();
                COMUN.LogActividad.registrar(request, "INVENTARIO", "EDITAR",
                        fecha != null ? "Programo el mantenimiento del equipo #" + idEquipo + " para el " + fecha
                                      : "Quito la programacion de mantenimiento del equipo #" + idEquipo);
                msj = fecha != null ? "Mantenimiento programado para el " + fecha : "Programacion eliminada";

            } else if ("MASIVA".equals(accion)) {
                LocalDate inicio = LocalDate.parse(request.getParameter("fechaInicio").trim());
                int porDia = Integer.parseInt(request.getParameter("porDia").trim());
                String oficina = request.getParameter("oficina");
                if (inicio.isBefore(hoy)) {
                    cn.rollback();
                    response.sendRedirect(base + "?error=" + enc("La fecha de inicio no puede ser pasada"));
                    return;
                }
                if (porDia < 1 || porDia > 30) {
                    cn.rollback();
                    response.sendRedirect(base + "?error=" + enc("Equipos por dia debe estar entre 1 y 30"));
                    return;
                }
                List<INV_MantenimientoHelper.Fila> cand = new ArrayList<>();
                for (INV_MantenimientoHelper.Fila f : INV_MantenimientoHelper.cargar(cn, true)) {
                    if (!"VENCIDO".equals(f.estado) || f.programada != null) continue;
                    if (oficina != null && !oficina.trim().isEmpty() && !oficina.equals(f.oficina)) continue;
                    cand.add(f);
                }
                cand.sort(Comparator.comparing((INV_MantenimientoHelper.Fila f) -> f.oficina)
                        .thenComparing(f -> f.usuario == null ? "~" : f.usuario)
                        .thenComparing(f -> f.dispositivo));
                LocalDate dia = inicio;
                while (dia.getDayOfWeek() == DayOfWeek.SATURDAY || dia.getDayOfWeek() == DayOfWeek.SUNDAY) dia = dia.plusDays(1);
                int enDia = 0;
                LocalDate primero = dia, ultimo = dia;
                try (PreparedStatement st = cn.prepareStatement("UPDATE INV_EQUIPOS SET MANT_PROGRAMADO = ? WHERE IDINVEQUIPO = ?")) {
                    for (INV_MantenimientoHelper.Fila f : cand) {
                        if (enDia >= porDia) {
                            dia = dia.plusDays(1);
                            while (dia.getDayOfWeek() == DayOfWeek.SATURDAY || dia.getDayOfWeek() == DayOfWeek.SUNDAY) dia = dia.plusDays(1);
                            enDia = 0;
                        }
                        st.setDate(1, Date.valueOf(dia));
                        st.setInt(2, f.idEquipo);
                        st.addBatch();
                        enDia++;
                        ultimo = dia;
                    }
                    if (!cand.isEmpty()) st.executeBatch();
                }
                cn.commit();
                COMUN.LogActividad.registrar(request, "INVENTARIO", "EDITAR",
                        "Programo en bloque el mantenimiento de " + cand.size() + " equipos (" + primero + " a " + ultimo + ", " + porDia + " por dia"
                        + (oficina != null && !oficina.trim().isEmpty() ? ", oficina " + oficina : "") + ")");
                msj = cand.isEmpty() ? "No habia equipos vencidos sin programar" :
                        cand.size() + " equipos programados del " + primero + " al " + ultimo;
            } else {
                response.sendRedirect(base + "?error=" + enc("Accion invalida"));
                return;
            }
            response.sendRedirect(base + "?msj=" + enc(msj));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            String det = e.getMessage() == null ? "" : e.getMessage().replaceAll("[\\r\\n]+", " ").trim();
            if (det.length() > 120) det = det.substring(0, 120);
            response.sendRedirect(base + "?error=" + enc("No se pudo programar: " + det));
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
