<%--
    Document   : MAN_Vacaciones
    Manual de usuario: SOLICITUD DE VACACIONES (orientado a quien solicita).
    Corto, una sola pagina, imprimible (Ctrl+P -> Guardar como PDF).

    Visible para quien tenga VACACIONES_SOLICITAR. La guia rapida de arriba es
    la misma de "Mis Vacaciones" (web/_guias/guia_vacaciones.jspf).
    Si cambia una regla (factor, mensajes, flujo) actualizar la guia y las
    tablas de este archivo.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_SOLICITAR")) {
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
<title>Manual - Solicitud de vacaciones</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .btn-demo { display:inline-block; padding:.1rem .55rem; border-radius:.4rem; background:#f0f2f5; border:1px solid #d9dee6;
                font-size:.78rem; font-weight:600; color:#344767; white-space:nowrap; }
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
                    <li class="breadcrumb-item text-sm text-white active">Solicitud de vacaciones</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manual: Solicitud de vacaciones</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=nombre%> <%=apellidos%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <div class="row justify-content-center">
        <div class="col-xl-10">

            <div class="d-flex justify-content-between align-items-center flex-wrap mb-3">
                <p class="text-white text-sm mb-0">Para quien solicita vacaciones. Lectura: 3 minutos.</p>
                <button class="btn btn-sm btn-white mb-0 no-print" onclick="window.print()"><i class="fas fa-print me-1"></i> Imprimir / PDF</button>
            </div>

            <%@ include file="/_guias/guia_vacaciones.jspf" %>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-calculator text-primary me-2"></i>&iquest;Cu&aacute;ntos d&iacute;as se descuentan?</h6></div>
                        <div class="card-body text-sm">
                            <p>Se cuentan solo los <b>d&iacute;as h&aacute;biles (lunes a viernes)</b> del rango que pides y cada uno se multiplica por <b>1.3636</b> (15 d&iacute;as de calendario &divide; 11 h&aacute;biles).</p>
                            <table class="table table-sm mb-2">
                                <thead><tr><th>Pides</th><th class="text-center">D&iacute;as h&aacute;biles</th><th class="text-center">Se descuenta</th></tr></thead>
                                <tbody>
                                    <tr><td>Un lunes</td><td class="text-center">1</td><td class="text-center"><b>1.36</b></td></tr>
                                    <tr><td>Lunes a viernes</td><td class="text-center">5</td><td class="text-center"><b>6.82</b></td></tr>
                                    <tr><td>Dos semanas seguidas</td><td class="text-center">10</td><td class="text-center"><b>13.64</b></td></tr>
                                </tbody>
                            </table>
                            <p class="mb-0 text-xs text-secondary">11 d&iacute;as h&aacute;biles = 15.00, el m&aacute;ximo de un a&ntilde;o. S&aacute;bados y domingos no descuentan. El sistema te muestra el c&aacute;lculo antes de enviar.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-route text-info me-2"></i>Estados de mi solicitud</h6></div>
                        <div class="card-body text-sm">
                            <table class="table table-sm align-middle mb-0">
                                <tbody>
                                    <tr><td><span class="badge badge-sm bg-gradient-warning">Jefe</span> pendiente</td><td>Tu jefe directo a&uacute;n no responde.</td></tr>
                                    <tr><td><span class="badge badge-sm bg-gradient-warning">Admin.</span> pendiente</td><td>Tu jefe aprob&oacute;; falta Administraci&oacute;n.</td></tr>
                                    <tr><td><span class="badge badge-sm bg-gradient-success">Admin.</span> aprobado</td><td>Aprobada. Imprime el documento, f&iacute;rmalo y entr&eacute;galo.</td></tr>
                                    <tr><td><span class="badge badge-sm bg-gradient-danger">Rechazado</span></td><td>Revisa el motivo en &laquo;Mis solicitudes&raquo; y vuelve a solicitar si corresponde.</td></tr>
                                </tbody>
                            </table>
                            <p class="text-xs text-secondary mt-2 mb-0">Mientras est&eacute; pendiente o aprobada, los d&iacute;as ya se descuentan de tu saldo. Si la rechazan, se devuelven.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-list-check text-primary me-2"></i>Reglas a recordar</h6></div>
                        <div class="card-body regla text-sm">
                            <p class="mb-2"><i class="fas fa-calendar-day text-info"></i> Pide <b>desde hoy en adelante</b> (las fechas pasadas solo cuando Administraci&oacute;n habilita el registro de vacaciones ya gozadas).</p>
                            <p class="mb-2"><i class="fas fa-layer-group text-info"></i> Una solicitud debe caber en <b>un solo periodo</b> (un a&ntilde;o de trabajo cumplido).</p>
                            <p class="mb-2"><i class="fas fa-ban text-info"></i> No puedes pedir fechas que se <b>crucen</b> con otra solicitud activa.</p>
                            <p class="mb-2"><i class="fas fa-user-tie text-info"></i> Necesitas tener <b>jefe directo</b> y <b>fecha de ingreso</b> registrados por Talento Humano.</p>
                            <p class="mb-2"><i class="fas fa-user-clock text-info"></i> <b>Permisos por horas:</b> los registra Talento Humano y los ves en &laquo;Permisos solicitados&raquo;. Solo un permiso <b>personal de 8 horas</b> descuenta 1 d&iacute;a de vacaciones (1.36); de 1 a 7 horas, salud, estudio y otros no descuentan.</p>
                            <p class="mb-0"><i class="fas fa-clock-rotate-left text-info"></i> En &laquo;Mis vacaciones gozadas registradas&raquo; ves los d&iacute;as que Talento Humano carg&oacute; a tu historial; tambi&eacute;n se descuentan.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-circle-question text-warning me-2"></i>Si el sistema me dice...</h6></div>
                        <div class="card-body text-sm">
                            <table class="table table-sm align-middle mb-0">
                                <tbody>
                                    <tr><td><i>No tienes un jefe directo asignado</i></td><td>Avisa a Talento Humano para que lo registre.</td></tr>
                                    <tr><td><i>No tienes fecha de ingreso configurada</i></td><td>Igual: Talento Humano debe cargarla.</td></tr>
                                    <tr><td><i>No tienes suficientes d&iacute;as disponibles en un solo periodo</i></td><td>Pide menos d&iacute;as, o marca &laquo;Solicitud anticipada&raquo; si es un adelanto acordado.</td></tr>
                                    <tr><td><i>Debes indicar la justificaci&oacute;n</i></td><td>En una solicitud anticipada escribe el motivo.</td></tr>
                                    <tr><td><i>El adelanto no puede superar los d&iacute;as que ganar&iacute;as</i></td><td>Baja la cantidad al m&aacute;ximo indicado en el mensaje.</td></tr>
                                    <tr><td><i>Ya tienes una solicitud que se solapa</i></td><td>Cambia las fechas o cancela la anterior.</td></tr>
                                    <tr><td><i>No puedes solicitar con fecha desde en el pasado</i></td><td>Usa fechas desde hoy; las pasadas requieren que Administraci&oacute;n habilite el registro.</td></tr>
                                    <tr><td><i>El rango no contiene d&iacute;as h&aacute;biles</i></td><td>Elige al menos un d&iacute;a de lunes a viernes.</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-xs text-secondary text-center no-print">
                <a href="MAN_Indice.jsp">&larr; Todos los manuales</a> &middot; <a href="../Vacaciones/VAC_MiSaldo.jsp">Ir a Mis Vacaciones</a>
            </p>
        </div>
        </div>
    </div>
</main>
</body>
</html>
