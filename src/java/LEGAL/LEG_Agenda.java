package LEGAL;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Types;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Agenda legal: calendario de audiencias, mediaciones, reuniones, tramites, etc. (tablas LEG_AGENDA*, script docs/legal/003).
 * Estados: PENDIENTE -> CUMPLIDO | CANCELADO (justificacion obligatoria) | REPROGRAMADO (crea un evento nuevo enlazado, con
 * justificacion). CUMPLIDO y CANCELADO se pueden reabrir; REPROGRAMADO es final porque ya existe el evento nuevo.
 * Solo un evento PENDIENTE se edita. Todo cambio queda en LEG_AGENDA_HIST. Los errores de validacion son IllegalArgumentException
 * con mensaje apto para el usuario.
 */
public class LEG_Agenda {

    private static final DateTimeFormatter F = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    // ------------------------------------------------------------------ validacion

    private static boolean horaValida(String h) { return h != null && h.matches("([01]\\d|2[0-3]):[0-5]\\d"); }

    private static String norm(String s, int max) {
        if (s == null) return null;
        s = s.trim();
        if (s.isEmpty()) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }

    static void validarHorario(LocalDate fecha, String ini, String fin) {
        if (fecha == null) throw new IllegalArgumentException("Indica la fecha.");
        if (!horaValida(ini)) throw new IllegalArgumentException("Indica la hora de inicio (HH:MM).");
        if (fin != null && !fin.isEmpty()) {
            if (!horaValida(fin)) throw new IllegalArgumentException("La hora de fin no es válida.");
            if (fin.compareTo(ini) <= 0) throw new IllegalArgumentException("La hora de fin debe ser posterior a la de inicio.");
        }
    }

    // ------------------------------------------------------------------ lectura

    public static JSONArray tipos(Connection cn, boolean soloActivos) throws SQLException {
        JSONArray r = new JSONArray();
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_TIPO, NOMBRE, COLOR, ESTADO FROM LEG_AGENDA_TIPO" + (soloActivos ? " WHERE ESTADO = 'A'" : "") + " ORDER BY NOMBRE");
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) r.put(new JSONObject().put("id", rs.getInt(1)).put("nombre", rs.getString(2)).put("color", rs.getString(3)).put("activo", "A".equals(rs.getString(4))));
        }
        return r;
    }

    /** Eventos entre dos fechas (formato FullCalendar), con filtros opcionales por tipo, estado y responsable. */
    public static JSONArray eventos(Connection cn, LocalDate ini, LocalDate fin, Integer tipo, String estado, Integer resp) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM (SELECT a.ID_EVENTO, a.ID_GRUPO, a.ID_TIPO, t.NOMBRE AS TIPO_NOM, t.COLOR, a.ASUNTO, TO_CHAR(a.FECHA,'YYYY-MM-DD') AS F, a.HORA_INI, a.HORA_FIN, " +
            "a.MODALIDAD, a.LUGAR, a.COMENTARIO, a.ESTADO, a.JUSTIFICACION, a.ID_REPROG_A, " +
            "(SELECT TO_CHAR(r.FECHA,'DD/MM/YYYY') FROM LEG_AGENDA r WHERE r.ID_EVENTO = a.ID_REPROG_A) AS REPROG_FECHA, " +
            "ROW_NUMBER() OVER (PARTITION BY a.ID_GRUPO ORDER BY a.FECHA, a.HORA_INI, a.ID_EVENTO) AS N, " +
            "SUM(CASE WHEN a.ESTADO <> 'REPROGRAMADO' THEN 1 ELSE 0 END) OVER (PARTITION BY a.ID_GRUPO) AS TOTAL, a.FECHA AS FD " +
            "FROM LEG_AGENDA a JOIN LEG_AGENDA_TIPO t ON t.ID_TIPO = a.ID_TIPO) x WHERE x.FD BETWEEN ? AND ? ");
        if (tipo != null) sql.append("AND x.ID_TIPO = ").append(tipo.intValue()).append(" ");
        if (estado != null && estado.matches("PENDIENTE|CUMPLIDO|CANCELADO|REPROGRAMADO")) sql.append("AND x.ESTADO = '").append(estado).append("' ");
        if (resp != null) sql.append("AND EXISTS (SELECT 1 FROM LEG_AGENDA_RESP r WHERE r.ID_EVENTO = x.ID_EVENTO AND r.ID_USUARIO = ").append(resp.intValue()).append(") ");
        sql.append("ORDER BY x.FD, x.HORA_INI, x.ID_EVENTO");

        List<JSONObject> lista = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement(sql.toString())) {
            st.setDate(1, Date.valueOf(ini)); st.setDate(2, Date.valueOf(fin));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String f = rs.getString("F"), hi = rs.getString("HORA_INI"), hf = rs.getString("HORA_FIN"), est = rs.getString("ESTADO");
                    JSONObject p = new JSONObject();
                    p.put("tipoId", rs.getInt("ID_TIPO")).put("tipo", rs.getString("TIPO_NOM")).put("color", rs.getString("COLOR")).put("asunto", rs.getString("ASUNTO"))
                     .put("fecha", f).put("horaIni", hi).put("horaFin", hf == null ? "" : hf).put("modalidad", rs.getString("MODALIDAD"))
                     .put("lugar", rs.getString("LUGAR") == null ? "" : rs.getString("LUGAR")).put("comentario", rs.getString("COMENTARIO") == null ? "" : rs.getString("COMENTARIO"))
                     .put("estado", est).put("justificacion", rs.getString("JUSTIFICACION") == null ? "" : rs.getString("JUSTIFICACION"))
                     .put("reprogA", rs.getObject("ID_REPROG_A") == null ? JSONObject.NULL : rs.getInt("ID_REPROG_A")).put("reprogFecha", rs.getString("REPROG_FECHA"))
                     .put("grupo", rs.getObject("ID_GRUPO") == null ? JSONObject.NULL : rs.getInt("ID_GRUPO"))
                     .put("serieN", rs.getObject("ID_GRUPO") == null ? 0 : rs.getInt("N")).put("serieTotal", rs.getObject("ID_GRUPO") == null ? 0 : rs.getInt("TOTAL"));
                    JSONObject e = new JSONObject();
                    e.put("id", rs.getInt("ID_EVENTO")).put("title", rs.getString("ASUNTO")).put("start", f + "T" + hi + ":00");
                    if (hf != null && !hf.isEmpty()) e.put("end", f + "T" + hf + ":00");
                    e.put("color", rs.getString("COLOR"));
                    e.put("classNames", new JSONArray().put("ev-" + est.toLowerCase()));
                    e.put("extendedProps", p);
                    lista.add(e);
                }
            }
        }
        // responsables de los eventos devueltos
        if (!lista.isEmpty()) {
            StringBuilder in = new StringBuilder();
            Map<Integer, JSONObject> porId = new HashMap<>();
            for (JSONObject e : lista) { in.append(in.length() > 0 ? "," : "").append(e.getInt("id")); porId.put(e.getInt("id"), e); e.getJSONObject("extendedProps").put("responsables", new JSONArray()); }
            try (PreparedStatement st = cn.prepareStatement("SELECT r.ID_EVENTO, u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS FROM LEG_AGENDA_RESP r JOIN USUARIO u ON u.IDUSUARIO = r.ID_USUARIO WHERE r.ID_EVENTO IN (" + in + ") ORDER BY u.NOMBRE");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) porId.get(rs.getInt(1)).getJSONObject("extendedProps").getJSONArray("responsables").put(new JSONObject().put("id", rs.getInt(2)).put("nombre", rs.getString(3)));
            }
        }
        marcarCruces(lista);
        return new JSONArray(lista);
    }

    private static int minutos(String hhmm) { return Integer.parseInt(hhmm.substring(0, 2)) * 60 + Integer.parseInt(hhmm.substring(3, 5)); }
    /** Hora de fin efectiva: la indicada o, si no hay, una hora despues del inicio. */
    private static int finMin(String ini, String fin) { return fin == null || fin.isEmpty() ? minutos(ini) + 60 : minutos(fin); }

    /** Marca (cruce = true y crucesCon) los eventos PENDIENTES del mismo dia que se solapan y comparten algun responsable. */
    private static void marcarCruces(List<JSONObject> lista) {
        for (JSONObject e : lista) { e.getJSONObject("extendedProps").put("cruce", false).put("crucesCon", new JSONArray()); }
        for (int i = 0; i < lista.size(); i++) {
            JSONObject pi = lista.get(i).getJSONObject("extendedProps");
            if (!"PENDIENTE".equals(pi.getString("estado"))) continue;
            for (int j = i + 1; j < lista.size(); j++) {
                JSONObject pj = lista.get(j).getJSONObject("extendedProps");
                if (!"PENDIENTE".equals(pj.getString("estado")) || !pi.getString("fecha").equals(pj.getString("fecha"))) continue;
                if (minutos(pi.getString("horaIni")) >= finMin(pj.getString("horaIni"), pj.getString("horaFin")) || minutos(pj.getString("horaIni")) >= finMin(pi.getString("horaIni"), pi.getString("horaFin"))) continue;
                String comun = null;
                JSONArray ri = pi.getJSONArray("responsables"), rj = pj.getJSONArray("responsables");
                for (int a = 0; a < ri.length() && comun == null; a++) for (int b = 0; b < rj.length(); b++) if (ri.getJSONObject(a).getInt("id") == rj.getJSONObject(b).getInt("id")) { comun = ri.getJSONObject(a).getString("nombre"); break; }
                if (comun == null) continue;
                pi.put("cruce", true).getJSONArray("crucesCon").put(comun + ": " + lista.get(j).getString("title") + " (" + pj.getString("horaIni") + (pj.getString("horaFin").isEmpty() ? "" : "-" + pj.getString("horaFin")) + ")");
                pj.put("cruce", true).getJSONArray("crucesCon").put(comun + ": " + lista.get(i).getString("title") + " (" + pi.getString("horaIni") + (pi.getString("horaFin").isEmpty() ? "" : "-" + pi.getString("horaFin")) + ")");
            }
        }
    }

    /**
     * Eventos PENDIENTES de los responsables indicados que se solapan con fecha/ini/fin (aviso previo al guardar; no bloquea).
     * Devuelve [{id, asunto, ini, fin, responsable}]. excluirId = el propio evento al editarlo.
     */
    public static JSONArray conflictos(Connection cn, LocalDate fecha, String ini, String fin, List<Integer> resp, Integer excluirId) throws SQLException {
        JSONArray r = new JSONArray();
        if (fecha == null || !horaValida(ini) || resp == null || resp.isEmpty()) return r;
        String fin2 = fin == null || fin.isEmpty() || !horaValida(fin) ? null : fin;
        int a1 = minutos(ini), a2 = finMin(ini, fin2);
        StringBuilder in = new StringBuilder();
        for (Integer u : new LinkedHashSet<>(resp)) in.append(in.length() > 0 ? "," : "").append(u.intValue());
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT a.ID_EVENTO, a.ASUNTO, a.HORA_INI, a.HORA_FIN, u.NOMBRE || ' ' || u.APELLIDOS FROM LEG_AGENDA a " +
                "JOIN LEG_AGENDA_RESP r ON r.ID_EVENTO = a.ID_EVENTO JOIN USUARIO u ON u.IDUSUARIO = r.ID_USUARIO " +
                "WHERE a.FECHA = ? AND a.ESTADO = 'PENDIENTE' AND r.ID_USUARIO IN (" + in + ") " + (excluirId != null ? "AND a.ID_EVENTO <> " + excluirId.intValue() + " " : "") + "ORDER BY a.HORA_INI")) {
            st.setDate(1, Date.valueOf(fecha));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int b1 = minutos(rs.getString(3)), b2 = finMin(rs.getString(3), rs.getString(4));
                    if (a1 < b2 && b1 < a2) r.put(new JSONObject().put("id", rs.getInt(1)).put("asunto", rs.getString(2)).put("ini", rs.getString(3)).put("fin", rs.getString(4) == null ? "" : rs.getString(4)).put("responsable", rs.getString(5)));
                }
            }
        }
        return r;
    }

    public static JSONArray historial(Connection cn, int idEvento) throws SQLException {
        JSONArray r = new JSONArray();
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT TO_CHAR(h.FECHA_HORA,'DD/MM/YYYY HH24:MI'), NVL(u.NOMBRE || ' ' || u.APELLIDOS, '-'), h.ACCION, h.DETALLE FROM LEG_AGENDA_HIST h " +
                "LEFT JOIN USUARIO u ON u.IDUSUARIO = h.ID_USUARIO WHERE h.ID_EVENTO = ? ORDER BY h.FECHA_HORA DESC, h.ID_HIST DESC")) {
            st.setInt(1, idEvento);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) r.put(new JSONObject().put("fecha", rs.getString(1)).put("usuario", rs.getString(2)).put("accion", rs.getString(3)).put("detalle", rs.getString(4) == null ? "" : rs.getString(4)));
            }
        }
        return r;
    }

    // ------------------------------------------------------------------ escritura

    private static int siguienteId(Connection cn, String tabla, String col) throws SQLException {
        try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(" + col + "),0)+1 FROM " + tabla); ResultSet rs = st.executeQuery()) { return rs.next() ? rs.getInt(1) : 1; }
    }

    private static void hist(Connection cn, int idEvento, int yo, String accion, String detalle) throws SQLException {
        int id = siguienteId(cn, "LEG_AGENDA_HIST", "ID_HIST");
        try (PreparedStatement st = cn.prepareStatement("INSERT INTO LEG_AGENDA_HIST (ID_HIST, ID_EVENTO, ID_USUARIO, ACCION, DETALLE) VALUES (?, ?, ?, ?, ?)")) {
            st.setInt(1, id); st.setInt(2, idEvento); st.setInt(3, yo); st.setString(4, accion);
            if (detalle == null) st.setNull(5, Types.VARCHAR); else st.setString(5, detalle.length() > 800 ? detalle.substring(0, 800) : detalle);
            st.executeUpdate();
        }
    }

    private static void guardarResponsables(Connection cn, int idEvento, List<Integer> resp) throws SQLException {
        try (PreparedStatement st = cn.prepareStatement("DELETE FROM LEG_AGENDA_RESP WHERE ID_EVENTO = ?")) { st.setInt(1, idEvento); st.executeUpdate(); }
        Set<Integer> unicos = new LinkedHashSet<>(resp);
        if (unicos.isEmpty()) return;
        try (PreparedStatement st = cn.prepareStatement("INSERT INTO LEG_AGENDA_RESP (ID_EVENTO, ID_USUARIO) VALUES (?, ?)")) {
            for (Integer u : unicos) { st.setInt(1, idEvento); st.setInt(2, u); st.addBatch(); }
            st.executeBatch();
        }
    }

    private static int insertarEvento(Connection cn, Integer grupo, int tipo, String asunto, LocalDate fecha, String ini, String fin, String modalidad, String lugar, String comentario, int yo) throws SQLException {
        for (int intento = 0; intento < 3; intento++) {
            int id = siguienteId(cn, "LEG_AGENDA", "ID_EVENTO");
            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO LEG_AGENDA (ID_EVENTO, ID_GRUPO, ID_TIPO, ASUNTO, FECHA, HORA_INI, HORA_FIN, MODALIDAD, LUGAR, COMENTARIO, ESTADO, ID_CREA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE', ?)")) {
                st.setInt(1, id);
                if (grupo == null) st.setNull(2, Types.NUMERIC); else st.setInt(2, grupo);
                st.setInt(3, tipo); st.setString(4, asunto); st.setDate(5, Date.valueOf(fecha)); st.setString(6, ini);
                if (fin == null) st.setNull(7, Types.VARCHAR); else st.setString(7, fin);
                st.setString(8, modalidad);
                if (lugar == null) st.setNull(9, Types.VARCHAR); else st.setString(9, lugar);
                if (comentario == null) st.setNull(10, Types.VARCHAR); else st.setString(10, comentario);
                st.setInt(11, yo);
                st.executeUpdate();
                return id;
            } catch (SQLIntegrityConstraintViolationException dup) { /* otro usuario tomo ese id: reintenta */ }
        }
        throw new SQLException("No se pudo generar el número del evento, intenta de nuevo.");
    }

    /** Crea uno o varios eventos (una fila de "fechas" = {fecha, horaIni, horaFin}). Varias fechas quedan agrupadas como serie. */
    public static List<Integer> crear(Connection cn, int yo, int tipo, String asunto, String modalidad, String lugar, String comentario, List<Integer> resp, List<String[]> fechas) throws Exception {
        asunto = norm(asunto, 200);
        if (asunto == null) throw new IllegalArgumentException("El asunto es obligatorio.");
        if (fechas == null || fechas.isEmpty()) throw new IllegalArgumentException("Agrega al menos una fecha.");
        modalidad = "V".equals(modalidad) ? "V" : "P";
        lugar = norm(lugar, 300); comentario = norm(comentario, 1000);
        List<LocalDate> fs = new ArrayList<>();
        for (String[] f : fechas) {
            LocalDate d;
            try { d = LocalDate.parse(f[0]); } catch (Exception e) { throw new IllegalArgumentException("Revisa las fechas."); }
            String fin = norm(f[2], 5);
            validarHorario(d, f[1], fin);
            fs.add(d);
        }
        if (resp == null || resp.isEmpty()) { resp = new ArrayList<>(); resp.add(yo); }   // sin responsable elegido: quien lo registra
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            existeTipo(cn, tipo);
            List<Integer> ids = new ArrayList<>();
            Integer grupo = null;
            for (int i = 0; i < fechas.size(); i++) {
                String[] f = fechas.get(i);
                int id = insertarEvento(cn, grupo, tipo, asunto, fs.get(i), f[1], norm(f[2], 5), modalidad, lugar, comentario, yo);
                if (i == 0 && fechas.size() > 1) {   // la serie se identifica con el id del primer evento
                    grupo = id;
                    try (PreparedStatement st = cn.prepareStatement("UPDATE LEG_AGENDA SET ID_GRUPO = ? WHERE ID_EVENTO = ?")) { st.setInt(1, id); st.setInt(2, id); st.executeUpdate(); }
                }
                guardarResponsables(cn, id, resp);
                hist(cn, id, yo, "CREADO", "Registrado para el " + F.format(fs.get(i)) + " a las " + f[1] + (fechas.size() > 1 ? " (serie de " + fechas.size() + " fechas)" : ""));
                ids.add(id);
            }
            cn.commit();
            return ids;
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    private static void existeTipo(Connection cn, int tipo) throws SQLException {
        try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM LEG_AGENDA_TIPO WHERE ID_TIPO = ? AND ESTADO = 'A'")) {
            st.setInt(1, tipo);
            try (ResultSet rs = st.executeQuery()) { if (!rs.next() || rs.getInt(1) == 0) throw new IllegalArgumentException("El tipo elegido no está disponible."); }
        }
    }

    private static Object[] fila(Connection cn, int id) throws SQLException {
        try (PreparedStatement st = cn.prepareStatement("SELECT ESTADO, ID_TIPO, ASUNTO, FECHA, HORA_INI, HORA_FIN, MODALIDAD, LUGAR, COMENTARIO, ID_GRUPO FROM LEG_AGENDA WHERE ID_EVENTO = ?")) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("El evento no existe.");
                return new Object[]{rs.getString(1), rs.getInt(2), rs.getString(3), rs.getDate(4).toLocalDate(), rs.getString(5), rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getObject(10)};
            }
        }
    }

    private static String ig(Object o) { return o == null ? "" : o.toString(); }

    /** Edita un evento PENDIENTE (incluida su fecha). Deja en el historial lo que cambio. */
    public static void editar(Connection cn, int yo, int id, int tipo, String asunto, LocalDate fecha, String ini, String fin, String modalidad, String lugar, String comentario, List<Integer> resp) throws Exception {
        asunto = norm(asunto, 200);
        if (asunto == null) throw new IllegalArgumentException("El asunto es obligatorio.");
        fin = norm(fin, 5);
        validarHorario(fecha, ini, fin);
        modalidad = "V".equals(modalidad) ? "V" : "P";
        lugar = norm(lugar, 300); comentario = norm(comentario, 1000);
        if (resp == null || resp.isEmpty()) { resp = new ArrayList<>(); resp.add(yo); }
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            Object[] o = fila(cn, id);
            if (!"PENDIENTE".equals(o[0])) throw new IllegalArgumentException("Solo se puede editar un evento pendiente. Reabre el evento primero.");
            existeTipo(cn, tipo);
            List<String> cambios = new ArrayList<>();
            if (!asunto.equals(o[2])) cambios.add("Asunto");
            if (!fecha.equals(o[3])) cambios.add("Fecha: " + F.format((LocalDate) o[3]) + " → " + F.format(fecha));
            if (!ini.equals(o[4]) || !ig(fin).equals(ig(o[5]))) cambios.add("Hora: " + o[4] + (o[5] == null ? "" : "-" + o[5]) + " → " + ini + (fin == null ? "" : "-" + fin));
            if (tipo != (Integer) o[1]) cambios.add("Tipo");
            if (!modalidad.equals(o[6]) || !ig(lugar).equals(ig(o[7]))) cambios.add("Lugar/modalidad");
            if (!ig(comentario).equals(ig(o[8]))) cambios.add("Comentario");
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE LEG_AGENDA SET ID_TIPO = ?, ASUNTO = ?, FECHA = ?, HORA_INI = ?, HORA_FIN = ?, MODALIDAD = ?, LUGAR = ?, COMENTARIO = ?, ID_MODIFICA = ?, FECHA_MODIFICA = SYSDATE WHERE ID_EVENTO = ?")) {
                st.setInt(1, tipo); st.setString(2, asunto); st.setDate(3, Date.valueOf(fecha)); st.setString(4, ini);
                if (fin == null) st.setNull(5, Types.VARCHAR); else st.setString(5, fin);
                st.setString(6, modalidad);
                if (lugar == null) st.setNull(7, Types.VARCHAR); else st.setString(7, lugar);
                if (comentario == null) st.setNull(8, Types.VARCHAR); else st.setString(8, comentario);
                st.setInt(9, yo); st.setInt(10, id);
                st.executeUpdate();
            }
            guardarResponsables(cn, id, resp);
            hist(cn, id, yo, "EDITADO", cambios.isEmpty() ? "Sin cambios en los datos principales" : String.join("; ", cambios));
            cn.commit();
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    /** Cambia el estado: CUMPLIDO (justificacion opcional), CANCELADO (obligatoria) o PENDIENTE (reabrir un cumplido/cancelado). */
    public static void cambiarEstado(Connection cn, int yo, int id, String nuevo, String justificacion) throws Exception {
        justificacion = norm(justificacion, 500);
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            Object[] o = fila(cn, id);
            String actual = (String) o[0];
            if ("CANCELADO".equals(nuevo)) {
                if (!"PENDIENTE".equals(actual)) throw new IllegalArgumentException("Solo se puede cancelar un evento pendiente.");
                if (justificacion == null || justificacion.length() < 3) throw new IllegalArgumentException("Escribe la justificación de la cancelación.");
            } else if ("CUMPLIDO".equals(nuevo)) {
                if (!"PENDIENTE".equals(actual)) throw new IllegalArgumentException("Solo se puede marcar como cumplido un evento pendiente.");
            } else if ("PENDIENTE".equals(nuevo)) {
                if (!"CUMPLIDO".equals(actual) && !"CANCELADO".equals(actual)) throw new IllegalArgumentException("Solo se puede reabrir un evento cumplido o cancelado.");
            } else throw new IllegalArgumentException("Estado no válido.");
            try (PreparedStatement st = cn.prepareStatement("UPDATE LEG_AGENDA SET ESTADO = ?, JUSTIFICACION = ?, ID_MODIFICA = ?, FECHA_MODIFICA = SYSDATE WHERE ID_EVENTO = ? AND ESTADO = ?")) {
                st.setString(1, nuevo);
                if ("PENDIENTE".equals(nuevo) || justificacion == null) st.setNull(2, Types.VARCHAR); else st.setString(2, justificacion);
                st.setInt(3, yo); st.setInt(4, id); st.setString(5, actual);
                if (st.executeUpdate() == 0) throw new IllegalArgumentException("El evento cambió de estado mientras lo editabas. Recarga el calendario.");
            }
            hist(cn, id, yo, "PENDIENTE".equals(nuevo) ? "REABIERTO" : nuevo, justificacion);
            cn.commit();
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    /** Reprograma un evento PENDIENTE: queda REPROGRAMADO (con justificacion) y se crea uno nuevo, enlazado, en la fecha dada. */
    public static int reprogramar(Connection cn, int yo, int id, LocalDate fecha, String ini, String fin, String justificacion) throws Exception {
        justificacion = norm(justificacion, 500);
        fin = norm(fin, 5);
        validarHorario(fecha, ini, fin);
        if (justificacion == null || justificacion.length() < 3) throw new IllegalArgumentException("Escribe el motivo de la reprogramación.");
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            Object[] o = fila(cn, id);
            if (!"PENDIENTE".equals(o[0])) throw new IllegalArgumentException("Solo se puede reprogramar un evento pendiente.");
            Integer grupo = o[9] == null ? null : ((Number) o[9]).intValue();
            if (grupo == null) {   // la reprogramacion forma una "serie" con el original para poder seguirla
                grupo = id;
                try (PreparedStatement st = cn.prepareStatement("UPDATE LEG_AGENDA SET ID_GRUPO = ? WHERE ID_EVENTO = ?")) { st.setInt(1, id); st.setInt(2, id); st.executeUpdate(); }
            }
            int nuevo = insertarEvento(cn, grupo, (Integer) o[1], (String) o[2], fecha, ini, fin, (String) o[6], (String) o[7], (String) o[8], yo);
            // mismos responsables
            try (PreparedStatement st = cn.prepareStatement("INSERT INTO LEG_AGENDA_RESP (ID_EVENTO, ID_USUARIO) SELECT ?, ID_USUARIO FROM LEG_AGENDA_RESP WHERE ID_EVENTO = ?")) { st.setInt(1, nuevo); st.setInt(2, id); st.executeUpdate(); }
            try (PreparedStatement st = cn.prepareStatement("UPDATE LEG_AGENDA SET ESTADO = 'REPROGRAMADO', JUSTIFICACION = ?, ID_REPROG_A = ?, ID_MODIFICA = ?, FECHA_MODIFICA = SYSDATE WHERE ID_EVENTO = ? AND ESTADO = 'PENDIENTE'")) {
                st.setString(1, justificacion); st.setInt(2, nuevo); st.setInt(3, yo); st.setInt(4, id);
                if (st.executeUpdate() == 0) throw new IllegalArgumentException("El evento cambió de estado mientras lo editabas. Recarga el calendario.");
            }
            hist(cn, id, yo, "REPROGRAMADO", "Pasó del " + F.format((LocalDate) o[3]) + " " + o[4] + " al " + F.format(fecha) + " " + ini + ". Motivo: " + justificacion);
            hist(cn, nuevo, yo, "CREADO", "Reprogramado desde el evento #" + id + " (" + F.format((LocalDate) o[3]) + "). Motivo: " + justificacion);
            cn.commit();
            return nuevo;
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    // ------------------------------------------------------------------ tipos

    /** Crea (id == null) o actualiza un tipo: nombre, color (#RRGGBB) y si esta activo. */
    public static void guardarTipo(Connection cn, Integer id, String nombre, String color, boolean activo) throws Exception {
        nombre = norm(nombre, 60);
        if (nombre == null) throw new IllegalArgumentException("El nombre del tipo es obligatorio.");
        if (color == null || !color.matches("#[0-9a-fA-F]{6}")) throw new IllegalArgumentException("Elige un color válido.");
        try {
            if (id == null) {
                int nuevo = siguienteId(cn, "LEG_AGENDA_TIPO", "ID_TIPO");
                try (PreparedStatement st = cn.prepareStatement("INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR, ESTADO) VALUES (?, ?, ?, 'A')")) {
                    st.setInt(1, nuevo); st.setString(2, nombre); st.setString(3, color.toLowerCase()); st.executeUpdate();
                }
            } else {
                try (PreparedStatement st = cn.prepareStatement("UPDATE LEG_AGENDA_TIPO SET NOMBRE = ?, COLOR = ?, ESTADO = ? WHERE ID_TIPO = ?")) {
                    st.setString(1, nombre); st.setString(2, color.toLowerCase()); st.setString(3, activo ? "A" : "I"); st.setInt(4, id); st.executeUpdate();
                }
            }
        } catch (SQLIntegrityConstraintViolationException dup) { throw new IllegalArgumentException("Ya existe un tipo con ese nombre."); }
    }
}
