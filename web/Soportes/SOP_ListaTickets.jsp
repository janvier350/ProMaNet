<%--
    Document   : SOP_ListaTickets
    Lista UNIFICADA de tickets de soporte con filtros potentes. Reemplaza
    SOP_ListaSolicitudes_ALL.jsp y SOP_ListaSolicitudes_Anual.jsp.

    Filtros disponibles:
      - Estados (checkbox multiple): PENDIENTE, EN_PROGRESO, REASIGNADO,
        ATENDIDO, CERRADO_SIN_SOLUCION, CANCELADO_USR
      - Prioridad: Alta / Media / Baja (dropdown)
      - Fecha desde / hasta (rango sobre FECHA_SOLICITUD)
      - Usuario solicitante: substring sobre nombre+apellidos
      - Tecnico asignado: substring
      - Equipo: substring sobre marca+modelo+serial
      - Texto en soporte: substring (busqueda libre)
      - Solo "en espera > N dias" (checkbox para encontrar casos
        olvidados rapido)

    Permisos:
      - SOPORTES_VER_PENDIENTES, SOPORTES_VER_ATENDIDOS o
        SOPORTES_VER_HISTORIAL cualquiera habilita ver la pantalla.
      - El filtro de estado se preselecciona segun los permisos:
          * si solo tiene VER_PENDIENTES, el default es PENDIENTE+EN_PROGRESO
          * si solo tiene VER_ATENDIDOS, el default es ATENDIDO
          * si tiene VER_HISTORIAL, todos los estados por default.

    Export: botones Excel/PDF via DataTables Buttons (misma config
    estetica que las otras listas del sistema).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.*"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private static String escAttr(String s) { return esc(s); }
    private static String nz(String s, String def) { return s == null ? def : s; }
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    boolean puedeVerPendientes = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_PENDIENTES");
    boolean puedeVerAtendidos  = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_ATENDIDOS");
    boolean puedeVerHistorial  = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_HISTORIAL");
    boolean puedeAtender       = COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER");
    boolean puedeEliminar      = COMUN.PermisoHelper.tiene(session, "SOPORTES_ELIMINAR");
    if (!(puedeVerPendientes || puedeVerAtendidos || puedeVerHistorial)) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    // ------- Filtros ---------------------------------------------------
    String[] fEstados = request.getParameterValues("fEstado");
    String fPrioridad = request.getParameter("fPrioridad");
    String fDesde     = request.getParameter("fDesde");
    String fHasta     = request.getParameter("fHasta");
    String fUsuario   = request.getParameter("fUsuario");
    String fTecnico   = request.getParameter("fTecnico");
    String fEquipo    = request.getParameter("fEquipo");
    String fTexto     = request.getParameter("fTexto");
    String fEsperaMas = request.getParameter("fEsperaMas");  // "3" (dias) o vacio

    boolean esPrimeraCarga = request.getParameter("filtrar") == null;
    if (esPrimeraCarga) {
        // Por default, al entrar siempre se muestran los ABIERTOS
        // (PENDIENTE + EN_PROGRESO + REASIGNADO). Es lo mas util del
        // dia a dia -- lo pendiente aparece arriba. Si el usuario
        // quiere ver cerrados, destilda los checkboxes y marca otros.
        fEstados = new String[]{"PENDIENTE","EN_PROGRESO","REASIGNADO"};
    }

    // ------- Query dinamico -------------------------------------------
    StringBuilder sql = new StringBuilder(
        "SELECT * FROM (" +
        "  SELECT a.IDSOPORTE, TO_CHAR(a.FECHA_SOLICITUD,'YYYY-MM-DD HH24:MI') FSOL, " +
        "    u.NOMBRE || ' ' || u.APELLIDOS SOLICITANTE, " +
        "    e.MARCA, e.MODELO, e.SERIAL, " +
        "    a.SOPORTE, a.PRIORIDAD, a.ESTADO, " +
        "    NVL(t.NOMBRE || ' ' || t.APELLIDOS, a.TECNICO) TECNICO_NOMBRE, " +
        "    TO_CHAR(a.FECHA_REPORTE,'YYYY-MM-DD HH24:MI') FREP, " +
        "    a.REPORTE, " +
        "    TRUNC(SYSDATE - a.FECHA_SOLICITUD) DIAS_ESPERA, " +
        "    a.ID_TECNICO_ASIGNADO " +
        "  FROM SOP_SOPORTE_CAB a " +
        "  LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
        "  LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDEQUIPO " +
        "  LEFT JOIN USUARIO t ON t.IDUSUARIO = a.ID_TECNICO_ASIGNADO " +
        "  WHERE 1 = 1 ");
    List<Object> params = new ArrayList<>();

    if (fEstados != null && fEstados.length > 0) {
        sql.append(" AND a.ESTADO IN (");
        for (int i = 0; i < fEstados.length; i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
            params.add(fEstados[i]);
        }
        sql.append(") ");
    }
    if (fPrioridad != null && !fPrioridad.trim().isEmpty()) {
        sql.append(" AND UPPER(a.PRIORIDAD) = UPPER(?) ");
        params.add(fPrioridad.trim());
    }
    if (fDesde != null && !fDesde.trim().isEmpty()) {
        sql.append(" AND a.FECHA_SOLICITUD >= TO_DATE(?, 'YYYY-MM-DD') ");
        params.add(fDesde);
    }
    if (fHasta != null && !fHasta.trim().isEmpty()) {
        sql.append(" AND a.FECHA_SOLICITUD < TO_DATE(?, 'YYYY-MM-DD') + 1 ");
        params.add(fHasta);
    }
    if (fUsuario != null && !fUsuario.trim().isEmpty()) {
        sql.append(" AND UPPER(u.NOMBRE || ' ' || u.APELLIDOS) LIKE UPPER('%' || ? || '%') ");
        params.add(fUsuario.trim());
    }
    if (fTecnico != null && !fTecnico.trim().isEmpty()) {
        sql.append(" AND (UPPER(t.NOMBRE || ' ' || t.APELLIDOS) LIKE UPPER('%' || ? || '%') ");
        sql.append("  OR UPPER(NVL(a.TECNICO,' ')) LIKE UPPER('%' || ? || '%')) ");
        params.add(fTecnico.trim()); params.add(fTecnico.trim());
    }
    if (fEquipo != null && !fEquipo.trim().isEmpty()) {
        sql.append(" AND (UPPER(e.MARCA || ' ' || e.MODELO || ' ' || NVL(e.SERIAL,' ')) LIKE UPPER('%' || ? || '%')) ");
        params.add(fEquipo.trim());
    }
    if (fTexto != null && !fTexto.trim().isEmpty()) {
        sql.append(" AND UPPER(a.SOPORTE) LIKE UPPER('%' || ? || '%') ");
        params.add(fTexto.trim());
    }
    if (fEsperaMas != null && !fEsperaMas.trim().isEmpty()) {
        try {
            int diasMin = Integer.parseInt(fEsperaMas.trim());
            sql.append(" AND a.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') ");
            sql.append(" AND TRUNC(SYSDATE - a.FECHA_SOLICITUD) >= ? ");
            params.add(diasMin);
        } catch (Exception ignore) {}
    }
    sql.append("  ORDER BY a.FECHA_SOLICITUD DESC) WHERE ROWNUM <= 2000");

    // Totales por estado para los chip-contadores de arriba (sin filtros)
    Map<String,Long> totales = new LinkedHashMap<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ESTADO, COUNT(*) FROM SOP_SOPORTE_CAB GROUP BY ESTADO");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) totales.put(nz(rs.getString(1),"-"), rs.getLong(2));
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Tickets de soporte</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
<link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
<link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js"></script>
<style>
  .estado-badge { font-size: 0.65rem; padding: 0.3rem 0.5rem; }
  .filtro-estado-check { margin-right: 10px; display: inline-block; font-size: 0.75rem; }
</style>
</head>
<body class="g-sidenav-show bg-gray-100">
<%@ include file="/_sidenav.jspf" %>
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Tickets de soporte</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Tickets de soporte</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

        <!-- Totales rapidos (independiente de filtros) -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-body p-3">
                        <% long pend = totales.getOrDefault("PENDIENTE",0L); %>
                        <% long enProg = totales.getOrDefault("EN_PROGRESO",0L); %>
                        <% long reasig = totales.getOrDefault("REASIGNADO",0L); %>
                        <% long atend = totales.getOrDefault("ATENDIDO",0L); %>
                        <% long cerrSin = totales.getOrDefault("CERRADO_SIN_SOLUCION",0L); %>
                        <% long canc = totales.getOrDefault("CANCELADO_USR",0L); %>
                        <span class="badge bg-gradient-warning me-2 estado-badge">Pendientes: <%=pend%></span>
                        <span class="badge bg-gradient-info me-2 estado-badge">En progreso: <%=enProg%></span>
                        <span class="badge bg-gradient-secondary me-2 estado-badge">Reasignados: <%=reasig%></span>
                        <span class="badge bg-gradient-success me-2 estado-badge">Atendidos: <%=atend%></span>
                        <span class="badge bg-gradient-dark me-2 estado-badge">Sin solucion: <%=cerrSin%></span>
                        <span class="badge bg-gradient-faded-danger me-2 estado-badge">Cancelados: <%=canc%></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filtros -->
        <div class="card mb-4">
            <div class="card-header pb-0"><h6>Filtros</h6></div>
            <div class="card-body p-3">
                <form method="get">
                    <input type="hidden" name="filtrar" value="1">
                    <div class="row g-2">
                        <div class="col-md-12 mb-2">
                            <label class="text-xxs font-weight-bold text-uppercase d-block">Estado</label>
                            <%
                                String[] estTodos = {"PENDIENTE","EN_PROGRESO","REASIGNADO","ATENDIDO","CERRADO_SIN_SOLUCION","CANCELADO_USR"};
                                Set<String> estSel = new HashSet<>();
                                if (fEstados != null) for (String e : fEstados) estSel.add(e);
                                for (String e : estTodos) {
                                    boolean ck = estSel.contains(e);
                            %>
                            <label class="filtro-estado-check">
                                <input type="checkbox" name="fEstado" value="<%=e%>" <%=ck?"checked":""%>>
                                <%=e%>
                            </label>
                            <% } %>
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Prioridad</label>
                            <select name="fPrioridad" class="form-control form-control-sm">
                                <option value="">Todas</option>
                                <% for (String p : new String[]{"Alta","Media","Baja"}) { %>
                                <option value="<%=p%>" <%= p.equalsIgnoreCase(nz(fPrioridad,""))?"selected":"" %>><%=p%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Desde</label>
                            <input type="date" name="fDesde" class="form-control form-control-sm" value="<%=esc(nz(fDesde,""))%>">
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Hasta</label>
                            <input type="date" name="fHasta" class="form-control form-control-sm" value="<%=esc(nz(fHasta,""))%>">
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Usuario</label>
                            <input type="text" name="fUsuario" class="form-control form-control-sm" placeholder="nombre o apellido" value="<%=esc(nz(fUsuario,""))%>">
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Tecnico</label>
                            <input type="text" name="fTecnico" class="form-control form-control-sm" placeholder="asignado o atendio" value="<%=esc(nz(fTecnico,""))%>">
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Equipo</label>
                            <input type="text" name="fEquipo" class="form-control form-control-sm" placeholder="marca / modelo / sn" value="<%=esc(nz(fEquipo,""))%>">
                        </div>
                        <div class="col-md-6">
                            <label class="text-xxs font-weight-bold text-uppercase">Texto en soporte</label>
                            <input type="text" name="fTexto" class="form-control form-control-sm" placeholder="busca en el detalle del problema" value="<%=esc(nz(fTexto,""))%>">
                        </div>
                        <div class="col-md-2">
                            <label class="text-xxs font-weight-bold text-uppercase">Espera &gt; dias</label>
                            <input type="number" name="fEsperaMas" min="1" class="form-control form-control-sm" placeholder="ej. 3" value="<%=esc(nz(fEsperaMas,""))%>">
                        </div>
                        <div class="col-md-12 text-end mt-2">
                            <a href="SOP_ListaTickets.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                <i class="fa fa-eraser me-1"></i> Limpiar
                            </a>
                            <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">
                                <i class="fa fa-search me-1"></i> Aplicar filtros
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Tabla -->
        <div class="card mb-4">
            <div class="card-header pb-0 d-flex justify-content-between align-items-center">
                <h6>Resultados <small class="text-secondary">(maximo 2000 filas)</small></h6>
                <div>
                    <button type="button" id="btnExportarExcel" class="btn btn-outline-success btn-sm mb-0 me-1"><i class="fa fa-file-excel me-1"></i> Excel</button>
                    <button type="button" id="btnExportarPdf" class="btn btn-outline-danger btn-sm mb-0"><i class="fa fa-file-pdf me-1"></i> PDF</button>
                </div>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-3">
                    <table id="tablaTickets" class="table align-items-center mb-0" style="width:100%">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">#</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dias</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Solicitante</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Equipo</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Soporte</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Prioridad</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tecnico</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
<%
    int filas = 0;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    Object p = params.get(i);
                    if (p instanceof Integer) st.setInt(i+1, (Integer)p);
                    else st.setString(i+1, p.toString());
                }
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        filas++;
                        String idSop  = rs.getString(1);
                        String fSol   = rs.getString(2);
                        String solic  = rs.getString(3);
                        String marca  = rs.getString(4);
                        String modelo = rs.getString(5);
                        String serial = rs.getString(6);
                        String sop    = rs.getString(7);
                        String prio   = rs.getString(8);
                        String est    = rs.getString(9);
                        String tec    = rs.getString(10);
                        int diasEsp   = rs.getInt(13);

                        String badgePrio;
                        if ("Alta".equalsIgnoreCase(prio))       badgePrio = "bg-gradient-danger";
                        else if ("Media".equalsIgnoreCase(prio)) badgePrio = "bg-gradient-warning";
                        else                                      badgePrio = "bg-gradient-info";

                        String badgeEst;
                        switch (nz(est,"-")) {
                            case "PENDIENTE":            badgeEst = "bg-gradient-warning"; break;
                            case "EN_PROGRESO":          badgeEst = "bg-gradient-info"; break;
                            case "REASIGNADO":           badgeEst = "bg-gradient-secondary"; break;
                            case "ATENDIDO":             badgeEst = "bg-gradient-success"; break;
                            case "CERRADO_SIN_SOLUCION": badgeEst = "bg-gradient-dark"; break;
                            case "CANCELADO_USR":        badgeEst = "bg-gradient-faded-danger"; break;
                            default:                     badgeEst = "bg-gradient-secondary"; break;
                        }

                        // "Dias en espera" solo tiene sentido para abiertos
                        boolean abierto = "PENDIENTE".equals(est) || "EN_PROGRESO".equals(est) || "REASIGNADO".equals(est);
                        String badgeDias;
                        if (!abierto)       badgeDias = "bg-gradient-secondary";
                        else if (diasEsp <= 1) badgeDias = "bg-gradient-success";
                        else if (diasEsp <= 3) badgeDias = "bg-gradient-warning";
                        else                   badgeDias = "bg-gradient-danger";
%>
                            <tr>
                                <td><p class="text-xs mb-0">#<%=idSop%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(fSol)%></p></td>
                                <td><span class="badge badge-sm <%=badgeDias%>"><%=diasEsp%>d</span></td>
                                <td><p class="text-xs font-weight-bold mb-0"><%=esc(solic)%></p></td>
                                <td>
                                    <p class="text-xs mb-0"><%=esc(marca)%> <%=esc(modelo)%></p>
                                    <% if (serial != null && !serial.isEmpty()) { %>
                                    <p class="text-xxs text-muted mb-0">S/N <%=esc(serial)%></p>
                                    <% } %>
                                </td>
                                <td style="max-width:350px;"><p class="text-xs mb-0" style="white-space:normal;"><%=esc(sop)%></p></td>
                                <td><span class="badge badge-sm <%=badgePrio%>"><%=esc(prio)%></span></td>
                                <td><span class="badge badge-sm <%=badgeEst%>"><%=esc(est)%></span></td>
                                <td><p class="text-xs mb-0"><%=esc(nz(tec,"-"))%></p></td>
                                <td class="text-center" style="white-space:nowrap;">
                                    <% if (puedeAtender && abierto) { %>
                                    <a href="SOP_AtenderTicket.jsp?idSolicitud=<%=idSop%>" class="btn btn-xs bg-gradient-warning py-1 mb-0" title="Atender"><i class="fas fa-wrench"></i></a>
                                    <% } %>
                                    <% if (!abierto) { %>
                                    <a href="SOP_AtenderTicket.jsp?idSolicitud=<%=idSop%>" class="btn btn-xs btn-outline-info py-1 mb-0" title="Ver"><i class="fas fa-eye"></i></a>
                                    <% } %>
                                    <% if (puedeEliminar && !"CANCELADO_USR".equals(est)) { %>
                                    <form method="post" action="../SOP_EliminarSolicitud" style="display:inline;"
                                          onsubmit="return confirm('Cancelar ticket #<%=idSop%>?');">
                                        <input type="hidden" name="idSolicitud" value="<%=idSop%>">
                                        <button type="submit" class="btn btn-xs btn-outline-danger py-1 mb-0" title="Cancelar"><i class="fas fa-times"></i></button>
                                    </form>
                                    <% } %>
                                </td>
                            </tr>
<%
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    if (filas == 0) {
%>
                            <tr><td colspan="10" class="text-center text-muted py-4">Sin resultados para los filtros aplicados.</td></tr>
<% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
$(document).ready(function(){
    var dt = $('#tablaTickets').DataTable({
        "pageLength": 25,
        "order": [[1, "desc"]],
        "language": { "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json" },
        "dom": "<'row'<'col-md-6'l><'col-md-6'f>>" +
               "<'row'<'col-md-12'tr>>" +
               "<'row'<'col-md-5'i><'col-md-7'p>>",
        "buttons": [
            {
                extend: 'excelHtml5',
                title: 'Tickets de soporte',
                filename: function(){ return 'tickets_' + new Date().toISOString().slice(0,10); },
                exportOptions: { columns: [0,1,2,3,4,5,6,7,8] }
            },
            {
                extend: 'pdfHtml5',
                title: 'Tickets de soporte',
                orientation: 'landscape',
                pageSize: 'A3',
                filename: function(){ return 'tickets_' + new Date().toISOString().slice(0,10); },
                exportOptions: { columns: [0,1,2,3,4,5,6,7,8] }
            }
        ]
    });
    $('#btnExportarExcel').on('click', function(){ dt.button(0).trigger(); });
    $('#btnExportarPdf').on('click',   function(){ dt.button(1).trigger(); });
});
</script>
</body>
</html>
