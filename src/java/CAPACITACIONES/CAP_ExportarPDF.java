package CAPACITACIONES;

import COMUN.PermisoHelper;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// Exporta el listado de capacitaciones a PDF con iText (ya en el
// classpath del proyecto, usado igual en src/java/pdf/*).
@WebServlet(name = "CAP_ExportarPDF", urlPatterns = {"/CAP_ExportarPDF"})
public class CAP_ExportarPDF extends HttpServlet {

    private static final String[] ENCABEZADOS = {
        "Seminario", "Empresa Capacitadora", "Aprobacion", "No. Part.", "Participantes",
        "Compania Facturada", "Fecha Factura", "Subtotal", "IVA", "Total Factura", "Retencion", "Total Pagado"
    };
    private static final float[] ANCHOS = {14, 12, 8, 4, 14, 12, 7, 7, 6, 7, 6, 7};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null
                || !PermisoHelper.tiene(session, "CAPACITACIONES_ACCESO")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String fechaDesde = request.getParameter("fechaDesde");
        String fechaHasta = request.getParameter("fechaHasta");

        StringBuilder sql = new StringBuilder(
                "SELECT s.NOMBRE_SEMINARIO, e.DESCRIPCION, s.APROBACION, s.NO_PARTICIPANTES, " +
                "s.NOMBRE_PARTICIPANTES, c.COMPANIA, TO_CHAR(s.FECHA_FACTURA,'DD/MM/YYYY'), " +
                "s.SUBTOTAL, s.IVA_VALOR, s.TOTAL_FACTURA, s.RETENCION, s.TOTAL_PAGADO " +
                "FROM CAPACITACIONES_SEMINARIO s " +
                "LEFT JOIN CAPACITACIONES_EMPRESA e ON s.ID_EMPRESA = e.ID_EMPRESA " +
                "LEFT JOIN COMPANIA c ON s.ID_COMPANIA_FACTURA = c.IDCOMPANIA " +
                "WHERE s.ACTIVO = 'A'");
        List<String> params = new ArrayList<>();
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND s.FECHA_FACTURA >= TO_DATE(?,'YYYY-MM-DD')");
            params.add(fechaDesde.trim());
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND s.FECHA_FACTURA <= TO_DATE(?,'YYYY-MM-DD')");
            params.add(fechaHasta.trim());
        }
        sql.append(" ORDER BY s.FECHA_FACTURA NULLS LAST, s.ID_SEMINARIO");

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=capacitaciones.pdf");

        Document document = new Document(PageSize.A4.rotate(), 20, 20, 30, 20);
        try {
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            Font tituloFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
            Font subFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.DARK_GRAY);
            document.add(new Paragraph("Reporte de Capacitaciones", tituloFont));
            String rango = (fechaDesde != null && !fechaDesde.trim().isEmpty() ? fechaDesde.trim() : "inicio")
                    + " a " + (fechaHasta != null && !fechaHasta.trim().isEmpty() ? fechaHasta.trim() : "hoy");
            document.add(new Paragraph("Rango de fecha de factura: " + rango, subFont));
            document.add(new Paragraph(" "));

            PdfPTable table = new PdfPTable(ANCHOS.length);
            table.setWidthPercentage(100);
            table.setWidths(ANCHOS);

            Font headerFont = new Font(Font.FontFamily.HELVETICA, 7, Font.BOLD, BaseColor.WHITE);
            for (String h : ENCABEZADOS) {
                PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
                cell.setBackgroundColor(new BaseColor(94, 114, 228));
                cell.setPadding(4);
                table.addCell(cell);
            }

            Font celdaFont = new Font(Font.FontFamily.HELVETICA, 7, Font.NORMAL);
            Connection cn = null;
            try {
                cn = Servlets.Conexion.getConnection();
                if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
                try (PreparedStatement st = cn.prepareStatement(sql.toString())) {
                    for (int i = 0; i < params.size(); i++) {
                        st.setString(i + 1, params.get(i));
                    }
                    try (ResultSet rs = st.executeQuery()) {
                        while (rs.next()) {
                            for (int col = 1; col <= 12; col++) {
                                String valor = rs.getString(col);
                                PdfPCell cell = new PdfPCell(new Phrase(valor != null ? valor : "", celdaFont));
                                cell.setPadding(3);
                                table.addCell(cell);
                            }
                        }
                    }
                }
            } finally {
                try { if (cn != null) cn.close(); } catch (Exception e2) {}
            }

            document.add(table);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (document.isOpen()) document.close();
        }
    }
}
