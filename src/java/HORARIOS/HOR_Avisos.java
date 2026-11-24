package HORARIOS;

import Servlets.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Correos del horario de clases (se envian en un hilo aparte; si fallan no afectan la operacion):
 *  - nuevaSolicitudAsync: al jefe directo del usuario (si no tiene, a los gestores de Vacaciones de su grupo) cuando llega una solicitud.
 *  - decisionAsync: al usuario cuando se aprueba, se rechaza o la administracion/jefe registra el horario por el.
 * Con "horarios.aviso.prueba=correo" en db.properties todo va solo a esa direccion (ver MailConfig). Sin clave SMTP no se envia nada.
 */
public class HOR_Avisos {

    private static final DateTimeFormatter F = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public static void nuevaSolicitudAsync(final int idSol) {
        lanzar("horarios-aviso-nueva", () -> enviarNueva(idSol));
    }

    /** tipo: APROBADO | RECHAZADO | REGISTRADO (lo registro el jefe/administracion por el usuario, ya aprobado). */
    public static void decisionAsync(final int idSol, final String tipo) {
        lanzar("horarios-aviso-decision", () -> enviarDecision(idSol, tipo));
    }

    private interface Tarea { void run() throws Exception; }

    private static void lanzar(String nombre, final Tarea t) {
        Thread th = new Thread(() -> {
            try { t.run(); } catch (Exception e) { System.out.println("HOR_Avisos: no se pudo enviar el aviso. " + e); }
        }, nombre);
        th.setDaemon(true);
        th.start();
    }

    private static void enviarNueva(int idSol) throws Exception {
        if (!Servlets.MailConfig.SMTP_HABILITADO) return;
        try (Connection cn = Conexion.getConnection()) {
            HOR_Helper.Solicitud s = HOR_Helper.obtener(cn, idSol);
            if (s == null || !"PENDIENTE".equals(s.estado)) return;
            Set<String> dest = correos(cn,
                    "SELECT u.EMAIL FROM VAC_CONFIG_USUARIO vc JOIN USUARIO u ON u.IDUSUARIO = vc.ID_JEFE_DIRECTO WHERE vc.ID_USUARIO = ? AND u.ESTADO = 'a'", s.idUsuario);
            if (dest.isEmpty())
                dest = correos(cn, "SELECT u.EMAIL FROM VAC_CONFIG_USUARIO vc JOIN VAC_GRUPO_GESTOR gg ON gg.ID_GRUPO = vc.ID_GRUPO " +
                        "JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO WHERE vc.ID_USUARIO = ? AND u.ESTADO = 'a'", s.idUsuario);
            StringBuilder b = new StringBuilder();
            b.append("Estimado/a,\n\n").append(s.nombre).append(" registr\u00f3 su horario de clases, vigente del ")
             .append(F.format(s.desde)).append(" al ").append(F.format(s.hasta)).append(", y est\u00e1 pendiente de aprobaci\u00f3n:\n\n");
            for (String l : HOR_Helper.resumen(s.bloques)) b.append("  - ").append(l).append("\n");
            if (s.observacion != null && !s.observacion.isEmpty()) b.append("\nObservaci\u00f3n: ").append(s.observacion).append("\n");
            b.append("\nIngresa a ProMaNet > Horario de clases > Horarios del equipo para aprobarlo o rechazarlo.\n\nSaludos cordiales,\nProMaNet");
            enviar(dest, "Horario de clases por aprobar: " + s.nombre, b.toString());
        }
    }

    private static void enviarDecision(int idSol, String tipo) throws Exception {
        if (!Servlets.MailConfig.SMTP_HABILITADO) return;
        try (Connection cn = Conexion.getConnection()) {
            HOR_Helper.Solicitud s = HOR_Helper.obtener(cn, idSol);
            if (s == null) return;
            Set<String> dest = correos(cn, "SELECT EMAIL FROM USUARIO WHERE IDUSUARIO = ? AND ESTADO = 'a'", s.idUsuario);
            StringBuilder b = new StringBuilder("Hola ").append(s.nombre).append(",\n\n");
            String asunto;
            String periodo = "del " + F.format(s.desde) + " al " + F.format(s.hasta);
            if ("RECHAZADO".equals(tipo)) {
                asunto = "Tu horario de clases fue rechazado";
                b.append("Tu horario de clases ").append(periodo).append(" fue rechazado");
                if (s.apruebaNombre != null) b.append(" por ").append(s.apruebaNombre);
                b.append(".\nMotivo: ").append(s.motivoRechazo == null ? "-" : s.motivoRechazo).append("\n\nPuedes registrar uno nuevo desde ProMaNet > Horario de clases.");
            } else {
                asunto = "REGISTRADO".equals(tipo) ? "Se registr\u00f3 tu horario de clases" : "Tu horario de clases fue aprobado";
                if ("REGISTRADO".equals(tipo)) b.append(s.registradoPor == null ? "Se" : s.registradoPor).append(" registr\u00f3 tu horario de clases ").append(periodo).append(" y qued\u00f3 aprobado:\n\n");
                else b.append("Tu horario de clases ").append(periodo).append(" fue aprobado").append(s.apruebaNombre != null ? " por " + s.apruebaNombre : "").append(":\n\n");
                for (String l : HOR_Helper.resumen(s.bloques)) b.append("  - ").append(l).append("\n");
            }
            b.append("\n\nSaludos cordiales,\nProMaNet");
            enviar(dest, asunto, b.toString());
        }
    }

    private static Set<String> correos(Connection cn, String sql, int id) throws Exception {
        Set<String> r = new LinkedHashSet<>();
        try (PreparedStatement st = cn.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String e = rs.getString(1);
                    if (e == null) continue;
                    for (String c : e.split("[,;\\s]+")) { c = c.trim(); if (c.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) r.add(c); }
                }
            }
        }
        return r;
    }

    private static void enviar(Set<String> dest, String asunto, String cuerpo) throws Exception {
        if (dest.isEmpty()) return;
        String prueba = Servlets.MailConfig.HORARIOS_AVISO_PRUEBA;
        if (prueba != null && !prueba.isEmpty()) {
            cuerpo = "[MODO PRUEBA] Este correo habr\u00eda ido a: " + String.join(", ", dest) + "\n\n" + cuerpo;
            asunto = "[PRUEBA] " + asunto;
            dest = new LinkedHashSet<>(); dest.add(prueba);
        }
        for (String d : new ArrayList<>(dest)) {
            try { Servlets.Correo.enviar(d, asunto, cuerpo); }
            catch (Exception e) { System.out.println("HOR_Avisos: fallo el env\u00edo a " + d + ". " + e); }
        }
    }
}
