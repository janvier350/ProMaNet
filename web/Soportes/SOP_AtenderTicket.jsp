<%--
    Document   : SOP_AtenderTicket
    Pantalla rediseñada para atender un ticket (reemplaza funcionalmente
    a SOP_EditarSolicitudes.jsp, que era improvisada).

    Layout:
      - Header: numero de ticket, fecha solicitud, dias en espera.
      - Info: solicitante, equipo, estado actual, prioridad, tecnico.
      - Descripcion del problema (SOPORTE) completa.
      - Si ya tiene REPORTE (fue atendido o cerrado sin solucion):
        lo muestra como lectura con la fecha.
      - Si es un ticket abierto Y tengo SOPORTES_ATENDER:
        formulario de reporte tecnico con botones:
          * Atender y cerrar  -> InsertReporteTecnico (cierra en ATENDIDO)
          * Marcar en progreso -> SOP_CambiarEstado?accion=EN_PROGRESO
          * Cerrar sin solucion -> SOP_CambiarEstado?accion=SIN_SOLUCION
      - Si tengo SOPORTES_REASIGNAR: modal para reasignar a otro tecnico.
      - Si tengo SOPORTES_ELIMINAR: boton cancelar.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeAtender   = COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER");
    boolean puedeReasignar = COMUN.PermisoHelper.tiene(session, "SOPORTES_REASIGNAR");
    boolean puedeEliminar  = COMUN.PermisoHelper.tiene(session, "SOPORTES_ELIMINAR");

    String idSolicitud = request.getParameter("idSolicitud");
    if (idSolicitud == null || idSolicitud.trim().isEmpty()) {
        response.sendRedirect("SOP_ListaTickets.jsp?error=Falta idSolicitud"); return;
    }

    // Carga del ticket
    String fSol="", solicNom="", marca="", modelo="", serial="", sop="", prio="", estado="";
    String reporte="", fRep="", tecnico="", fPrimAt="";
    int diasEspera = 0;
    double horasAtencion = -1;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT TO_CHAR(a.FECHA_SOLICITUD,'YYYY-MM-DD HH24:MI'), " +
                    "       u.NOMBRE || ' ' || u.APELLIDOS, " +
                    "       e.MARCA, e.MODELO, NVL(e.SERIAL,'-'), " +
                    "       a.SOPORTE, a.PRIORIDAD, a.ESTADO, " +
                    "       a.REPORTE, TO_CHAR(a.FECHA_REPORTE,'YYYY-MM-DD HH24:MI'), " +
                    "       NVL(t.NOMBRE || ' ' || t.APELLIDOS, a.TECNICO), " +
                    "       TO_CHAR(a.FECHA_PRIMERA_ATENCION,'YYYY-MM-DD HH24:MI'), " +
                    "       TRUNC(SYSDATE - a.FECHA_SOLICITUD), " +
                    "       (a.FECHA_REPORTE - a.FECHA_SOLICITUD) * 24 " +
                    "FROM SOP_SOPORTE_CAB a " +
                    "LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
                    "LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDEQUIPO " +
                    "LEFT JOIN USUARIO t ON t.IDUSUARIO = a.ID_TECNICO_ASIGNADO " +
                    "WHERE a.IDSOPORTE = ?")) {
                st.setInt(1, Integer.parseInt(idSolicitud.trim()));
                try (ResultSet rs = st.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("SOP_ListaTickets.jsp?error=Ticket no encontrado"); return;
                    }
                    fSol = esc(rs.getString(1)); solicNom = esc(rs.getString(2));
                    marca = esc(rs.getString(3)); modelo = esc(rs.getString(4)); serial = esc(rs.getString(5));
                    sop = esc(rs.getString(6)); prio = esc(rs.getString(7)); estado = rs.getString(8);
                    reporte = esc(rs.getString(9)); fRep = esc(rs.getString(10));
                    tecnico = esc(rs.getString(11)); fPrimAt = esc(rs.getString(12));
                    diasEspera = rs.getInt(13);
                    horasAtencion = rs.getDouble(14);
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    boolean abierto = "PENDIENTE".equals(estado) || "EN_PROGRESO".equals(estado) || "REASIGNADO".equals(estado);
    boolean cerrado = "ATENDIDO".equals(estado) || "CERRADO_SIN_SOLUCION".equals(estado);

    String badgeEstado;
    switch (estado == null ? "-" : estado) {
        case "PENDIENTE":            badgeEstado = "bg-gradient-warning"; break;
        case "EN_PROGRESO":          badgeEstado = "bg-gradient-info"; break;
        case "REASIGNADO":           badgeEstado = "bg-gradient-secondary"; break;
        case "ATENDIDO":             badgeEstado = "bg-gradient-success"; break;
        case "CERRADO_SIN_SOLUCION": badgeEstado = "bg-gradient-dark"; break;
        case "CANCELADO_USR":        badgeEstado = "bg-gradient-faded-danger"; break;
        default:                     badgeEstado = "bg-gradient-secondary"; break;
    }
    String badgePrio;
    if ("Alta".equalsIgnoreCase(prio)) badgePrio = "bg-gradient-danger";
    else if ("Media".equalsIgnoreCase(prio)) badgePrio = "bg-gradient-warning";
    else badgePrio = "bg-gradient-info";
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Ticket #<%=esc(idSolicitud)%></title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="SOP_Dashboard.jsp">Soportes</a></li>
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="SOP_ListaTickets.jsp">Lista</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Ticket #<%=esc(idSolicitud)%></li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Ticket #<%=esc(idSolicitud)%></h6>
            </nav>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% String msj = request.getParameter("msj"); String err = request.getParameter("error");
           if (msj != null) { %>
        <div class="alert alert-success alert-dismissible fade show py-2" role="alert">
            <%=esc(msj)%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } if (err != null) { %>
        <div class="alert alert-danger alert-dismissible fade show py-2" role="alert">
            <%=esc(err)%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Header del ticket -->
        <div class="card mb-4">
            <div class="card-body p-3">
                <div class="row align-items-center">
                    <div class="col-md-7">
                        <h5 class="mb-1">Ticket #<%=esc(idSolicitud)%>
                            <span class="badge <%=badgeEstado%> ms-2"><%=esc(estado)%></span>
                            <span class="badge <%=badgePrio%> ms-1">Prioridad <%=esc(prio)%></span>
                        </h5>
                        <p class="text-sm text-secondary mb-0">
                            Creado el <%=fSol%> &middot;
                            <% if (abierto) { %>
                                <b class="<%= diasEspera > 3 ? "text-danger" : (diasEspera > 1 ? "text-warning" : "text-success") %>">
                                    <%=diasEspera%> dia(s) en espera
                                </b>
                            <% } else if (cerrado && horasAtencion >= 0) { %>
                                <b>Resuelto en <%=String.format(java.util.Locale.US,"%.1f",horasAtencion)%> horas</b>
                            <% } %>
                        </p>
                    </div>
                    <div class="col-md-5 text-end">
                        <% if (abierto && puedeAtender) { %>
                        <form method="post" action="../SOP_CambiarEstado" style="display:inline;">
                            <input type="hidden" name="idSolicitud" value="<%=esc(idSolicitud)%>">
                            <input type="hidden" name="accion" value="EN_PROGRESO">
                            <button type="submit" class="btn btn-outline-info btn-sm mb-0" title="Marcar en progreso">
                                <i class="fa fa-play me-1"></i>En progreso
                            </button>
                        </form>
                        <% } %>
                        <% if (abierto && puedeReasignar) { %>
                        <button type="button" class="btn btn-outline-secondary btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#modalReasignar">
                            <i class="fa fa-random me-1"></i>Reasignar
                        </button>
                        <% } %>
                        <% if (puedeEliminar && !"CANCELADO_USR".equals(estado)) { %>
                        <form method="post" action="../SOP_EliminarSolicitud" style="display:inline;"
                              onsubmit="return confirm('Cancelar ticket #<%=esc(idSolicitud)%>?');">
                            <input type="hidden" name="idSolicitud" value="<%=esc(idSolicitud)%>">
                            <button type="submit" class="btn btn-outline-danger btn-sm mb-0" title="Cancelar">
                                <i class="fa fa-times me-1"></i>Cancelar
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Info del ticket -->
        <div class="row">
            <div class="col-lg-5">
                <div class="card mb-4">
                    <div class="card-header pb-0"><h6>Informacion</h6></div>
                    <div class="card-body p-3">
                        <p class="text-xs text-uppercase font-weight-bold mb-1">Solicitante</p>
                        <p class="text-sm mb-3"><%=solicNom%></p>

                        <p class="text-xs text-uppercase font-weight-bold mb-1">Equipo</p>
                        <p class="text-sm mb-1"><%=marca%> <%=modelo%></p>
                        <p class="text-xs text-muted mb-3">S/N: <%=serial%></p>

                        <p class="text-xs text-uppercase font-weight-bold mb-1">Tecnico asignado</p>
                        <p class="text-sm mb-3"><%= tecnico.isEmpty() ? "<em class='text-muted'>sin asignar</em>" : tecnico %></p>

                        <% if (!fPrimAt.isEmpty()) { %>
                        <p class="text-xs text-uppercase font-weight-bold mb-1">Primera atencion</p>
                        <p class="text-sm mb-0"><%=fPrimAt%></p>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-lg-7">
                <div class="card mb-4">
                    <div class="card-header pb-0"><h6>Descripcion del problema</h6></div>
                    <div class="card-body p-3">
                        <p class="text-sm mb-0" style="white-space:pre-wrap;"><%=sop%></p>
                    </div>
                </div>

                <% if (!reporte.isEmpty()) { %>
                <div class="card mb-4">
                    <div class="card-header pb-0 d-flex justify-content-between align-items-center">
                        <h6>Reporte tecnico</h6>
                        <% if (!fRep.isEmpty()) { %><small class="text-secondary">Registrado el <%=fRep%></small><% } %>
                    </div>
                    <div class="card-body p-3">
                        <p class="text-sm mb-0" style="white-space:pre-wrap;"><%=reporte%></p>
                    </div>
                </div>
                <% } %>

                <% if (abierto && puedeAtender) { %>
                <div class="card mb-4">
                    <div class="card-header pb-0"><h6>Registrar reporte y cerrar</h6></div>
                    <div class="card-body p-3">
                        <form action="../InsertReporteTecnico" method="post" id="formAtender">
                            <input type="hidden" name="idSolicitudTicket" value="<%=esc(idSolicitud)%>">
                            <div class="form-group mb-3">
                                <label class="text-xs font-weight-bold text-uppercase">Describe la solucion aplicada</label>
                                <textarea name="reporte" class="form-control" rows="5" required
                                          placeholder="Ej. Se reinstalo Office, se actualizo driver de video, equipo quedo operativo."></textarea>
                            </div>
                            <div class="d-flex justify-content-between flex-wrap" style="gap:8px;">
                                <button type="button" class="btn btn-outline-dark btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#modalSinSol">
                                    <i class="fa fa-ban me-1"></i>Cerrar sin solucion
                                </button>
                                <button type="submit" class="btn bg-gradient-success btn-sm mb-0">
                                    <i class="fa fa-check me-1"></i>Atender y cerrar como ATENDIDO
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</main>

<!-- Modal reasignar -->
<% if (abierto && puedeReasignar) { %>
<div class="modal fade" id="modalReasignar" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="../SOP_CambiarEstado">
                <input type="hidden" name="idSolicitud" value="<%=esc(idSolicitud)%>">
                <input type="hidden" name="accion" value="REASIGNAR">
                <div class="modal-header"><h5 class="modal-title">Reasignar ticket</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="form-group mb-3">
                        <label class="text-xs font-weight-bold text-uppercase">Nuevo tecnico</label>
                        <select name="idTecnico" class="form-control" required>
                            <option value="">-- Elegir --</option>
                            <%
                                // Lista de usuarios con permiso SOPORTES_ATENDER para reasignar
                                try (Connection cnT = Servlets.Conexion.getConnection()) {
                                    if (cnT != null) {
                                        try (PreparedStatement st = cnT.prepareStatement(
                                                "SELECT DISTINCT u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS " +
                                                "FROM USUARIO u " +
                                                "LEFT JOIN APP_USUARIO_PERMISO up ON up.IDUSUARIO = u.IDUSUARIO " +
                                                "LEFT JOIN APP_PERMISO p1 ON p1.ID_PERMISO = up.ID_PERMISO AND p1.CODIGO = 'SOPORTES_ATENDER' AND up.TIPO = 'G' " +
                                                "LEFT JOIN APP_ROL_PERMISO rp ON rp.IDROL = u.IDROL " +
                                                "LEFT JOIN APP_PERMISO p2 ON p2.ID_PERMISO = rp.ID_PERMISO AND p2.CODIGO = 'SOPORTES_ATENDER' " +
                                                "WHERE UPPER(u.ESTADO) = 'A' AND (p1.ID_PERMISO IS NOT NULL OR p2.ID_PERMISO IS NOT NULL) " +
                                                "ORDER BY 2");
                                             ResultSet rsT = st.executeQuery()) {
                                            while (rsT.next()) {
                            %>
                            <option value="<%=rsT.getString(1)%>"><%=esc(rsT.getString(2))%></option>
                            <% } } } } catch (Exception e) { e.printStackTrace(); } %>
                        </select>
                    </div>
                    <div class="form-group mb-0">
                        <label class="text-xs font-weight-bold text-uppercase">Motivo (opcional)</label>
                        <textarea name="comentario" class="form-control" rows="2"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-random me-1"></i>Reasignar</button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<!-- Modal cerrar sin solucion -->
<% if (abierto && puedeAtender) { %>
<div class="modal fade" id="modalSinSol" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="../SOP_CambiarEstado">
                <input type="hidden" name="idSolicitud" value="<%=esc(idSolicitud)%>">
                <input type="hidden" name="accion" value="SIN_SOLUCION">
                <div class="modal-header bg-gradient-dark text-white"><h5 class="modal-title">Cerrar sin solucion</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm">Usar esta opcion cuando no se pudo resolver el ticket pero igual se da por cerrado (ej. el usuario abandono, el equipo se dio de baja, se escalo a un tercero externo).</p>
                    <div class="form-group mb-0">
                        <label class="text-xs font-weight-bold text-uppercase">Motivo (obligatorio)</label>
                        <textarea name="comentario" class="form-control" rows="3" required
                                  placeholder="Ej. Equipo dado de baja; usuario reporto que ya no es necesario; etc."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn bg-gradient-dark btn-sm"><i class="fa fa-ban me-1"></i>Cerrar sin solucion</button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

</body>
</html>
