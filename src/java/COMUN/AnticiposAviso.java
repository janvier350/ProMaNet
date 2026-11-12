package COMUN;

import Servlets.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Aviso por correo de que el modulo de anticipos esta habilitado, al registrar la fecha de corte del mes.
 * Destinatarios: usuarios activos con correo y con acceso al modulo (permiso resuelto por cargo, departamento y
 * usuario, igual que al iniciar sesion). Fecha de apertura = dia en que se registra el corte; cierre = fecha de corte.
 * Se envia en un hilo aparte: si el correo falla o tarda, el registro de la fecha de corte no se ve afectado.
 */
public class AnticiposAviso {

    public static final String MODULO_AUDITORIA = "AUD";
    public static final String MODULO_CONTROL = "CTRL";

    private static final String[] MESES = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
        "agosto", "septiembre", "octubre", "noviembre", "diciembre"};

    /** Nombre de quien registra la fecha de corte, para la firma del correo de aviso. */
    public static String firmante(jakarta.servlet.http.HttpSession s) {
        String n = s.getAttribute("nombre") == null ? "" : s.getAttribute("nombre").toString().trim();
        String a = s.getAttribute("apellidos") == null ? "" : s.getAttribute("apellidos").toString().trim();
        return (n + " " + a).trim();
    }

    /** Lanza el envio en segundo plano. No lanza excepciones. */
    public static void enviarAsync(final String modulo, final LocalDate corte, final String firmante) {
        Thread t = new Thread(() -> {
            try {
                int n = enviar(modulo, corte, firmante);
                System.out.println("AnticiposAviso[" + modulo + "]: aviso de apertura enviado a " + n + " usuarios.");
            } catch (Exception e) {
                System.out.println("AnticiposAviso[" + modulo + "]: no se pudo enviar el aviso. " + e);
            }
        }, "anticipos-aviso-" + modulo);
        t.setDaemon(true);
        t.start();
    }

    public static int enviar(String modulo, LocalDate corte, String firmante) throws Exception {
        if (!Servlets.MailConfig.SMTP_HABILITADO) return 0;
        String permiso = MODULO_AUDITORIA.equals(modulo) ? "ANTICIPOS_AUD_ACCESO" : "CONTROL_ACCESO";
        List<String> correos = destinatarios(permiso);
        if (correos.isEmpty()) return 0;

        LocalDate apertura = LocalDate.now();
        String html = construirHtml(corte, apertura, firmante);
        String asunto = "Anticipos de sueldo de " + MESES[corte.getMonthValue() - 1] + " habilitados en PROMANET";
        return Servlets.Correo.enviarHtmlBcc(correos, asunto, html);
    }

    static List<String> destinatarios(String permiso) throws Exception {
        Set<String> out = new LinkedHashSet<>();
        try (Connection cn = Conexion.getConnection()) {
            if (cn == null) return new ArrayList<>();
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT u.IDUSUARIO, u.IDROL, u.EMAIL, d.DEPARTAMENTO FROM USUARIO u " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
                    "WHERE u.ESTADO = 'a' AND u.EMAIL IS NOT NULL");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Set<String> perm = PermisoHelper.cargarPermisos(rs.getInt(1), rs.getInt(2), rs.getString(4));
                    if (!perm.contains(permiso)) continue;
                    String e = rs.getString(3);
                    if (e == null) continue;
                    for (String c : e.split("[,;\\s]+")) {
                        c = c.trim();
                        if (c.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) out.add(c);
                    }
                }
            }
        }
        return new ArrayList<>(out);
    }

    private static String fecha(LocalDate f) {
        return f.getDayOfMonth() + " de " + MESES[f.getMonthValue() - 1] + "/" + f.getYear();
    }

    private static String esc(String s) {
        return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    static String construirHtml(LocalDate corte, LocalDate apertura, String firmante) {
        String mes = MESES[corte.getMonthValue() - 1];
        return "<div style=\"font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#222;line-height:1.5\">"
            + "<p>Estimados</p>"
            + "<p>Por medio del presente correo, les informamos que la plataforma <b><u>PROMANET</u></b> se encuentra habilitada "
            + "para que puedan realizar sus solicitudes de anticipos de sueldo correspondiente al mes de " + mes + ".</p>"
            + "<p>El sistema estar&aacute; disponible para la recepci&oacute;n de sus requerimientos estrictamente en el siguiente per&iacute;odo:</p>"
            + "<ul><li><b>Fecha de apertura:</b> " + fecha(apertura) + "</li>"
            + "<li><b>Fecha de cierre:</b> " + fecha(corte) + "</li></ul>"
            + "<p><b><u>Aviso importante:</u></b> Es de suma importancia que registren su solicitud dentro del plazo mencionado. "
            + "Por motivos administrativos y de cierre, no se procesar&aacute; ninguna solicitud que ingrese fuera de este horario, "
            + "les sugerimos realizar su tr&aacute;mite con la debida anticipaci&oacute;n para evitar cualquier inconveniente de &uacute;ltimo minuto.</p>"
            + "<p>Agradecemos su comprensi&oacute;n y puntualidad.</p>"
            + "<p><b>Saludos cordiales,</b></p>"
            + "<p><b>" + esc(firmante) + "</b></p>"
            + "</div>";
    }
}
