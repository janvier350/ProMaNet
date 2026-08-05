<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashMap"%>
<%
    String cargo       = (String) session.getAttribute("cargo");
    String nombre      = (String) session.getAttribute("nombre");
    String apellidos   = (String) session.getAttribute("apellidos");
    String compania    = (String) session.getAttribute("compania");
    String idUsuarioSesion = (String) session.getAttribute("cod");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR");

    List<Map<String,String>> movilizadores = new ArrayList<>();
    List<Map<String,String>> motivos = new ArrayList<>();
    List<Map<String,String>> destinos = new ArrayList<>();
    try (Connection cnCat = Servlets.Conexion.getConnection()) {
        if (cnCat != null) {
            try (PreparedStatement st = cnCat.prepareStatement(
                    "SELECT ID_MOVILIZADOR, NOMBRE FROM MOV_MOVILIZADOR WHERE ESTADO = 'A' ORDER BY NOMBRE");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String,String> m = new LinkedHashMap<>();
                    m.put("id", rs.getString(1));
                    m.put("nombre", rs.getString(2));
                    movilizadores.add(m);
                }
            }
            try (PreparedStatement st = cnCat.prepareStatement(
                    "SELECT ID_MOTIVO, DESCRIPCION FROM MOV_MOTIVO WHERE ESTADO = 'A' ORDER BY ID_MOTIVO");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String,String> m = new LinkedHashMap<>();
                    m.put("id", rs.getString(1));
                    m.put("descripcion", rs.getString(2));
                    motivos.add(m);
                }
            }
            try (PreparedStatement st = cnCat.prepareStatement(
                    "SELECT ID_DESTINO, DESCRIPCION FROM MOV_DESTINO WHERE ESTADO = 'A' ORDER BY DESCRIPCION");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String,String> m = new LinkedHashMap<>();
                    m.put("id", rs.getString(1));
                    m.put("descripcion", rs.getString(2));
                    destinos.add(m);
                }
            }
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Movilizacion</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
        <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
    <style>
        #calendar{max-width:100%;--fc-timegrid-slot-height:3.4em;}
        .fc{font-size:.85rem;}
        .fc .fc-toolbar-title{font-size:1.05rem;}
        .fc-event{cursor:pointer;}
        .fc-timegrid-event-harness{overflow:visible;}
        .fc-timegrid-event{overflow:visible;}
        .fc-timegrid-event .fc-event-main-frame{overflow:visible;}
        .mov-event-content{white-space:normal;overflow:visible;font-size:.72rem;line-height:1.2;padding:1px 2px;}
        .fc-list-event-title a{white-space:normal;}
        .badge-estado{padding:.4em .75em;border-radius:.5rem;font-size:.75rem;font-weight:600;}
        .badge-PENDIENTE{background:#fff3cd;color:#856404;}
        .badge-APROBADA{background:#d1e7dd;color:#0f5132;}
        .badge-RECHAZADA{background:#f8d7da;color:#842029;}
        .badge-CANCELADA{background:#e2e3e5;color:#41464b;}
        .badge-MOVILIZADO{background:#cff4fc;color:#055160;}
        #modalDetalle .table{table-layout:fixed;width:100%;}
        #modalDetalle .table th{width:38%;word-break:break-word;}
        #modalDetalle .table td{word-break:break-word;white-space:normal;}
        @media (max-width: 576px) {
            .fc .fc-toolbar{flex-direction:column;gap:.5rem;}
            .fc .fc-toolbar-title{font-size:.95rem;}
            .fc .fc-button{padding:.3rem .5rem;font-size:.75rem;}
            .fc-daygrid-day-number{font-size:.75rem;}
        }
    </style>
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4" id="sidenav-main">
    <div class="sidenav-header">
        <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
        <a class="navbar-brand m-0" href="../Proyectos/PRO_Dashboard.jsp">
            <img src="../assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
            <span class="ms-1 font-weight-bold">ProMaNet</span>
        </a>
    </div>
    <hr class="horizontal dark mt-0">
    <div class="collapse navbar-collapse w-auto" id="sidenav-collapse-main">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link " href="../Proyectos/PRO_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="MOV_Calendario.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-car text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Movilizacion</span>
                </a>
            </li>
            <li class="nav-item mt-3">
                <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Panel de control</h6>
            </li>
            <li class="nav-item">
                <a class="nav-link " href="../Proyectos/Perfil.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Perfil</span>
                </a>
            </li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <div class="card card-plain shadow-none" id="sidenavCard">
            <img class="w-50 mx-auto" src="../assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
            <div class="card-body text-center p-3 w-100 pt-0">
                <div class="docs-info">
                    <h6 class="mb-0">Necesitas ayuda?</h6>
                    <p class="text-xs font-weight-bold mb-0">Visita nuestro Tutorial</p>
                </div>
            </div>
        </div>
        <button type="button" class="btn btn-danger btn-sm w-100 mb-3" onclick="abrirTutorial('AGd9hJCuhSo','Tutorial: Solicitar Movilizacion')">Tutorial: Solicitar Movilizacion</button>
        <% if (puedeGestionar) { %>
        <button type="button" class="btn btn-danger btn-sm w-100 mb-3" onclick="abrirTutorial('174NEH_rfvo','Tutorial: Gestion de Movilizacion')">Tutorial: Gestion de Movilizacion</button>
        <% } %>
        <a href="../cerrar.jsp" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesi&oacute;n</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Movilizacion</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Calendario de Movilizacion</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                    <div class="input-group">
                        <span class="text-body text-white-50"><i class="fas fa-home"></i> <%=compania%></span>
                    </div>
                </div>
                <ul class="navbar-nav justify-content-end">
                    <li class="nav-item d-flex align-items-center">
                        <span class="nav-link text-white font-weight-bold px-0">
                            <i class="fa fa-user me-sm-1"></i>
                            <span class="d-sm-inline d-none"><b><%=nombre%> <%=apellidos%></b></span>
                        </span>
                    </li>
                    <li class="nav-item ps-3 d-flex align-items-center">
                        <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                            <div class="sidenav-toggler-inner">
                                <i class="sidenav-toggler-line bg-white"></i>
                                <i class="sidenav-toggler-line bg-white"></i>
                                <i class="sidenav-toggler-line bg-white"></i>
                            </div>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

        <% if (msgExito != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%=msgExito%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (msgError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%=msgError%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="card mb-4">
            <div class="card-body py-3">
                <div class="d-flex flex-wrap align-items-center" style="gap:14px;">
                    <div class="d-flex align-items-center" style="gap:8px;">
                        <label class="mb-0 text-sm text-secondary">Estado:</label>
                        <select id="filtroEstado" class="form-control form-control-sm" style="width:auto;">
                            <option value="">Todos</option>
                            <option value="PENDIENTE">Pendientes</option>
                            <option value="APROBADA">Aprobadas</option>
                            <option value="RECHAZADA">Rechazadas</option>
                            <option value="CANCELADA">Canceladas</option>
                            <option value="MOVILIZADO">Movilizadas</option>
                        </select>
                    </div>
                    <div class="form-check mb-0">
                        <input type="checkbox" class="form-check-input" id="soloMias">
                        <label class="form-check-label text-sm" for="soloMias">Solo mis solicitudes</label>
                    </div>
                    <% if (puedeGestionar) { %>
                    <button type="button" class="btn btn-sm btn-outline-warning mb-0" id="btnPendientes"><i class="fa fa-clock-o me-1"></i>Pendientes por aprobar</button>
                    <% } %>
                    <button type="button" class="btn btn-sm bg-gradient-primary mb-0 ms-md-auto" id="btnSolicitar"><i class="fa fa-plus me-1"></i>Solicitar Movilizacion</button>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-body p-2 p-md-4">
                <div id="calendar"></div>
            </div>
        </div>
    </div>

    <footer class="footer pt-3">
        <div class="container-fluid">
            <div class="row align-items-center justify-content-lg-between">
                <div class="col-12 text-center">
                    <div class="copyright text-center text-sm text-muted">
                        &copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0
                    </div>
                </div>
            </div>
        </div>
    </footer>
</main>

<!-- Modal: Solicitar Movilizacion -->
<div class="modal fade" id="modalSolicitar" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <form method="post" action="../MOV_InsertarSolicitud">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-plus me-2"></i>Solicitar Movilizacion</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Fecha</label>
                        <input type="date" name="fecha" id="solFecha" class="form-control" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Hora inicio</label>
                                <input type="time" name="horaInicio" id="solHoraInicio" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Hora fin</label>
                                <input type="time" name="horaFin" id="solHoraFin" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Movilizador</label>
                        <% if (puedeGestionar) { %>
                        <select name="idMovilizador" id="solMovilizador" class="form-control select2-modal">
                            <% for (java.util.Map<String,String> mv : movilizadores) { %>
                            <option value="<%=mv.get("id")%>"><%=mv.get("nombre")%></option>
                            <% } %>
                        </select>
                        <% } else { %>
                        <input type="text" class="form-control" value="Carlos Briones" readonly>
                        <input type="hidden" name="idMovilizador" id="solMovilizador" value="1">
                        <% } %>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Destino</label>
                        <div class="d-flex align-items-start" style="gap:6px;">
                            <div class="flex-grow-1">
                                <select name="idDestino" id="solDestino" class="form-control select2-modal" required>
                                    <% for (java.util.Map<String,String> ds : destinos) { %>
                                    <option value="<%=ds.get("id")%>"><%=ds.get("descripcion")%></option>
                                    <% } %>
                                </select>
                            </div>
                            <button type="button" class="btn btn-outline-secondary flex-shrink-0" id="btnNuevoDestino" title="Agregar destino"><i class="fa fa-plus"></i></button>
                        </div>
                        <% if (destinos.isEmpty()) { %>
                        <small class="text-danger">No hay destinos registrados todavia. Usa el boton "+" para agregar el primero.</small>
                        <% } %>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Motivo</label>
                        <div class="d-flex align-items-start" style="gap:6px;">
                            <div class="flex-grow-1">
                                <select name="idMotivo" id="solMotivo" class="form-control select2-modal" required>
                                    <% for (java.util.Map<String,String> mt : motivos) { %>
                                    <option value="<%=mt.get("id")%>"><%=mt.get("descripcion")%></option>
                                    <% } %>
                                </select>
                            </div>
                            <button type="button" class="btn btn-outline-secondary flex-shrink-0" id="btnNuevoMotivo" title="Agregar motivo"><i class="fa fa-plus"></i></button>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Comentario / Observacion</label>
                        <textarea name="comentario" class="form-control" rows="3"></textarea>
                    </div>
                    <div id="solDisponibilidad"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-check me-1"></i>Solicitar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Nuevo Destino -->
<div class="modal fade" id="modalNuevoDestino" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <form method="post" action="../MOV_InsertDestino">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-map-marker me-2"></i>Nuevo Destino</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Descripcion</label>
                        <input type="text" name="descripcion" class="form-control" placeholder="Ej. SRI, Produbanco, Oficina Norte" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-check me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Nuevo Motivo -->
<div class="modal fade" id="modalNuevoMotivo" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <form method="post" action="../MOV_InsertMotivo">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-tag me-2"></i>Nuevo Motivo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Descripcion</label>
                        <input type="text" name="descripcion" class="form-control" placeholder="Ej. Tramite bancario" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-check me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Video Tutorial -->
<div class="modal fade" id="modalTutorial" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="tutorialTitulo">Tutorial</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-0">
                <div class="ratio ratio-16x9">
                    <iframe id="tutorialIframe" src="" title="Tutorial" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Detalle de Solicitud -->
<div class="modal fade" id="modalDetalle" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fa fa-info-circle me-2"></i>Detalle Solicitud #<span id="detId"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="detModalBody">
                <p><span class="badge-estado" id="detEstadoBadge"></span></p>
                <table class="table table-sm">
                    <tr><th>Fecha</th><td id="detFecha"></td></tr>
                    <tr><th>Hora</th><td id="detHora"></td></tr>
                    <tr><th>Solicitante</th><td id="detSolicitante"></td></tr>
                    <tr><th>Departamento</th><td id="detDepartamento"></td></tr>
                    <tr><th>Movilizador</th><td id="detMovilizador"></td></tr>
                    <tr><th>Destino</th><td id="detDestino"></td></tr>
                    <tr><th>Motivo</th><td id="detMotivo"></td></tr>
                    <tr><th>Comentario</th><td id="detComentario"></td></tr>
                    <tr><th>Solicitado el</th><td id="detFechaSolicitud"></td></tr>
                    <tr id="filaGestionadoPor" style="display:none;"><th>Gestionado por</th><td id="detGestionadoPor"></td></tr>
                    <tr id="filaMotivoRechazo" style="display:none;"><th>Motivo de rechazo</th><td id="detMotivoRechazo"></td></tr>
                </table>

                <div id="detAccionesEditables" style="display:none;">
                    <hr>
                    <div id="detFechaEditBox" class="mb-3" style="display:none;">
                        <label class="form-label">Fecha (reagendar)</label>
                        <input type="date" id="detFechaEdit" class="form-control form-control-sm">
                    </div>
                    <div id="detMovilizadorEditBox" class="mb-3" style="display:none;">
                        <label class="form-label">Movilizador</label>
                        <select id="detMovilizadorEdit" class="form-control form-control-sm">
                            <% for (java.util.Map<String,String> mv : movilizadores) { %>
                            <option value="<%=mv.get("id")%>"><%=mv.get("nombre")%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Destino</label>
                        <select id="detDestinoEdit" class="form-control form-control-sm">
                            <% for (java.util.Map<String,String> ds : destinos) { %>
                            <option value="<%=ds.get("id")%>"><%=ds.get("descripcion")%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Motivo</label>
                        <select id="detMotivoEdit" class="form-control form-control-sm">
                            <% for (java.util.Map<String,String> mt : motivos) { %>
                            <option value="<%=mt.get("id")%>"><%=mt.get("descripcion")%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Hora inicio</label>
                                <input type="time" id="detHoraInicioEdit" class="form-control form-control-sm">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Hora fin</label>
                                <input type="time" id="detHoraFinEdit" class="form-control form-control-sm">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Comentario / Observacion</label>
                        <textarea id="detComentarioEdit" class="form-control form-control-sm" rows="2"></textarea>
                    </div>
                    <div id="detRechazoBox" style="display:none;">
                        <div class="mb-3">
                            <label class="form-label">Motivo de rechazo</label>
                            <textarea id="detMotivoRechazoInput" class="form-control form-control-sm" rows="2"></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer flex-wrap" id="detBotones"></div>
        </div>
    </div>
</div>

<form id="formAccion" method="post" style="display:none;">
    <input type="hidden" name="idSolicitud" id="accIdSolicitud">
    <input type="hidden" name="fecha" id="accFecha">
    <input type="hidden" name="horaInicio" id="accHoraInicio">
    <input type="hidden" name="horaFin" id="accHoraFin">
    <input type="hidden" name="idMovilizador" id="accIdMovilizador">
    <input type="hidden" name="idDestino" id="accIdDestino">
    <input type="hidden" name="idMotivo" id="accIdMotivo">
    <input type="hidden" name="comentario" id="accComentario">
    <input type="hidden" name="accion" id="accAccion">
    <input type="hidden" name="motivoRechazo" id="accMotivoRechazo">
</form>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
        <script src="../assets/js/custom-sidenav-toggle.js"></script>
<script>
var ctx = '<%=request.getContextPath()%>';
var miIdUsuario = <%=idUsuarioSesion%>;
var puedeGestionar = <%=puedeGestionar%>;
var eventoActual = null;

var modalSolicitarEl = document.getElementById('modalSolicitar');
var modalSolicitar = new bootstrap.Modal(modalSolicitarEl);
var modalDetalleEl = document.getElementById('modalDetalle');
var modalDetalle = new bootstrap.Modal(modalDetalleEl);
var modalNuevoDestinoEl = document.getElementById('modalNuevoDestino');
var modalNuevoDestino = new bootstrap.Modal(modalNuevoDestinoEl);
var modalNuevoMotivoEl = document.getElementById('modalNuevoMotivo');
var modalNuevoMotivo = new bootstrap.Modal(modalNuevoMotivoEl);
var modalTutorialEl = document.getElementById('modalTutorial');
var modalTutorial = new bootstrap.Modal(modalTutorialEl);

function abrirTutorial(idVideo, titulo) {
    document.getElementById('tutorialTitulo').textContent = titulo;
    document.getElementById('tutorialIframe').src = 'https://www.youtube.com/embed/' + idVideo + '?autoplay=1';
    modalTutorial.show();
}
modalTutorialEl.addEventListener('hidden.bs.modal', function() {
    document.getElementById('tutorialIframe').src = '';
});

$(modalSolicitarEl).find('.select2-modal').select2({
    theme: 'bootstrap-5',
    width: '100%',
    dropdownParent: $(modalSolicitarEl)
});
var detModalBodyEl = document.getElementById('detModalBody');
$('#detMovilizadorEdit').select2({
    theme: 'bootstrap-5',
    width: '100%',
    dropdownParent: $(detModalBodyEl)
});
$('#detDestinoEdit').select2({
    theme: 'bootstrap-5',
    width: '100%',
    dropdownParent: $(detModalBodyEl)
});
$('#detMotivoEdit').select2({
    theme: 'bootstrap-5',
    width: '100%',
    dropdownParent: $(detModalBodyEl)
});
// El modal-body ahora es scrolleable (modal-dialog-scrollable); si el
// usuario hace scroll con un select2 abierto, la lista queda flotando
// en la posicion vieja -- se cierra para evitar que se vea superpuesta.
$(detModalBodyEl).on('scroll', function() {
    $('#detMovilizadorEdit, #detDestinoEdit, #detMotivoEdit').select2('close');
});

document.getElementById('btnNuevoDestino').addEventListener('click', function() {
    modalSolicitar.hide();
    modalNuevoDestino.show();
});
document.getElementById('btnNuevoMotivo').addEventListener('click', function() {
    modalSolicitar.hide();
    modalNuevoMotivo.show();
});

function sumarUnaHora(hora) {
    var partes = hora.split(':');
    var h = (parseInt(partes[0], 10) + 1) % 24;
    return String(h).padStart(2, '0') + ':' + partes[1];
}

document.getElementById('solHoraInicio').addEventListener('change', function() {
    if (!document.getElementById('solHoraFin').dataset.manual) {
        document.getElementById('solHoraFin').value = sumarUnaHora(this.value);
    }
    verificarDisponibilidadSolicitud();
});
document.getElementById('solHoraFin').addEventListener('change', function() {
    this.dataset.manual = '1';
    verificarDisponibilidadSolicitud();
});
document.getElementById('solFecha').addEventListener('change', verificarDisponibilidadSolicitud);
document.getElementById('solMovilizador').addEventListener('change', verificarDisponibilidadSolicitud);

function verificarDisponibilidadSolicitud() {
    var fecha = document.getElementById('solFecha').value;
    var hi = document.getElementById('solHoraInicio').value;
    var hf = document.getElementById('solHoraFin').value;
    var mov = document.getElementById('solMovilizador').value;
    var box = document.getElementById('solDisponibilidad');
    if (!fecha || !hi || !hf) { box.innerHTML = ''; return; }
    fetch(ctx + '/MOV_VerificarDisponibilidad?idMovilizador=' + mov + '&fecha=' + fecha + '&horaInicio=' + hi + '&horaFin=' + hf)
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.disponible) {
                box.innerHTML = '<div class="alert alert-success py-1 mb-0"><i class="fa fa-check me-1"></i>Horario disponible</div>';
            } else {
                box.innerHTML = '<div class="alert alert-danger py-1 mb-0"><i class="fa fa-times me-1"></i>Ese movilizador ya esta ocupado en ese horario</div>';
            }
        });
}

// Fecha de hoy (local) en formato YYYY-MM-DD para bloquear fechas pasadas.
function movHoyStr() {
    var d = new Date();
    var m = d.getMonth() + 1;
    var day = d.getDate();
    return d.getFullYear() + '-' + (m < 10 ? '0' + m : m) + '-' + (day < 10 ? '0' + day : day);
}
document.getElementById('solFecha').min = movHoyStr();

document.getElementById('btnSolicitar').addEventListener('click', function() {
    document.getElementById('solHoraFin').dataset.manual = '';
    document.getElementById('solDisponibilidad').innerHTML = '';
    document.getElementById('solFecha').min = movHoyStr();
    modalSolicitar.show();
});

var calendarEl = document.getElementById('calendar');
var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: window.innerWidth < 576 ? 'listWeek' : 'dayGridMonth',
    height: 'auto',
    headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: window.innerWidth < 576 ? 'dayGridMonth,listWeek' : 'dayGridMonth,timeGridWeek,listWeek'
    },
    dateClick: function(info) {
        if (info.dateStr < movHoyStr()) {
            alert('No se puede registrar movilizaciones en fechas anteriores al dia de hoy.');
            return;
        }
        document.getElementById('solHoraFin').dataset.manual = '';
        document.getElementById('solFecha').value = info.dateStr;
        document.getElementById('solFecha').min = movHoyStr();
        document.getElementById('solDisponibilidad').innerHTML = '';
        modalSolicitar.show();
    },
    events: function(info, successCallback, failureCallback) {
        var estado = document.getElementById('filtroEstado').value;
        var soloMias = document.getElementById('soloMias').checked;
        fetch(ctx + '/MOV_EventosJson?start=' + info.startStr + '&end=' + info.endStr + '&estado=' + estado)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (soloMias) data = data.filter(function(e) { return e.extendedProps.idUsuario == miIdUsuario; });
                successCallback(data);
            })
            .catch(failureCallback);
    },
    eventClick: function(info) {
        mostrarDetalle(info.event);
    },
    eventContent: function(arg) {
        if (arg.view.type !== 'timeGridWeek') {
            return true;
        }
        var p = arg.event.extendedProps;
        var div = document.createElement('div');
        div.className = 'mov-event-content';
        var destinoTxt = (p.destino && p.destino !== '-') ? (' - ' + p.destino) : '';
        div.innerHTML = '<b>' + arg.timeText + '</b><br>' + p.solicitante + '<br>' + p.motivo + destinoTxt;
        return { domNodes: [div] };
    },
    eventDidMount: function(info) {
        var p = info.event.extendedProps;
        info.el.title = p.solicitante + ' - ' + p.motivo + '\n' +
            'Destino: ' + p.destino + '\n' +
            'Horario: ' + p.horaInicio + ' - ' + p.horaFin + '\n' +
            'Estado: ' + p.estado;
    }
});
calendar.render();

document.getElementById('filtroEstado').addEventListener('change', function() { calendar.refetchEvents(); });
document.getElementById('soloMias').addEventListener('change', function() { calendar.refetchEvents(); });
<% if (puedeGestionar) { %>
document.getElementById('btnPendientes').addEventListener('click', function() {
    document.getElementById('filtroEstado').value = 'PENDIENTE';
    calendar.refetchEvents();
});
<% } %>

function mostrarDetalle(event) {
    eventoActual = event;
    var p = event.extendedProps;
    document.getElementById('detId').textContent = event.id;
    document.getElementById('detEstadoBadge').textContent = p.estado;
    document.getElementById('detEstadoBadge').className = 'badge-estado badge-' + p.estado;
    document.getElementById('detFecha').textContent = p.fecha;
    document.getElementById('detHora').textContent = p.horaInicio + ' - ' + p.horaFin;
    document.getElementById('detSolicitante').textContent = p.solicitante;
    document.getElementById('detDepartamento').textContent = p.departamento;
    document.getElementById('detMovilizador').textContent = p.movilizador;
    document.getElementById('detDestino').textContent = p.destino;
    if (p.verDetalle === false) {
        document.getElementById('detMotivo').textContent = '🔒 Confidencial';
        document.getElementById('detComentario').textContent = '🔒 Confidencial';
    } else {
        document.getElementById('detMotivo').textContent = p.motivo || '-';
        document.getElementById('detComentario').textContent = p.comentario || '-';
    }
    document.getElementById('detFechaSolicitud').textContent = p.fechaSolicitud;

    if (p.gestionadoPor) {
        document.getElementById('filaGestionadoPor').style.display = '';
        document.getElementById('detGestionadoPor').textContent = p.gestionadoPor;
    } else {
        document.getElementById('filaGestionadoPor').style.display = 'none';
    }
    if (p.estado === 'RECHAZADA' && p.motivoRechazo) {
        document.getElementById('filaMotivoRechazo').style.display = '';
        document.getElementById('detMotivoRechazo').textContent = p.motivoRechazo;
    } else {
        document.getElementById('filaMotivoRechazo').style.display = 'none';
    }

    var esDueno = (p.idUsuario == miIdUsuario);
    var esEditableEstado = (p.estado === 'PENDIENTE' || p.estado === 'APROBADA');
    var puedeReagendar = puedeGestionar && esEditableEstado;
    var editable = puedeReagendar || (esDueno && p.estado === 'PENDIENTE');
    document.getElementById('detAccionesEditables').style.display = editable ? '' : 'none';
    document.getElementById('detRechazoBox').style.display = 'none';
    document.getElementById('detFechaEditBox').style.display = puedeReagendar ? '' : 'none';
    document.getElementById('detMovilizadorEditBox').style.display = puedeReagendar ? '' : 'none';
    if (editable) {
        document.getElementById('detFechaEdit').value = p.fecha;
        document.getElementById('detHoraInicioEdit').value = p.horaInicio;
        document.getElementById('detHoraFinEdit').value = p.horaFin;
        document.getElementById('detComentarioEdit').value = p.comentario || '';
        $('#detDestinoEdit').val(p.idDestino).trigger('change');
        $('#detMotivoEdit').val(p.idMotivo).trigger('change');
    }
    if (puedeReagendar) {
        document.getElementById('detMovilizadorEdit').value = p.idMovilizador;
    }

    var botones = document.getElementById('detBotones');
    botones.innerHTML = '';

    if (editable) {
        var btnGuardar = document.createElement('button');
        btnGuardar.type = 'button';
        btnGuardar.className = 'btn btn-info btn-sm';
        btnGuardar.innerHTML = '<i class="fa fa-clock-o me-1"></i>Guardar hora';
        btnGuardar.onclick = function() { enviarAccion(ctx + '/MOV_ModificarHora', null); };
        botones.appendChild(btnGuardar);
    }

    if (puedeGestionar && p.estado === 'PENDIENTE') {
        var btnAprobar = document.createElement('button');
        btnAprobar.type = 'button';
        btnAprobar.className = 'btn btn-success btn-sm';
        btnAprobar.innerHTML = '<i class="fa fa-check me-1"></i>Aprobar';
        btnAprobar.onclick = function() { enviarAccion(ctx + '/MOV_GestionarSolicitud', 'APROBAR'); };
        botones.appendChild(btnAprobar);

        var btnRechazar = document.createElement('button');
        btnRechazar.type = 'button';
        btnRechazar.className = 'btn btn-danger btn-sm';
        btnRechazar.innerHTML = '<i class="fa fa-times me-1"></i>Rechazar';
        btnRechazar.onclick = function() {
            var box = document.getElementById('detRechazoBox');
            if (box.style.display === 'none') { box.style.display = ''; return; }
            enviarAccion(ctx + '/MOV_GestionarSolicitud', 'RECHAZAR');
        };
        botones.appendChild(btnRechazar);
    }

    if (puedeGestionar && p.estado === 'APROBADA') {
        var btnMovilizar = document.createElement('button');
        btnMovilizar.type = 'button';
        btnMovilizar.className = 'btn btn-info btn-sm';
        btnMovilizar.innerHTML = '<i class="fa fa-flag-checkered me-1"></i>Marcar Movilizado';
        btnMovilizar.onclick = function() { enviarAccion(ctx + '/MOV_GestionarSolicitud', 'MOVILIZAR'); };
        botones.appendChild(btnMovilizar);
    }

    var puedeCancelar = (puedeGestionar && (p.estado === 'PENDIENTE' || p.estado === 'APROBADA'))
            || (esDueno && p.estado === 'PENDIENTE');
    if (puedeCancelar) {
        var btnCancelar = document.createElement('button');
        btnCancelar.type = 'button';
        btnCancelar.className = 'btn btn-outline-secondary btn-sm';
        btnCancelar.innerHTML = '<i class="fa fa-ban me-1"></i>Cancelar solicitud';
        btnCancelar.onclick = function() {
            if (confirm('¿Cancelar esta solicitud de movilizacion?')) {
                document.getElementById('accIdSolicitud').value = eventoActual.id;
                document.getElementById('formAccion').action = ctx + '/MOV_CancelarSolicitud';
                document.getElementById('formAccion').submit();
            }
        };
        botones.appendChild(btnCancelar);
    }

    var puedeEliminar = puedeGestionar
            || (esDueno && (p.estado === 'PENDIENTE' || p.estado === 'RECHAZADA' || p.estado === 'CANCELADA'));
    if (puedeEliminar) {
        var btnEliminar = document.createElement('button');
        btnEliminar.type = 'button';
        btnEliminar.className = 'btn btn-danger btn-sm';
        btnEliminar.innerHTML = '<i class="fa fa-trash me-1"></i>Eliminar solicitud';
        btnEliminar.onclick = function() {
            if (confirm('¿Eliminar definitivamente esta solicitud de movilizacion? Esta accion no se puede deshacer.')) {
                document.getElementById('accIdSolicitud').value = eventoActual.id;
                document.getElementById('formAccion').action = ctx + '/MOV_EliminarSolicitud';
                document.getElementById('formAccion').submit();
            }
        };
        botones.appendChild(btnEliminar);
    }

    modalDetalle.show();
}

function enviarAccion(url, accion) {
    document.getElementById('accIdSolicitud').value = eventoActual.id;
    document.getElementById('accFecha').value = document.getElementById('detFechaEditBox').style.display !== 'none'
            ? document.getElementById('detFechaEdit').value : '';
    document.getElementById('accHoraInicio').value = document.getElementById('detHoraInicioEdit').value;
    document.getElementById('accHoraFin').value = document.getElementById('detHoraFinEdit').value;
    document.getElementById('accIdMovilizador').value = document.getElementById('detMovilizadorEditBox').style.display !== 'none'
            ? document.getElementById('detMovilizadorEdit').value : '';
    document.getElementById('accIdDestino').value = document.getElementById('detDestinoEdit').value;
    document.getElementById('accIdMotivo').value = document.getElementById('detMotivoEdit').value;
    document.getElementById('accComentario').value = document.getElementById('detComentarioEdit').value;
    document.getElementById('accAccion').value = accion || '';
    document.getElementById('accMotivoRechazo').value = document.getElementById('detMotivoRechazoInput').value;
    document.getElementById('formAccion').action = url;
    document.getElementById('formAccion').submit();
}
</script>
</body>
</html>
