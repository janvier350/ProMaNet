package COMUN;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

// Filter global que registra en LOG_ACTIVIDAD cada request de pantalla
// con sesion activa. Se mapea a "/*" via @WebFilter y filtra adentro
// por extension / prefijo para evitar basura de recursos estaticos
// (CSS, JS, imagenes, fuentes, servlets de imagen inline).
//
// Reglas:
//   - Solo si hay sesion con "usuario" (evita loguear requests pre-login).
//   - Se omiten: assets/*, dist/*, css/*, js/*, img/*, favicons, fuentes.
//   - Se omiten los servlets de servir imagen de inventario (ruido alto).
//   - Las paginas de sesion expirada / invalida se omiten.
//
// El insert es asincrono (ver LogActividad.logVista) asi que no suma
// latencia al request, aun si Oracle esta lento o la cola llena.
@WebFilter(filterName = "ActividadFilter", urlPatterns = {"/*"})
public class ActividadFilter implements Filter {

    private static final Set<String> EXT_SKIP = new HashSet<>(Arrays.asList(
            ".css", ".js", ".map", ".png", ".jpg", ".jpeg", ".gif", ".svg",
            ".ico", ".woff", ".woff2", ".ttf", ".otf", ".eot", ".webp",
            ".mp4", ".webm", ".pdf"
    ));

    private static final String[] PATH_SKIP = new String[]{
            "/assets/", "/dist/", "/css/", "/js/", "/img/", "/fonts/",
            "/sesionExpirada", "/sesionInvalida", "/break.jsp",
            "/INV_MostrarImagen", "/INV_MostrarImagenPeriferico",
            "/favicon"
    };

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        if (req instanceof HttpServletRequest) {
            HttpServletRequest request = (HttpServletRequest) req;
            try {
                if (debeLoguear(request)) {
                    LogActividad.logVista(request);
                }
            } catch (Exception ignore) {
                // nunca romper la cadena por un error de log
            }
        }
        chain.doFilter(req, res);
    }

    private boolean debeLoguear(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri == null || uri.isEmpty()) return false;

        // Skip por prefijo (estaticos / paginas de sesion)
        for (String p : PATH_SKIP) {
            if (uri.contains(p)) return false;
        }
        // Skip por extension estatica
        int dot = uri.lastIndexOf('.');
        if (dot >= 0) {
            String ext = uri.substring(dot).toLowerCase();
            if (EXT_SKIP.contains(ext)) return false;
        }
        return true;
    }
}
