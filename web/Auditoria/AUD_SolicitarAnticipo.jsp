<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
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
    if (!COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR");

    int idUsuarioSesion = -1;
    try { idUsuarioSesion = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

    double sueldo = 0;
    String corteTexto = null;
    boolean plazoVencido = false;
    boolean tienePendiente = false;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement("SELECT SUELDO FROM USUARIO WHERE IDUSUARIO = ?")) {
                st.setInt(1, idUsuarioSesion);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) sueldo = rs.getDouble(1);
                }
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1")) {
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        java.sql.Date fc = rs.getDate(1);
                        if (fc != null) {
                            corteTexto = new java.text.SimpleDateFormat("dd/MM/yyyy").format(fc);
                            plazoVencido = new java.util.Date().after(fc);
                        }
                    }
                }
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(*) FROM AUD_ANTICIPOS WHERE ID_USUARIO = ? AND ESTADO = 'PENDIENTE'")) {
                st.setInt(1, idUsuarioSesion);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) tienePendiente = rs.getInt(1) > 0;
                }
            }
        }
    } catch (Exception ex) { ex.printStackTrace(); }

    double tope = sueldo * 0.50;
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
    <title>ProMaNet - Anticipos Auditoria</title>
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
                <a class="nav-link active" href="AUD_SolicitarAnticipo.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-hand-holding-usd text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Anticipos Auditoria</span>
                </a>
            </li>
            <% if (puedeGestionar) { %>
            <li class="nav-item">
                <a class="nav-link " href="AUD_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-tasks text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Panel de Gestion</span>
                </a>
            </li>
            <% } %>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Anticipos Auditoria</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Anticipos - Auditoria</h6>
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

        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Sueldo registrado</p>
                        <h4 class="mb-0">$ <%=sueldo%></h4>
                        <p class="text-xs text-secondary mb-0">Tope de anticipo (50%): $ <%=tope%></p>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Fecha de corte vigente</p>
                        <% if (corteTexto != null) { %>
                            <h4 class="mb-0"><%=corteTexto%></h4>
                            <% if (plazoVencido) { %>
                                <span class="badge badge-sm bg-gradient-danger">Plazo vencido</span>
                            <% } else { %>
                                <span class="badge badge-sm bg-gradient-success">Plazo vigente</span>
                            <% } %>
                        <% } else { %>
                            <span class="badge badge-sm bg-gradient-secondary">Sin fecha de corte definida</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card bg-gradient-info">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold text-white">Solicitar anticipo</p>
                        <% if (plazoVencido) { %>
                            <p class="text-white text-xs mb-0">El plazo para solicitar ya vencio.</p>
                        <% } else if (tienePendiente) { %>
                            <p class="text-white text-xs mb-0">Ya tienes una solicitud pendiente.</p>
                        <% } else { %>
                            <button type="button" class="btn btn-white btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#modalSolicitar">
                                <i class="fa fa-plus me-1"></i> Nueva solicitud
                            </button>
                        <% } %>
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
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Anticipo</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn2 = Servlets.Conexion.getConnection()) {
                                            if (cn2 != null) {
                                                try (PreparedStatement st2 = cn2.prepareStatement(
                                                        "SELECT ID_AUD_ANTICIPO, TO_CHAR(FECHA_SOLICITUD,'DD/MM/YYYY'), ANTICIPO, ESTADO " +
                                                        "FROM AUD_ANTICIPOS WHERE ID_USUARIO = ? ORDER BY FECHA_SOLICITUD DESC")) {
                                                    st2.setInt(1, idUsuarioSesion);
                                                    try (ResultSet rs2 = st2.executeQuery()) {
                                                        boolean hay = false;
                                                        while (rs2.next()) {
                                                            hay = true;
                                                            String idA = rs2.getString(1);
                                                            String fechaA = rs2.getString(2);
                                                            String montoA = rs2.getString(3);
                                                            String estadoA = rs2.getString(4);
                                                            boolean esPendiente = "PENDIENTE".equals(estadoA);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=fechaA%></p></td>
                                                        <td><p class="text-xs font-weight-bold mb-0">$ <%=montoA%></p></td>
                                                        <td class="text-center">
                                                            <% if (esPendiente) { %>
                                                                <span class="badge badge-sm bg-gradient-warning">PENDIENTE</span>
                                                            <% } else { %>
                                                                <span class="badge badge-sm bg-gradient-success">PAGADO</span>
                                                            <% } %>
                                                        </td>
                                                        <td class="text-center">
                                                            <div class="d-flex justify-content-center gap-1">
                                                                <% if (esPendiente && !plazoVencido) { %>
                                                                <button type="button" class="btn btn-xs btn-outline-primary py-1 btn-editar-anticipo"
                                                                        data-id="<%=idA%>" data-monto="<%=montoA%>">
                                                                    <i class="fa fa-pencil"></i>
                                                                </button>
                                                                <% } %>
                                                                <a class="btn btn-xs btn-outline-success py-1" href="../AUD_ComprobantePDF?id=<%=idA%>" target="_blank">
                                                                    <i class="fa fa-file-pdf"></i>
                                                                </a>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay) {
                                                    %>
                                                    <tr><td colspan="4" class="text-center text-muted py-4">No tienes solicitudes registradas.</td></tr>
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
    </div>
</main>

<%-- Modal: Nueva solicitud --%>
<div class="modal fade" id="modalSolicitar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../AUD_InsertarAnticipo" method="post">
                <div class="modal-header" style="background:#17a2b8;">
                    <h5 class="modal-title text-white"><i class="fa fa-hand-holding-usd me-2"></i>Nueva Solicitud de Anticipo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm">Sueldo: <strong>$ <%=sueldo%></strong> &mdash; Tope maximo: <strong>$ <%=tope%></strong></p>
                    <div class="form-group mb-0">
                        <label>Monto del anticipo</label>
                        <input type="number" step="0.01" min="0.01" max="<%=tope%>" name="anticipo" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-info btn-sm"><i class="fa fa-save me-1"></i>Solicitar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Modal: Editar solicitud --%>
<div class="modal fade" id="modalEditar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../AUD_EditarAnticipo" method="post">
                <input type="hidden" name="idAnticipo" id="editIdAnticipo">
                <div class="modal-header" style="background:#6c757d;">
                    <h5 class="modal-title text-white"><i class="fa fa-pencil me-2"></i>Editar Solicitud</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <div class="form-group mb-0">
                        <label>Nuevo monto</label>
                        <input type="number" step="0.01" min="0.01" max="<%=tope%>" name="anticipo" id="editMontoAnticipo" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-dark btn-sm"><i class="fa fa-save me-1"></i>Guardar cambios</button>
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
    document.querySelectorAll('.btn-editar-anticipo').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('editIdAnticipo').value = this.getAttribute('data-id');
            document.getElementById('editMontoAnticipo').value = this.getAttribute('data-monto');
            new bootstrap.Modal(document.getElementById('modalEditar')).show();
        });
    });
</script>
</body>
</html>
