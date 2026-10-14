<%--
    Document   : MAN_AnticiposAuditoria
    Manual de usuario del modulo Anticipos de Auditoria: del sueldo al
    anticipo pagado. Corto (6 pasos), una sola pagina, imprimible
    (Ctrl+P -> Guardar como PDF).

    Visible para quien tenga ANTICIPOS_AUD_ACCESO (ejecutivos) o
    ANTICIPOS_AUD_GESTIONAR (gestor). Cada paso lleva una etiqueta de
    rol y se puede filtrar para ver solo lo propio.

    Si cambia una regla del modulo (tope, plazo, etc.) actualizar la
    seccion "Reglas" y la tabla de mensajes de este archivo.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    boolean esGestor    = COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR");
    boolean esEjecutivo = COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO");
    if (!esGestor && !esEjecutivo) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    request.setAttribute("sidenav_active", "manuales");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manual - Anticipos Auditoria</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .paso { position: relative; padding-left: 3.4rem; margin-bottom: 1.4rem; }
    .paso::before { content:''; position:absolute; left:1.15rem; top:2.6rem; bottom:-1.6rem; width:2px; background:#e9ecef; }
    .paso:last-child::before { display:none; }
    .paso-num { position:absolute; left:0; top:0; width:2.4rem; height:2.4rem; border-radius:50%;
                background:#5e72e4; color:#fff; font-weight:700; display:flex; align-items:center; justify-content:center; }
    .paso h6 { margin-bottom:.15rem; }
    .donde { font-size:.8rem; color:#8392ab; margin-bottom:.4rem; }
    .btn-demo { display:inline-block; padding:.1rem .55rem; border-radius:.4rem; background:#f0f2f5; border:1px solid #d9dee6;
                font-size:.78rem; font-weight:600; color:#344767; white-space:nowrap; }
    .paso ul { margin-bottom:0; padding-left:1.1rem; font-size:.9rem; }
    .regla i { width:1.4rem; }
    @media print {
        #iconNavbarSidenav, #sidenav-main, .no-print, .min-height-300 { display:none !important; }
        .main-content { margin-left:0 !important; }
        body { background:#fff !important; }
        .card { box-shadow:none !important; border:1px solid #ddd; }
        .paso { page-break-inside: avoid; }
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
                    <li class="breadcrumb-item text-sm text-white active">Anticipos Auditoria</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manual: Anticipos de Auditoria</h6>
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
        <div class="col-xl-9">

            <div class="card mb-4">
                <div class="card-body">
                    <div class="d-flex justify-content-between flex-wrap align-items-start">
                        <div>
                            <h5 class="mb-1">Del sueldo al anticipo pagado, en 6 pasos</h5>
                            <p class="text-sm text-secondary mb-0">Lectura: 3 minutos. Cada paso indica quien lo hace.</p>
                        </div>
                        <button class="btn btn-outline-secondary btn-sm mb-0 no-print" onclick="window.print()">
                            <i class="fas fa-print me-1"></i> Imprimir / PDF
                        </button>
                    </div>
                    <div class="btn-group btn-group-sm mt-3 no-print" role="group" aria-label="Filtrar por rol">
                        <button type="button" class="btn btn-primary mb-0" data-filtro="todos">Todo el proceso</button>
                        <button type="button" class="btn btn-outline-primary mb-0" data-filtro="ejecutivo">Solo ejecutivo</button>
                        <button type="button" class="btn btn-outline-primary mb-0" data-filtro="gestor">Solo gestor</button>
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-body pb-1">

                    <div class="paso" data-rol="gestor">
                        <span class="paso-num">1</span>
                        <h6>Asignar el sueldo <span class="badge bg-gradient-warning ms-1">Gestor</span></h6>
                        <p class="donde">Menu <b>Panel de Gestion</b> &rarr; tabla <b>Sueldos de Auditoria</b></p>
                        <ul>
                            <li>Busque al ejecutivo y pulse <span class="btn-demo"><i class="fa fa-pencil"></i> Editar</span>.</li>
                            <li>Escriba el sueldo y <span class="btn-demo">Guardar</span>.</li>
                            <li>Sin sueldo, el ejecutivo no puede pedir anticipo (el tope se calcula con el sueldo).</li>
                        </ul>
                    </div>

                    <div class="paso" data-rol="gestor">
                        <span class="paso-num">2</span>
                        <h6>Definir la fecha de corte del mes <span class="badge bg-gradient-warning ms-1">Gestor</span></h6>
                        <p class="donde"><b>Panel de Gestion</b> &rarr; tarjeta <b>Fecha de corte vigente</b></p>
                        <ul>
                            <li>Pulse <span class="btn-demo"><i class="fa fa-calendar"></i> Definir nueva fecha</span>, elija el dia limite y guarde.</li>
                            <li>Solo puede haber una fecha activa por mes.</li>
                            <li>Hasta ese dia (inclusive) los ejecutivos pueden pedir su anticipo.</li>
                        </ul>
                    </div>

                    <div class="paso" data-rol="ejecutivo">
                        <span class="paso-num">3</span>
                        <h6>Solicitar el anticipo <span class="badge bg-gradient-info ms-1">Ejecutivo</span></h6>
                        <p class="donde">Dashboard &rarr; tarjeta <b>AUDITORIA</b> (o menu <b>Anticipos Auditoria</b>)</p>
                        <ul>
                            <li>Pulse <span class="btn-demo"><i class="fa fa-plus"></i> Nueva solicitud</span>.</li>
                            <li>Escriba el monto (maximo el 50% de su sueldo; la pantalla le muestra el tope) y pulse <span class="btn-demo">Solicitar</span>.</li>
                            <li>Queda en estado <span class="badge badge-sm bg-gradient-warning">PENDIENTE</span>.</li>
                            <li>Si se equivoco de monto, pulse el lapiz <i class="fa fa-pencil"></i> de su solicitud en <b>Mis solicitudes</b> y corrijalo (mientras siga PENDIENTE y no venza el plazo).</li>
                        </ul>
                    </div>

                    <div class="paso" data-rol="gestor">
                        <span class="paso-num">4</span>
                        <h6>Registrar o corregir anticipos (si hace falta) <span class="badge bg-gradient-warning ms-1">Gestor</span></h6>
                        <p class="donde"><b>Panel de Gestion</b></p>
                        <ul>
                            <li><b>Registrar por otro</b> (ej. quien no tiene computadora): en <b>Sueldos de Auditoria</b>, pulse <span class="btn-demo"><i class="fa fa-hand-holding-usd"></i> Registrar Anticipo</span>.</li>
                            <li><b>Corregir un monto</b>: en <b>Solicitudes de Auditoria - mes actual</b>, pulse el lapiz <i class="fa fa-pencil"></i> (solo si sigue PENDIENTE y no vencio el plazo).</li>
                        </ul>
                    </div>

                    <div class="paso" data-rol="gestor">
                        <span class="paso-num">5</span>
                        <h6>Pagar y marcar como pagado <span class="badge bg-gradient-warning ms-1">Gestor</span></h6>
                        <p class="donde"><b>Panel de Gestion</b> &rarr; tarjeta naranja <b>Pendiente de pago (mes actual)</b></p>
                        <ul>
                            <li>Revise el total y pulse <span class="btn-demo"><i class="fa fa-check-circle"></i> Marcar como Pagado</span>; confirme.</li>
                            <li>Marca <b>todos</b> los pendientes del mes a la vez. Despues ya no se pueden editar.</li>
                        </ul>
                    </div>

                    <div class="paso" data-rol="ejecutivo gestor">
                        <span class="paso-num">6</span>
                        <h6>Comprobante y reporte <span class="badge bg-gradient-info ms-1">Ejecutivo</span> <span class="badge bg-gradient-warning">Gestor</span></h6>
                        <p class="donde">Icono <i class="fa fa-file-pdf text-success"></i> en cada fila de la tabla</p>
                        <ul>
                            <li><b>Ejecutivo:</b> en <b>Mis solicitudes</b> abre su comprobante del anticipo, ya pagado.</li>
                            <li><b>Gestor:</b> <span class="btn-demo"><i class="fa fa-file-pdf"></i> Exportar Reporte</span> (todo el mes) y, en <b>Historial de fechas de corte</b>, <span class="btn-demo">Ver pagados</span> de meses anteriores.</li>
                        </ul>
                    </div>

                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-list-check text-primary me-2"></i>Reglas a recordar</h6></div>
                        <div class="card-body regla text-sm">
                            <p class="mb-2"><i class="fas fa-percent text-info"></i> El anticipo no puede pasar del <b>50% del sueldo</b>.</p>
                            <p class="mb-2"><i class="fas fa-hourglass-half text-info"></i> Solo <b>1 solicitud pendiente</b> a la vez por persona.</p>
                            <p class="mb-2"><i class="fas fa-calendar-check text-info"></i> Se puede pedir <b>hasta el dia de corte inclusive</b>.</p>
                            <p class="mb-2"><i class="fas fa-lock text-info"></i> Un anticipo <b>PAGADO</b> no se edita.</p>
                            <p class="mb-0"><i class="fas fa-lock text-info"></i> Una fecha de corte con anticipos pagados ya <b>no se puede cambiar</b>.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-circle-question text-warning me-2"></i>Si el sistema le dice...</h6></div>
                        <div class="card-body text-sm">
                            <table class="table table-sm align-middle mb-0">
                                <tbody>
                                    <tr><td><i>No tienes un sueldo asignado</i></td><td>Falta el paso 1. Avise al gestor.</td></tr>
                                    <tr><td><i>El plazo ya vencio</i></td><td>Paso 2: el gestor define o corrige la fecha de corte.</td></tr>
                                    <tr><td><i>Ya tienes una solicitud pendiente</i></td><td>Espere a que se pague la actual, o corrijala con el lapiz.</td></tr>
                                    <tr><td><i>El monto excede el 50%</i></td><td>Baje el monto al tope mostrado.</td></tr>
                                    <tr><td><i>El anticipo ya fue pagado</i></td><td>Ya no se edita; registre uno nuevo el mes siguiente.</td></tr>
                                    <tr><td><i>No se puede editar: ya hay pagados</i></td><td>La fecha de corte de ese mes quedo cerrada.</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-xs text-secondary text-center no-print">
                <a href="MAN_Indice.jsp">&larr; Todos los manuales</a>
                <% if (esEjecutivo) { %> &middot; <a href="../Auditoria/AUD_SolicitarAnticipo.jsp">Ir a Anticipos Auditoria</a><% } %>
                <% if (esGestor) { %> &middot; <a href="../Auditoria/AUD_Dashboard.jsp">Ir al Panel de Gestion</a><% } %>
            </p>
        </div>
        </div>
    </div>
</main>
<script>
    (function () {
        var botones = document.querySelectorAll('[data-filtro]');
        var pasos = document.querySelectorAll('.paso');
        function aplicar(f) {
            pasos.forEach(function (p) {
                var roles = p.getAttribute('data-rol').split(' ');
                p.style.display = (f === 'todos' || roles.indexOf(f) >= 0) ? '' : 'none';
            });
            botones.forEach(function (b) {
                var activo = b.getAttribute('data-filtro') === f;
                b.classList.toggle('btn-primary', activo);
                b.classList.toggle('btn-outline-primary', !activo);
            });
        }
        botones.forEach(function (b) {
            b.addEventListener('click', function () { aplicar(this.getAttribute('data-filtro')); });
        });
        // Por defecto: si solo es ejecutivo (no gestor), muestra solo lo suyo.
        <% if (esEjecutivo && !esGestor) { %> aplicar('ejecutivo'); <% } %>
    })();
</script>
</body>
</html>
