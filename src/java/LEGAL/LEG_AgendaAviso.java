package LEGAL;

import Servlets.Conexion;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Recordatorio por correo de la agenda legal. A cada responsable le llega UN correo con sus eventos PENDIENTES del proximo dia habil
 * (los viernes: sabado, domingo y lunes). No repite: LEG_AGENDA_AVISO guarda evento + fecha + responsable ya avisados.
 * Con legal.aviso.prueba el correo va solo a esa direccion y no se marca como enviado. Lo dispara LEG_AgendaScheduler (si
 * legal.recordatorio=S) o manualmente la pagina Legal/LEG_AgendaAviso.jsp.
 */
public class LEG_AgendaAviso {

    public static class Resultado {
        public int usuarios, eventos, enviados;
        public List<String> detalle = new ArrayList<>(), errores = new ArrayList<>();
        public LocalDate desde, hasta;
    }

    private static final DateTimeFormatter F = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final String[] DIA = {"", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"};

    /** Ventana de fechas a recordar para el dia "hoy": del dia siguiente al proximo dia habil. */
    public static LocalDate[] ventana(LocalDate hoy) {
        LocalDate desde = hoy.plusDays(1), hasta = desde;
        while (hasta.getDayOfWeek() == DayOfWeek.SATURDAY || hasta.getDayOfWeek() == DayOfWeek.SUNDAY) hasta = hasta.plusDays(1);
        return new LocalDate[]{desde, hasta};
    }

    /** enviar = false solo calcula (vista previa). */
    public static Resultado ejecutar(boolean enviar) throws Exception {
        Resultado r = new Resultado();
        LocalDate[] v = ventana(LocalDate.now());
        r.desde = v[0]; r.hasta = v[1];
        String prueba = Servlets.MailConfig.LEGAL_AVISO_PRUEBA;
        boolean modoPrueba = prueba != null && !prueba.isEmpty();
        // por responsable: {nombre, emails, lineas...}
        Map<Integer, String[]> datos = new LinkedHashMap<>();
        Map<Integer, List<String>> lineas = new LinkedHashMap<>();
        Map<Integer, List<Object[]>> claves = new LinkedHashMap<>();   // {idEvento, fecha} para marcar como avisados
        try (Connection cn = Conexion.getConnection()) {
            if (cn == null) throw new Exception("Sin conexión a la base de datos");
            String sql = "SELECT a.ID_EVENTO, a.FECHA, a.HORA_INI, a.HORA_FIN, a.ASUNTO, t.NOMBRE, a.MODALIDAD, a.LUGAR, u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS, u.EMAIL " +
                    "FROM LEG_AGENDA a JOIN LEG_AGENDA_TIPO t ON t.ID_TIPO = a.ID_TIPO JOIN LEG_AGENDA_RESP r ON r.ID_EVENTO = a.ID_EVENTO " +
                    "JOIN USUARIO u ON u.IDUSUARIO = r.ID_USUARIO " +
                    "WHERE a.ESTADO = 'PENDIENTE' AND u.ESTADO = 'a' AND TRUNC(a.FECHA) BETWEEN ? AND ? " +
                    (modoPrueba ? "" : "AND NOT EXISTS (SELECT 1 FROM LEG_AGENDA_AVISO x WHERE x.ID_EVENTO = a.ID_EVENTO AND x.FECHA_EVENTO = TRUNC(a.FECHA) AND x.ID_USUARIO = u.IDUSUARIO) ") +
                    "ORDER BY u.IDUSUARIO, a.FECHA, a.HORA_INI";
            try (PreparedStatement st = cn.prepareStatement(sql)) {
                st.setDate(1, Date.valueOf(v[0])); st.setDate(2, Date.valueOf(v[1]));
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        int uid = rs.getInt(9);
                        datos.putIfAbsent(uid, new String[]{rs.getString(10), rs.getString(11)});
                        LocalDate f = rs.getDate(2).toLocalDate();
                        String l = "- " + DIA[f.getDayOfWeek().getValue()] + " " + F.format(f) + " " + rs.getString(3) + (rs.getString(4) == null ? "" : "-" + rs.getString(4)) + " · " + rs.getString(6) + " · " + rs.getString(5)
                                + "\n    " + ("V".equals(rs.getString(7)) ? "Virtual" : "Presencial") + (rs.getString(8) == null || rs.getString(8).isEmpty() ? "" : ": " + rs.getString(8));
                        lineas.computeIfAbsent(uid, k -> new ArrayList<>()).add(l);
                        claves.computeIfAbsent(uid, k -> new ArrayList<>()).add(new Object[]{rs.getInt(1), f});
                        r.eventos++;
                    }
                }
            }
            r.usuarios = datos.size();
            for (Map.Entry<Integer, String[]> e : datos.entrySet()) {
                Set<String> dest = correos(e.getValue()[1]);
                r.detalle.add(e.getValue()[0] + " (" + lineas.get(e.getKey()).size() + " evento(s)) → " + (dest.isEmpty() ? "SIN CORREO VÁLIDO" : String.join(", ", dest)));
                if (!enviar) continue;
                if (!Servlets.MailConfig.SMTP_HABILITADO) { r.errores.add("SMTP deshabilitado en este servidor: no se envió nada."); break; }
                if (dest.isEmpty()) continue;
                StringBuilder b = new StringBuilder("Hola ").append(e.getValue()[0]).append(",\n\nEstos son tus eventos próximos de la agenda legal:\n\n");
                for (String l : lineas.get(e.getKey())) b.append(l).append("\n");
                b.append("\nEntra a ProMaNet > Agenda legal para verlos o actualizar su estado.\n\nSaludos cordiales,\nProMaNet");
                String asunto = "Agenda legal: " + lineas.get(e.getKey()).size() + (lineas.get(e.getKey()).size() == 1 ? " evento próximo" : " eventos próximos");
                String cuerpo = b.toString();
                Set<String> destinos = dest;
                if (modoPrueba) {
                    cuerpo = "[MODO PRUEBA] Este correo habría ido a: " + String.join(", ", dest) + "\n\n" + cuerpo;
                    asunto = "[PRUEBA] " + asunto; destinos = new LinkedHashSet<>(); destinos.add(prueba);
                }
                boolean alguno = false;
                for (String d : destinos) {
                    try { Servlets.Correo.enviar(d, asunto, cuerpo); alguno = true; }
                    catch (Exception ex) { r.errores.add("Falló el envío a " + d + ": " + ex.getMessage()); }
                }
                if (alguno) {
                    r.enviados++;
                    if (!modoPrueba) {
                        try (PreparedStatement ins = cn.prepareStatement("INSERT INTO LEG_AGENDA_AVISO (ID_EVENTO, FECHA_EVENTO, ID_USUARIO) VALUES (?, ?, ?)")) {
                            for (Object[] k : claves.get(e.getKey())) { ins.setInt(1, (Integer) k[0]); ins.setDate(2, Date.valueOf((LocalDate) k[1])); ins.setInt(3, e.getKey()); ins.addBatch(); }
                            ins.executeBatch();
                        }
                    }
                }
            }
        }
        return r;
    }

    private static Set<String> correos(String campo) {
        Set<String> r = new LinkedHashSet<>();
        if (campo == null) return r;
        for (String c : campo.split("[,;\\s]+")) { c = c.trim(); if (c.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) r.add(c); }
        return r;
    }
}
