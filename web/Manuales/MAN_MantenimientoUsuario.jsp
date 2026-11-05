<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
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
<title>Manual - Mantenimiento de mi equipo</title>
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
                    <li class="breadcrumb-item text-sm text-white active">Mantenimiento de mi equipo</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manual: Mantenimiento de mi equipo</h6>
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
            <%@ include file="/_guias/guia_mantenimiento_usuario.jspf" %>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-broom text-success me-2"></i>&iquest;Para qu&eacute; sirve?</h6></div>
                        <div class="card-body text-sm">
                            <p>La limpieza y revisi&oacute;n peri&oacute;dica alarga la vida de tu equipo y evita que se caliente, se apague o se vuelva lento por el polvo.</p>
                            <p class="mb-0">Sistemas lleva el control de qu&eacute; equipos ya recibieron mantenimiento y cu&aacute;les les toca, y te avisa a ti cuando es el momento del tuyo.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-circle-question text-warning me-2"></i>Preguntas frecuentes</h6></div>
                        <div class="card-body text-sm">
                            <p class="mb-2"><b>No me aparece el aviso.</b> Es porque a tu equipo todav&iacute;a no le toca, o Sistemas a&uacute;n no activa los avisos para tu oficina.</p>
                            <p class="mb-2"><b>Ya solicit&eacute; y sigo viendo el aviso.</b> Dice &laquo;Solicitado &middot; ticket #N&raquo; hasta que Sistemas cierre el ticket.</p>
                            <p class="mb-2"><b>Tengo varios equipos.</b> Ves un aviso por cada uno.</p>
                            <p class="mb-0"><b>Prefiero otra fecha.</b> Ponte de acuerdo con Sistemas cuando te contacten por el ticket.</p>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-xs text-secondary text-center no-print">
                <a href="MAN_Indice.jsp">&larr; Todos los manuales</a>
            </p>
        </div>
        </div>
    </div>
</main>
</body>
</html>
