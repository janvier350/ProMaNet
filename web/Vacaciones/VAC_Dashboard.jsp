<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
    boolean puedeConfigurar = COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR");
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR");
    if (!puedeConfigurar && !puedeGestionar) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    // Estado de la ventana "registro de vacaciones ya gozadas".
    String retroLimite = null, retroLimiteIso = null, retroAbrio = null;
    String retroDefaultIso = java.time.LocalDate.now().plusDays(7).toString();
    String retroMaxIso = java.time.LocalDate.now().plusDays(30).toString();
    String retroHoyIso = java.time.LocalDate.now().toString();
    try (java.sql.Connection cnRetro = Servlets.Conexion.getConnection()) {
        if (cnRetro != null) {
            java.sql.Date lim = VACACIONES.VAC_RetroHelper.fechaLimiteVigente(cnRetro);
            if (lim != null) {
                retroLimite = new java.text.SimpleDateFormat("dd/MM/yyyy").format(lim);
                try (java.sql.PreparedStatement stR = cnRetro.prepareStatement(
                        "SELECT u.NOMBRE||' '||u.APELLIDOS FROM (SELECT ID_USUARIO_ABRE FROM VAC_RETRO_VENTANA " +
                        "WHERE ACTIVA = 'S' ORDER BY ID_VENTANA DESC) v LEFT JOIN USUARIO u ON u.IDUSUARIO = v.ID_USUARIO_ABRE " +
                        "WHERE ROWNUM = 1");
                     java.sql.ResultSet rsR = stR.executeQuery()) {
                    if (rsR.next()) retroAbrio = rsR.getString(1);
                }
            }
        }
    } catch (Exception exRetro) { exRetro.printStackTrace(); }
    String msjDash = request.getParameter("msj");
    String errDash = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Panel de Vacaciones</title>
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
                <a class="nav-link active" href="VAC_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-tasks text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Administrar Vacaciones</span>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Administrar Vacaciones</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Panel de Vacaciones</h6>
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
        <div class="alert alert-info">
            <i class="fa fa-info-circle me-2"></i>
            Punto de entrada del modulo de Vacaciones para quien lo administra. Aqui se iran agregando las
            demas funciones del modulo a medida que se necesiten.
        </div>

        <div class="row">
            <% if (puedeConfigurar) { %>
            <div class="col-xl-3 col-sm-6 mb-4">
                <div class="card">
                    <a href="VAC_ConfigUsuarios.jsp">
                        <div class="card-body p-3">
                            <div class="row">
                                <div class="col-8">
                                    <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Mantener</p>
                                        <h5 class="font-weight-bolder">CONFIGURACION</h5>
                                        <p class="mb-0">
                                            <span class="text-warning text-sm font-weight-bolder">Fecha de ingreso, jefe</span>
                                            <b class="text-warning"> directo, cedula y empresa.</b>
                                        </p>
                                    </div>
                                </div>
                                <div class="col-4 text-end">
                                    <div class="icon icon-shape bg-gradient-warning shadow-warning text-center rounded-circle">
                                        <i class="fa fa-sliders text-lg opacity-10" aria-hidden="true"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            <% } %>

            <% if (puedeGestionar) { %>
            <div class="col-xl-3 col-sm-6 mb-4">
                <div class="card">
                    <a href="VAC_AprobacionesAdmin.jsp">
                        <div class="card-body p-3">
                            <div class="row">
                                <div class="col-8">
                                    <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Gestionar</p>
                                        <h5 class="font-weight-bolder">APROBACIONES</h5>
                                        <p class="mb-0">
                                            <span class="text-info text-sm font-weight-bolder">Aprobar, rechazar y</span>
                                            <b class="text-info"> ver todas las solicitudes.</b>
                                        </p>
                                    </div>
                                </div>
                                <div class="col-4 text-end">
                                    <div class="icon icon-shape bg-gradient-info shadow-info text-center rounded-circle">
                                        <i class="fa fa-tasks text-lg opacity-10" aria-hidden="true"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            <% } %>

            <%-- Ventana para registrar vacaciones ya gozadas: habilita temporalmente a los
                 usuarios a solicitar fechas pasadas; se cierra con el boton o al vencer la fecha limite. --%>
            <div class="col-xl-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Vacaciones ya gozadas</p>
                        <% if (retroLimite != null) { %>
                        <h5 class="font-weight-bolder mb-1"><span class="badge bg-gradient-success">HABILITADO</span></h5>
                        <p class="text-xs mb-2">Los usuarios pueden registrar fechas pasadas hasta el <b><%=retroLimite%></b><%= retroAbrio != null ? " (abierto por " + retroAbrio + ")" : "" %>.</p>
                        <form action="../VAC_RetroactivasToggle" method="post" class="d-inline"
                              onsubmit="return confirm('Volver al modo normal? Los usuarios ya no podran registrar fechas pasadas.');">
                            <input type="hidden" name="accion" value="CERRAR">
                            <button type="submit" class="btn btn-sm btn-outline-danger mb-0"><i class="fa fa-lock me-1"></i> Volver al modo normal</button>
                        </form>
                        <% } else { %>
                        <h5 class="font-weight-bolder mb-1"><span class="badge bg-gradient-secondary">MODO NORMAL</span></h5>
                        <p class="text-xs mb-2">Los usuarios solo pueden solicitar desde hoy en adelante.</p>
                        <button type="button" class="btn btn-sm btn-outline-warning mb-0" data-bs-toggle="modal" data-bs-target="#modalRetro">
                            <i class="fa fa-unlock me-1"></i> Habilitar fechas pasadas
                        </button>
                        <% } %>
                    </div>
                </div>
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

<%-- Modal: habilitar el registro de vacaciones ya gozadas --%>
<div class="modal fade" id="modalRetro" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="../VAC_RetroactivasToggle" method="post">
                <input type="hidden" name="accion" value="ABRIR">
                <div class="modal-header" style="background:#f0ad4e;">
                    <h5 class="modal-title text-white"><i class="fa fa-unlock me-2"></i>Habilitar vacaciones ya gozadas</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm">Mientras este habilitado, todos los usuarios podran solicitar vacaciones con fechas
                        <b>completamente pasadas</b>. Siguen el flujo normal de aprobacion (jefe y administracion) y se
                        marcan como &quot;Ya gozadas&quot;. Vuelve solo al modo normal al vencer la fecha limite.</p>
                    <div class="form-group mb-3">
                        <label>Habilitado hasta (maximo 30 dias)</label>
                        <input type="date" name="fechaLimite" class="form-control" value="<%=retroDefaultIso%>"
                               min="<%=retroHoyIso%>" max="<%=retroMaxIso%>" required>
                    </div>
                    <div class="form-group mb-0">
                        <label>Motivo (opcional)</label>
                        <input type="text" name="motivo" class="form-control" maxlength="300" placeholder="Ej: ponerse al dia con vacaciones 2026">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning btn-sm"><i class="fa fa-unlock me-1"></i>Habilitar</button>
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
</body>
</html>
