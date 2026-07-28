package CAPACITACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import java.io.PrintWriter;
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

// Exporta el listado de capacitaciones a un .xls que Excel abre nativo
// como hoja de calculo real (tabla HTML con content-type de Excel), sin
// depender de una libreria como Apache POI que no esta en el proyecto.
@WebServlet(name = "CAP_ExportarExcel", urlPatterns = {"/CAP_ExportarExcel"})
public class CAP_ExportarExcel extends HttpServlet {

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

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

        response.setContentType("application/vnd.ms-excel;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=capacitaciones.xls");

        StringBuilder sql = new StringBuilder(
                "SELECT s.NOMBRE_SEMINARIO, e.DESCRIPCION, s.ESTADO_PAGO, s.FORMA_PAGO, s.APROBACION, " +
                "s.HORARIO, s.FECHA_CAPACITACION, s.DURACION_HORAS, s.MODALIDAD, s.UBICACION, " +
                "s.NO_PARTICIPANTES, s.NOMBRE_PARTICIPANTES, s.SUBTOTAL, s.IVA_PORCENTAJE, s.IVA_VALOR, " +
                "s.TOTAL_FACTURA, s.RETENCION, s.TOTAL_PAGADO, c.COMPANIA, TO_CHAR(s.FECHA_FACTURA,'DD/MM/YYYY') " +
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

        try (PrintWriter out = response.getWriter()) {
            out.println("<html><head><meta charset=\"UTF-8\"></head><body>");
            out.println("<table border=\"1\">");
            out.println("<tr>"
                    + "<th>Seminario</th><th>Empresa Capacitadora</th><th>Estado</th><th>Forma de Pago</th>"
                    + "<th>Aprobacion</th><th>Horario</th><th>Fecha(s) Capacitacion</th><th>Duracion (horas)</th>"
                    + "<th>Modalidad</th><th>Ubicacion</th><th>No. Participantes</th><th>Nombre Participantes</th>"
                    + "<th>Subtotal</th><th>% IVA</th><th>IVA</th><th>Total Factura</th><th>Retencion</th>"
                    + "<th>Total Pagado</th><th>Compania Facturada</th><th>Fecha Factura</th>"
                    + "</tr>");

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
                            out.println("<tr>"
                                    + "<td>" + esc(rs.getString(1)) + "</td>"
                                    + "<td>" + esc(rs.getString(2)) + "</td>"
                                    + "<td>" + esc(rs.getString(3)) + "</td>"
                                    + "<td>" + esc(rs.getString(4)) + "</td>"
                                    + "<td>" + esc(rs.getString(5)) + "</td>"
                                    + "<td>" + esc(rs.getString(6)) + "</td>"
                                    + "<td>" + esc(rs.getString(7)) + "</td>"
                                    + "<td>" + esc(rs.getString(8)) + "</td>"
                                    + "<td>" + esc(rs.getString(9)) + "</td>"
                                    + "<td>" + esc(rs.getString(10)) + "</td>"
                                    + "<td>" + esc(rs.getString(11)) + "</td>"
                                    + "<td>" + esc(rs.getString(12)) + "</td>"
                                    + "<td>" + esc(rs.getString(13)) + "</td>"
                                    + "<td>" + esc(rs.getString(14)) + "</td>"
                                    + "<td>" + esc(rs.getString(15)) + "</td>"
                                    + "<td>" + esc(rs.getString(16)) + "</td>"
                                    + "<td>" + esc(rs.getString(17)) + "</td>"
                                    + "<td>" + esc(rs.getString(18)) + "</td>"
                                    + "<td>" + esc(rs.getString(19)) + "</td>"
                                    + "<td>" + esc(rs.getString(20)) + "</td>"
                                    + "</tr>");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try { if (cn != null) cn.close(); } catch (Exception e2) {}
            }

            out.println("</table></body></html>");
        }
    }
}
