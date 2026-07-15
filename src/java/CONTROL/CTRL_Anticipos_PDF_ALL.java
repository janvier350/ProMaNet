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
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime; // Asegúrate de tener este import
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author janvier
 */
@WebServlet(name = "CTRL_Anticipos_PDF_ALL", urlPatterns = {"/CTRL_Anticipos_PDF_ALL"})
public class CTRL_Anticipos_PDF_ALL extends HttpServlet {

    
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

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp");
        return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
        response.sendRedirect("sesionInvalida.jsp");
        return;
    }

    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String fecha = request.getParameter("fecha");
    String estadoFiltro = request.getParameter("estado");
    if (estadoFiltro != null && estadoFiltro.trim().isEmpty()) {
        estadoFiltro = null;
    }

    String url = new String("" + ip);

    String fechaImpresion = "";

    String mesAnio = "";
    int mesFiltro = 0;
    int anioFiltro = 0;

    String fechaParam = request.getParameter("fecha");
    if (fechaParam != null && !fechaParam.isEmpty()) {
        fecha = fechaParam;

        // Extraer mes y año de la fecha
        try {
            if (fechaParam.contains("-")) {
                String[] partes = fechaParam.split("-");
                if (partes.length >= 2) {
                    anioFiltro = Integer.parseInt(partes[0]);
                    mesFiltro = Integer.parseInt(partes[1]);

                    String[] meses = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
                                      "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};

                    mesAnio = meses[mesFiltro - 1] + " " + anioFiltro;
                }
            }
            else if (fechaParam.contains("/")) {
                String[] partes = fechaParam.split("/");
                if (partes.length >= 3) {
                    mesFiltro = Integer.parseInt(partes[1]);
                    anioFiltro = Integer.parseInt(partes[2]);

                    String[] meses = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
                                      "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};

                    mesAnio = meses[mesFiltro - 1] + " " + anioFiltro;
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
        mesFiltro = hoy.getMonthValue();
        anioFiltro = hoy.getYear();
    }

    if (mesFiltro == 0 || anioFiltro == 0) {
        LocalDate hoy = LocalDate.now();
        mesFiltro = hoy.getMonthValue();
        anioFiltro = hoy.getYear();
    }

    // CORREGIDO: Usar LocalDateTime en lugar de LocalDate
    LocalDateTime ahora = LocalDateTime.now();
    DateTimeFormatter formatterImpresion = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    fechaImpresion = ahora.format(formatterImpresion);
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            // Primero, ejecutar la consulta para obtener todos los anticipos del mes
List<Map<String, Object>> listaAnticipos = new ArrayList<>();
BigDecimal totalGeneralAnticipos = BigDecimal.ZERO;

try {
   DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
    Connection cnSum = DriverManager.getConnection(url, user, pass);
    
    // Tu consulta SQL
    String sql4 = "SELECT u.apellidos, u.nombre, d.departamento, u.sueldo, " +
                  "TO_CHAR(a.fecha_solicitud, 'DD/MM/YYYY') as fecha_solicitud, " +
                  "a.anticipo, a.estado, a.id_ctrl_anticipo " +
                  "FROM ctrl_anticipos a " +
                  "INNER JOIN usuario u ON a.id_usuario = u.idusuario " +
                  "INNER JOIN adm_departamento d ON a.id_departamento = d.id_departamento " +
                  "WHERE TRUNC(a.fecha_solicitud, 'MM') = TO_DATE(?, 'MM/YYYY') " +
                  (estadoFiltro != null ? "AND a.estado = ? " : "") +
                  "ORDER BY a.fecha_solicitud DESC";

    PreparedStatement stSum = cnSum.prepareStatement(sql4);
    stSum.setString(1, String.format("%02d/%d", mesFiltro, anioFiltro));
    if (estadoFiltro != null) {
        stSum.setString(2, estadoFiltro);
    }
    ResultSet rsSum = stSum.executeQuery();
    
    while (rsSum.next()) {
        Map<String, Object> anticipo = new HashMap<>();
        anticipo.put("apellidos", rsSum.getString("apellidos"));
        anticipo.put("nombre", rsSum.getString("nombre"));
        anticipo.put("departamento", rsSum.getString("departamento"));
        anticipo.put("sueldo", rsSum.getBigDecimal("sueldo"));
        anticipo.put("fecha_solicitud", rsSum.getString("fecha_solicitud"));
        anticipo.put("anticipo", rsSum.getBigDecimal("anticipo"));
        anticipo.put("estado", rsSum.getString("estado"));
        anticipo.put("id_ctrl_anticipo", rsSum.getInt("id_ctrl_anticipo"));
        
        listaAnticipos.add(anticipo);
        
        // Sumar al total general
        if (rsSum.getBigDecimal("anticipo") != null) {
            totalGeneralAnticipos = totalGeneralAnticipos.add(rsSum.getBigDecimal("anticipo"));
        }
    }
    
    rsSum.close();
    stSum.close();
    cnSum.close();
    
} catch (Exception e) {
    e.printStackTrace();
}

// Ahora, generar el HTML con todos los ejecutivos
out.println("<!DOCTYPE html>");
out.println("<html>");
out.println("<head>");
out.println("<title>Reporte de Anticipos del Mes</title>");
out.println("<meta charset='UTF-8'>");
out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
out.println("<!-- Bootstrap 5 CSS -->");
out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>");
out.println("<!-- Font Awesome para iconos -->");
out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
out.println("<style>");
out.println("    body { background-color: #f4f6f9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }");
out.println("    .reporte-container { max-width: 1200px; margin: 30px auto; }");
out.println("    .reporte-card { background: white; border-radius: 20px; box-shadow: 0 15px 40px rgba(0,0,0,0.1); padding: 30px; }");
out.println("    .header-title { color: #0d6efd; font-weight: 700; }");
out.println("    .subheader-title { color: #6c757d; }");
out.println("    .separator { height: 4px; background: linear-gradient(90deg, #0d6efd, #20c997); margin: 20px 0; border-radius: 2px; }");
out.println("    .badge-fecha { background: #e9ecef; color: #495057; padding: 8px 15px; border-radius: 20px; font-size: 0.9rem; }");
out.println("    .table-header { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; }");
out.println("    .table-header th { padding: 15px; font-weight: 600; border: none; }");
out.println("    .table tbody tr { transition: all 0.2s; }");
out.println("    .table tbody tr:hover { background-color: #f0f7ff; transform: scale(1.01); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }");
out.println("    .estado-badge { padding: 5px 10px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; }");
out.println("    .estado-aprobado { background: #d1e7dd; color: #0f5132; }");
out.println("    .estado-pendiente { background: #fff3cd; color: #856404; }");
out.println("    .estado-rechazado { background: #f8d7da; color: #842029; }");
out.println("    .total-general { background: linear-gradient(135deg, #198754, #157347); color: white; padding: 20px; border-radius: 15px; margin-top: 30px; }");
out.println("    .card-ejecutivo { border-left: 5px solid #0d6efd; background: #f8f9fa; border-radius: 12px; padding: 15px; margin-bottom: 20px; }");
out.println("    .firma-section { margin-top: 50px; padding-top: 30px; border-top: 3px dashed #dee2e6; }");
out.println("    .firma-line { border-bottom: 3px solid #dee2e6; width: 250px; height: 40px; margin: 0 auto; }");
out.println("    .footer-note { color: #6c757d; font-size: 0.9rem; text-align: center; margin-top: 40px; }");
out.println("    .stats-card { background: linear-gradient(135deg, #f8f9fa, #e9ecef); border-radius: 15px; padding: 20px; margin-bottom: 25px; }");
out.println("</style>");
out.println("</head>");
out.println("<body>");
out.println("<div class='reporte-container'>");
out.println("<div class='reporte-card'>");

// Header
out.println("    <div class='text-center mb-4'>");
out.println("        <h1 class='header-title'><i class='fas fa-chart-line me-3'></i>" + mesAnio + "</h1>");
out.println("        <h3 class='subheader-title'>REPORTE DE ANTICIPOS " + ("PAGADO".equals(estadoFiltro) ? "PAGADOS" : "SOLICITADOS") + "</h3>");
out.println("        <div class='separator'></div>");
out.println("    </div>");

// Fechas
out.println("    <div class='d-flex justify-content-between align-items-center mb-4'>");
out.println("        <div class='badge-fecha'>");
out.println("            <i class='far fa-calendar-alt me-2'></i>Período: " + mesAnio);
out.println("        </div>");
out.println("        <div class='badge-fecha'>");
out.println("            <i class='far fa-clock me-2'></i>Fecha de emisión: " + fechaImpresion);
out.println("        </div>");
out.println("    </div>");

// Estadísticas rápidas
int totalSolicitudes = listaAnticipos.size();
long solicitudesAprobadas = listaAnticipos.stream().filter(a -> "APROBADO".equals(a.get("estado"))).count();
long solicitudesPendientes = listaAnticipos.stream().filter(a -> "PENDIENTE".equals(a.get("estado"))).count();

out.println("    <div class='row stats-card g-4 mb-4'>");
out.println("        <div class='col-md-4 text-center'>");
out.println("            <div class='p-3'>");
out.println("                <i class='fas fa-file-invoice fa-2x text-primary mb-2'></i>");
out.println("                <h3 class='mb-0'>" + totalSolicitudes + "</h3>");
out.println("                <small class='text-muted'>Total Solicitudes</small>");
out.println("            </div>");
out.println("        </div>");
out.println("        <div class='col-md-4 text-center'>");
out.println("            <div class='p-3'>");
out.println("                <i class='fas fa-check-circle fa-2x text-success mb-2'></i>");
out.println("                <h3 class='mb-0'>" + solicitudesAprobadas + "</h3>");
out.println("                <small class='text-muted'>Aprobadas</small>");
out.println("            </div>");
out.println("        </div>");
out.println("        <div class='col-md-4 text-center'>");
out.println("            <div class='p-3'>");
out.println("                <i class='fas fa-clock fa-2x text-warning mb-2'></i>");
out.println("                <h3 class='mb-0'>" + solicitudesPendientes + "</h3>");
out.println("                <small class='text-muted'>Pendientes</small>");
out.println("            </div>");
out.println("        </div>");
out.println("    </div>");

// Tabla de anticipos
out.println("    <div class='table-responsive'>");
out.println("        <table class='table table-hover align-middle'>");
out.println("            <thead class='table-header'>");
out.println("                <tr>");
out.println("                    <th><i class='fas fa-user me-2'></i>Ejecutivo</th>");
out.println("                    <th><i class='fas fa-building me-2'></i>Departamento</th>");
out.println("                    <th><i class='fas fa-dollar-sign me-2'></i>Sueldo</th>");
out.println("                    <th><i class='far fa-calendar me-2'></i>Fecha Solicitud</th>");
out.println("                    <th><i class='fas fa-hand-holding-usd me-2'></i>Anticipo</th>");
out.println("                    <th><i class='fas fa-tag me-2'></i>Estado</th>");
out.println("                    <th><i class='fas fa-hashtag me-2'></i>ID</th>");
out.println("                </tr>");
out.println("            </thead>");
out.println("            <tbody>");

// Iterar sobre la lista de anticipos
for (Map<String, Object> anticipo : listaAnticipos) {
    String nombreCompleto = anticipo.get("nombre") + " " + anticipo.get("apellidos");
    String departamento = (String) anticipo.get("departamento");
    BigDecimal sueldo = (BigDecimal) anticipo.get("sueldo");
    String fechaSolicitud = (String) anticipo.get("fecha_solicitud");
    BigDecimal montoAnticipo = (BigDecimal) anticipo.get("anticipo");
    String estado = (String) anticipo.get("estado");
    Integer id = (Integer) anticipo.get("id_ctrl_anticipo");
    
    // Determinar clase CSS para el estado
    String estadoClass = "estado-pendiente";
    if ("APROBADO".equals(estado)) {
        estadoClass = "estado-aprobado";
    } else if ("RECHAZADO".equals(estado)) {
        estadoClass = "estado-rechazado";
    }
    
    out.println("                <tr>");
    out.println("                    <td><strong>" + nombreCompleto + "</strong></td>");
    out.println("                    <td>" + departamento + "</td>");
    out.println("                    <td>$ " + (sueldo != null ? sueldo : "0") + "</td>");
    out.println("                    <td>" + fechaSolicitud + "</td>");
    out.println("                    <td><strong class='text-danger'>$ " + montoAnticipo + "</strong></td>");
    out.println("                    <td><span class='estado-badge " + estadoClass + "'>" + estado + "</span></td>");
    out.println("                    <td><code>" + id + "</code></td>");
    out.println("                </tr>");
}

out.println("            </tbody>");
out.println("        </table>");
out.println("    </div>");

// Total general
out.println("    <div class='total-general text-center'>");
out.println("        <h4 class='mb-0'><i class='fas fa-calculator me-3'></i>TOTAL GENERAL ANTICIPOS: $ " + totalGeneralAnticipos + "</h4>");
out.println("    </div>");

// Sección de firmas
out.println("    <div class='firma-section'>");
out.println("        <div class='row'>");
out.println("            <div class='col-md-4 text-center mb-4 mb-md-0'>");
out.println("                <div class='fw-bold text-muted mb-2'>ELABORADO POR</div>");
out.println("                <div class='firma-line'></div>");
out.println("                <div class='mt-2'><small class='text-muted'>" + nombre + " " + apellidos + "</small></div>");
out.println("            </div>");
out.println("            <div class='col-md-4 text-center mb-4 mb-md-0'>");
out.println("                <div class='fw-bold text-muted mb-2'>REVISADO POR</div>");
out.println("                <div class='firma-line'></div>");
out.println("                <div class='mt-2'><small class='text-muted'>(Nombre y Firma)</small></div>");
out.println("            </div>");
out.println("            <div class='col-md-4 text-center'>");
out.println("                <div class='fw-bold text-muted mb-2'>AUTORIZADO POR</div>");
out.println("                <div class='firma-line'></div>");
out.println("                <div class='mt-2'><small class='text-muted'>(Nombre y Firma)</small></div>");
out.println("            </div>");
out.println("        </div>");
out.println("    </div>");

// Footer
out.println("    <div class='footer-note'>");
out.println("        <i class='fas fa-print me-2'></i>Documento generado electrónicamente el " + fechaImpresion);
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
