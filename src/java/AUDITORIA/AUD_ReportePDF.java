package AUDITORIA;

import COMUN.PermisoHelper;
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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

// Reporte mensual de todos los anticipos de Auditoria (solo gestor).
@WebServlet(name = "AUD_ReportePDF", urlPatterns = {"/AUD_ReportePDF"})
public class AUD_ReportePDF extends HttpServlet {

    private static final String[] MESES = {"ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
        "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String nombreGestor = session.getAttribute("nombre") + " " + session.getAttribute("apellidos");
        String fechaParam = request.getParameter("mes"); // YYYY-MM, opcional
        String estadoFiltro = request.getParameter("estado"); // PENDIENTE/PAGADO, opcional
        if (estadoFiltro != null && estadoFiltro.trim().isEmpty()) estadoFiltro = null;
        int mesFiltro, anioFiltro;
        if (fechaParam != null && fechaParam.matches("\\d{4}-\\d{2}")) {
            String[] p = fechaParam.split("-");
            anioFiltro = Integer.parseInt(p[0]);
            mesFiltro = Integer.parseInt(p[1]);
        } else {
            LocalDate hoy = LocalDate.now();
            mesFiltro = hoy.getMonthValue();
            anioFiltro = hoy.getYear();
        }
        String mesAnio = MESES[mesFiltro - 1] + " " + anioFiltro;
        String fechaImpresion = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));

        response.setContentType("text/html;charset=UTF-8");

        List<Object[]> filas = new ArrayList<>();
        BigDecimal totalGeneral = BigDecimal.ZERO;

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT u.NOMBRE||' '||u.APELLIDOS, a.SUELDO, TO_CHAR(a.FECHA_SOLICITUD,'DD/MM/YYYY'), " +
                    "a.ANTICIPO, a.ESTADO, a.ID_AUD_ANTICIPO " +
                    "FROM AUD_ANTICIPOS a JOIN USUARIO u ON a.ID_USUARIO = u.IDUSUARIO " +
                    "WHERE TRUNC(a.FECHA_SOLICITUD,'MM') = TO_DATE(?, 'MM/YYYY') " +
                    (estadoFiltro != null ? "AND a.ESTADO = ? " : "") +
                    "ORDER BY a.FECHA_SOLICITUD DESC")) {
                st.setString(1, String.format("%02d/%d", mesFiltro, anioFiltro));
                if (estadoFiltro != null) st.setString(2, estadoFiltro);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        BigDecimal monto = rs.getBigDecimal(4);
                        filas.add(new Object[]{rs.getString(1), rs.getBigDecimal(2), rs.getString(3), monto, rs.getString(5), rs.getInt(6)});
                        if (monto != null) totalGeneral = totalGeneral.add(monto);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        long pagados = filas.stream().filter(f -> "PAGADO".equals(f[4])).count();
        long pendientes = filas.stream().filter(f -> "PENDIENTE".equals(f[4])).count();

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html><html><head><title>Reporte de Anticipos - Auditoria</title>");
            out.println("<meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>");
            out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>");
            out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
            out.println("<style>");
            out.println("body{background:#f4f6f9;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}");
            out.println(".reporte-container{max-width:1100px;margin:30px auto;}");
            out.println(".reporte-card{background:#fff;border-radius:20px;box-shadow:0 15px 40px rgba(0,0,0,.1);padding:30px;}");
            out.println(".header-title{color:#0d6efd;font-weight:700;}");
            out.println(".subheader-title{color:#6c757d;}");
            out.println(".separator{height:4px;background:linear-gradient(90deg,#0d6efd,#20c997);margin:20px 0;border-radius:2px;}");
            out.println(".badge-fecha{background:#e9ecef;color:#495057;padding:8px 15px;border-radius:20px;font-size:.9rem;}");
            out.println(".table-header{background:linear-gradient(135deg,#0d6efd,#0b5ed7);color:#fff;}");
            out.println(".table-header th{padding:15px;font-weight:600;border:none;}");
            out.println(".estado-badge{padding:5px 10px;border-radius:20px;font-size:.85rem;font-weight:600;}");
            out.println(".estado-pagado{background:#d1e7dd;color:#0f5132;}");
            out.println(".estado-pendiente{background:#fff3cd;color:#856404;}");
            out.println(".total-general{background:linear-gradient(135deg,#198754,#157347);color:#fff;padding:20px;border-radius:15px;margin-top:30px;}");
            out.println(".firma-section{margin-top:50px;padding-top:30px;border-top:3px dashed #dee2e6;}");
            out.println(".firma-line{border-bottom:3px solid #dee2e6;width:250px;height:40px;margin:0 auto;}");
            out.println(".stats-card{background:linear-gradient(135deg,#f8f9fa,#e9ecef);border-radius:15px;padding:20px;margin-bottom:25px;}");
            out.println("</style></head><body>");
            out.println("<div class='reporte-container'><div class='reporte-card'>");
            out.println("<div class='text-center mb-4'>");
            out.println("<h1 class='header-title'><i class='fas fa-chart-line me-3'></i>" + mesAnio + "</h1>");
            out.println("<h3 class='subheader-title'>REPORTE DE ANTICIPOS " + ("PAGADO".equals(estadoFiltro) ? "PAGADOS" : "PENDIENTE".equals(estadoFiltro) ? "PENDIENTES" : "") + " - AUDITORIA</h3>");
            out.println("<div class='separator'></div></div>");
            out.println("<div class='d-flex justify-content-between align-items-center mb-4'>");
            out.println("<div class='badge-fecha'><i class='far fa-calendar-alt me-2'></i>Periodo: " + mesAnio + "</div>");
            out.println("<div class='badge-fecha'><i class='far fa-clock me-2'></i>Fecha de emision: " + fechaImpresion + "</div>");
            out.println("</div>");
            out.println("<div class='row stats-card g-4 mb-4'>");
            out.println("<div class='col-md-4 text-center'><div class='p-3'><i class='fas fa-file-invoice fa-2x text-primary mb-2'></i><h3 class='mb-0'>" + filas.size() + "</h3><small class='text-muted'>Total Solicitudes</small></div></div>");
            out.println("<div class='col-md-4 text-center'><div class='p-3'><i class='fas fa-check-circle fa-2x text-success mb-2'></i><h3 class='mb-0'>" + pagados + "</h3><small class='text-muted'>Pagados</small></div></div>");
            out.println("<div class='col-md-4 text-center'><div class='p-3'><i class='fas fa-clock fa-2x text-warning mb-2'></i><h3 class='mb-0'>" + pendientes + "</h3><small class='text-muted'>Pendientes</small></div></div>");
            out.println("</div>");
            out.println("<div class='table-responsive'><table class='table table-hover align-middle'>");
            out.println("<thead class='table-header'><tr>");
            out.println("<th><i class='fas fa-user me-2'></i>Ejecutivo</th><th><i class='fas fa-dollar-sign me-2'></i>Sueldo</th>");
            out.println("<th><i class='far fa-calendar me-2'></i>Fecha Solicitud</th><th><i class='fas fa-hand-holding-usd me-2'></i>Anticipo</th>");
            out.println("<th><i class='fas fa-tag me-2'></i>Estado</th><th><i class='fas fa-hashtag me-2'></i>ID</th></tr></thead><tbody>");
            for (Object[] f : filas) {
                String estado = (String) f[4];
                String estadoClass = "PAGADO".equals(estado) ? "estado-pagado" : "estado-pendiente";
                out.println("<tr><td><strong>" + f[0] + "</strong></td><td>$ " + f[1] + "</td><td>" + f[2] + "</td>");
                out.println("<td><strong class='text-danger'>$ " + f[3] + "</strong></td>");
                out.println("<td><span class='estado-badge " + estadoClass + "'>" + estado + "</span></td><td><code>" + f[5] + "</code></td></tr>");
            }
            out.println("</tbody></table></div>");
            out.println("<div class='total-general text-center'><h4 class='mb-0'><i class='fas fa-calculator me-3'></i>TOTAL GENERAL: $ " + totalGeneral + "</h4></div>");
            out.println("<div class='firma-section'><div class='row'>");
            out.println("<div class='col-md-6 text-center mb-4 mb-md-0'><div class='fw-bold text-muted mb-2'>ELABORADO POR</div><div class='firma-line'></div><div class='mt-2'><small class='text-muted'>" + nombreGestor + "</small></div></div>");
            out.println("<div class='col-md-6 text-center'><div class='fw-bold text-muted mb-2'>AUTORIZADO POR</div><div class='firma-line'></div><div class='mt-2'><small class='text-muted'>(Nombre y Firma)</small></div></div>");
            out.println("</div></div>");
            out.println("</div></div></body></html>");
        }
    }
}
