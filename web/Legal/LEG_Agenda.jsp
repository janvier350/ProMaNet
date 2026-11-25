<%--
    Document   : LEG_Agenda
    Agenda legal: calendario de audiencias, mediaciones, reuniones, tramites, etc. (departamento Legal, permiso LEGAL_ACCESO).
    Registrar (una o varias fechas), ver, editar, cambiar estado (cumplido / cancelado con justificacion / reprogramado) y tipos con color.
    Datos por LEG_AgendaApi.jsp; logica en LEGAL.LEG_Agenda; tablas en docs/legal/003_agenda_legal.sql.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
    /** JSON seguro para incrustar dentro de un <script>. */
    private static String js(Object o) { return o.toString().replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026"); }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "LEGAL_ACCESO")) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    String nombre = (String) session.getAttribute("nombre"), apellidos = (String) session.getAttribute("apellidos");
    int yo = -1;
    try { yo = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (yo <= 0) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setAttribute("sidenav_active", "leg_agenda");

    JSONArray tipos = new JSONArray(), usuarios = new JSONArray();
    String errCarga = null;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        tipos = LEGAL.LEG_Agenda.tipos(cn, true);
        // Responsables posibles: el personal del departamento Legal (activos) + quien esta registrando
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS FROM USUARIO u LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
                "WHERE u.ESTADO = 'a' AND (UPPER(d.DEPARTAMENTO) LIKE 'LEGAL%' OR u.IDUSUARIO = ?) ORDER BY u.NOMBRE, u.APELLIDOS")) {
            st.setInt(1, yo);
            try (ResultSet rs = st.executeQuery()) { while (rs.next()) usuarios.put(new JSONObject().put("id", rs.getInt(1)).put("nombre", rs.getString(2))); }
        }
    } catch (Exception e) { e.printStackTrace(); errCarga = "No se pudo cargar la agenda. ¿Se ejecutó el script docs/legal/003_agenda_legal.sql? (" + e.getMessage() + ")"; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Agenda legal</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
<style>
    #calendar { max-width:100%; --fc-timegrid-slot-height:3em; }
    .fc { font-size:.85rem; }
    .fc .fc-toolbar-title { font-size:1.05rem; }
    .fc-event { cursor:pointer; }
    .ev-cancelado { opacity:.55; } .ev-cancelado .ev-titulo { text-decoration:line-through; }
    .ev-reprogramado { opacity:.5; border-style:dashed !important; } .ev-reprogramado .ev-titulo { text-decoration:line-through; }
    .ev-cumplido { opacity:.8; }
    .ev-linea { white-space:normal; overflow:hidden; font-size:.74rem; line-height:1.25; padding:1px 3px; color:#fff; }
    .chip { display:inline-flex; align-items:center; gap:6px; font-size:.75rem; padding:3px 10px; border-radius:20px; background:#f1f3f5; cursor:pointer; user-select:none; border:2px solid transparent; }
    .chip.on { border-color:#344767; }
    .chip i { width:10px; height:10px; border-radius:50%; display:inline-block; }
    .badge-est { padding:.35em .7em; border-radius:.5rem; font-size:.72rem; font-weight:700; }
    .est-PENDIENTE { background:#fff3cd; color:#856404; } .est-CUMPLIDO { background:#d1e7dd; color:#0f5132; }
    .est-CANCELADO { background:#e2e3e5; color:#41464b; } .est-REPROGRAMADO { background:#e7e0f7; color:#4b2f8c; }
    .resp-lista { max-height:130px; overflow:auto; border:1px solid #dee2e6; border-radius:6px; padding:6px 10px; }
    .hist li { font-size:.75rem; }
    /* vista Lista: el texto del evento va sobre fondo claro (no blanco) */
    .fc-list-event .ev-linea { color:#344767; font-size:.85rem; padding:0; }
    .fc-list-event-title a { color:inherit; }
    /* detalle: nada se sale del cuadro, aunque haya muchos responsables o textos largos */
    #modalDetalle .table { table-layout:fixed; width:100%; }
    #modalDetalle .table td, #modalDetalle .table th { word-break:break-word; white-space:normal; }
    .resp-chip { display:inline-block; background:#f1f3f5; color:#344767; font-size:.74rem; padding:2px 9px; border-radius:12px; margin:0 4px 4px 0; }
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="LEG_Dashboard.jsp">Legal</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Agenda</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Agenda legal</h6>
            </nav>
            <div class="ms-auto"><span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%></span></div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (errCarga != null) { %><div class="alert alert-danger text-white"><%= esc(errCarga) %></div><% } %>
        <div id="avisos"></div>

        <div class="card mb-3">
            <div class="card-body py-3">
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <select id="fTipo" class="form-control form-control-sm" style="width:auto"><option value="">Todos los tipos</option></select>
                    <select id="fEstado" class="form-control form-control-sm" style="width:auto">
                        <option value="">Todos los estados</option><option value="PENDIENTE">Pendientes</option><option value="CUMPLIDO">Cumplidos</option>
                        <option value="CANCELADO">Cancelados</option><option value="REPROGRAMADO">Reprogramados</option>
                    </select>
                    <select id="fResp" class="form-control form-control-sm" style="width:auto"><option value="">Todos los responsables</option></select>
                    <div class="form-check mb-0"><input class="form-check-input" type="checkbox" id="fMios"><label class="form-check-label text-sm" for="fMios">Solo mis eventos</label></div>
                    <div class="ms-auto d-flex gap-2">
                        <button class="btn btn-sm btn-outline-secondary mb-0" id="btnTipos"><i class="fas fa-palette me-1"></i> Tipos y colores</button>
                        <button class="btn btn-sm bg-gradient-primary mb-0" id="btnNuevo"><i class="fas fa-plus me-1"></i> Nuevo evento</button>
                    </div>
                </div>
                <div id="leyenda" class="d-flex flex-wrap gap-2 mt-3"></div>
            </div>
        </div>

        <div class="card"><div class="card-body"><div id="calendar"></div></div></div>
    </div>
</main>

<%-- ===== Modal: registrar / editar ===== --%>
<div class="modal fade" id="modalEvento" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title" id="evTitulo">Nuevo evento</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">
      <input type="hidden" id="evId">
      <div class="row g-3">
        <div class="col-md-4"><label class="text-xs text-uppercase font-weight-bold">Tipo</label><select id="evTipo" class="form-control"></select></div>
        <div class="col-md-8"><label class="text-xs text-uppercase font-weight-bold">Asunto / caso</label><input id="evAsunto" class="form-control" maxlength="200" placeholder="Ej.: Audiencia de juzgamiento - Estafa (Perito XP)"></div>
        <div class="col-12">
          <label class="text-xs text-uppercase font-weight-bold mb-1">Fecha y hora</label>
          <div id="evFechas"></div>
          <button type="button" class="btn btn-sm btn-outline-primary mt-1" id="evAgregarFecha"><i class="fas fa-plus me-1"></i> Agregar otra fecha (misma causa)</button>
          <p class="text-xs text-secondary mb-0 mt-1" id="evAyudaFechas">Si el caso tiene varias audiencias, agrega todas las fechas aqu&iacute;: quedan agrupadas como una serie.</p>
        </div>
        <div class="col-md-4"><label class="text-xs text-uppercase font-weight-bold">Modalidad</label>
          <select id="evModalidad" class="form-control"><option value="P">Presencial</option><option value="V">Virtual (Zoom, etc.)</option></select></div>
        <div class="col-md-8"><label class="text-xs text-uppercase font-weight-bold">Lugar o enlace</label><input id="evLugar" class="form-control" maxlength="300" placeholder="Direcci&oacute;n, sala, Ministerio de Trabajo, enlace de Zoom..."></div>
        <div class="col-12"><label class="text-xs text-uppercase font-weight-bold">Responsables</label><div id="evResp" class="resp-lista"></div>
          <p class="text-xs text-secondary mb-0">Si no marcas a nadie, queda a tu nombre.</p></div>
        <div class="col-12"><label class="text-xs text-uppercase font-weight-bold">Comentario</label><textarea id="evComentario" class="form-control" rows="2" maxlength="1000"></textarea></div>
      </div>
      <div id="evError" class="alert alert-danger text-white py-2 mt-3 d-none"></div>
    </div>
    <div class="modal-footer"><button class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button><button class="btn bg-gradient-primary btn-sm" id="evGuardar">Guardar</button></div>
  </div></div>
</div>

<%-- ===== Modal: detalle ===== --%>
<div class="modal fade" id="modalDetalle" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title" id="dTitulo"></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">
      <div class="d-flex flex-wrap align-items-center gap-2 mb-3"><span id="dEstado" class="badge-est"></span><span id="dTipo" class="badge" style="color:#fff"></span><span id="dSerie" class="text-xs text-secondary"></span></div>
      <table class="table table-sm mb-3"><tbody>
        <tr><th style="width:28%">Fecha</th><td id="dFecha"></td></tr>
        <tr><th>Hora</th><td id="dHora"></td></tr>
        <tr><th>Modalidad / lugar</th><td id="dLugar"></td></tr>
        <tr><th>Responsables</th><td id="dResp"></td></tr>
        <tr><th>Comentario</th><td id="dComentario" style="white-space:pre-line"></td></tr>
        <tr id="dJustFila"><th id="dJustLabel">Justificaci&oacute;n</th><td id="dJust" style="white-space:pre-line"></td></tr>
      </tbody></table>
      <div class="d-flex flex-wrap gap-2" id="dAcciones"></div>
      <h6 class="mt-4 mb-1 text-sm">Historial</h6><ul class="hist ps-3 mb-0" id="dHist"><li class="text-secondary">Cargando...</li></ul>
    </div>
  </div></div>
</div>

<%-- ===== Modal: accion con justificacion (cumplido / cancelar / reprogramar) ===== --%>
<div class="modal fade" id="modalAccion" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title" id="aTitulo"></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">
      <div id="aFecha" class="row g-2 mb-3 d-none">
        <div class="col-6"><label class="text-xs text-uppercase font-weight-bold">Nueva fecha</label><input type="date" id="aFechaV" class="form-control"></div>
        <div class="col-3"><label class="text-xs text-uppercase font-weight-bold">Inicio</label><input type="time" id="aIni" class="form-control"></div>
        <div class="col-3"><label class="text-xs text-uppercase font-weight-bold">Fin</label><input type="time" id="aFin" class="form-control"></div>
      </div>
      <label class="text-xs text-uppercase font-weight-bold" id="aLabel"></label>
      <textarea id="aTexto" class="form-control" rows="3" maxlength="500"></textarea>
      <div id="aError" class="alert alert-danger text-white py-2 mt-3 d-none"></div>
    </div>
    <div class="modal-footer"><button class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button><button class="btn bg-gradient-primary btn-sm" id="aConfirmar">Confirmar</button></div>
  </div></div>
</div>

<%-- ===== Modal: tipos y colores ===== --%>
<div class="modal fade" id="modalTipos" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title">Tipos de evento y colores</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">
      <div id="tiposLista"></div>
      <hr><h6 class="text-sm">Agregar un tipo</h6>
      <div class="d-flex gap-2"><input id="tNuevoNombre" class="form-control form-control-sm" placeholder="Nombre" maxlength="60"><input type="color" id="tNuevoColor" value="#5e72e4" class="form-control form-control-color form-control-sm" style="width:60px"><button class="btn btn-sm bg-gradient-primary mb-0" id="tNuevoGuardar">Agregar</button></div>
      <div id="tError" class="alert alert-danger text-white py-2 mt-3 d-none"></div>
    </div>
  </div></div>
</div>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script>
var API = 'LEG_AgendaApi.jsp', YO = <%= yo %>;
var TIPOS = <%= js(tipos) %>, USUARIOS = <%= js(usuarios) %>;
var DIAS = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
function $(id) { return document.getElementById(id); }
function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]; }); }
function fmtFecha(iso) { var p = iso.split('-'); return p[2] + '/' + p[1] + '/' + p[0]; }
function diaSemana(iso) { var p = iso.split('-'); return DIAS[new Date(+p[0], +p[1] - 1, +p[2]).getDay()]; }
function aviso(txt, tipo) {
    var d = document.createElement('div'); d.className = 'alert alert-' + (tipo || 'success') + ' text-white py-2'; d.textContent = txt;
    $('avisos').innerHTML = ''; $('avisos').appendChild(d); setTimeout(function () { if (d.parentNode) d.parentNode.removeChild(d); }, 6000);
}
function modal(id) { return bootstrap.Modal.getOrCreateInstance($(id)); }
function post(a, datos) {
    var b = new URLSearchParams(); b.append('a', a);
    Object.keys(datos).forEach(function (k) { var v = datos[k]; if (Array.isArray(v)) v.forEach(function (x) { b.append(k, x); }); else if (v != null) b.append(k, v); });
    return fetch(API, {method: 'POST', credentials: 'same-origin', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: b.toString()})
        .then(function (r) { return r.json(); }).catch(function () { return {ok: false, error: 'No se pudo comunicar con el servidor.'}; });
}

// ---- tipos: selects, leyenda
var tipoFiltro = '';
function pintarTipos() {
    var f = $('fTipo'), e = $('evTipo'); f.innerHTML = '<option value="">Todos los tipos</option>'; e.innerHTML = '';
    TIPOS.forEach(function (t) { f.insertAdjacentHTML('beforeend', '<option value="' + t.id + '">' + esc(t.nombre) + '</option>'); e.insertAdjacentHTML('beforeend', '<option value="' + t.id + '">' + esc(t.nombre) + '</option>'); });
    f.value = tipoFiltro;
    var l = $('leyenda'); l.innerHTML = '';
    TIPOS.forEach(function (t) {
        var c = document.createElement('span'); c.className = 'chip' + (String(t.id) === tipoFiltro ? ' on' : ''); c.innerHTML = '<i style="background:' + esc(t.color) + '"></i>' + esc(t.nombre);
        c.onclick = function () { tipoFiltro = String(t.id) === tipoFiltro ? '' : String(t.id); f.value = tipoFiltro; pintarTipos(); calendar.refetchEvents(); };
        l.appendChild(c);
    });
}
(function () {
    var r = $('fResp'); USUARIOS.forEach(function (u) { r.insertAdjacentHTML('beforeend', '<option value="' + u.id + '">' + esc(u.nombre) + '</option>'); });
})();

// ---- calendario
var calendar = new FullCalendar.Calendar($('calendar'), {
    initialView: window.innerWidth < 576 ? 'listWeek' : 'dayGridMonth',
    height: 'auto', locale: 'es', firstDay: 1, eventDisplay: 'block', dayMaxEvents: 4, moreLinkText: function (n) { return '+' + n + ' más'; }, buttonText: {today: 'Hoy', month: 'Mes', week: 'Semana', list: 'Lista'},
    headerToolbar: {left: 'prev,next today', center: 'title', right: window.innerWidth < 576 ? 'dayGridMonth,listWeek' : 'dayGridMonth,timeGridWeek,listWeek'},
    dateClick: function (info) { abrirNuevo(info.dateStr.substring(0, 10)); },
    events: function (info, ok, fail) {
        var q = 'a=eventos&start=' + info.startStr.substring(0, 10) + '&end=' + info.endStr.substring(0, 10) + '&tipo=' + encodeURIComponent($('fTipo').value) + '&estado=' + $('fEstado').value + '&resp=' + ($('fMios').checked ? YO : $('fResp').value);
        fetch(API + '?' + q, {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (d) { if (d && d.ok === false) { fail(d.error); aviso(d.error, 'danger'); } else ok(d); }).catch(fail);
    },
    eventClick: function (info) { abrirDetalle(info.event); },
    eventContent: function (arg) {
        var p = arg.event.extendedProps, d = document.createElement('div'); d.className = 'ev-linea';
        var ico = p.estado === 'CUMPLIDO' ? '✔ ' : (p.estado === 'REPROGRAMADO' ? '↻ ' : '');
        var hora = arg.view.type === 'listWeek' ? '' : '<b>' + esc(p.horaIni) + '</b> ';
        d.innerHTML = hora + '<span class="ev-titulo">' + ico + esc(arg.event.title) + (p.serieTotal > 1 ? ' (' + p.serieN + '/' + p.serieTotal + ')' : '') + '</span>';
        return {domNodes: [d]};
    },
    eventDidMount: function (info) { var p = info.event.extendedProps; info.el.title = p.tipo + ' · ' + p.estado + (p.lugar ? '\n' + p.lugar : '') + (p.responsables.length ? '\nResp.: ' + p.responsables.map(function (r) { return r.nombre; }).join(', ') : ''); }
});
calendar.render();
['fTipo', 'fEstado', 'fResp'].forEach(function (id) { $(id).addEventListener('change', function () { if (id === 'fTipo') { tipoFiltro = this.value; pintarTipos(); } calendar.refetchEvents(); }); });
$('fMios').addEventListener('change', function () { calendar.refetchEvents(); });
pintarTipos();

// ---- formulario de evento
var filaN = 0;
function agregarFila(fecha, ini, fin) {
    var i = filaN++, d = document.createElement('div'); d.className = 'd-flex flex-wrap align-items-center gap-2 mb-2'; d.setAttribute('data-fila', i);
    d.innerHTML = '<input type="date" class="form-control form-control-sm ev-fecha" style="width:150px" value="' + (fecha || '') + '">' +
        '<span class="text-xs text-secondary ev-dia" style="width:32px"></span>' +
        '<input type="time" class="form-control form-control-sm ev-ini" style="width:110px" value="' + (ini || '') + '"><span class="text-sm">a</span>' +
        '<input type="time" class="form-control form-control-sm ev-fin" style="width:110px" value="' + (fin || '') + '" title="Hora de fin (opcional)">' +
        '<button type="button" class="btn btn-sm btn-link text-danger mb-0 ev-quitar" title="Quitar"><i class="fas fa-trash"></i></button>';
    $('evFechas').appendChild(d); actualizarDia(d);
}
function actualizarDia(fila) { var f = fila.querySelector('.ev-fecha').value; fila.querySelector('.ev-dia').textContent = f ? diaSemana(f) : ''; }
$('evFechas').addEventListener('input', function (e) { var f = e.target.closest('[data-fila]'); if (f) actualizarDia(f); });
$('evFechas').addEventListener('click', function (e) { var b = e.target.closest('.ev-quitar'); if (b && $('evFechas').children.length > 1) $('evFechas').removeChild(b.closest('[data-fila]')); });
$('evAgregarFecha').addEventListener('click', function () {
    var ult = $('evFechas').lastElementChild; agregarFila('', ult ? ult.querySelector('.ev-ini').value : '', ult ? ult.querySelector('.ev-fin').value : '');
});
function pintarResp(sel) {
    var h = ''; USUARIOS.forEach(function (u) { h += '<div class="form-check mb-0"><input class="form-check-input ev-resp" type="checkbox" value="' + u.id + '" id="rs' + u.id + '"' + (sel.indexOf(u.id) >= 0 ? ' checked' : '') + '><label class="form-check-label text-sm" for="rs' + u.id + '">' + esc(u.nombre) + '</label></div>'; });
    $('evResp').innerHTML = h || '<span class="text-sm text-secondary">Sin personal de Legal registrado.</span>';
}
function abrirNuevo(fecha) {
    $('evTitulo').textContent = 'Nuevo evento'; $('evId').value = ''; $('evAsunto').value = ''; $('evLugar').value = ''; $('evComentario').value = ''; $('evModalidad').value = 'P';
    if (TIPOS.length) $('evTipo').value = TIPOS[0].id;
    $('evFechas').innerHTML = ''; filaN = 0; agregarFila(fecha || '', '', '');
    $('evAgregarFecha').classList.remove('d-none'); $('evAyudaFechas').classList.remove('d-none');
    pintarResp([YO]); $('evError').classList.add('d-none'); modal('modalEvento').show();
}
function abrirEditar(ev) {
    var p = ev.extendedProps;
    $('evTitulo').textContent = 'Editar evento #' + ev.id; $('evId').value = ev.id; $('evAsunto').value = ev.title; $('evLugar').value = p.lugar; $('evComentario').value = p.comentario; $('evModalidad').value = p.modalidad;
    var yaEsta = TIPOS.some(function (t) { return t.id === p.tipoId; });
    if (!yaEsta) { $('evTipo').insertAdjacentHTML('beforeend', '<option value="' + p.tipoId + '">' + esc(p.tipo) + ' (inactivo)</option>'); }
    $('evTipo').value = p.tipoId;
    $('evFechas').innerHTML = ''; filaN = 0; agregarFila(p.fecha, p.horaIni, p.horaFin);
    $('evAgregarFecha').classList.add('d-none'); $('evAyudaFechas').classList.add('d-none');
    pintarResp(p.responsables.map(function (r) { return r.id; })); $('evError').classList.add('d-none');
    modal('modalDetalle').hide(); modal('modalEvento').show();
}
$('btnNuevo').addEventListener('click', function () { abrirNuevo(''); });
$('evGuardar').addEventListener('click', function () {
    var datos = {tipo: $('evTipo').value, asunto: $('evAsunto').value, modalidad: $('evModalidad').value, lugar: $('evLugar').value, comentario: $('evComentario').value, resp: []};
    document.querySelectorAll('.ev-resp:checked').forEach(function (c) { datos.resp.push(c.value); });
    var i = 0; document.querySelectorAll('#evFechas [data-fila]').forEach(function (f) {
        datos['fecha_' + i] = f.querySelector('.ev-fecha').value; datos['ini_' + i] = f.querySelector('.ev-ini').value; datos['fin_' + i] = f.querySelector('.ev-fin').value; i++;
    });
    var edit = $('evId').value; if (edit) datos.id = edit;
    $('evGuardar').disabled = true;
    post(edit ? 'editar' : 'crear', datos).then(function (r) {
        $('evGuardar').disabled = false;
        if (r.ok) { modal('modalEvento').hide(); aviso(r.msg); calendar.refetchEvents(); } else { $('evError').textContent = r.error; $('evError').classList.remove('d-none'); }
    });
});

// ---- detalle
var evActual = null;
function abrirDetalle(ev) {
    evActual = ev; var p = ev.extendedProps;
    $('dTitulo').textContent = ev.title;
    $('dEstado').textContent = p.estado; $('dEstado').className = 'badge-est est-' + p.estado;
    $('dTipo').textContent = p.tipo; $('dTipo').style.background = p.color;
    $('dSerie').textContent = p.serieTotal > 1 ? 'Fecha ' + p.serieN + ' de ' + p.serieTotal + ' de la misma causa' : '';
    $('dFecha').textContent = diaSemana(p.fecha) + ' ' + fmtFecha(p.fecha);
    $('dHora').textContent = p.horaIni + (p.horaFin ? ' a ' + p.horaFin : '');
    $('dLugar').textContent = (p.modalidad === 'V' ? 'Virtual' : 'Presencial') + (p.lugar ? ' · ' + p.lugar : '');
    $('dResp').innerHTML = p.responsables.length ? p.responsables.map(function (r) { return '<span class="resp-chip">' + esc(r.nombre) + '</span>'; }).join('') : '-';
    $('dComentario').textContent = p.comentario || '-';
    var just = p.justificacion;
    $('dJustFila').classList.toggle('d-none', !just && p.estado !== 'REPROGRAMADO');
    $('dJustLabel').textContent = p.estado === 'CANCELADO' ? 'Justificación' : (p.estado === 'REPROGRAMADO' ? 'Reprogramado' : 'Nota');
    $('dJust').textContent = (p.estado === 'REPROGRAMADO' && p.reprogFecha ? 'Nueva fecha: ' + p.reprogFecha + '. ' : '') + (just || '');
    var a = $('dAcciones'); a.innerHTML = '';
    function btn(txt, cls, fn) { var b = document.createElement('button'); b.className = 'btn btn-sm mb-0 ' + cls; b.innerHTML = txt; b.onclick = fn; a.appendChild(b); }
    if (p.estado === 'PENDIENTE') {
        btn('<i class="fas fa-pen me-1"></i>Editar', 'btn-outline-primary', function () { abrirEditar(ev); });
        btn('<i class="fas fa-check me-1"></i>Cumplido', 'bg-gradient-success', function () { abrirAccion('CUMPLIDO'); });
        btn('<i class="fas fa-rotate me-1"></i>Reprogramar', 'btn-outline-info', function () { abrirAccion('REPROGRAMAR'); });
        btn('<i class="fas fa-ban me-1"></i>Cancelar', 'btn-outline-danger', function () { abrirAccion('CANCELADO'); });
    } else if (p.estado === 'CUMPLIDO' || p.estado === 'CANCELADO') {
        btn('<i class="fas fa-undo me-1"></i>Reabrir', 'btn-outline-secondary', function () { abrirAccion('REABRIR'); });
    }
    $('dHist').innerHTML = '<li class="text-secondary">Cargando...</li>';
    fetch(API + '?a=historial&id=' + ev.id, {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (h) {
        $('dHist').innerHTML = (h && h.length) ? h.map(function (x) { return '<li><b>' + esc(x.fecha) + '</b> · ' + esc(x.usuario) + ' · ' + esc(x.accion) + (x.detalle ? ': ' + esc(x.detalle) : '') + '</li>'; }).join('') : '<li class="text-secondary">Sin historial.</li>';
    }).catch(function () { $('dHist').innerHTML = '<li class="text-danger">No se pudo cargar el historial.</li>'; });
    modal('modalDetalle').show();
}

// ---- acciones con justificacion
var accion = null;
function abrirAccion(tipo) {
    accion = tipo; var p = evActual.extendedProps;
    $('aError').classList.add('d-none'); $('aTexto').value = ''; $('aFecha').classList.add('d-none');
    var cfg = {
        CUMPLIDO: ['Marcar como cumplido', 'Resultado o nota (opcional)', false],
        CANCELADO: ['Cancelar el evento', 'Justificación de la cancelación (obligatoria)', true],
        REPROGRAMAR: ['Reprogramar el evento', 'Motivo de la reprogramación (obligatorio)', true],
        REABRIR: ['Reabrir el evento', 'Nota (opcional)', false]
    }[tipo];
    $('aTitulo').textContent = cfg[0] + ' · ' + evActual.title; $('aLabel').textContent = cfg[1];
    if (tipo === 'REPROGRAMAR') { $('aFecha').classList.remove('d-none'); $('aFechaV').value = ''; $('aIni').value = p.horaIni; $('aFin').value = p.horaFin; }
    modal('modalDetalle').hide(); modal('modalAccion').show();
}
$('aConfirmar').addEventListener('click', function () {
    var texto = $('aTexto').value, id = evActual.id, req, datos = {id: id, justificacion: texto};
    if (accion === 'REPROGRAMAR') { datos.fecha_0 = $('aFechaV').value; datos.ini_0 = $('aIni').value; datos.fin_0 = $('aFin').value; req = post('reprogramar', datos); }
    else { datos.estado = accion === 'REABRIR' ? 'PENDIENTE' : accion; req = post('estado', datos); }
    $('aConfirmar').disabled = true;
    req.then(function (r) {
        $('aConfirmar').disabled = false;
        if (r.ok) { modal('modalAccion').hide(); aviso(r.msg); calendar.refetchEvents(); } else { $('aError').textContent = r.error; $('aError').classList.remove('d-none'); }
    });
});

// ---- tipos y colores
function cargarTiposAdmin() {
    fetch(API + '?a=tipos&todos=1', {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (lista) {
        var c = $('tiposLista'); c.innerHTML = '';
        lista.forEach(function (t) {
            var f = document.createElement('div'); f.className = 'd-flex align-items-center gap-2 mb-2';
            f.innerHTML = '<input type="color" class="form-control form-control-color form-control-sm t-color" style="width:50px" value="' + esc(t.color) + '">' +
                '<input class="form-control form-control-sm t-nombre" maxlength="60" value="' + esc(t.nombre) + '">' +
                '<div class="form-check mb-0"><input class="form-check-input t-activo" type="checkbox"' + (t.activo ? ' checked' : '') + '><label class="form-check-label text-xs">Activo</label></div>' +
                '<button class="btn btn-sm btn-outline-primary mb-0 t-guardar">Guardar</button>';
            f.querySelector('.t-guardar').onclick = function () {
                post('tipo', {id: t.id, nombre: f.querySelector('.t-nombre').value, color: f.querySelector('.t-color').value, activo: f.querySelector('.t-activo').checked ? '1' : '0'}).then(function (r) { tiposRespuesta(r); });
            };
            c.appendChild(f);
        });
    });
}
function tiposRespuesta(r) {
    if (r.ok) { $('tError').classList.add('d-none'); refrescarTipos(); cargarTiposAdmin(); calendar.refetchEvents(); }
    else { $('tError').textContent = r.error; $('tError').classList.remove('d-none'); }
}
function refrescarTipos() { fetch(API + '?a=tipos', {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (t) { TIPOS = t; pintarTipos(); }); }
$('btnTipos').addEventListener('click', function () { $('tError').classList.add('d-none'); cargarTiposAdmin(); modal('modalTipos').show(); });
$('tNuevoGuardar').addEventListener('click', function () {
    post('tipo', {nombre: $('tNuevoNombre').value, color: $('tNuevoColor').value}).then(function (r) { if (r.ok) $('tNuevoNombre').value = ''; tiposRespuesta(r); });
});
</script>
</body>
</html>
