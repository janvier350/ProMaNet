package LEGAL;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Revisa cada 20 minutos si toca enviar los recordatorios de la agenda legal: de lunes a viernes, a partir de la hora configurada
 * (legal.recordatorio.hora, por defecto 16). Solo corre si legal.recordatorio=S en el db.properties de ese servidor; sin eso no
 * hace nada (asi un Tomcat de pruebas o de casa nunca envia correos). Si hay mas de un servidor encendido, LEG_AGENDA_AVISO evita duplicados.
 */
@WebListener
public class LEG_AgendaScheduler implements ServletContextListener {

    private ScheduledExecutorService ex;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        if (!Servlets.MailConfig.LEGAL_RECORDATORIO) {
            System.out.println("LEG_AgendaScheduler: recordatorios de agenda legal APAGADOS (legal.recordatorio no es S).");
            return;
        }
        ex = Executors.newSingleThreadScheduledExecutor(r -> { Thread t = new Thread(r, "legal-recordatorio"); t.setDaemon(true); return t; });
        ex.scheduleWithFixedDelay(() -> {
            try {
                LocalDateTime ahora = LocalDateTime.now();
                DayOfWeek d = ahora.getDayOfWeek();
                if (d == DayOfWeek.SATURDAY || d == DayOfWeek.SUNDAY) return;
                if (ahora.getHour() < Servlets.MailConfig.LEGAL_RECORDATORIO_HORA) return;
                LEG_AgendaAviso.Resultado r = LEG_AgendaAviso.ejecutar(true);
                if (r.usuarios > 0 || !r.errores.isEmpty())
                    System.out.println("LEG_AgendaScheduler: " + r.enviados + " recordatorio(s) enviado(s) de " + r.usuarios + ". Errores: " + r.errores);
            } catch (Throwable t) { System.out.println("LEG_AgendaScheduler: " + t); }
        }, 1, 20, TimeUnit.MINUTES);
        System.out.println("LEG_AgendaScheduler: recordatorios de agenda legal ENCENDIDOS (desde las " + Servlets.MailConfig.LEGAL_RECORDATORIO_HORA + ":00, lunes a viernes).");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) { if (ex != null) ex.shutdownNow(); }
}
