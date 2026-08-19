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

// Documento imprimible de una solicitud de vacaciones, replica del
// formato en papel (bloque "Solicitud" + bloque "Aprobacion
// Administracion/RRHH" + lineas de firma). Solo lo puede ver el
// propio solicitante, su jefe directo, o quien tenga
// VACACIONES_GESTIONAR -- nunca confia en datos de la URL, todo se
// vuelve a leer de la base por ID.
@WebServlet(name = "VAC_ImprimirSolicitud", urlPatterns = {"/VAC_ImprimirSolicitud"})
public class VAC_ImprimirSolicitud extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }

        int miId;
        try {
            miId = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
        boolean puedeGestionar = PermisoHelper.tiene(session, "VACACIONES_GESTIONAR");

        String idSolicitud = request.getParameter("id");
        response.setContentType("text/html;charset=UTF-8");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idUsuarioSolicitud = -1, idJefeDirecto = -1, numPeriodo = -1, diasSolicitados = 0, diasAprobados = 0;
            String nombreSolicitante = "", cargoSolicitante = "", departamentoSolicitante = "";
            String fechaSolicitud = "", fechaDesde = "", fechaHasta = "", fechaReincorporacion = "";
            String estado = "";
            String nombreJefe = "", fechaAprobacionJefe = "";
            String nombreAdmin = "", fechaAprobacionAdmin = "";
            String cedulaSolicitante = "";
            String comentarioJefe = "", comentarioAdmin = "";
            String empresaSolicitante = "";

            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT s.ID_USUARIO, s.ID_JEFE_DIRECTO, s.NUM_PERIODO, s.DIAS_SOLICITADOS, " +
                    "NVL(s.DIAS_APROBADOS,0), s.ESTADO, " +
                    "TO_CHAR(s.FECHA_SOLICITUD,'DD/MM/YYYY'), TO_CHAR(s.FECHA_DESDE,'DD/MM/YYYY'), " +
                    "TO_CHAR(s.FECHA_HASTA,'DD/MM/YYYY'), TO_CHAR(s.FECHA_REINCORPORACION,'DD/MM/YYYY'), " +
                    "u.NOMBRE||' '||u.APELLIDOS, r.CARGO, d.DEPARTAMENTO, " +
                    "j.NOMBRE||' '||j.APELLIDOS, TO_CHAR(s.FECHA_APROBACION_JEFE,'DD/MM/YYYY'), " +
                    "a.NOMBRE||' '||a.APELLIDOS, TO_CHAR(s.FECHA_APROBACION_ADMIN,'DD/MM/YYYY'), " +
                    "vc.CEDULA, s.COMENTARIO_JEFE, s.COMENTARIO_ADMIN, vc.EMPRESA_IESS " +
                    "FROM VAC_SOLICITUD s " +
                    "JOIN USUARIO u ON s.ID_USUARIO = u.IDUSUARIO " +
                    "LEFT JOIN ROL r ON u.IDROL = r.IDROL " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO " +
                    "JOIN USUARIO j ON s.ID_JEFE_DIRECTO = j.IDUSUARIO " +
                    "LEFT JOIN USUARIO a ON s.ID_USUARIO_APRUEBA_ADMIN = a.IDUSUARIO " +
                    "LEFT JOIN VAC_CONFIG_USUARIO vc ON u.IDUSUARIO = vc.ID_USUARIO " +
                    "WHERE s.ID_SOLICITUD = ?")) {
                st.setString(1, idSolicitud);
                try (ResultSet rs = st.executeQuery()) {
                    if (!rs.next()) {
                        response.getWriter().println("Solicitud no encontrada.");
                        return;
                    }
                    idUsuarioSolicitud = rs.getInt(1);
                    idJefeDirecto = rs.getInt(2);
                    numPeriodo = rs.getInt(3);
                    diasSolicitados = rs.getInt(4);
                    diasAprobados = rs.getInt(5);
                    estado = rs.getString(6);
                    fechaSolicitud = rs.getString(7);
                    fechaDesde = rs.getString(8);
                    fechaHasta = rs.getString(9);
                    fechaReincorporacion = rs.getString(10);
                    nombreSolicitante = rs.getString(11);
                    cargoSolicitante = rs.getString(12) != null ? rs.getString(12) : "-";
                    departamentoSolicitante = rs.getString(13) != null ? rs.getString(13) : "-";
                    nombreJefe = rs.getString(14);
                    fechaAprobacionJefe = rs.getString(15);
                    nombreAdmin = rs.getString(16);
                    fechaAprobacionAdmin = rs.getString(17);
                    cedulaSolicitante = rs.getString(18);
                    comentarioJefe = rs.getString(19);
                    comentarioAdmin = rs.getString(20);
                    empresaSolicitante = rs.getString(21);
                }
            }

            if (miId != idUsuarioSolicitud && miId != idJefeDirecto && !puedeGestionar) {
                response.sendRedirect("sesionInvalida.jsp");
                return;
            }

            // Periodo de acumulacion al que corresponde (desde/hasta) y el
            // saldo "dias por gozar" actual de ese periodo, para el bloque
            // de aprobacion -- se recalcula en vivo, nunca se guarda estatico.
            String periodoDesde = "-", periodoHasta = "-";
            int diasPorGozar = 0;
            VAC_CalculoSaldo.Saldo saldo = VAC_CalculoSaldo.calcular(cn, idUsuarioSolicitud);
            for (VAC_CalculoSaldo.Periodo p : saldo.periodos) {
                if (p.numero == numPeriodo) {
                    periodoDesde = new java.text.SimpleDateFormat("dd/MM/yyyy").format(p.desde);
                    periodoHasta = new java.text.SimpleDateFormat("dd/MM/yyyy").format(p.hasta);
                    diasPorGozar = p.diasDisponibles;
                    break;
                }
            }

            boolean aprobado = "APROBADO".equals(estado) || "RECIBIDO".equals(estado);
            boolean rechazadoJefe = "RECHAZADO_JEFE".equals(estado);
            boolean rechazadoAdmin = "RECHAZADO_ADMIN".equals(estado);
            // Si el jefe rechazo, la solicitud nunca llego a Administracion --
            // ese bloque no debe decir "Pendiente" (da a entender que sigue
            // en tramite) sino que el flujo se detuvo antes.
            boolean noAlcanzoAdmin = rechazadoJefe;
            String logoEmpresa = logoParaEmpresa(empresaSolicitante);

            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html><html><head><title>Solicitud de Vacaciones</title>");
                out.println("<meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>");
                out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>");
                out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
                out.println("<style>");
                out.println("body{background:#f4f6f9;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}");
                out.println(".doc-container{max-width:900px;margin:30px auto;}");
                out.println(".doc-card{background:#fff;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,.1);padding:35px;}");
                out.println(".bloque-titulo{background:#343a40;color:#fff;text-align:center;padding:10px;border-radius:8px;font-weight:700;letter-spacing:.5px;margin-bottom:20px;}");
                out.println(".bloque-titulo.aprobacion{background:#0d6efd;}");
                out.println(".campo{margin-bottom:14px;}");
                out.println(".campo label{display:block;font-size:.72rem;text-transform:uppercase;color:#6c757d;font-weight:700;letter-spacing:.4px;}");
                out.println(".campo .valor{font-size:1rem;color:#212529;border-bottom:1px solid #ced4da;padding-bottom:3px;min-height:1.4em;}");
                out.println(".estado-badge{display:inline-block;padding:6px 16px;border-radius:20px;font-weight:700;letter-spacing:.5px;}");
                out.println(".estado-aprobado{background:#d1e7dd;color:#0f5132;}");
                out.println(".estado-pendiente{background:#fff3cd;color:#856404;}");
                out.println(".estado-rechazado{background:#f8d7da;color:#842029;}");
                out.println(".firma-section{margin-top:40px;}");
                out.println(".firma-linea{border-top:1px solid #495057;width:260px;margin:50px auto 6px;}");
                out.println(".separator{height:1px;background:#dee2e6;margin:25px 0;}");
                out.println(".doc-header{display:flex;align-items:center;gap:15px;margin-bottom:20px;}");
                out.println(".doc-logo{max-height:70px;max-width:220px;}");
                out.println(".doc-empresa{font-weight:700;color:#343a40;font-size:1rem;}");
                out.println("@media print{body{background:#fff;} .doc-card{box-shadow:none;} .btn-imprimir{display:none;}}");
                out.println("</style></head><body>");
                out.println("<div class='doc-container'>");
                out.println("<div class='text-end mb-2'><button class='btn btn-primary btn-sm btn-imprimir' onclick='window.print()'><i class='fa fa-print me-1'></i>Imprimir</button></div>");
                out.println("<div class='doc-card'>");

                // Encabezado: logo + nombre de la empresa de afiliacion IESS
                // (vc.EMPRESA_IESS). Si todavia no hay logo cargado para esa
                // empresa se muestra solo el nombre, nunca un logo generico
                // que no le corresponda.
                out.println("<div class='doc-header'>");
                if (logoEmpresa != null) {
                    out.println("<img src='image/" + logoEmpresa + "' alt='Logo' class='doc-logo'>");
                }
                if (empresaSolicitante != null && !empresaSolicitante.trim().isEmpty()) {
                    out.println("<div class='doc-empresa'>" + empresaSolicitante + "</div>");
                }
                out.println("</div>");

                // Bloque 1: Solicitud (empleado)
                out.println("<div class='bloque-titulo'>SOLICITUD DE VACACIONES (EMPLEADO)</div>");
                out.println("<div class='row'>");
                out.println("<div class='col-md-4 campo'><label>Fecha de solicitud</label><div class='valor'>" + fechaSolicitud + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Funcionario</label><div class='valor'>" + nombreSolicitante + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Cedula</label><div class='valor'>" + (cedulaSolicitante != null && !cedulaSolicitante.trim().isEmpty() ? cedulaSolicitante : "&nbsp;") + "</div></div>");
                out.println("</div><div class='row'>");
                out.println("<div class='col-md-6 campo'><label>Cargo</label><div class='valor'>" + cargoSolicitante + "</div></div>");
                out.println("<div class='col-md-6 campo'><label>Departamento</label><div class='valor'>" + departamentoSolicitante + "</div></div>");
                out.println("</div><div class='row'>");
                out.println("<div class='col-md-4 campo'><label>Periodo de vacaciones - Desde</label><div class='valor'>" + fechaDesde + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Periodo de vacaciones - Hasta</label><div class='valor'>" + fechaHasta + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Fecha de reincorporacion</label><div class='valor'>" + fechaReincorporacion + "</div></div>");
                out.println("</div><div class='row'>");
                out.println("<div class='col-md-6 campo'><label>Numero de dias que solicita</label><div class='valor'>" + diasSolicitados + " dias</div></div>");
                out.println("<div class='col-md-6 campo'><label>Periodo de vacaciones al que corresponde</label><div class='valor'>DEL " + periodoDesde + " - " + periodoHasta + "</div></div>");
                out.println("</div>");
                if (rechazadoJefe) {
                    out.println("<div class='text-center mb-2'><span class='estado-badge estado-rechazado'><i class='fa fa-times-circle me-1'></i>RECHAZADO POR EL JEFE DIRECTO</span></div>");
                    if (comentarioJefe != null && !comentarioJefe.trim().isEmpty()) {
                        out.println("<div class='campo'><label>Motivo del rechazo</label><div class='valor'>" + comentarioJefe + "</div></div>");
                    }
                }
                out.println("<div class='firma-section text-center'>");
                out.println("<div class='firma-linea'></div><div class='text-xs'>Firma Jefe Departamental</div>");
                out.println("<div style='margin-top:-40px;'><small class='text-muted'>" + nombreJefe + "</small></div>");
                out.println("</div>");

                out.println("<div class='separator'></div>");

                // Bloque 2: Aprobacion Administracion / RRHH
                out.println("<div class='bloque-titulo aprobacion'>APROBACION DE VACACIONES (ADMINISTRACION - RRHH)</div>");
                out.println("<div class='text-center mb-4'>");
                if (aprobado) {
                    out.println("<span class='estado-badge estado-aprobado'><i class='fa fa-check-circle me-1'></i>APROBADO</span>");
                } else if (rechazadoAdmin) {
                    out.println("<span class='estado-badge estado-rechazado'><i class='fa fa-times-circle me-1'></i>RECHAZADO</span>");
                } else if (noAlcanzoAdmin) {
                    out.println("<span class='estado-badge estado-rechazado'><i class='fa fa-ban me-1'></i>NO APLICA (RECHAZADO POR EL JEFE)</span>");
                } else {
                    out.println("<span class='estado-badge estado-pendiente'><i class='fa fa-clock me-1'></i>PENDIENTE</span>");
                }
                out.println("</div>");
                if (rechazadoAdmin && comentarioAdmin != null && !comentarioAdmin.trim().isEmpty()) {
                    out.println("<div class='campo'><label>Motivo del rechazo</label><div class='valor'>" + comentarioAdmin + "</div></div>");
                }
                out.println("<div class='row'>");
                out.println("<div class='col-md-4 campo'><label>Numero de dias aprobados</label><div class='valor'>" + (aprobado ? diasAprobados + " dias" : "-") + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Dias por gozar (saldo)</label><div class='valor'>" + (aprobado ? diasPorGozar + " dias" : "-") + "</div></div>");
                out.println("<div class='col-md-4 campo'><label>Fecha de aprobacion</label><div class='valor'>" + (fechaAprobacionAdmin != null ? fechaAprobacionAdmin : "-") + "</div></div>");
                out.println("</div>");
                out.println("<div class='firma-section text-center'>");
                out.println("<div class='firma-linea'></div><div class='text-xs'>Firma Administrador</div>");
                out.println("<div style='margin-top:-40px;'><small class='text-muted'>" + (nombreAdmin != null ? nombreAdmin : "") + "</small></div>");
                out.println("</div>");

                out.println("</div></div></body></html>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }

    // Logo del documento impreso, segun la empresa de afiliacion IESS
    // (VAC_CONFIG_USUARIO.EMPRESA_IESS) -- NO segun la Compania de
    // Inventario, que puede ser otra. Solo se listan las empresas para
    // las que ya existe un archivo en /web/image; el resto se deja sin
    // logo (nunca se usa el logo de una empresa distinta) hasta que se
    // cargue el archivo correspondiente y se agregue aqui.
    private static String logoParaEmpresa(String empresa) {
        if (empresa == null) return null;
        String e = empresa.trim();
        if (e.equalsIgnoreCase("BUSINESS ADVISOR NETWORK BUADNET S.A.")) return "buadnet2020.png";
        if (e.equalsIgnoreCase("LATINCONSULTING S.A.")) return "LatiSA.png";
        if (e.equalsIgnoreCase("ARTHURS AUDIT GLOBAL HURSDIT S.A.")) return "Arthurs.png";
        return null;
    }
}
