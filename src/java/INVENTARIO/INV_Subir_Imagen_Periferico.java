/*
 * Subir la foto de un periferico.
 *
 * Mismo patron que INV_Subir_Imagen_Equipo:
 *  - Se guarda en C:/Inventario
 *  - Nombre: perif_<idPeriferico>.<ext>   (jpg/jpeg/png en minusculas)
 *  - idPeriferico debe ser numerico (evita path traversal via nombre)
 *  - Requiere permiso INVENTARIO_EQUIPOS_GESTIONAR (mismo que el modulo)
 */
package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;

@MultipartConfig
@WebServlet(name = "INV_Subir_Imagen_Periferico", urlPatterns = {"/INV_Subir_Imagen_Periferico"})
public class INV_Subir_Imagen_Periferico extends HttpServlet {

    private static final String IMAGE_DIRECTORY = "C:/Inventario";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sesion no valida.");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No autorizado.");
            return;
        }

        String idPeriferico = request.getParameter("idPeriferico");
        Part filePart = request.getPart("imagen");

        if (idPeriferico == null || !idPeriferico.matches("\\d+")) {
            response.getWriter().println("Error: idPeriferico invalido.");
            return;
        }
        if (filePart == null || filePart.getSize() == 0) {
            response.getWriter().println("Error: no se recibio archivo.");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        int dot = fileName.lastIndexOf('.');
        if (dot < 0) {
            response.getWriter().println("Error: archivo sin extension.");
            return;
        }
        String extension = fileName.substring(dot).toLowerCase();
        if (!extension.equals(".jpg") && !extension.equals(".jpeg") && !extension.equals(".png")) {
            response.getWriter().println("Formato no permitido. Solo JPG, JPEG o PNG.");
            return;
        }

        File uploads = new File(IMAGE_DIRECTORY);
        if (!uploads.exists()) uploads.mkdirs();

        // Antes de escribir el nuevo, borrar cualquier extension previa para
        // que no queden dos ficheros perif_5.jpg + perif_5.png y confundan al
        // visor.
        for (String ext : new String[]{".jpg", ".jpeg", ".png"}) {
            File anterior = new File(uploads, "perif_" + idPeriferico + ext);
            if (anterior.exists() && !anterior.equals(new File(uploads, "perif_" + idPeriferico + extension))) {
                anterior.delete();
            }
        }

        String newFileName = "perif_" + idPeriferico + extension;
        filePart.write(new File(uploads, newFileName).getAbsolutePath());

        response.sendRedirect("../ProMaNet/Inventario/INV_Periferico_Editar.jsp?idPeriferico=" + idPeriferico + "&ok=foto");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Inventario/INV_Perifericos.jsp");
    }
}
