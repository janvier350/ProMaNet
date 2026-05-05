/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package INVENTARIO;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import jakarta.servlet.annotation.MultipartConfig;

/**
 *
 * @author developer
 */
@MultipartConfig
@WebServlet(name = "INV_Subir_Imagen_Equipo", urlPatterns = {"/INV_Subir_Imagen_Equipo"})
public class INV_Subir_Imagen_Equipo extends HttpServlet {
    //  private static final String IMAGE_DIRECTORY = "D:/imagenes_equipos/";  /home/developer/Imágenes
 private static final String IMAGE_DIRECTORY = "C:/Inventario";
    //private static final String IMAGE_DIRECTORY = "/home/developer/Imágenes/Inventario";

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_Subir_Imagen_Equipo</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet INV_Subir_Imagen_Equipo at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String equipoId = request.getParameter("equipoId");
        String idInvEquipo = request.getParameter("idInvEquipo");
        Part filePart = request.getPart("imagen");

        if (filePart != null && equipoId != null && !equipoId.isEmpty()) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            //  String extension = fileName.substring(fileName.lastIndexOf("."));
            String extension = fileName.substring(fileName.lastIndexOf("."));
            //String newFileName = "equipo_" + equipoId + extension;
            String newFileName = "equipo_" + equipoId + extension.toLowerCase(); // aseguramos minúsculas
// Validar extensiones permitidas
            if (!extension.equalsIgnoreCase(".jpg")
                    && !extension.equalsIgnoreCase(".jpeg")
                    && !extension.equalsIgnoreCase(".png")) {
                response.getWriter().println("Formato no permitido. Solo se permiten JPG, JPEG o PNG.");
                return;
            }

            File uploads = new File(IMAGE_DIRECTORY);
            if (!uploads.exists()) {
                uploads.mkdirs();
            }

            filePart.write(new File(uploads, newFileName).getAbsolutePath());

            // response.getWriter().println("Imagen guardada exitosamente en: " + IMAGE_DIRECTORY + newFileName);
            //response.sendRedirect("../ProMaNet/Inventario/INV_Equipos_Editar.jsp?idInvEquipo=" + idInvEquipo);
            response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");
        } else {
            response.getWriter().println("Error: Datos incompletos.");
        }
        // processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
