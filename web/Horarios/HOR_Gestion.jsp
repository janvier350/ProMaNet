<%--
    Document   : HOR_Gestion
    Horarios de clases del equipo. Entran el jefe directo (su equipo) y la administracion = gestores de Vacaciones (empleados de su
    grupo; todos si es administrador global). Aqui se aprueban/rechazan las solicitudes, se ven los horarios vigentes y se puede
    registrar el horario por un empleado (queda aprobado de inmediato) o anular uno vigente.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.*"%>
<%@page import="HORARIOS.HOR_Helper"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    String nombre = (String) session.getAttribute("nombre"), apellidos = (String) session.getAttribute("apellidos");
    int yo = -1;
    try { yo = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (yo <= 0) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("sidenav_active", "hor_gest");

    String msg = request.getParameter("msj"), err = null;
    List<HOR_Helper.Solicitud> pendientes = new ArrayList<>(), vigentes = new ArrayList<>();
    List<String[]> empleados = new ArrayList<>();
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (!HOR_Helper.puedeEntrarGestion(session, cn, yo)) { response.sendRedirect("../sesionInvalida.jsp"); return; }
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String accion = request.getParameter("accion");
            try {
                if ("aprobar".equals(accion) || "rechazar".equals(accion) || "anular".equals(accion)) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Object[] b = HOR_Helper.datosBasicos(cn, id);
                    if (b == null || !HOR_Helper.puedeGestionar(session, cn, (Integer) b[0], yo)) throw new IllegalArgumentException("No tienes alcance sobre esta solicitud.");
                    String texto;
                    if ("aprobar".equals(accion)) { HOR_Helper.aprobar(cn, id, yo); texto = "Solicitud aprobada."; }
                    else if ("rechazar".equals(accion)) { HOR_Helper.rechazar(cn, id, yo, request.getParameter("motivo")); texto = "Solicitud rechazada."; }
                    else { HOR_Helper.cancelar(cn, id, true); texto = "Horario anulado."; }
                    COMUN.LogActividad.registrar(request, "HORARIOS", "aprobar".equals(accion) ? "APROBAR" : ("rechazar".equals(accion) ? "RECHAZAR" : "ELIMINAR"), accion + " horario de clases #" + id);
                    response.sendRedirect("HOR_Gestion.jsp?msj=" + java.net.URLEncoder.encode(texto, "UTF-8"));
                    return;
                } else if ("crear".equals(accion)) {
                    int emp = Integer.parseInt(request.getParameter("empleado"));
                    if (!HOR_Helper.puedeGestionar(session, cn, emp, yo)) throw new IllegalArgumentException("No tienes alcance sobre ese empleado.");
                    LocalDate d = LocalDate.parse(request.getParameter("desde")), h = LocalDate.parse(request.getParameter("hasta"));
                    int id = HOR_Helper.crear(cn, emp, yo, d, h, request.getParameter("obs"), HOR_Helper.leerBloques(request), true);
                    COMUN.LogActividad.registrar(request, "HORARIOS", "CREAR", "Registro horario de clases #" + id + " para el usuario " + emp);
                    response.sendRedirect("HOR_Gestion.jsp?msj=" + java.net.URLEncoder.encode("Horario registrado y aprobado.", "UTF-8"));
                    return;
                }
            } catch (NumberFormatException | java.time.format.DateTimeParseException ex) {
                err = "Revisa los datos del formulario (empleado y fechas).";
            } catch (IllegalArgumentException ex) { err = ex.getMessage(); }
        }
        pendientes = HOR_Helper.pendientes(session, cn, yo);
        vigentes = HOR_Helper.vigentes(session, cn, yo);
        empleados = HOR_Helper.empleadosGestionables(session, cn, yo);
    } catch (Exception e) {
        e.printStackTrace();
        err = "No se pudo cargar. ¿Se ejecutó el script 056? (" + e.getMessage() + ")";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Horarios de clases del equipo</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="HOR_MisClases.jsp">Horario de clases</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Equipo</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Horarios de clases del equipo</h6>
            </nav>
            <div class="ms-auto"><span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%></span></div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (msg != null) { %><div class="alert alert-success text-white py-2"><i class="fas fa-check-circle me-1"></i><%= esc(msg) %></div><% } %>
        <% if (err != null) { %><div class="alert alert-danger text-white py-2"><i class="fas fa-exclamation-circle me-1"></i><%= esc(err) %></div><% } %>

        <%-- Pendientes --%>
        <div class="card mb-4">
            <div class="card-header pb-0">
                <h5 class="mb-0">Pendientes de aprobaci&oacute;n <span class="badge bg-gradient-<%= pendientes.isEmpty() ? "secondary" : "warning" %> ms-1"><%= pendientes.size() %></span></h5>
            </div>
            <div class="card-body">
                <% if (pendientes.isEmpty()) { %><p class="text-sm text-secondary mb-0">No hay solicitudes pendientes.</p><% } %>
                <% for (HOR_Helper.Solicitud s : pendientes) { %>
                <div class="border rounded p-3 mb-3">
                    <div class="d-flex justify-content-between align-items-start flex-wrap">
                        <div>
                            <h6 class="mb-0"><%= esc(s.nombre) %> <span class="text-xs text-secondary font-weight-normal">&middot; <%= esc(s.departamento) %></span></h6>
                            <p class="text-sm mb-1">Del <b><%= fmt.format(s.desde) %></b> al <b><%= fmt.format(s.hasta) %></b></p>
                        </div>
                        <div class="d-flex gap-2">
                            <form method="post" class="m-0"><input type="hidden" name="accion" value="aprobar"><input type="hidden" name="id" value="<%= s.id %>"><button class="btn btn-sm bg-gradient-success mb-0">Aprobar</button></form>
                            <form method="post" class="m-0" onsubmit="var m = prompt('Motivo del rechazo:'); if (!m) return false; this.motivo.value = m; return true;">
                                <input type="hidden" name="accion" value="rechazar"><input type="hidden" name="id" value="<%= s.id %>"><input type="hidden" name="motivo" value="">
                                <button class="btn btn-sm btn-outline-danger mb-0">Rechazar</button>
                            </form>
                        </div>
                    </div>
                    <ul class="mb-1 ps-3"><% for (String l : HOR_Helper.resumen(s.bloques)) { %><li class="text-sm"><%= esc(l) %></li><% } %></ul>
                    <% if (s.observacion != null && !s.observacion.isEmpty()) { %><p class="text-xs text-secondary mb-0"><%= esc(s.observacion) %></p><% } %>
                </div>
                <% } %>
            </div>
        </div>

        <div class="row">
            <%-- Vigentes --%>
            <div class="col-lg-7 mb-4">
                <div class="card h-100">
                    <div class="card-header pb-0"><h5 class="mb-0">Horarios vigentes <span class="badge bg-gradient-info ms-1"><%= vigentes.size() %></span></h5>
                        <p class="text-sm text-secondary mb-0">Aprobados cuya vigencia no ha terminado.</p></div>
                    <div class="card-body">
                        <% if (vigentes.isEmpty()) { %><p class="text-sm text-secondary mb-0">Ning&uacute;n empleado tiene horario de clases vigente.</p><% } %>
                        <% for (HOR_Helper.Solicitud s : vigentes) { %>
                        <div class="border rounded p-3 mb-2">
                            <div class="d-flex justify-content-between align-items-start flex-wrap">
                                <h6 class="mb-0"><%= esc(s.nombre) %> <span class="text-xs text-secondary font-weight-normal">&middot; <%= esc(s.departamento) %></span>
                                    <% if (s.vigenteHoy()) { %><span class="badge bg-gradient-success ms-1">vigente</span><% } else { %><span class="badge bg-gradient-info ms-1">inicia <%= fmt.format(s.desde) %></span><% } %></h6>
                                <form method="post" class="m-0" onsubmit="return confirm('¿Anular este horario?');"><input type="hidden" name="accion" value="anular"><input type="hidden" name="id" value="<%= s.id %>"><button class="btn btn-sm btn-link text-danger mb-0 p-0">Anular</button></form>
                            </div>
                            <p class="text-xs text-secondary mb-1">Hasta el <%= fmt.format(s.hasta) %></p>
                            <ul class="mb-0 ps-3"><% for (String l : HOR_Helper.resumen(s.bloques)) { %><li class="text-sm"><%= esc(l) %></li><% } %></ul>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <%-- Registrar por un empleado --%>
            <div class="col-lg-5 mb-4">
                <div class="card h-100">
                    <div class="card-header pb-0"><h5 class="mb-0">Registrar por un empleado</h5>
                        <p class="text-sm text-secondary mb-0">Queda aprobado de inmediato.</p></div>
                    <div class="card-body">
                        <form method="post">
                            <input type="hidden" name="accion" value="crear">
                            <label class="form-control-label text-xs text-uppercase font-weight-bold">Empleado</label>
                            <input type="text" id="filtroEmp" class="form-control form-control-sm mb-1" placeholder="Buscar por nombre..." autocomplete="off">
                            <select name="empleado" id="selEmp" class="form-control mb-3" required>
                                <option value="">-- Elija un empleado --</option>
                                <% for (String[] e : empleados) { %><option value="<%= esc(e[0]) %>"><%= esc(e[1]) %><%= e[2] != null ? " · " + esc(e[2]) : "" %></option><% } %>
                            </select>
                            <%@ include file="_hor_bloques.jspf" %>
                            <div class="text-end mt-3"><button class="btn bg-gradient-primary mb-0"><i class="fas fa-save me-1"></i> Registrar</button></div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script>
// Busqueda rapida en el selector de empleados (sin tildes ni mayusculas, varias palabras en cualquier orden)
(function () {
    var inp = document.getElementById('filtroEmp'), sel = document.getElementById('selEmp'); if (!inp || !sel) return;
    var todos = []; for (var i = 1; i < sel.options.length; i++) todos.push({v: sel.options[i].value, t: sel.options[i].text});
    function norm(x) { return (x || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, ''); }
    inp.addEventListener('input', function () {
        var ws = norm(inp.value).split(/\s+/).filter(Boolean), n = 0;
        sel.innerHTML = '<option value="">-- Elija un empleado --</option>';
        todos.forEach(function (e) { var t = norm(e.t); if (ws.every(function (w) { return t.indexOf(w) !== -1; })) { var o = document.createElement('option'); o.value = e.v; o.text = e.t; sel.appendChild(o); n++; } });
        if (inp.value && n === 1) sel.selectedIndex = 1;
    });
})();
</script>
</body>
</html>
