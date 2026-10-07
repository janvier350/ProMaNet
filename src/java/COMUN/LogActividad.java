package COMUN;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

// Helper para registrar actividad de usuarios en LOG_ACTIVIDAD. Dos
// usos:
//
//   1) Automatico: COMUN.ActividadFilter llama a logVista(request) por
//      cada request al que entra una pantalla, para capturar "quien
//      estuvo en que modulo cuando". Esto cubre vistas de lectura.
//
//   2) Manual: los servlets de negocio llaman a registrar(session,
//      modulo, accion, descripcion) despues de hacer un cambio con
//      valor contable ("Creo ticket #544"), para que en la pantalla
//      de reporte se vea la accion con una descripcion humana en
//      vez de solo la URL.
//
// Los inserts se despachan a un ThreadPool chico para no sumarle
// latencia a la respuesta HTTP. Si el pool esta saturado se descarta
// el evento (lo preferimos a bloquear al usuario). Si Oracle esta
// caido no se cae la aplicacion -- se traga la excepcion.
public class LogActividad {

    private static final ExecutorService POOL = new ThreadPoolExecutor(
            1, 2, 60L, TimeUnit.SECONDS,
            new LinkedBlockingQueue<>(500),
            r -> {
                Thread t = new Thread(r, "LogActividad");
                t.setDaemon(true);
                return t;
            },
            new ThreadPoolExecutor.DiscardPolicy()
    );

    // Deriva el modulo a partir de la primera carpeta de la URL. Si no
    // calza con uno conocido, cae en OTRO para que igual quede registrado.
    public static String derivarModulo(String uri) {
        if (uri == null) return "OTRO";
        String u = uri.toUpperCase();
        // Login / cierre
        if (u.contains("/INGRESO") || u.endsWith("/INDEX.JSP") || u.equals("/PROMANET/") || u.equals("/PROMANET"))
            return "LOGIN";
        if (u.contains("CERRAR.JSP") || u.contains("LOGOUT"))
            return "LOGIN";
        // Modulos por carpeta
        if (u.contains("/INVENTARIO/INV_PERIFERICO") || u.contains("INV_PERIFERICO")) return "PERIFERICOS";
        if (u.contains("/INVENTARIO/") || u.contains("/INV_")) return "INVENTARIO";
        if (u.contains("/SOPORTES/")  || u.contains("/SOP_"))  return "SOPORTES";
        if (u.contains("/VACACIONES/") || u.contains("/VAC_")) return "VACACIONES";
        if (u.contains("/AUDITORIA/")  || u.contains("/AUD_") || u.contains("ANTICIPO")) return "ANTICIPOS";
        if (u.contains("/MOVILIZACION/") || u.contains("/MOV_") || u.contains("MOVILIZ")) return "MOVILIZACION";
        if (u.contains("/CAPACITACIONES/") || u.contains("/CAP_")) return "CAPACITACIONES";
        if (u.contains("/CONTROL/")   || u.contains("/ADM_") || u.contains("/PCN_")) return "ADMINISTRACION";
        if (u.contains("/TODO")) return "TODO";
        if (u.contains("/LEGAL") || u.contains("/LGL_")) return "LEGAL";
        if (u.contains("/AGENDA") || u.contains("CALENDARIO")) return "AGENDA";
        if (u.contains("/REPORTEGASTOS") || u.contains("REPORTEGAST")) return "REPORTE_GASTOS";
        if (u.contains("/PROYECTOS/") || u.contains("/PRO_")) return "PROYECTOS";
        return "OTRO";
    }

    // Deriva la accion por default a partir del metodo HTTP y la URL.
    // Las acciones mas finas (APROBAR, RECHAZAR, etc.) las informan los
    // servlets llamando a registrar() con el valor correcto.
    public static String derivarAccion(String metodoHttp, String uri) {
        if (uri != null) {
            String u = uri.toUpperCase();
            if (u.contains("IMPRIMIR") || u.contains("IMPRESION") || u.contains("ACTA.JSP")) return "IMPRIMIR";
            if (u.contains("EXPORTAR") || u.contains("EXPORT"))    return "EXPORTAR";
        }
        if ("POST".equalsIgnoreCase(metodoHttp)) return "ACTUALIZAR";
        return "VER";
    }

    // Llamado por el Filter: una fila por request de pantalla.
    public static void logVista(HttpServletRequest request) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("usuario") == null) return;

            String uri = request.getRequestURI();   // ej. /ProMaNet/Soportes/SOP_Dashboard.jsp
            String modulo = derivarModulo(uri);
            String accion = derivarAccion(request.getMethod(), uri);
            String ip = obtenerIp(request);
            Integer idUsuario = obtenerIdUsuario(session);
            String login = (String) session.getAttribute("usuario");

            insertarAsync(idUsuario, login, modulo, accion, null, uri, ip);
        } catch (Exception ignore) {
            // nunca romper el flujo del usuario por un log
        }
    }

    // API publica para servlets: una linea con descripcion humana.
    public static void registrar(HttpSession session, String modulo, String accion, String descripcion) {
        try {
            if (session == null) return;
            Integer idUsuario = obtenerIdUsuario(session);
            String login = (String) session.getAttribute("usuario");
            insertarAsync(idUsuario, login, modulo, accion, descripcion, null, null);
        } catch (Exception ignore) {}
    }

    // Variante que acepta request para capturar IP y URL tambien.
    public static void registrar(HttpServletRequest request, String modulo, String accion, String descripcion) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null) return;
            Integer idUsuario = obtenerIdUsuario(session);
            String login = (String) session.getAttribute("usuario");
            insertarAsync(idUsuario, login, modulo, accion, descripcion,
                    request.getRequestURI(), obtenerIp(request));
        } catch (Exception ignore) {}
    }

    // Inserta en LOG_ACTIVIDAD en el pool background. Si la cola esta
    // llena, el DiscardPolicy del executor descarta la tarea
    // silenciosamente -- preferimos perder un log antes que ralentizar
    // al usuario.
    private static void insertarAsync(final Integer idUsuario, final String login,
                                      final String modulo, final String accion,
                                      final String descripcion, final String url, final String ip) {
        POOL.submit(() -> {
            try (Connection cn = Servlets.Conexion.getConnection()) {
                if (cn == null) return;
                // Usar sequence NVL(MAX)+1 por coherencia con el resto
                // del proyecto (no hay sequence Oracle creada aparte).
                int idNuevo = 1;
                try (PreparedStatement stSec = cn.prepareStatement(
                        "SELECT NVL(MAX(ID_LOG),0)+1 FROM LOG_ACTIVIDAD");
                     java.sql.ResultSet rs = stSec.executeQuery()) {
                    if (rs.next()) idNuevo = rs.getInt(1);
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO LOG_ACTIVIDAD " +
                        "(ID_LOG, FECHA_HORA, ID_USUARIO, USUARIO_LOGIN, MODULO, ACCION, DESCRIPCION, URL, IP) " +
                        "VALUES (?, SYSDATE, ?, ?, ?, ?, ?, ?, ?)")) {
                    st.setInt(1, idNuevo);
                    if (idUsuario == null) st.setNull(2, java.sql.Types.NUMERIC);
                    else                   st.setInt(2, idUsuario);
                    st.setString(3, trunc(login, 60));
                    st.setString(4, trunc(modulo, 40));
                    st.setString(5, trunc(accion, 30));
                    st.setString(6, trunc(descripcion, 500));
                    st.setString(7, trunc(url, 300));
                    st.setString(8, trunc(ip, 45));
                    st.executeUpdate();
                }
            } catch (Exception e) {
                // No propagar. Logueado a stdout por si Admin quiere
                // revisar logs del server.
                System.out.println("LogActividad: no se pudo guardar actividad (" + modulo + "/" + accion + ") -> " + e.getMessage());
            }
        });
    }

    private static Integer obtenerIdUsuario(HttpSession session) {
        Object cod = session.getAttribute("cod");
        if (cod == null) return null;
        try { return Integer.parseInt(cod.toString().trim()); } catch (Exception e) { return null; }
    }

    // IP real detras de proxy (X-Forwarded-For) o la del request si no
    // hay proxy. Toma solo la primera IP si hay cadena.
    private static String obtenerIp(HttpServletRequest request) {
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.trim().isEmpty()) {
            int coma = xff.indexOf(',');
            return (coma >= 0 ? xff.substring(0, coma) : xff).trim();
        }
        return request.getRemoteAddr();
    }

    private static String trunc(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }
}
