package HORARIOS;

import COMUN.PermisoHelper;
import VACACIONES.VAC_Alcance;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

/**
 * Horario de clases de los usuarios que estudian: dias y horas en que NO estan disponibles en la oficina.
 * Una solicitud (HOR_CLASE_SOL) tiene vigencia (semestre) y bloques (HOR_CLASE_BLOQUE: dia, hora inicio, hora fin, materia).
 * Aprueban el jefe directo (VAC_CONFIG_USUARIO.ID_JEFE_DIRECTO) o la administracion = gestores de Vacaciones dentro de su
 * grupo (VACACIONES_GESTIONAR + VAC_Alcance). Quien registra por otro (jefe/administracion) lo deja aprobado de inmediato.
 * Los errores de validacion se lanzan como IllegalArgumentException con un mensaje apto para mostrar al usuario.
 */
public class HOR_Helper {

    public static final String[] DIAS = {"", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"};
    public static final String[] DIAS_CORTO = {"", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"};

    public static class Bloque {
        public int dia;
        public String ini, fin, materia;
        public Bloque() { }
        public Bloque(int dia, String ini, String fin, String materia) { this.dia = dia; this.ini = ini; this.fin = fin; this.materia = materia; }
    }

    public static class Solicitud {
        public int id, idUsuario;
        public String nombre, departamento, estado, observacion, registradoPor, apruebaNombre, motivoRechazo;
        public LocalDate desde, hasta;
        public boolean registradoPorOtro;
        public List<Bloque> bloques = new ArrayList<>();
        public boolean vigenteHoy() { LocalDate h = LocalDate.now(); return "APROBADO".equals(estado) && !h.isBefore(desde) && !h.isAfter(hasta); }
    }

    // ------------------------------------------------------------------ permisos / alcance

    /** true si tiene gente a cargo (es jefe directo de alguien). */
    public static boolean esJefe(Connection cn, int yo) {
        try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM VAC_CONFIG_USUARIO WHERE ID_JEFE_DIRECTO = ?")) {
            st.setInt(1, yo);
            try (ResultSet rs = st.executeQuery()) { return rs.next() && rs.getInt(1) > 0; }
        } catch (Exception e) { return false; }
    }

    public static boolean esGestorVacaciones(HttpSession session) { return PermisoHelper.tiene(session, "VACACIONES_GESTIONAR"); }

    public static boolean puedeEntrarGestion(HttpSession session, Connection cn, int yo) {
        return esGestorVacaciones(session) || esJefe(cn, yo);
    }

    /**
     * Fragmento SQL (solo enteros, sin texto del usuario) que cubre a los empleados que "yo" puede gestionar: los que tienen
     * como jefe directo a "yo" o, si es gestor de Vacaciones, los de sus grupos (todos si es administrador global).
     * Usa los alias vc.ID_JEFE_DIRECTO y vc.ID_GRUPO (LEFT JOIN VAC_CONFIG_USUARIO vc).
     */
    public static String condicionEquipoSql(HttpSession session, Connection cn, int yo) {
        String g = "1 = 0";
        if (esGestorVacaciones(session)) {
            String f = VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO").trim();
            if (f.isEmpty()) g = "1 = 1";
            else g = f.regionMatches(true, 0, "AND ", 0, 4) ? f.substring(4) : f;
        }
        return "(vc.ID_JEFE_DIRECTO = " + yo + " OR (" + g + "))";
    }

    /** Puede aprobar/rechazar/registrar por este empleado: su jefe directo o un gestor de Vacaciones con alcance sobre el. */
    public static boolean puedeGestionar(HttpSession session, Connection cn, int idEmpleado, int yo) {
        if (idEmpleado == yo && !VAC_Alcance.esGlobal(session)) return false;   // nadie aprueba lo propio (salvo admin global)
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_JEFE_DIRECTO FROM VAC_CONFIG_USUARIO WHERE ID_USUARIO = ?")) {
            st.setInt(1, idEmpleado);
            try (ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) == yo) return true; }
        } catch (Exception e) { /* sigue con la regla de gestor */ }
        return esGestorVacaciones(session) && VAC_Alcance.puedeSobre(session, cn, idEmpleado);
    }

    /** Empleados activos por los que "yo" puede registrar/aprobar (sin incluirse): {id, nombre, departamento}. */
    public static List<String[]> empleadosGestionables(HttpSession session, Connection cn, int yo) throws Exception {
        List<String[]> r = new ArrayList<>();
        String sql = "SELECT u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS, d.DEPARTAMENTO FROM USUARIO u " +
                "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
                "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
                "WHERE u.ESTADO = 'a' AND u.IDUSUARIO <> " + yo + " AND " + condicionEquipoSql(session, cn, yo) + " ORDER BY u.NOMBRE, u.APELLIDOS";
        try (PreparedStatement st = cn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) r.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3)});
        }
        return r;
    }

    // ------------------------------------------------------------------ lectura de formulario y validacion

    /** Lee los bloques del formulario: filas i = 0..39 con dias_i (varios), ini_i, fin_i, mat_i. Cada dia marcado genera un bloque. */
    public static List<Bloque> leerBloques(HttpServletRequest request) {
        List<Bloque> r = new ArrayList<>();
        for (int i = 0; i < 40; i++) {
            String ini = request.getParameter("ini_" + i), fin = request.getParameter("fin_" + i);
            String[] dias = request.getParameterValues("dias_" + i);
            if (ini == null && fin == null && dias == null) continue;
            if (dias == null || dias.length == 0) throw new IllegalArgumentException("Marca al menos un día en cada bloque de horario.");
            String mat = request.getParameter("mat_" + i);
            mat = mat == null ? "" : mat.trim();
            if (mat.length() > 100) mat = mat.substring(0, 100);
            for (String d : dias) {
                int dia;
                try { dia = Integer.parseInt(d.trim()); } catch (Exception e) { throw new IllegalArgumentException("Día no válido."); }
                r.add(new Bloque(dia, ini == null ? "" : ini.trim(), fin == null ? "" : fin.trim(), mat));
            }
        }
        return r;
    }

    private static boolean horaValida(String h) { return h != null && h.matches("([01]\\d|2[0-3]):[0-5]\\d"); }

    static void validar(LocalDate desde, LocalDate hasta, List<Bloque> bl) {
        if (desde == null || hasta == null) throw new IllegalArgumentException("Indica la fecha de inicio y de fin del semestre.");
        if (hasta.isBefore(desde)) throw new IllegalArgumentException("La fecha de fin no puede ser anterior a la de inicio.");
        if (java.time.temporal.ChronoUnit.DAYS.between(desde, hasta) > 400) throw new IllegalArgumentException("La vigencia no puede superar 13 meses; registra cada semestre por separado.");
        if (hasta.isBefore(LocalDate.now())) throw new IllegalArgumentException("La vigencia ya terminó: elige fechas actuales o futuras.");
        if (bl == null || bl.isEmpty()) throw new IllegalArgumentException("Agrega al menos un horario de clases.");
        for (Bloque b : bl) {
            if (b.dia < 1 || b.dia > 7) throw new IllegalArgumentException("Día no válido.");
            if (!horaValida(b.ini) || !horaValida(b.fin)) throw new IllegalArgumentException("Las horas deben tener formato HH:MM.");
            if (b.ini.compareTo(b.fin) >= 0) throw new IllegalArgumentException(DIAS[b.dia] + ": la hora de fin debe ser posterior a la de inicio.");
        }
        for (int i = 0; i < bl.size(); i++)
            for (int j = i + 1; j < bl.size(); j++) {
                Bloque a = bl.get(i), b = bl.get(j);
                if (a.dia == b.dia && a.ini.compareTo(b.fin) < 0 && b.ini.compareTo(a.fin) < 0)
                    throw new IllegalArgumentException(DIAS[a.dia] + ": los horarios " + a.ini + "-" + a.fin + " y " + b.ini + "-" + b.fin + " se solapan.");
            }
    }

    // ------------------------------------------------------------------ escritura

    /**
     * Crea una solicitud con sus bloques. autoAprobar = true cuando la registra el jefe/administracion por el usuario.
     * Devuelve el id nuevo. Lanza IllegalArgumentException si los datos no son validos.
     */
    public static int crear(Connection cn, int idUsuario, int idRegistra, LocalDate desde, LocalDate hasta, String obs, List<Bloque> bl, boolean autoAprobar) throws Exception {
        validar(desde, hasta, bl);
        if (obs != null && obs.length() > 500) obs = obs.substring(0, 500);
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            int id = 0;
            for (int intento = 0; intento < 3 && id == 0; intento++) {
                int nuevo = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_SOL),0)+1 FROM HOR_CLASE_SOL"); ResultSet rs = st.executeQuery()) { if (rs.next()) nuevo = rs.getInt(1); }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO HOR_CLASE_SOL (ID_SOL, ID_USUARIO, FECHA_DESDE, FECHA_HASTA, ESTADO, OBSERVACION, ID_REGISTRA, ID_APRUEBA, FECHA_APRUEBA) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, " + (autoAprobar ? "SYSDATE" : "NULL") + ")")) {
                    st.setInt(1, nuevo); st.setInt(2, idUsuario);
                    st.setDate(3, Date.valueOf(desde)); st.setDate(4, Date.valueOf(hasta));
                    st.setString(5, autoAprobar ? "APROBADO" : "PENDIENTE");
                    if (obs == null || obs.trim().isEmpty()) st.setNull(6, Types.VARCHAR); else st.setString(6, obs.trim());
                    st.setInt(7, idRegistra);
                    if (autoAprobar) st.setInt(8, idRegistra); else st.setNull(8, Types.NUMERIC);
                    st.executeUpdate();
                    id = nuevo;
                } catch (SQLIntegrityConstraintViolationException dup) { id = 0; }
            }
            if (id == 0) throw new Exception("No se pudo generar el número de solicitud, intenta de nuevo.");
            try (PreparedStatement st = cn.prepareStatement("INSERT INTO HOR_CLASE_BLOQUE (ID_SOL, DIA, HORA_INI, HORA_FIN, MATERIA) VALUES (?, ?, ?, ?, ?)")) {
                for (Bloque b : bl) {
                    st.setInt(1, id); st.setInt(2, b.dia); st.setString(3, b.ini); st.setString(4, b.fin);
                    if (b.materia == null || b.materia.isEmpty()) st.setNull(5, Types.VARCHAR); else st.setString(5, b.materia);
                    st.addBatch();
                }
                st.executeBatch();
            }
            if (autoAprobar) reemplazarAnteriores(cn, idUsuario, id, desde, hasta);
            cn.commit();
            return id;
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    private static void reemplazarAnteriores(Connection cn, int idUsuario, int idNueva, LocalDate desde, LocalDate hasta) throws Exception {
        try (PreparedStatement st = cn.prepareStatement(
                "UPDATE HOR_CLASE_SOL SET ESTADO = 'REEMPLAZADO' WHERE ID_USUARIO = ? AND ID_SOL <> ? AND ESTADO = 'APROBADO' AND FECHA_DESDE <= ? AND FECHA_HASTA >= ?")) {
            st.setInt(1, idUsuario); st.setInt(2, idNueva); st.setDate(3, Date.valueOf(hasta)); st.setDate(4, Date.valueOf(desde));
            st.executeUpdate();
        }
    }

    /** Datos basicos de una solicitud: {idUsuario, estado, desde, hasta, idRegistra} o null si no existe. */
    public static Object[] datosBasicos(Connection cn, int idSol) throws Exception {
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_USUARIO, ESTADO, FECHA_DESDE, FECHA_HASTA, ID_REGISTRA FROM HOR_CLASE_SOL WHERE ID_SOL = ?")) {
            st.setInt(1, idSol);
            try (ResultSet rs = st.executeQuery()) {
                if (!rs.next()) return null;
                return new Object[]{rs.getInt(1), rs.getString(2), rs.getDate(3).toLocalDate(), rs.getDate(4).toLocalDate(), rs.getInt(5)};
            }
        }
    }

    public static void aprobar(Connection cn, int idSol, int idAprueba) throws Exception {
        Object[] b = datosBasicos(cn, idSol);
        if (b == null || !"PENDIENTE".equals(b[1])) throw new IllegalArgumentException("La solicitud ya no está pendiente.");
        boolean ac = cn.getAutoCommit();
        cn.setAutoCommit(false);
        try {
            int n;
            try (PreparedStatement st = cn.prepareStatement("UPDATE HOR_CLASE_SOL SET ESTADO = 'APROBADO', ID_APRUEBA = ?, FECHA_APRUEBA = SYSDATE WHERE ID_SOL = ? AND ESTADO = 'PENDIENTE'")) {
                st.setInt(1, idAprueba); st.setInt(2, idSol); n = st.executeUpdate();
            }
            if (n == 0) throw new IllegalArgumentException("La solicitud ya no está pendiente.");
            reemplazarAnteriores(cn, (Integer) b[0], idSol, (LocalDate) b[2], (LocalDate) b[3]);
            cn.commit();
        } catch (Exception e) { cn.rollback(); throw e; }
        finally { cn.setAutoCommit(ac); }
    }

    public static void rechazar(Connection cn, int idSol, int idAprueba, String motivo) throws Exception {
        if (motivo == null || motivo.trim().length() < 3) throw new IllegalArgumentException("Indica el motivo del rechazo.");
        if (motivo.length() > 500) motivo = motivo.substring(0, 500);
        try (PreparedStatement st = cn.prepareStatement("UPDATE HOR_CLASE_SOL SET ESTADO = 'RECHAZADO', ID_APRUEBA = ?, FECHA_APRUEBA = SYSDATE, MOTIVO_RECHAZO = ? WHERE ID_SOL = ? AND ESTADO = 'PENDIENTE'")) {
            st.setInt(1, idAprueba); st.setString(2, motivo.trim()); st.setInt(3, idSol);
            if (st.executeUpdate() == 0) throw new IllegalArgumentException("La solicitud ya no está pendiente.");
        }
    }

    /** Cancela: el propio usuario solo si esta PENDIENTE; la gestion (jefe/administracion) tambien una APROBADA (anularla). */
    public static void cancelar(Connection cn, int idSol, boolean comoGestion) throws Exception {
        try (PreparedStatement st = cn.prepareStatement("UPDATE HOR_CLASE_SOL SET ESTADO = 'CANCELADO' WHERE ID_SOL = ? AND ESTADO IN ('PENDIENTE'" + (comoGestion ? ",'APROBADO'" : "") + ")")) {
            st.setInt(1, idSol);
            if (st.executeUpdate() == 0) throw new IllegalArgumentException("No se puede cancelar: la solicitud ya cambió de estado.");
        }
    }

    // ------------------------------------------------------------------ consultas

    private static final String SELECT_SOL =
        "SELECT s.ID_SOL, s.ID_USUARIO, u.NOMBRE || ' ' || u.APELLIDOS, d.DEPARTAMENTO, s.ESTADO, s.OBSERVACION, s.FECHA_DESDE, s.FECHA_HASTA, " +
        "       s.ID_REGISTRA, ur.NOMBRE || ' ' || ur.APELLIDOS, ua.NOMBRE || ' ' || ua.APELLIDOS, s.MOTIVO_RECHAZO " +
        "FROM HOR_CLASE_SOL s JOIN USUARIO u ON u.IDUSUARIO = s.ID_USUARIO " +
        "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = s.ID_USUARIO " +
        "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
        "LEFT JOIN USUARIO ur ON ur.IDUSUARIO = s.ID_REGISTRA LEFT JOIN USUARIO ua ON ua.IDUSUARIO = s.ID_APRUEBA ";

    private static List<Solicitud> leer(Connection cn, String whereOrder, Integer parametro) throws Exception {
        List<Solicitud> r = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement(SELECT_SOL + whereOrder)) {
            if (parametro != null) st.setInt(1, parametro);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Solicitud s = new Solicitud();
                    s.id = rs.getInt(1); s.idUsuario = rs.getInt(2); s.nombre = rs.getString(3); s.departamento = rs.getString(4);
                    s.estado = rs.getString(5); s.observacion = rs.getString(6);
                    s.desde = rs.getDate(7).toLocalDate(); s.hasta = rs.getDate(8).toLocalDate();
                    s.registradoPorOtro = rs.getInt(9) != s.idUsuario; s.registradoPor = rs.getString(10);
                    s.apruebaNombre = rs.getString(11); s.motivoRechazo = rs.getString(12);
                    r.add(s);
                }
            }
        }
        cargarBloques(cn, r);
        return r;
    }

    /** Solicitudes de un usuario (las 30 mas recientes). */
    public static List<Solicitud> delUsuario(Connection cn, int idUsuario) throws Exception {
        return leer(cn, "WHERE s.ID_USUARIO = ? AND s.ESTADO <> 'REEMPLAZADO' ORDER BY s.FECHA_REG DESC, s.ID_SOL DESC", idUsuario);
    }

    /** Pendientes de los empleados que "yo" gestiona. */
    public static List<Solicitud> pendientes(HttpSession session, Connection cn, int yo) throws Exception {
        return leer(cn, "WHERE s.ESTADO = 'PENDIENTE' AND s.ID_USUARIO <> " + yo + " AND " + condicionEquipoSql(session, cn, yo) + " ORDER BY s.FECHA_REG, s.ID_SOL", null);
    }

    /** Aprobadas con vigencia que no ha terminado, de los empleados que "yo" gestiona. */
    public static List<Solicitud> vigentes(HttpSession session, Connection cn, int yo) throws Exception {
        return leer(cn, "WHERE s.ESTADO = 'APROBADO' AND s.FECHA_HASTA >= TRUNC(SYSDATE) AND s.ID_USUARIO <> " + yo + " AND " + condicionEquipoSql(session, cn, yo) + " ORDER BY u.NOMBRE, u.APELLIDOS", null);
    }

    private static void cargarBloques(Connection cn, List<Solicitud> l) throws Exception {
        if (l.isEmpty()) return;
        Map<Integer, Solicitud> m = new LinkedHashMap<>();
        StringBuilder in = new StringBuilder();
        for (Solicitud s : l) { m.put(s.id, s); in.append(in.length() > 0 ? "," : "").append(s.id); }
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_SOL, DIA, HORA_INI, HORA_FIN, MATERIA FROM HOR_CLASE_BLOQUE WHERE ID_SOL IN (" + in + ") ORDER BY DIA, HORA_INI");
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) m.get(rs.getInt(1)).bloques.add(new Bloque(rs.getInt(2), rs.getString(3), rs.getString(4), rs.getString(5)));
        }
    }

    /** Texto agrupado: "Lun, Mié, Jue · 13:00-15:00 · Materia" (una linea por franja horaria distinta). */
    public static List<String> resumen(List<Bloque> bl) {
        Map<String, TreeSet<Integer>> g = new LinkedHashMap<>();
        for (Bloque b : bl) g.computeIfAbsent(b.ini + "-" + b.fin + "|" + (b.materia == null ? "" : b.materia), k -> new TreeSet<>()).add(b.dia);
        List<String> r = new ArrayList<>();
        for (Map.Entry<String, TreeSet<Integer>> e : g.entrySet()) {
            StringBuilder sb = new StringBuilder();
            for (int d : e.getValue()) sb.append(sb.length() > 0 ? ", " : "").append(DIAS_CORTO[d]);
            String[] p = e.getKey().split("\\|", -1);
            sb.append(" · ").append(p[0]);
            if (p.length > 1 && !p[1].isEmpty()) sb.append(" · ").append(p[1]);
            r.add(sb.toString());
        }
        return r;
    }

    // ------------------------------------------------------------------ tarjetas del dashboard

    /**
     * Horarios aprobados del usuario con vigencia que no ha terminado. Con ellos se calculan "hoy" y "proximos dias".
     */
    public static List<Solicitud> aprobadasVigentesDe(Connection cn, int idUsuario) throws Exception {
        return leer(cn, "WHERE s.ID_USUARIO = ? AND s.ESTADO = 'APROBADO' AND s.FECHA_HASTA >= TRUNC(SYSDATE) ORDER BY s.FECHA_DESDE", idUsuario);
    }

    /** Bloques (ordenados por hora) que aplican al usuario en una fecha concreta segun sus horarios aprobados. */
    public static List<Bloque> bloquesEnFecha(List<Solicitud> aprobadas, LocalDate fecha) {
        List<Bloque> r = new ArrayList<>();
        int dia = fecha.getDayOfWeek().getValue();
        for (Solicitud s : aprobadas) {
            if (fecha.isBefore(s.desde) || fecha.isAfter(s.hasta)) continue;
            for (Bloque b : s.bloques) if (b.dia == dia) r.add(b);
        }
        r.sort((a, b) -> a.ini.compareTo(b.ini));
        return r;
    }

    /**
     * Empleados del equipo de "yo" con clases en la fecha dada (horarios aprobados y vigentes ese dia): una fila por bloque
     * {nombre, departamento, horaIni, horaFin}, ordenada por hora. No incluye a "yo".
     */
    public static List<String[]> conClasesEnFecha(HttpSession session, Connection cn, int yo, LocalDate fecha) throws Exception {
        List<String[]> r = new ArrayList<>();
        String sql = "SELECT u.NOMBRE || ' ' || u.APELLIDOS, d.DEPARTAMENTO, b.HORA_INI, b.HORA_FIN " +
                "FROM HOR_CLASE_SOL s JOIN HOR_CLASE_BLOQUE b ON b.ID_SOL = s.ID_SOL JOIN USUARIO u ON u.IDUSUARIO = s.ID_USUARIO " +
                "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = s.ID_USUARIO " +
                "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
                "WHERE s.ESTADO = 'APROBADO' AND u.ESTADO = 'a' AND ? BETWEEN s.FECHA_DESDE AND s.FECHA_HASTA AND b.DIA = ? " +
                "AND s.ID_USUARIO <> " + yo + " AND " + condicionEquipoSql(session, cn, yo) + " ORDER BY b.HORA_INI, u.NOMBRE";
        try (PreparedStatement st = cn.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(fecha)); st.setInt(2, fecha.getDayOfWeek().getValue());
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) r.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4)});
            }
        }
        return r;
    }
}
