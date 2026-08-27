package Servlets;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

// Configuracion SMTP para el envio de correos (ej. bienvenida al crear un
// usuario). Sigue la misma convencion que Conexion.java: valores por
// defecto no sensibles en el codigo, y la clave real SIEMPRE viene de un
// archivo externo que NO esta en el repositorio -- nunca se hardcodea ni
// se sube a git.
public class MailConfig {

    public static String SMTP_HOST = "mail.buadnet.com.ec";
    public static int SMTP_PORT = 465;
    public static String SMTP_USER = "soporte@buadnet.com.ec";
    public static String SMTP_PASS = "";
    public static String SMTP_FROM_NOMBRE = "ProMaNet - Soporte";

    // true solo si se cargo una clave real desde el archivo externo.
    public static boolean SMTP_HABILITADO = false;

    static {
        try {
            // Mismo archivo/propiedad que usa Conexion.java para la base de
            // datos -- evita tener que mantener un segundo archivo en el
            // servidor. Claves nuevas: smtp.host, smtp.port, smtp.user,
            // smtp.pass, smtp.from.nombre (todas opcionales).
            String ruta = System.getProperty("promanet.db.config", "/opt/promanet/db.properties");
            File f = new File(ruta);
            if (f.exists()) {
                Properties p = new Properties();
                FileInputStream in = new FileInputStream(f);
                try {
                    p.load(in);
                } finally {
                    in.close();
                }
                SMTP_HOST = p.getProperty("smtp.host", SMTP_HOST);
                SMTP_PORT = Integer.parseInt(p.getProperty("smtp.port", String.valueOf(SMTP_PORT)).trim());
                SMTP_USER = p.getProperty("smtp.user", SMTP_USER);
                SMTP_PASS = p.getProperty("smtp.pass", SMTP_PASS);
                SMTP_FROM_NOMBRE = p.getProperty("smtp.from.nombre", SMTP_FROM_NOMBRE);
                System.out.println("MailConfig: configuracion cargada desde " + ruta);
            }
        } catch (Exception e) {
            System.out.println("MailConfig: no se pudo cargar config externa, correo queda deshabilitado. " + e);
        }
        SMTP_HABILITADO = SMTP_PASS != null && !SMTP_PASS.trim().isEmpty();
    }
}
