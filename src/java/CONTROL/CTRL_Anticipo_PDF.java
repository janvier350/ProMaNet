/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package CONTROL;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime; // Asegúrate de tener este import


/**
 *
 * @author developer
 */
@WebServlet(name = "CTRL_Anticipo_PDF", urlPatterns = {"/CTRL_Anticipo_PDF"})
public class CTRL_Anticipo_PDF extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    response.setContentType("text/html;charset=UTF-8");

    HttpSession session = request.getSession(true);

    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");

    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");

    String anticipo = request.getParameter("anticipo");
    String fecha = request.getParameter("fecha");
    
    String nombres_Solicitante = request.getParameter("nombres_Solicitante");
    String apellidos_Solicitante = request.getParameter("apellidos_Solicitante");
    

    String url = new String("" + ip);
    String fechaImpresion = "";
    
    String mesAnio = "";

    String fechaParam = request.getParameter("fecha");
    if (fechaParam != null && !fechaParam.isEmpty()) {
        fecha = fechaParam;
        
        // Extraer mes y año de la fecha
        try {
            if (fechaParam.contains("-")) {
                String[] partes = fechaParam.split("-");
                if (partes.length >= 2) {
                    int año = Integer.parseInt(partes[0]);
                    int mes = Integer.parseInt(partes[1]);
                    
                    String[] meses = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", 
                                      "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};
                    
                    mesAnio = meses[mes - 1] + " " + año;
                }
            }
            else if (fechaParam.contains("/")) {
                String[] partes = fechaParam.split("/");
                if (partes.length >= 3) {
                    int mes = Integer.parseInt(partes[1]);
                    int año = Integer.parseInt(partes[2]);
                    
                    String[] meses = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", 
                                      "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};
                    
                    mesAnio = meses[mes - 1] + " " + año;
                }
            }
        } catch (Exception e) {
            mesAnio = fechaParam;
        }
    } else {
        LocalDate hoy = LocalDate.now();
        String[] meses = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", 
                          "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};
        
        mesAnio = meses[hoy.getMonthValue() - 1] + " " + hoy.getYear();
        fecha = hoy.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    // CORREGIDO: Usar LocalDateTime en lugar de LocalDate
    LocalDateTime ahora = LocalDateTime.now();
    DateTimeFormatter formatterImpresion = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    fechaImpresion = ahora.format(formatterImpresion);

    // Validaciones de sesión
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp");
        return;
    } else if (session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp");
        return;
    }
    
    if (cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR") || 
        cargo.equals("ASISTENTE") || cargo.equals("PASANTE") || 
        cargo.equals("CONTRALOR") || cargo.equals("JEFE")) {
        // OK
    } else {
        response.sendRedirect("sesionInvalida.jsp");
    }

    try (PrintWriter out = response.getWriter()) {
      out.println("<!DOCTYPE html>");
out.println("<html>");
out.println("<head>");
out.println("<title>Comprobante de Anticipo</title>");
out.println("<meta charset='UTF-8'>");
out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
out.println("<!-- Bootstrap 5 CSS -->");
out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>");
out.println("<!-- Font Awesome para iconos -->");
out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
out.println("<style>");
out.println("    body { background-color: #f8f9fa; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }");
out.println("    .comprobante-container { max-width: 800px; margin: 30px auto; }");
out.println("    .comprobante-card { background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); padding: 30px; }");
out.println("    .header-title { color: #0d6efd; font-weight: 700; margin-bottom: 5px; }");
out.println("    .subheader-title { color: #6c757d; font-size: 1.1rem; }");
out.println("    .info-section { background: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0; }");
out.println("    .info-item { margin-bottom: 15px; }");
out.println("    .info-label { font-weight: 600; color: #495057; margin-bottom: 5px; }");
out.println("    .info-value { font-size: 1.2rem; color: #212529; }");
out.println("    .monto-anticipo { font-size: 2.5rem; font-weight: 700; color: #dc3545; text-align: center; margin: 20px 0; }");
out.println("    .firma-section { margin-top: 40px; padding-top: 20px; border-top: 2px dashed #dee2e6; }");
out.println("    .firma-line { border-bottom: 2px solid #dee2e6; width: 200px; height: 30px; }");
out.println("    .footer-note { color: #6c757d; font-size: 0.85rem; text-align: center; margin-top: 30px; }");
out.println("    .badge-fecha { background: #e9ecef; color: #495057; padding: 8px 15px; border-radius: 20px; }");
out.println("    .separator { height: 3px; background: linear-gradient(90deg, #0d6efd, #20c997, #ffc107); margin: 20px 0; }");
out.println("</style>");
out.println("</head>");
out.println("<body>");
out.println("<div class='comprobante-container'>");
out.println("<div class='comprobante-card'>");
out.println("    <!-- Header -->");
out.println("    <div class='text-center mb-4'>");
out.println("        <h1 class='header-title'><i class='fas fa-hand-holding-usd me-2'></i>" + mesAnio + "</h1>");
out.println("        <h2 class='subheader-title'>COMPROBANTE DE ANTICIPO ENTREGADO</h2>");
out.println("        <div class='separator'></div>");
out.println("    </div>");
out.println("    ");
out.println("    <!-- Fechas -->");
out.println("    <div class='d-flex justify-content-between align-items-center mb-4'>");
out.println("        <div class='badge-fecha'>");
out.println("            <i class='far fa-calendar-alt me-2'></i>Fecha Solicitud: " + fecha);
out.println("        </div>");
out.println("        <div class='badge-fecha'>");
out.println("            <i class='far fa-clock me-2'></i>Impresión: " + fechaImpresion);
out.println("        </div>");
out.println("    </div>");
out.println("    ");
out.println("    <!-- Información del Ejecutivo Solicitante -->");
out.println("    <div class='info-section'>");
out.println("        <h5 class='mb-3'><i class='fas fa-user-circle me-2' style='color:#0d6efd;'></i>Datos del Solicitante</h5>");
out.println("        <div class='row'>");
out.println("            <div class='col-md-12'>");
out.println("                <div class='info-item'>");
out.println("                    <div class='info-label'>Ejecutivo:</div>");
out.println("                    <div class='info-value'><strong>" + nombres_Solicitante + " " + apellidos_Solicitante + "</strong></div>");
out.println("                </div>");
out.println("            </div>");
out.println("        </div>");
out.println("    </div>");
out.println("    ");
out.println("    <!-- Monto del Anticipo -->");
out.println("    <div class='monto-anticipo'>");
out.println("        <i class='fas fa-dollar-sign me-2'></i> " + anticipo);
out.println("    </div>");
out.println("    ");
out.println("    <!-- Firma Section -->");
out.println("    <div class='firma-section'>");
out.println("        <div class='row'>");
out.println("            <div class='col-md-6 text-center mb-4 mb-md-0'>");
out.println("                <div class='info-label'>REVISADO POR</div>");
out.println("                <div class='firma-line mx-auto'></div>");
out.println("                <div class='mt-2'><small class='text-muted'>Nombre y Firma</small></div>");
out.println("            </div>");
out.println("            <div class='col-md-6 text-center'>");
out.println("                <div class='info-label'>RECIBIDO POR</div>");
out.println("                <div class='firma-line mx-auto'></div>");
out.println("                <div class='mt-2'><small class='text-muted'>Nombre y Firma</small></div>");
out.println("            </div>");
out.println("        </div>");
out.println("    </div>");
out.println("    ");
out.println("    <!-- Ejecutivo que autoriza (si aplica) -->");
out.println("    <div class='alert alert-light mt-4 mb-0' role='alert' style='background:#f1f3f5; border:none;'>");
out.println("        <div class='d-flex align-items-center'>");
out.println("            <i class='fas fa-check-circle text-success me-3' style='font-size:1.5rem;'></i>");
out.println("            <div>");
out.println("                <small class='text-muted'>Autorizado por:</small>");
out.println("                <br><strong>" + nombre + " " + apellidos + "</strong>");
out.println("            </div>");
out.println("        </div>");
out.println("    </div>");
out.println("    ");
out.println("    <!-- Footer Note -->");
out.println("    <div class='footer-note'>");
out.println("        <i class='fas fa-print me-2'></i>Documento generado electrónicamente");
out.println("    </div>");
out.println("</div>");
out.println("</div>");
out.println("<!-- Bootstrap 5 JS Bundle -->");
out.println("<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js'></script>");
out.println("</body>");
out.println("</html>");
    }
}

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
