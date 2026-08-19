<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="VACACIONES.VAC_CalculoSaldo"%>
<%
    String cargo     = (String) session.getAttribute("cargo");
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String compania  = (String) session.getAttribute("compania");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_SOLICITAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    int idUsuarioSesion = -1;
    try { idUsuarioSesion = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

    VAC_CalculoSaldo.Saldo saldo = new VAC_CalculoSaldo.Saldo();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) saldo = VAC_CalculoSaldo.calcular(cn, idUsuarioSesion);
    } catch (Exception ex) { ex.printStackTrace(); }

    String msj = request.getParameter("msj");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Mis Vacaciones</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
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
                <a class="nav-link active" href="VAC_MiSaldo.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-umbrella-beach text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Mis Vacaciones</span>
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
        <a href="../cerrar.jsp" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesi&oacute;n</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Mis Vacaciones</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Mis Vacaciones</h6>
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
        <% if (msj != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%=msj%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%=error%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (!saldo.configurado) { %>
        <div class="alert alert-warning">
            <i class="fa fa-exclamation-triangle me-2"></i>
            Todavia no tienes tu fecha de ingreso configurada en el sistema. Contacta a Talento Humano
            para que la carguen y puedas ver tu saldo de vacaciones.
        </div>
        <% } else { %>

        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Fecha de ingreso</p>
                        <h4 class="mb-0"><%=new java.text.SimpleDateFormat("dd/MM/yyyy").format(saldo.fechaIngreso)%></h4>
                        <p class="text-xs text-secondary mb-0">Antiguedad: <%=String.format("%.1f años", saldo.antiguedadAnios)%></p>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card bg-gradient-success">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold text-white">Dias disponibles</p>
                        <h4 class="mb-0 text-white"><%=saldo.totalDisponible%> dias</h4>
                        <% if (saldo.periodos.isEmpty()) { %>
                        <p class="text-xs text-white mb-0">Aun no cumples 1 año de trabajo</p>
                        <% } else { %>
                        <p class="text-xs text-white mb-0"><%=saldo.periodos.size()%> periodo(s) cumplido(s)</p>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Solicitar vacaciones</p>
                        <% if (saldo.totalDisponible > 0) { %>
                        <button type="button" class="btn btn-outline-primary btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#modalSolicitar">
                            <i class="fa fa-plus me-1"></i> Nueva solicitud
                        </button>
                        <% } else { %>
                        <p class="text-xs text-muted mb-0">No tienes dias disponibles para solicitar.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Detalle por periodo</h6>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">#</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Desde</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hasta</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acumulados</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Gozados</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Disponibles</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (saldo.periodos.isEmpty()) { %>
                                    <tr><td colspan="6" class="text-center text-muted py-4">Sin periodos acumulados todavia.</td></tr>
                                    <% } %>
                                    <% for (VAC_CalculoSaldo.Periodo p : saldo.periodos) { %>
                                    <tr>
                                        <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=p.numero%></p></td>
                                        <td><p class="text-xs mb-0"><%=new java.text.SimpleDateFormat("dd/MM/yyyy").format(p.desde)%></p></td>
                                        <td><p class="text-xs mb-0"><%=new java.text.SimpleDateFormat("dd/MM/yyyy").format(p.hasta)%></p></td>
                                        <td class="text-center"><p class="text-xs mb-0"><%=p.diasAcumulados%></p></td>
                                        <td class="text-center"><p class="text-xs mb-0"><%=p.diasConsumidos%></p></td>
                                        <td class="text-center">
                                            <span class="badge badge-sm <%=p.diasDisponibles > 0 ? "bg-gradient-success" : "bg-gradient-secondary"%>"><%=p.diasDisponibles%></span>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Mis solicitudes</h6>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Solicitud</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Periodo</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Desde</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hasta</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dias</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Motivo del rechazo</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cnSol = Servlets.Conexion.getConnection()) {
                                            if (cnSol != null) {
                                                try (PreparedStatement stSol = cnSol.prepareStatement(
                                                        "SELECT TO_CHAR(FECHA_SOLICITUD,'DD/MM/YYYY'), NUM_PERIODO, " +
                                                        "TO_CHAR(FECHA_DESDE,'DD/MM/YYYY'), TO_CHAR(FECHA_HASTA,'DD/MM/YYYY'), " +
                                                        "DIAS_SOLICITADOS, ESTADO, ID_SOLICITUD, COMENTARIO_JEFE, COMENTARIO_ADMIN " +
                                                        "FROM VAC_SOLICITUD WHERE ID_USUARIO = ? ORDER BY FECHA_SOLICITUD DESC")) {
                                                    stSol.setInt(1, idUsuarioSesion);
                                                    try (ResultSet rsSol = stSol.executeQuery()) {
                                                        boolean haySol = false;
                                                        while (rsSol.next()) {
                                                            haySol = true;
                                                            String estadoSol = rsSol.getString(6);
                                                            boolean jefeAprobado = !"PENDIENTE_JEFE".equals(estadoSol) && !"RECHAZADO_JEFE".equals(estadoSol);
                                                            boolean jefeRechazado = "RECHAZADO_JEFE".equals(estadoSol);
                                                            boolean adminAlcanzado = jefeAprobado;
                                                            boolean adminAprobado = "APROBADO".equals(estadoSol) || "RECIBIDO".equals(estadoSol);
                                                            boolean adminRechazado = "RECHAZADO_ADMIN".equals(estadoSol);
                                                            String motivoRechazo = jefeRechazado ? rsSol.getString(8) : (adminRechazado ? rsSol.getString(9) : null);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs mb-0"><%=rsSol.getString(1)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rsSol.getString(2)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rsSol.getString(3)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rsSol.getString(4)%></p></td>
                                                        <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=rsSol.getInt(5)%></p></td>
                                                        <td>
                                                            <div class="d-flex align-items-center gap-1 flex-wrap">
                                                                <span class="badge badge-sm bg-gradient-success" title="Solicitante"><i class="fa fa-check"></i> Solicitante</span>
                                                                <i class="fa fa-arrow-right text-xs text-secondary"></i>
                                                                <% if (jefeRechazado) { %>
                                                                <span class="badge badge-sm bg-gradient-danger" title="Jefe directo"><i class="fa fa-times"></i> Jefe</span>
                                                                <% } else if (jefeAprobado) { %>
                                                                <span class="badge badge-sm bg-gradient-success" title="Jefe directo"><i class="fa fa-check"></i> Jefe</span>
                                                                <% } else { %>
                                                                <span class="badge badge-sm bg-gradient-warning" title="Jefe directo"><i class="fa fa-clock"></i> Jefe</span>
                                                                <% } %>
                                                                <i class="fa fa-arrow-right text-xs text-secondary"></i>
                                                                <% if (adminRechazado) { %>
                                                                <span class="badge badge-sm bg-gradient-danger" title="Administracion"><i class="fa fa-times"></i> Admin.</span>
                                                                <% } else if (adminAprobado) { %>
                                                                <span class="badge badge-sm bg-gradient-success" title="Administracion"><i class="fa fa-check"></i> Admin.</span>
                                                                <% } else if (adminAlcanzado) { %>
                                                                <span class="badge badge-sm bg-gradient-warning" title="Administracion"><i class="fa fa-clock"></i> Admin.</span>
                                                                <% } else { %>
                                                                <span class="badge badge-sm bg-gradient-secondary" title="Administracion"><i class="fa fa-circle"></i> Admin.</span>
                                                                <% } %>
                                                            </div>
                                                        </td>
                                                        <td><p class="text-xs mb-0"><%=motivoRechazo != null ? motivoRechazo : "-"%></p></td>
                                                        <td class="text-center">
                                                            <a class="btn btn-xs btn-outline-info py-1" href="../VAC_ImprimirSolicitud?id=<%=rsSol.getString(7)%>" target="_blank">
                                                                <i class="fa fa-print"></i>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!haySol) {
                                                    %>
                                                    <tr><td colspan="8" class="text-center text-muted py-4">No tienes solicitudes registradas.</td></tr>
                                                    <%
                                                        }
                                                    }
                                                } catch (Exception ex) { ex.printStackTrace(); }
                                            }
                                        } catch (Exception ex) { ex.printStackTrace(); }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</main>

<%-- Modal: nueva solicitud de vacaciones --%>
<div class="modal fade" id="modalSolicitar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../VAC_InsertarSolicitud" method="post" id="formSolicitar">
                <div class="modal-header" style="background:#f0ad4e;">
                    <h5 class="modal-title text-white"><i class="fa fa-umbrella-beach me-2"></i>Nueva Solicitud de Vacaciones</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-6 form-group mb-3">
                            <label>Fecha desde</label>
                            <input type="date" name="fechaDesde" id="solFechaDesde" class="form-control" required>
                        </div>
                        <div class="col-6 form-group mb-3">
                            <label>Fecha hasta</label>
                            <input type="date" name="fechaHasta" id="solFechaHasta" class="form-control" required>
                        </div>
                    </div>
                    <div id="solResumen" class="alert alert-secondary py-2 px-3 mb-2" style="display:none;"></div>
                    <div id="solAvisoFinde" class="alert alert-warning py-2 px-3 mb-0" style="display:none;">
                        <i class="fa fa-exclamation-triangle me-1"></i>
                        El regreso no puede caer viernes ni sabado: debes incluir el fin de semana completo.
                        Ajusta la fecha hasta a un domingo o posterior.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning btn-sm" id="btnEnviarSolicitud"><i class="fa fa-paper-plane me-1"></i>Enviar Solicitud</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script src="../assets/js/custom-sidenav-toggle.js"></script>
<script>
    (function () {
        var inputDesde = document.getElementById('solFechaDesde');
        var inputHasta = document.getElementById('solFechaHasta');
        var resumen = document.getElementById('solResumen');
        var avisoFinde = document.getElementById('solAvisoFinde');
        var btnEnviar = document.getElementById('btnEnviarSolicitud');
        if (!inputDesde) return;

        function parseFecha(v) {
            if (!v) return null;
            var partes = v.split('-');
            return new Date(Number(partes[0]), Number(partes[1]) - 1, Number(partes[2]));
        }

        function revisar() {
            var desde = parseFecha(inputDesde.value);
            var hasta = parseFecha(inputHasta.value);
            resumen.style.display = 'none';
            avisoFinde.style.display = 'none';
            btnEnviar.disabled = false;

            if (!desde || !hasta || hasta < desde) return;

            var dias = Math.round((hasta - desde) / (1000 * 60 * 60 * 24)) + 1;
            resumen.style.display = '';
            resumen.textContent = 'Dias solicitados: ' + dias + ' (calendario, incluye fines de semana)';

            var diaSemanaHasta = hasta.getDay(); // 0=domingo ... 5=viernes, 6=sabado
            if (diaSemanaHasta === 5 || diaSemanaHasta === 6) {
                avisoFinde.style.display = '';
                btnEnviar.disabled = true;
            }
        }

        inputDesde.addEventListener('change', revisar);
        inputHasta.addEventListener('change', revisar);
    })();
</script>
</body>
</html>
