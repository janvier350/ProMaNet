<%--
    Document   : INV_Mantenimientos
    Seguimiento del mantenimiento preventivo (limpieza y revision) de los equipos de inventario:
    vencidos, proximos, al dia y los que nunca han recibido mantenimiento. Desde aqui se registra
    cada mantenimiento y se consulta el historial por equipo.

    Permisos: INVENTARIO_MANTENIMIENTO_VER (ver) / INVENTARIO_MANTENIMIENTO_GESTIONAR (registrar).
    Reglas de calculo: INVENTARIO.INV_MantenimientoHelper (6 meses; 12 meses si el equipo tiene
    hasta 2 anos de compra; aviso 15 dias antes).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.*"%>
<%@page import="INVENTARIO.INV_MantenimientoHelper"%>
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
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR");
    boolean puedeVer = puedeGestionar || COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER");
    if (!puedeVer) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setAttribute("sidenav_active", "inv_mant");

    int miId = -1;
    try { miId = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

    List<INV_MantenimientoHelper.Fila> filas = new ArrayList<>();
    List<String[]> tecnicos = new ArrayList<>();     // {id, nombre}
    String errorCarga = null;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            filas = INV_MantenimientoHelper.cargar(cn, false);
            // Tecnicos: personal de Tecnologia + quien registra
            Set<Integer> vistos = new HashSet<>();
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS FROM USUARIO u " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO " +
                    "WHERE u.ESTADO = 'a' AND (UPPER(d.DEPARTAMENTO) LIKE 'TECNOLOG%' OR u.IDUSUARIO = ?) ORDER BY 2")) {
                st.setInt(1, miId);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) { vistos.add(rs.getInt(1)); tecnicos.add(new String[]{rs.getString(1), rs.getString(2)}); }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        errorCarga = (e.getMessage() != null && (e.getMessage().contains("ORA-00942") || e.getMessage().contains("ORA-00904")))
                ? "Falta ejecutar el script docs/permisos/046_inventario_mantenimiento.sql" : "No se pudo cargar el seguimiento: " + e.getMessage();
    }

    int vencidos = 0, proximos = 0, alDia = 0, nunca = 0;
    SortedSet<String> oficinas = new TreeSet<>(), tipos = new TreeSet<>();
    for (INV_MantenimientoHelper.Fila f : filas) {
        if (!f.aplica) continue;
        if ("VENCIDO".equals(f.estado)) vencidos++; else if ("PROXIMO".equals(f.estado)) proximos++; else alDia++;
        if (f.nunca) nunca++;
        if (!f.oficina.isEmpty()) oficinas.add(f.oficina);
        if (!f.dispositivo.isEmpty()) tipos.add(f.dispositivo);
    }
    String msj = request.getParameter("msj");
    String err = request.getParameter("error");
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Mantenimientos de equipos</title>
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
    .kpi-click { cursor: pointer; transition: transform .12s; }
    .kpi-click:hover { transform: translateY(-2px); }
    .kpi-activo { box-shadow: 0 0 0 2px #5e72e4 inset; }
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
                    <li class="breadcrumb-item text-sm text-white active">Mantenimientos</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Mantenimiento de equipos</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%></span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (msj != null && !msj.trim().isEmpty()) { %>
        <div class="alert alert-success alert-dismissible fade show text-white" role="alert"><%=esc(msj)%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button></div>
        <% } %>
        <% if (err != null && !err.trim().isEmpty()) { %>
        <div class="alert alert-danger alert-dismissible fade show text-white" role="alert"><%=esc(err)%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button></div>
        <% } %>
        <% if (errorCarga != null) { %>
        <div class="alert alert-warning text-white"><i class="fas fa-triangle-exclamation me-1"></i><%=esc(errorCarga)%></div>
        <% } %>

        <div class="row">
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card kpi-click" data-kpi="VENCIDO"><div class="card-body p-3"><div class="row">
                    <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Vencidos</p>
                        <h5 class="font-weight-bolder mb-0 text-danger"><%=vencidos%></h5>
                        <p class="mb-0 text-xs text-secondary">requieren mantenimiento ya</p></div>
                    <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-danger shadow text-center rounded-circle"><i class="fas fa-exclamation text-white" style="line-height:3rem;"></i></div></div>
                </div></div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card kpi-click" data-kpi="PROXIMO"><div class="card-body p-3"><div class="row">
                    <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Proximos</p>
                        <h5 class="font-weight-bolder mb-0 text-warning"><%=proximos%></h5>
                        <p class="mb-0 text-xs text-secondary">en los proximos <%=INV_MantenimientoHelper.DIAS_AVISO%> dias</p></div>
                    <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-warning shadow text-center rounded-circle"><i class="fas fa-clock text-white" style="line-height:3rem;"></i></div></div>
                </div></div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card kpi-click" data-kpi="AL_DIA"><div class="card-body p-3"><div class="row">
                    <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Al dia</p>
                        <h5 class="font-weight-bolder mb-0 text-success"><%=alDia%></h5>
                        <p class="mb-0 text-xs text-secondary">con mantenimiento vigente</p></div>
                    <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-success shadow text-center rounded-circle"><i class="fas fa-check text-white" style="line-height:3rem;"></i></div></div>
                </div></div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card kpi-click" data-kpi="NUNCA"><div class="card-body p-3"><div class="row">
                    <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Nunca mantenidos</p>
                        <h5 class="font-weight-bolder mb-0"><%=nunca%></h5>
                        <p class="mb-0 text-xs text-secondary">sin ningun registro</p></div>
                    <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-secondary shadow text-center rounded-circle"><i class="fas fa-circle-question text-white" style="line-height:3rem;"></i></div></div>
                </div></div></div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header pb-0">
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                    <div>
                        <h6 class="mb-0">Equipos en el plan de mantenimiento</h6>
                        <p class="text-xs text-secondary mb-0">Cada <b>6 meses</b>; cada <b>12 meses</b> los equipos de hasta 2 a&ntilde;os desde la compra (se puede fijar otra periodicidad por equipo).</p>
                    </div>
                    <div class="mt-2 mt-md-0">
                        <button type="button" class="btn btn-sm btn-outline-success mb-0" id="btnExcel"><i class="fas fa-file-excel me-1"></i>Excel</button>
                        <button type="button" class="btn btn-sm btn-outline-danger mb-0" id="btnPdf"><i class="fas fa-file-pdf me-1"></i>PDF</button>
                    </div>
                </div>
                <div class="row g-2 mt-2">
                    <div class="col-md-3"><select id="fEstado" class="form-select form-select-sm">
                        <option value="">Todos los estados</option><option value="VENCIDO">Vencidos</option><option value="PROXIMO">Proximos</option>
                        <option value="AL_DIA">Al dia</option><option value="NUNCA">Nunca mantenidos</option></select></div>
                    <div class="col-md-3"><select id="fOficina" class="form-select form-select-sm"><option value="">Todas las oficinas</option>
                        <% for (String o : oficinas) { %><option value="<%=esc(o)%>"><%=esc(o)%></option><% } %></select></div>
                    <div class="col-md-3"><select id="fTipo" class="form-select form-select-sm"><option value="">Todos los tipos</option>
                        <% for (String t : tipos) { %><option value="<%=esc(t)%>"><%=esc(t)%></option><% } %></select></div>
                    <div class="col-md-3 d-flex align-items-center"><div class="form-check mb-0">
                        <input class="form-check-input" type="checkbox" id="fExcluidos"><label class="form-check-label text-sm" for="fExcluidos">Ver excluidos del plan</label></div></div>
                </div>
            </div>
            <div class="card-body px-0 pt-2 pb-2">
                <div class="table-responsive p-3">
                    <table class="table align-items-center mb-0" id="tablaMant">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Equipo</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Usuario</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Oficina</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Ultimo mant.</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder">Cada</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Proximo</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder">Estado</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder no-export">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (INV_MantenimientoHelper.Fila f : filas) {
                               String desc = (f.dispositivo + " " + f.marca + " " + f.modelo).trim();
                               String badge, textoEstado;
                               if (!f.aplica) { badge = "bg-gradient-secondary"; textoEstado = "Excluido"; }
                               else if ("VENCIDO".equals(f.estado)) {
                                   badge = "bg-gradient-danger";
                                   textoEstado = f.dias == Long.MIN_VALUE ? "Vencido (sin fecha de compra)" : (f.nunca ? "Vencido hace " + (-f.dias) + " d (nunca)" : "Vencido hace " + (-f.dias) + " d");
                               } else if ("PROXIMO".equals(f.estado)) { badge = "bg-gradient-warning"; textoEstado = "En " + f.dias + " d"; }
                               else { badge = "bg-gradient-success"; textoEstado = "Al dia"; }
                        %>
                            <tr data-estado="<%=f.aplica ? f.estado : "EXCLUIDO"%>" data-nunca="<%=f.nunca ? "1" : "0"%>" data-aplica="<%=f.aplica ? "S" : "N"%>"
                                data-oficina="<%=esc(f.oficina)%>" data-tipo="<%=esc(f.dispositivo)%>">
                                <td><p class="text-sm font-weight-bold mb-0"><%=esc(desc)%></p>
                                    <p class="text-xs text-secondary mb-0">S/N <%=esc(f.serial.isEmpty() ? "-" : f.serial)%></p></td>
                                <td><p class="text-xs mb-0"><%= f.usuario != null ? esc(f.usuario) : "<span class='text-secondary'>sin asignar</span>" %></p></td>
                                <td><p class="text-xs mb-0"><%=esc(f.oficina.isEmpty() ? "-" : f.oficina)%></p></td>
                                <td data-order="<%= f.ultimo != null ? f.ultimo.toString() : "" %>"><p class="text-xs mb-0"><%= f.ultimo != null ? f.ultimo.format(fmt) : "-" %></p></td>
                                <td class="text-center"><p class="text-xs mb-0"><%=f.periodo%> m<%= f.periodoFijo != null ? " *" : "" %></p></td>
                                <td data-order="<%= f.proxima != null ? f.proxima.toString() : "" %>"><p class="text-xs mb-0"><%= f.proxima != null ? f.proxima.format(fmt) : "-" %></p></td>
                                <td class="text-center"><span class="badge badge-sm <%=badge%>"><%=esc(textoEstado)%></span></td>
                                <td class="text-center">
                                    <div class="d-flex justify-content-center gap-1">
                                        <% if (puedeGestionar && f.aplica) { %>
                                        <button type="button" class="btn btn-xs btn-outline-success py-1 mb-0 btn-registrar"
                                                data-id="<%=f.idEquipo%>" data-desc="<%=esc(desc)%>" data-periodo="<%= f.periodoFijo != null ? f.periodoFijo : "" %>"
                                                data-auto="<%=f.periodo%>"><i class="fas fa-broom"></i> Registrar</button>
                                        <% } %>
                                        <button type="button" class="btn btn-xs btn-outline-info py-1 mb-0 btn-historial" data-id="<%=f.idEquipo%>" data-desc="<%=esc(desc)%>" title="Historial">
                                            <i class="fas fa-clock-rotate-left"></i> <%=f.totalMant%></button>
                                        <% if (puedeGestionar) { %>
                                        <form action="../INV_MantenimientoAccion" method="post" class="d-inline"
                                              onsubmit="return confirm('<%= f.aplica ? "Excluir este equipo del plan de mantenimiento?" : "Incluir este equipo en el plan de mantenimiento?" %>');">
                                            <input type="hidden" name="accion" value="<%= f.aplica ? "EXCLUIR" : "INCLUIR" %>">
                                            <input type="hidden" name="idEquipo" value="<%=f.idEquipo%>">
                                            <button type="submit" class="btn btn-xs btn-outline-secondary py-1 mb-0" title="<%= f.aplica ? "Excluir del plan" : "Incluir en el plan" %>">
                                                <i class="fas <%= f.aplica ? "fa-ban" : "fa-rotate-left" %>"></i></button>
                                        </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<% if (puedeGestionar) { %>
<div class="modal fade" id="modalRegistrar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="../INV_RegistrarMantenimiento" method="post">
                <input type="hidden" name="idEquipo" id="regIdEquipo">
                <div class="modal-header" style="background:#2dce89;">
                    <h5 class="modal-title text-white"><i class="fas fa-broom me-2"></i>Registrar mantenimiento</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm mb-3"><b id="regDesc"></b></p>
                    <div class="row">
                        <div class="col-md-4 form-group mb-3">
                            <label>Fecha del mantenimiento</label>
                            <input type="date" name="fecha" id="regFecha" class="form-control" required>
                        </div>
                        <div class="col-md-4 form-group mb-3">
                            <label>Tipo</label>
                            <select name="tipo" class="form-control">
                                <option value="PREVENTIVO">Preventivo (limpieza / revision)</option>
                                <option value="CORRECTIVO">Correctivo (reparacion)</option>
                            </select>
                        </div>
                        <div class="col-md-4 form-group mb-3">
                            <label>Realizado por</label>
                            <select name="idTecnico" class="form-control">
                                <% for (String[] t : tecnicos) { %><option value="<%=t[0]%>" <%= t[0].equals(String.valueOf(miId)) ? "selected" : "" %>><%=esc(t[1])%></option><% } %>
                            </select>
                        </div>
                    </div>
                    <div class="form-group mb-3">
                        <label class="d-block">Actividades realizadas</label>
                        <% String[] acts = {"Limpieza externa", "Teclado", "Pantalla", "Polvo interno", "Ventiladores / disipador", "Pasta termica", "Limpieza de software", "Revision de bateria / UPS", "Revision de cableado / puertos"};
                           for (int i = 0; i < acts.length; i++) { %>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="actividades" id="act<%=i%>" value="<%=acts[i]%>" <%= i < 4 ? "checked" : "" %>>
                            <label class="form-check-label text-sm" for="act<%=i%>"><%=acts[i]%></label>
                        </div>
                        <% } %>
                    </div>
                    <div class="row">
                        <div class="col-md-5 form-group mb-3">
                            <label>Periodicidad de este equipo</label>
                            <select name="periodicidad" id="regPeriodicidad" class="form-control">
                                <option value="auto">Automatica (6 o 12 meses segun la antiguedad)</option>
                                <option value="3">Cada 3 meses</option><option value="4">Cada 4 meses</option>
                                <option value="6">Cada 6 meses</option><option value="12">Cada 12 meses</option>
                            </select>
                        </div>
                        <div class="col-md-7 form-group mb-3">
                            <label>Observaciones (opcional)</label>
                            <input type="text" name="observaciones" class="form-control" maxlength="500" placeholder="Ej: cambio de pasta termica, ventilador ruidoso">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-success btn-sm"><i class="fas fa-save me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<div class="modal fade" id="modalHistorial" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-clock-rotate-left me-2"></i>Historial &middot; <span id="histDesc"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="histCuerpo">Cargando...</div>
        </div>
    </div>
</div>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script>
$(document).ready(function () {
    var kpiActivo = '';
    $.fn.dataTable.ext.search.push(function (settings, data, idx) {
        if (settings.nTable.id !== 'tablaMant') return true;
        var tr = settings.aoData[idx].nTr;
        var aplica = tr.getAttribute('data-aplica');
        var ver = $('#fExcluidos').is(':checked');
        if (!ver && aplica === 'N') return false;
        var est = $('#fEstado').val();
        if (est) {
            if (est === 'NUNCA') { if (tr.getAttribute('data-nunca') !== '1' || aplica === 'N') return false; }
            else if (tr.getAttribute('data-estado') !== est) return false;
        }
        var of = $('#fOficina').val(); if (of && tr.getAttribute('data-oficina') !== of) return false;
        var tp = $('#fTipo').val();    if (tp && tr.getAttribute('data-tipo') !== tp) return false;
        return true;
    });
    var dt = $('#tablaMant').DataTable({
        pageLength: 25,
        order: [[5, 'asc']],
        language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' },
        dom: "<'row'<'col-md-6'l><'col-md-6'f>><'row'<'col-md-12'tr>><'row'<'col-md-5'i><'col-md-7'p>>",
        buttons: [
            { extend: 'excelHtml5', title: 'Mantenimiento de equipos', exportOptions: { columns: [0,1,2,3,4,5,6] } },
            { extend: 'pdfHtml5', title: 'Mantenimiento de equipos', orientation: 'landscape', pageSize: 'A3', exportOptions: { columns: [0,1,2,3,4,5,6] } }
        ]
    });
    $('#btnExcel').on('click', function () { dt.button(0).trigger(); });
    $('#btnPdf').on('click', function () { dt.button(1).trigger(); });
    $('#fEstado, #fOficina, #fTipo, #fExcluidos').on('change', function () {
        $('.kpi-click').removeClass('kpi-activo');
        if ($('#fEstado').val()) $('.kpi-click[data-kpi="' + $('#fEstado').val() + '"]').addClass('kpi-activo');
        dt.draw();
    });
    $('.kpi-click').on('click', function () {
        var k = $(this).data('kpi');
        $('#fEstado').val($('#fEstado').val() === k ? '' : k).trigger('change');
    });
    dt.draw();

    // Registrar
    $(document).on('click', '.btn-registrar', function () {
        var b = this;
        $('#regIdEquipo').val(b.getAttribute('data-id'));
        $('#regDesc').text(b.getAttribute('data-desc'));
        var d = new Date(); var iso = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
        $('#regFecha').val(iso).attr('max', iso);
        $('#regPeriodicidad').val(b.getAttribute('data-periodo') || 'auto');
        new bootstrap.Modal(document.getElementById('modalRegistrar')).show();
    });
    // Historial
    $(document).on('click', '.btn-historial', function () {
        var id = this.getAttribute('data-id');
        $('#histDesc').text(this.getAttribute('data-desc'));
        $('#histCuerpo').text('Cargando...');
        new bootstrap.Modal(document.getElementById('modalHistorial')).show();
        fetch('INV_MantenimientoHistorial.jsp?id=' + encodeURIComponent(id), { credentials: 'same-origin' })
            .then(function (r) { return r.text(); })
            .then(function (h) { $('#histCuerpo').html(h); })
            .catch(function () { $('#histCuerpo').text('No se pudo cargar el historial.'); });
    });
});
</script>
</body>
</html>
