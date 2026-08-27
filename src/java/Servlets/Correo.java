package Servlets;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
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

        Transport.send(msg);
        return true;
    }
}
