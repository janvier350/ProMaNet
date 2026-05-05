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
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

/**
 *
 * @author developer
 */

@WebServlet(name = "INV_MostrarImagenEquipo", urlPatterns = {"/INV_MostrarImagenEquipo"})
public class INV_MostrarImagenEquipo extends HttpServlet {
 //   private static final String IMAGE_DIRECTORY = "/home/developer/Imágenes/Inventario";
private static final String IMAGE_DIRECTORY = "C:/Inventario";
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet INV_MostrarImagenEquipo</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet INV_MostrarImagenEquipo at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String nombre = request.getParameter("nombre"); // ejemplo: equipo_123.jpg

        if (nombre == null || nombre.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de imagen no proporcionado.");
            return;
        }

     //   File imagen = new File(IMAGE_DIRECTORY + nombre);
     File imagen = new File(IMAGE_DIRECTORY, nombre);
     String nombreBase = request.getParameter("nombre"); // sin extensión

    // File imagen = new File(IMAGE_DIRECTORY + "/" + nombre);
     String[] extensiones = { ".jpg", ".jpeg", ".png" };


    for (String ext : extensiones) {
    File posible = new File(IMAGE_DIRECTORY + "/" + nombreBase + ext);
    if (posible.exists()) {
        imagen = posible;
        break;
    }
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
            int bytesRead;

            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
        //processRequest(request, response);
    }

  
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

  
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
