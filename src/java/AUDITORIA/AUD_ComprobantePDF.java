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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

// Comprobante de una solicitud puntual. A diferencia del comprobante
// del modulo general de Control (que confiaba en nombre/monto/fecha
// mandados por la URL, falsificables por cualquiera), este vuelve a
// leer los datos reales de AUD_ANTICIPOS por ID y valida que quien lo
// pide sea el dueno de la solicitud o el gestor del modulo.
@WebServlet(name = "AUD_ComprobantePDF", urlPatterns = {"/AUD_ComprobantePDF"})
public class AUD_ComprobantePDF extends HttpServlet {

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
        boolean puedeGestionar = PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR");
        if (!puedeGestionar && !PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        int miId;
        try {
            miId = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idAnticipo = request.getParameter("id");
        String nombreGestor = session.getAttribute("nombre") + " " + session.getAttribute("apellidos");

        response.setContentType("text/html;charset=UTF-8");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String nombreSolicitante = "";
            double anticipo = 0;
            java.sql.Date fechaSolicitud = null;
            int idUsuarioSolicitud = -1;

            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT u.NOMBRE||' '||u.APELLIDOS, a.ANTICIPO, a.FECHA_SOLICITUD, a.ID_USUARIO " +
                    "FROM AUD_ANTICIPOS a JOIN USUARIO u ON a.ID_USUARIO = u.IDUSUARIO " +
                    "WHERE a.ID_AUD_ANTICIPO = ?")) {
                st.setString(1, idAnticipo);
                try (ResultSet rs = st.executeQuery()) {
                    if (!rs.next()) {
                        response.getWriter().println("Solicitud no encontrada.");
                        return;
                    }
                    nombreSolicitante = rs.getString(1);
                    anticipo = rs.getDouble(2);
                    fechaSolicitud = rs.getDate(3);
                    idUsuarioSolicitud = rs.getInt(4);
                }
            }

            if (!puedeGestionar && idUsuarioSolicitud != miId) {
                response.sendRedirect("sesionInvalida.jsp");
                return;
            }

            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            String fecha = fechaSolicitud != null ? sdf.format(fechaSolicitud) : "";
            java.util.Calendar cal = java.util.Calendar.getInstance();
            if (fechaSolicitud != null) cal.setTime(fechaSolicitud);
            String mesAnio = MESES[cal.get(java.util.Calendar.MONTH)] + " " + cal.get(java.util.Calendar.YEAR);
            String fechaImpresion = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));

            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html><html><head><title>Comprobante de Anticipo</title>");
                out.println("<meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>");
                out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>");
                out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
                out.println("<style>");
                out.println("body{background:#f8f9fa;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}");
                out.println(".comprobante-container{max-width:800px;margin:30px auto;}");
                out.println(".comprobante-card{background:#fff;border-radius:15px;box-shadow:0 10px 30px rgba(0,0,0,.1);padding:30px;}");
                out.println(".header-title{color:#0d6efd;font-weight:700;margin-bottom:5px;}");
                out.println(".subheader-title{color:#6c757d;font-size:1.1rem;}");
                out.println(".info-section{background:#f8f9fa;border-radius:10px;padding:20px;margin:20px 0;}");
                out.println(".info-label{font-weight:600;color:#495057;margin-bottom:5px;}");
                out.println(".info-value{font-size:1.2rem;color:#212529;}");
                out.println(".monto-anticipo{font-size:2.5rem;font-weight:700;color:#dc3545;text-align:center;margin:20px 0;}");
                out.println(".firma-section{margin-top:40px;padding-top:20px;border-top:2px dashed #dee2e6;}");
                out.println(".firma-line{border-bottom:2px solid #dee2e6;width:200px;height:30px;}");
                out.println(".footer-note{color:#6c757d;font-size:.85rem;text-align:center;margin-top:30px;}");
                out.println(".badge-fecha{background:#e9ecef;color:#495057;padding:8px 15px;border-radius:20px;}");
                out.println(".separator{height:3px;background:linear-gradient(90deg,#0d6efd,#20c997,#ffc107);margin:20px 0;}");
                out.println("</style></head><body>");
                out.println("<div class='comprobante-container'><div class='comprobante-card'>");
                out.println("<div class='text-center mb-4'>");
                out.println("<h1 class='header-title'><i class='fas fa-hand-holding-usd me-2'></i>" + mesAnio + "</h1>");
                out.println("<h2 class='subheader-title'>COMPROBANTE DE ANTICIPO - AUDITORIA</h2>");
                out.println("<div class='separator'></div></div>");
                out.println("<div class='d-flex justify-content-between align-items-center mb-4'>");
                out.println("<div class='badge-fecha'><i class='far fa-calendar-alt me-2'></i>Fecha Solicitud: " + fecha + "</div>");
                out.println("<div class='badge-fecha'><i class='far fa-clock me-2'></i>Impresion: " + fechaImpresion + "</div>");
                out.println("</div>");
                out.println("<div class='info-section'><h5 class='mb-3'><i class='fas fa-user-circle me-2' style='color:#0d6efd;'></i>Datos del Solicitante</h5>");
                out.println("<div class='info-label'>Ejecutivo:</div><div class='info-value'><strong>" + nombreSolicitante + "</strong></div></div>");
                out.println("<div class='monto-anticipo'><i class='fas fa-dollar-sign me-2'></i> " + anticipo + "</div>");
                out.println("<div class='firma-section'><div class='row'>");
                out.println("<div class='col-md-6 text-center mb-4 mb-md-0'><div class='info-label'>REVISADO POR</div><div class='firma-line mx-auto'></div><div class='mt-2'><small class='text-muted'>Nombre y Firma</small></div></div>");
                out.println("<div class='col-md-6 text-center'><div class='info-label'>RECIBIDO POR</div><div class='firma-line mx-auto'></div><div class='mt-2'><small class='text-muted'>Nombre y Firma</small></div></div>");
                out.println("</div></div>");
                out.println("<div class='alert alert-light mt-4 mb-0' style='background:#f1f3f5;border:none;'><div class='d-flex align-items-center'>");
                out.println("<i class='fas fa-check-circle text-success me-3' style='font-size:1.5rem;'></i>");
                out.println("<div><small class='text-muted'>Autorizado por:</small><br><strong>" + nombreGestor + "</strong></div></div></div>");
                out.println("<div class='footer-note'><i class='fas fa-print me-2'></i>Documento generado electronicamente</div>");
                out.println("</div></div></body></html>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }
}
