package Servlets;

import jakarta.mail.Authenticator;
import jakarta.mail.Flags;
import jakarta.mail.Folder;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Store;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Date;
import java.util.Properties;

// Envio de correos por SMTP (cuenta soporte@buadnet.com.ec, hosting cPanel).
// Si no hay clave SMTP configurada en el servidor (ver MailConfig), enviar()
// no intenta nada y devuelve false -- quien llama debe tener un fallback
// (ej. el texto para copiar y pegar a mano que ya existia).
public class Correo {

    public static boolean enviar(String destinatario, String asunto, String cuerpoTexto) throws MessagingException {
        if (!MailConfig.SMTP_HABILITADO) return false;
        if (destinatario == null || destinatario.trim().isEmpty()) return false;

        Properties props = new Properties();
        props.put("mail.smtp.host", MailConfig.SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(MailConfig.SMTP_PORT));
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true");
        // Muchos hostings cPanel usan un certificado que no encadena con la
        // confianza por defecto del JVM -- sin esto, el handshake SSL falla
        // con "unable to find valid certification path".
        props.put("mail.smtp.ssl.trust", MailConfig.SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MailConfig.SMTP_USER, MailConfig.SMTP_PASS);
            }
        });

        MimeMessage msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(MailConfig.SMTP_USER, MailConfig.SMTP_FROM_NOMBRE));
        } catch (Exception e) {
            msg.setFrom(new InternetAddress(MailConfig.SMTP_USER));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        msg.setSubject(asunto, "UTF-8");
        msg.setText(cuerpoTexto, "UTF-8");
        msg.setSentDate(new Date());

        Transport.send(msg);

        // Dejar una copia en "Enviados" para que quede evidencia -- SMTP
        // puro no toca esa carpeta (eso lo hacen los clientes de correo via
        // IMAP, no el protocolo de envio). Si esto falla no se considera
        // que el correo no se envio: ya salio por SMTP, esto es solo
        // cosmetico/evidencia.
        guardarCopiaEnviados(msg);

        return true;
    }

    private static void guardarCopiaEnviados(MimeMessage msg) {
        try {
            msg.setFlag(Flags.Flag.SEEN, true);
        } catch (Exception ignore) {}

        Properties props = new Properties();
        props.put("mail.imap.ssl.enable", "true");
        props.put("mail.imap.ssl.trust", MailConfig.IMAP_HOST);
        Session imapSession = Session.getInstance(props);

        for (String nombreCarpeta : MailConfig.IMAP_CARPETAS_ENVIADOS) {
            Store store = null;
            Folder carpeta = null;
            try {
                store = imapSession.getStore("imaps");
                store.connect(MailConfig.IMAP_HOST, MailConfig.IMAP_PORT, MailConfig.SMTP_USER, MailConfig.SMTP_PASS);
                carpeta = store.getFolder(nombreCarpeta);
                if (!carpeta.exists()) continue;
                carpeta.open(Folder.READ_WRITE);
                carpeta.appendMessages(new Message[]{msg});
                return;
            } catch (Exception e) {
                System.out.println("Correo: no se pudo guardar copia en la carpeta '" + nombreCarpeta + "'. " + e);
            } finally {
                try { if (carpeta != null && carpeta.isOpen()) carpeta.close(false); } catch (Exception ignore) {}
                try { if (store != null) store.close(); } catch (Exception ignore) {}
            }
        }
        System.out.println("Correo: no se encontro ninguna carpeta de Enviados conocida ("
                + String.join(", ", MailConfig.IMAP_CARPETAS_ENVIADOS) + ") -- el correo SI se envio, solo no quedo copia.");
    }
}
