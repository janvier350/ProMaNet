package VACACIONES;

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
import java.text.SimpleDateFormat;

// Documento imprimible con el detalle de vacaciones consumidas de un
// empleado (el historial cargado manualmente, previo a este modulo, mas
// el resumen de periodos) para que el empleado lo firme y quede
// constancia de que el registro esta correcto. Solo lo puede generar
// quien administra el modulo (VACACIONES_CONFIGURAR), igual que la
// pantalla de saldo desde donde se imprime.
@WebServlet(name = "VAC_ImprimirSaldo", urlPatterns = {"/VAC_ImprimirSaldo"})
public class VAC_ImprimirSaldo extends HttpServlet {

    // Escapa texto libre (observaciones) antes de insertarlo en HTML.
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idEmpleado = request.getParameter("id");
        response.setContentType("text/html;charset=UTF-8");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String nombreEmpleado = "", cargoEmpleado = "-", departamentoEmpleado = "-", cedulaEmpleado = "";
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT u.NOMBRE||' '||u.APELLIDOS, r.CARGO, d.DEPARTAMENTO, vc.CEDULA " +
                    "FROM USUARIO u " +
                    "LEFT JOIN ROL r ON u.IDROL = r.IDROL " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO " +
                    "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
                    "WHERE u.IDUSUARIO = ?")) {
                st.setString(1, idEmpleado);
                try (ResultSet rs = st.executeQuery()) {
                    if (!rs.next()) {
                        response.getWriter().println("Empleado no encontrado.");
                        return;
                    }
                    nombreEmpleado = rs.getString(1);
                    cargoEmpleado = rs.getString(2) != null ? rs.getString(2) : "-";
                    departamentoEmpleado = rs.getString(3) != null ? rs.getString(3) : "-";
                    cedulaEmpleado = rs.getString(4);
                }
            }

            VAC_CalculoSaldo.Saldo saldo = VAC_CalculoSaldo.calcular(cn, Integer.parseInt(idEmpleado));

            StringBuilder filasAjustes = new StringBuilder();
            int totalAjustes = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NUM_PERIODO, DIAS_GOZADOS, TO_CHAR(FECHA_DESDE,'DD/MM/YYYY'), " +
                    "TO_CHAR(FECHA_HASTA,'DD/MM/YYYY'), OBSERVACIONES " +
                    "FROM VAC_HISTORICO_AJUSTE WHERE ID_USUARIO = ? ORDER BY NUM_PERIODO, FECHA_REGISTRO")) {
                st.setString(1, idEmpleado);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        totalAjustes++;
                        filasAjustes.append("<tr>")
                                .append("<td class='text-center'>").append(rs.getString(1)).append("</td>")
                                .append("<td class='text-center'>").append(rs.getString(2)).append("</td>")
                                .append("<td>").append(rs.getString(3) != null ? rs.getString(3) : "-").append("</td>")
                                .append("<td>").append(rs.getString(4) != null ? rs.getString(4) : "-").append("</td>")
                                .append("<td>").append(esc(rs.getString(5))).append("</td>")
                                .append("</tr>\n");
                    }
                }
            }

            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html><html><head><title>Vacaciones Consumidas</title>");
                out.println("<meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>");
                // Sin CSS externo (CDN) a proposito -- ver VAC_ImprimirSolicitud
                // para el motivo (la vista de impresion se colgaba si la red
                // estaba lenta o bloqueaba el CDN).
                out.println("<style>");
                out.println("*{box-sizing:border-box;}");
                out.println("body{background:#f4f6f9;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;margin:0;}");
                out.println(".doc-container{max-width:900px;margin:30px auto;padding:0 15px;}");
                out.println(".doc-card{background:#fff;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,.1);padding:35px;}");
                out.println(".bloque-titulo{background:#343a40;color:#fff;text-align:center;padding:10px;border-radius:8px;font-weight:700;letter-spacing:.5px;margin-bottom:20px;}");
                out.println(".campo{margin-bottom:14px;}");
                out.println(".campo label{display:block;font-size:.72rem;text-transform:uppercase;color:#6c757d;font-weight:700;letter-spacing:.4px;}");
                out.println(".campo .valor{font-size:1rem;color:#212529;border-bottom:1px solid #ced4da;padding-bottom:3px;min-height:1.4em;}");
                out.println(".row{display:flex;flex-wrap:wrap;margin:0 -8px;}");
                out.println(".row > div{padding:0 8px;}");
                out.println(".col-4{flex:0 0 33.3333%;max-width:33.3333%;}");
                out.println(".col-6{flex:0 0 50%;max-width:50%;}");
                out.println("table{width:100%;border-collapse:collapse;margin:12px 0 20px;font-size:.85rem;}");
                out.println("th,td{border:1px solid #dee2e6;padding:6px 8px;text-align:left;}");
                out.println("th{background:#f1f3f5;font-size:.72rem;text-transform:uppercase;color:#6c757d;}");
                out.println(".text-center{text-align:center;}");
                out.println(".sin-datos{text-align:center;color:#6c757d;padding:16px;}");
                out.println(".firma-section{margin-top:35px;text-align:center;}");
                out.println(".firma-linea{border-top:1px solid #495057;width:260px;margin:8px auto 6px;}");
                out.println(".text-xs{font-size:.75rem;}");
                out.println(".text-muted{color:#6c757d;}");
                out.println(".btn-imprimir{background:#0d6efd;color:#fff;border:none;border-radius:6px;padding:8px 16px;font-size:.85rem;cursor:pointer;}");
                out.println("@media print{body{background:#fff;} .doc-card{box-shadow:none;} .btn-imprimir{display:none;}}");
                out.println("</style></head><body>");
                out.println("<div class='doc-container'>");
                out.println("<div style='text-align:right;margin-bottom:8px;'><button class='btn-imprimir' onclick='window.print()'>Imprimir</button></div>");
                out.println("<div class='doc-card'>");

                out.println("<div class='bloque-titulo'>REGISTRO DE VACACIONES CONSUMIDAS</div>");
                out.println("<div class='row'>");
                out.println("<div class='col-6 campo'><label>Funcionario</label><div class='valor'>" + esc(nombreEmpleado) + "</div></div>");
                out.println("<div class='col-4 campo'><label>Cedula</label><div class='valor'>" + (cedulaEmpleado != null && !cedulaEmpleado.trim().isEmpty() ? esc(cedulaEmpleado) : "&nbsp;") + "</div></div>");
                out.println("</div><div class='row'>");
                out.println("<div class='col-6 campo'><label>Cargo</label><div class='valor'>" + esc(cargoEmpleado) + "</div></div>");
                out.println("<div class='col-6 campo'><label>Departamento</label><div class='valor'>" + esc(departamentoEmpleado) + "</div></div>");
                out.println("</div><div class='row'>");
                if (saldo.configurado) {
                    out.println("<div class='col-4 campo'><label>Fecha de ingreso</label><div class='valor'>" + new SimpleDateFormat("dd/MM/yyyy").format(saldo.fechaIngreso) + "</div></div>");
                    out.println("<div class='col-4 campo'><label>Antiguedad</label><div class='valor'>" + String.format("%.1f años", saldo.antiguedadAnios) + "</div></div>");
                    out.println("<div class='col-4 campo'><label>Dias disponibles hoy</label><div class='valor'>" + saldo.totalDisponible + " dias</div></div>");
                }
                out.println("</div>");

                out.println("<h6>Periodos acumulados</h6>");
                out.println("<table><thead><tr><th class='text-center'>#</th><th>Desde</th><th>Hasta</th>" +
                        "<th class='text-center'>Acumulados</th><th class='text-center'>Gozados</th><th class='text-center'>Disponibles</th></tr></thead><tbody>");
                if (saldo.periodos.isEmpty()) {
                    out.println("<tr><td colspan='6' class='sin-datos'>Sin periodos acumulados todavia.</td></tr>");
                } else {
                    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
                    for (VAC_CalculoSaldo.Periodo p : saldo.periodos) {
                        out.println("<tr><td class='text-center'>" + p.numero + "</td><td>" + fmt.format(p.desde) + "</td><td>" + fmt.format(p.hasta) +
                                "</td><td class='text-center'>" + p.diasAcumulados + "</td><td class='text-center'>" + p.diasConsumidos +
                                "</td><td class='text-center'>" + p.diasDisponibles + "</td></tr>");
                    }
                }
                out.println("</tbody></table>");

                out.println("<h6>Detalle de dias consumidos (historico cargado previo a este modulo)</h6>");
                out.println("<table><thead><tr><th class='text-center'>Periodo</th><th class='text-center'>Dias</th>" +
                        "<th>Fecha Desde</th><th>Fecha Hasta</th><th>Observaciones</th></tr></thead><tbody>");
                if (totalAjustes == 0) {
                    out.println("<tr><td colspan='5' class='sin-datos'>Sin ajustes historicos registrados.</td></tr>");
                } else {
                    out.println(filasAjustes.toString());
                }
                out.println("</tbody></table>");

                out.println("<div class='firma-section'>");
                out.println("<div class='firma-linea'></div>");
                out.println("<div><small class='text-muted'>" + esc(nombreEmpleado) + "</small></div>");
                out.println("<div class='text-xs'>Firma del Empleado -- confirma que el registro de vacaciones consumidas es correcto</div>");
                out.println("</div>");

                out.println("</div></div></body></html>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
