package VACACIONES;

import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// Datos del dashboard de Vacaciones: "eventos" de vacaciones tomadas o programadas por empleado, unificando
//   * SOLICITUD: solicitudes APROBADAS / RECIBIDAS (VAC_SOLICITUD)
//   * AJUSTE:    consumo historico con fechas cargado por el gestor (VAC_HISTORICO_AJUSTE)
//   * PERMISO:   ajustes generados por un permiso personal de 8 horas (ID_PERMISO no nulo)
// Respeta el alcance del usuario (VAC_Alcance): un gestor solo ve a los empleados de su grupo.
public class VAC_EventosHelper {

    public static class Evento {
        public String tipo, nombre, departamento, oficina, grupo;
        public int idUsuario;
        public LocalDate desde, hasta;
        public double dias;
        public boolean anticipada, retroactiva;

        /** Los permisos de un dia no cuentan como "estar de vacaciones" en las listas de personas. */
        public boolean esVacacion() { return !"PERMISO".equals(tipo); }
        public boolean seSolapaCon(LocalDate ini, LocalDate fin) { return !hasta.isBefore(ini) && !desde.isAfter(fin); }
    }

    /**
     * Eventos que se solapan con [ini, fin]. grupoFiltro: null = todos los del alcance; 0 = sin asignar (solo
     * administrador global); n = ese grupo (solo si esta en el alcance del usuario).
     */
    public static List<Evento> cargar(Connection cn, HttpSession session, LocalDate ini, LocalDate fin, Integer grupoFiltro) throws SQLException {
        String sql =
            "SELECT x.TIPO, x.ID_USUARIO, u.NOMBRE || ' ' || u.APELLIDOS, d.DEPARTAMENTO, vc.OFICINA, g.NOMBRE, " +
            "       x.DESDE, x.HASTA, x.DIAS, x.ANTICIPADA, x.RETRO " +
            "FROM ( " +
            "  SELECT 'SOLICITUD' AS TIPO, s.ID_USUARIO, s.FECHA_DESDE AS DESDE, s.FECHA_HASTA AS HASTA, " +
            "         NVL(s.DIAS_APROBADOS, s.DIAS_SOLICITADOS) AS DIAS, s.ANTICIPADA, s.RETROACTIVA AS RETRO " +
            "  FROM VAC_SOLICITUD s WHERE s.ESTADO IN ('APROBADO','RECIBIDO') " +
            "  UNION ALL " +
            "  SELECT CASE WHEN a.ID_PERMISO IS NULL THEN 'AJUSTE' ELSE 'PERMISO' END, a.ID_USUARIO, a.FECHA_DESDE, a.FECHA_HASTA, " +
            "         a.DIAS_GOZADOS, 'N', 'N' " +
            "  FROM VAC_HISTORICO_AJUSTE a WHERE a.FECHA_DESDE IS NOT NULL AND a.FECHA_HASTA IS NOT NULL " +
            ") x " +
            "JOIN USUARIO u ON u.IDUSUARIO = x.ID_USUARIO " +
            "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
            "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
            "LEFT JOIN VAC_GRUPO g ON g.ID_GRUPO = vc.ID_GRUPO " +
            "WHERE x.HASTA >= ? AND x.DESDE <= ? " +
            VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO") +
            (grupoFiltro != null && grupoFiltro == 0 ? " AND vc.ID_GRUPO IS NULL " : "") +
            (grupoFiltro != null && grupoFiltro > 0 ? " AND vc.ID_GRUPO = " + grupoFiltro.intValue() + " " : "") +
            "ORDER BY x.DESDE DESC, 3";
        List<Evento> r = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(ini));
            st.setDate(2, Date.valueOf(fin));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Evento e = new Evento();
                    e.tipo = rs.getString(1); e.idUsuario = rs.getInt(2); e.nombre = rs.getString(3);
                    e.departamento = rs.getString(4) == null ? "Sin departamento" : rs.getString(4);
                    e.oficina = rs.getString(5) == null ? "" : rs.getString(5);
                    e.grupo = rs.getString(6) == null ? "Sin asignar" : rs.getString(6);
                    e.desde = rs.getDate(7).toLocalDate(); e.hasta = rs.getDate(8).toLocalDate();
                    e.dias = rs.getDouble(9);
                    e.anticipada = "S".equals(rs.getString(10)); e.retroactiva = "S".equals(rs.getString(11));
                    r.add(e);
                }
            }
        }
        return r;
    }

    /** Solicitudes por estado {PENDIENTE_JEFE, PENDIENTE_ADMIN, APROBADO(+RECIBIDO), RECHAZADO} con fecha desde en el anio. */
    public static int[] solicitudesPorEstado(Connection cn, HttpSession session, int anio, Integer grupoFiltro) throws SQLException {
        String sql =
            "SELECT s.ESTADO, COUNT(*) FROM VAC_SOLICITUD s LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = s.ID_USUARIO " +
            "WHERE EXTRACT(YEAR FROM s.FECHA_DESDE) = ? " +
            VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO") +
            (grupoFiltro != null && grupoFiltro == 0 ? " AND vc.ID_GRUPO IS NULL " : "") +
            (grupoFiltro != null && grupoFiltro > 0 ? " AND vc.ID_GRUPO = " + grupoFiltro.intValue() + " " : "") +
            "GROUP BY s.ESTADO";
        int[] r = new int[4];
        try (PreparedStatement st = cn.prepareStatement(sql)) {
            st.setInt(1, anio);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String e = rs.getString(1); int n = rs.getInt(2);
                    if ("PENDIENTE_JEFE".equals(e)) r[0] += n;
                    else if ("PENDIENTE_ADMIN".equals(e)) r[1] += n;
                    else if ("APROBADO".equals(e) || "RECIBIDO".equals(e)) r[2] += n;
                    else if ("RECHAZADO_JEFE".equals(e) || "RECHAZADO_ADMIN".equals(e)) r[3] += n;
                }
            }
        }
        return r;
    }
}
