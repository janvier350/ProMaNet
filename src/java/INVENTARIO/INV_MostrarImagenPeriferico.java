/*
 * Devolver la foto de un periferico al browser.
 *
 * Se pasa el nombre base (p.ej. perif_5) sin extension; se prueba con
 * .jpg / .jpeg / .png y se sirve la que exista. Mismo patron y misma
 * proteccion contra path traversal que INV_MostrarImagenEquipo.
 */
package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

@WebServlet(name = "INV_MostrarImagenPeriferico", urlPatterns = {"/INV_MostrarImagenPeriferico"})
public class INV_MostrarImagenPeriferico extends HttpServlet {

    private static final String IMAGE_DIRECTORY = "C:/Inventario";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sesion no valida.");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_VER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No autorizado.");
            return;
        }

        String nombre = request.getParameter("nombre");   // p.ej. perif_5
        if (nombre == null || nombre.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de imagen no proporcionado.");
            return;
        }
        if (nombre.contains("/") || nombre.contains("\\") || nombre.contains("..")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de imagen invalido.");
            return;
        }

        File imagen = null;
        for (String ext : new String[]{".jpg", ".jpeg", ".png"}) {
            File posible = new File(IMAGE_DIRECTORY, nombre + ext);
            if (posible.exists()) { imagen = posible; break; }
        }
        if (imagen == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Imagen no encontrada.");
            return;
        }

        String contentType = getServletContext().getMimeType(imagen.getName());
        response.setContentType(contentType != null ? contentType : "image/jpeg");
        response.setContentLengthLong(imagen.length());

        try (FileInputStream fis = new FileInputStream(imagen);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int n;
            while ((n = fis.read(buffer)) != -1) os.write(buffer, 0, n);
        }
    }
}
