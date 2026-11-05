<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER") && !COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    request.setAttribute("sidenav_active", "manuales");
    request.setAttribute("guiaSiempreVisible", Boolean.TRUE);
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manual - Mantenimiento de equipos</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .regla i { width:1.4rem; }
    @media print {
        #iconNavbarSidenav, #sidenav-main, .no-print, .min-height-300 { display:none !important; }
        .main-content { margin-left:0 !important; }
        body { background:#fff !important; }
        .card { box-shadow:none !important; border:1px solid #ddd; page-break-inside: avoid; }
    }
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="MAN_Indice.jsp">Manuales</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Mantenimiento de equipos</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manual: Mantenimiento de equipos (Sistemas)</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=nombre%> <%=apellidos%></span>
            </div>
        </div>
    </nav>
    <div class="container-fluid py-4">
        <div class="row justify-content-center">
        <div class="col-xl-10">
            <div class="d-flex justify-content-between align-items-center flex-wrap mb-3">
                <p class="text-white text-sm mb-0">Lectura: 2 minutos.</p>
                <button class="btn btn-sm btn-white mb-0 no-print" onclick="window.print()"><i class="fas fa-print me-1"></i> Imprimir / PDF</button>
            </div>
            <%@ include file="/_guias/guia_mantenimiento_sistemas.jspf" %>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-calendar-days text-primary me-2"></i>Regla de periodicidad</h6></div>
                        <div class="card-body text-sm">
                            <table class="table table-sm align-middle mb-2">
                                <thead><tr><th>Equipo</th><th>Cada</th></tr></thead>
                                <tbody>
                                    <tr><td>Hasta 2 a&ntilde;os desde la compra</td><td><b>12 meses</b></td></tr>
                                    <tr><td>M&aacute;s de 2 a&ntilde;os</td><td><b>6 meses</b></td></tr>
                                    <tr><td>Equipo con periodicidad fijada a mano</td><td>Lo que indiques (3, 4, 6 o 12)</td></tr>
                                </tbody>
                            </table>
                            <p class="text-xs text-secondary mb-0">Se cuenta desde el &uacute;ltimo mantenimiento preventivo; si nunca tuvo, desde la fecha de compra.
                                Aplica a laptops, impresoras, DVR, NVR, servidores y dem&aacute;s equipos en servicio; los perif&eacute;ricos (mouse, teclado) no entran.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-traffic-light text-warning me-2"></i>Estados</h6></div>
                        <div class="card-body text-sm">
                            <p class="mb-2"><span class="badge bg-gradient-danger">Vencido</span> pas&oacute; su fecha: requiere mantenimiento ya.</p>
                            <p class="mb-2"><span class="badge bg-gradient-warning">Pr&oacute;ximo</span> faltan 15 d&iacute;as o menos.</p>
                            <p class="mb-2"><span class="badge bg-gradient-success">Al d&iacute;a</span> mantenimiento vigente.</p>
                            <p class="mb-0"><span class="badge bg-gradient-secondary">Nunca mantenido</span> sin ning&uacute;n registro (incluye equipos viejos al lanzar el sistema).</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-calendar-check text-info me-2"></i>Programar la primera ronda</h6></div>
                        <div class="card-body text-sm">
                            <p>Al lanzar el seguimiento casi todos los equipos aparecen vencidos. Para no avisar a todos a la vez:</p>
                            <ol class="mb-2 ps-3">
                                <li>Pulsa <b>Programar primera ronda</b>, elige la fecha de inicio y cu&aacute;ntos equipos por d&iacute;a. Una vista previa muestra los d&iacute;as que tomar&aacute;.</li>
                                <li>Se reparten por oficina y por usuario, solo en d&iacute;as h&aacute;biles.</li>
                                <li>Un equipo programado avisa a su usuario <b>15 d&iacute;as antes de su fecha</b>, no de inmediato.</li>
                                <li>Puedes programar o quitar la fecha de un equipo con el icono del calendario.</li>
                                <li>Cuando est&eacute; listo, <b>Activar avisos</b>. Mientras est&eacute;n apagados, nadie ve nada.</li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-ticket text-primary me-2"></i>Tickets de mantenimiento</h6></div>
                        <div class="card-body text-sm">
                            <ul class="mb-2 ps-3">
                                <li>Desde su aviso, el usuario pulsa <b>Solicitar mantenimiento</b>: se crea un ticket <b>[MANTENIMIENTO]</b> de prioridad Baja.</li>
                                <li>En el panel, el equipo muestra la etiqueta <b>Ticket #N</b> mientras est&eacute; abierto; no se crea otro duplicado.</li>
                                <li>Al cerrarlo como <b>Atendido</b>, el mantenimiento se <b>registra solo</b> en el historial del equipo y se borra la fecha programada.</li>
                                <li>Si lo haces sin ticket, usa <b>Registrar</b> en el panel (actividades, qui&eacute;n lo hizo y observaciones).</li>
                            </ul>
                            <p class="text-xs text-secondary mb-0">Equipos que no requieren mantenimiento (monitores, switches, etc.) se pueden <b>excluir del plan</b> con el bot&oacute;n de la prohibici&oacute;n; se vuelven a incluir con &laquo;Ver excluidos&raquo;.</p>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-xs text-secondary text-center no-print">
                <a href="MAN_Indice.jsp">&larr; Todos los manuales</a> &middot; <a href="../Inventario/INV_Mantenimientos.jsp">Ir a Mantenimientos</a>
            </p>
        </div>
        </div>
    </div>
</main>
</body>
</html>
