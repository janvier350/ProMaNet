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
    if (!COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean tieneAcceso = COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO");

    String corteTexto = null;
    boolean plazoVencido = false;
    double totalPendienteMes = 0;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
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
                    "SELECT NVL(SUM(ANTICIPO),0) FROM AUD_ANTICIPOS " +
                    "WHERE TRUNC(FECHA_SOLICITUD,'MM') = TRUNC(SYSDATE,'MM') AND ESTADO = 'PENDIENTE'")) {
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) totalPendienteMes = rs.getDouble(1);
                }
            }
        }
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
    <title>ProMaNet - Panel de Gestion - Anticipos Auditoria</title>
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
            <% if (tieneAcceso) { %>
            <li class="nav-item">
                <a class="nav-link " href="AUD_SolicitarAnticipo.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-hand-holding-usd text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Anticipos Auditoria</span>
                </a>
            </li>
            <% } %>
            <li class="nav-item">
                <a class="nav-link active" href="AUD_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-tasks text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Panel de Gestion</span>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Panel de Gestion</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Anticipos Auditoria - Panel de Gestion</h6>
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
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Fecha de corte vigente</p>
                        <% if (corteTexto != null) { %>
                            <h4 class="mb-0"><%=corteTexto%></h4>
                            <% if (plazoVencido) { %>
                                <span class="badge badge-sm bg-gradient-danger">Vencida</span>
                            <% } else { %>
                                <span class="badge badge-sm bg-gradient-success">Vigente</span>
                            <% } %>
                        <% } else { %>
                            <span class="badge badge-sm bg-gradient-secondary">Sin definir</span>
                        <% } %>
                        <div class="mt-2">
                            <button type="button" class="btn btn-outline-dark btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#modalFechaCorte">
                                <i class="fa fa-calendar me-1"></i> Definir nueva fecha
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card bg-gradient-warning">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold text-white">Pendiente de pago (mes actual)</p>
                        <h4 class="mb-0 text-white">$ <%=totalPendienteMes%></h4>
                        <% if (totalPendienteMes > 0) { %>
                        <form action="../AUD_ProcesarPago" method="post" class="mt-2"
                              onsubmit="return confirm('¿Marcar $<%=totalPendienteMes%> como pagados?');">
                            <button type="submit" class="btn btn-white btn-sm mb-0">
                                <i class="fa fa-check-circle me-1"></i> Marcar como Pagado
                            </button>
                        </form>
                        <% } else { %>
                        <span class="badge badge-sm bg-white text-warning mt-2">Todo al dia</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Reporte del mes</p>
                        <a class="btn btn-outline-success btn-sm mb-0" href="../AUD_ReportePDF" target="_blank">
                            <i class="fa fa-file-pdf me-1"></i> Exportar Reporte
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Solicitudes de Auditoria - mes actual</h6>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Sueldo</th>
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
                                                        "SELECT a.ID_AUD_ANTICIPO, u.NOMBRE||' '||u.APELLIDOS, a.SUELDO, " +
                                                        "TO_CHAR(a.FECHA_SOLICITUD,'DD/MM/YYYY'), a.ANTICIPO, a.ESTADO " +
                                                        "FROM AUD_ANTICIPOS a JOIN USUARIO u ON a.ID_USUARIO = u.IDUSUARIO " +
                                                        "WHERE TRUNC(a.FECHA_SOLICITUD,'MM') = TRUNC(SYSDATE,'MM') " +
                                                        "ORDER BY a.FECHA_SOLICITUD DESC")) {
                                                    try (ResultSet rs2 = st2.executeQuery()) {
                                                        boolean hay = false;
                                                        while (rs2.next()) {
                                                            hay = true;
                                                            String idA = rs2.getString(1);
                                                            String nombreA = rs2.getString(2);
                                                            String sueldoA = rs2.getString(3);
                                                            String fechaA = rs2.getString(4);
                                                            String montoA = rs2.getString(5);
                                                            String estadoA = rs2.getString(6);
                                                            boolean esPendiente = "PENDIENTE".equals(estadoA);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=nombreA%></p></td>
                                                        <td><p class="text-xs mb-0">$ <%=sueldoA%></p></td>
                                                        <td><p class="text-xs mb-0"><%=fechaA%></p></td>
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
                                                                <% if (esPendiente) { %>
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
                                                    <tr><td colspan="6" class="text-center text-muted py-4">No hay solicitudes este mes.</td></tr>
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

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Sueldos de Auditoria</h6>
                        <p class="text-xs text-secondary mb-0">Base para calcular el tope de anticipo (50%) de cada ejecutivo.</p>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Sueldo</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn3 = Servlets.Conexion.getConnection()) {
                                            if (cn3 != null) {
                                                try (PreparedStatement st3 = cn3.prepareStatement(
                                                        "SELECT u.IDUSUARIO, u.NOMBRE||' '||u.APELLIDOS, NVL(u.SUELDO,0) " +
                                                        "FROM USUARIO u " +
                                                        "LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO " +
                                                        "WHERE u.ESTADO = 'a' " +
                                                        "AND (" +
                                                        "  EXISTS (SELECT 1 FROM APP_DEPARTAMENTO_PERMISO dp JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO " +
                                                        "          WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G' AND UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO)) " +
                                                        "  OR EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO " +
                                                        "             WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up.TIPO = 'G' AND up.IDUSUARIO = u.IDUSUARIO) " +
                                                        ") " +
                                                        "AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up2 JOIN APP_PERMISO p2 ON p2.ID_PERMISO = up2.ID_PERMISO " +
                                                        "                WHERE p2.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up2.TIPO = 'D' AND up2.IDUSUARIO = u.IDUSUARIO) " +
                                                        "ORDER BY u.NOMBRE, u.APELLIDOS")) {
                                                    try (ResultSet rs3 = st3.executeQuery()) {
                                                        boolean hay3 = false;
                                                        while (rs3.next()) {
                                                            hay3 = true;
                                                            String idE = rs3.getString(1);
                                                            String nombreE = rs3.getString(2);
                                                            String sueldoE = rs3.getString(3);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=nombreE%></p></td>
                                                        <td><p class="text-xs mb-0">$ <%=sueldoE%></p></td>
                                                        <td class="text-center">
                                                            <button type="button" class="btn btn-xs btn-outline-primary py-1 btn-editar-sueldo"
                                                                    data-id="<%=idE%>" data-nombre="<%=nombreE%>" data-sueldo="<%=sueldoE%>">
                                                                <i class="fa fa-pencil"></i> Editar
                                                            </button>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay3) {
                                                    %>
                                                    <tr><td colspan="3" class="text-center text-muted py-4">No hay ejecutivos registrados en Auditoria.</td></tr>
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

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Historial de fechas de corte</h6>
                        <p class="text-xs text-secondary mb-0">Consulta los anticipos pagados de cualquier mes anterior.</p>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Corte</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Definido por</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn4 = Servlets.Conexion.getConnection()) {
                                            if (cn4 != null) {
                                                try (PreparedStatement st4 = cn4.prepareStatement(
                                                        "SELECT TO_CHAR(fc.FECHA_CORTE,'DD/MM/YYYY'), TO_CHAR(fc.FECHA_CORTE,'YYYY-MM'), " +
                                                        "NVL(u.NOMBRE||' '||u.APELLIDOS,'-'), fc.ESTADO " +
                                                        "FROM AUD_FECHA_CORTE_ANTICIPO fc LEFT JOIN USUARIO u ON fc.ID_USUARIO = u.IDUSUARIO " +
                                                        "ORDER BY fc.FECHA_CORTE DESC")) {
                                                    try (ResultSet rs4 = st4.executeQuery()) {
                                                        boolean hay4 = false;
                                                        while (rs4.next()) {
                                                            hay4 = true;
                                                            String fechaDisplay = rs4.getString(1);
                                                            String mesParam = rs4.getString(2);
                                                            String definidoPor = rs4.getString(3);
                                                            String estadoCorte = rs4.getString(4);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=fechaDisplay%></p></td>
                                                        <td><p class="text-xs mb-0"><%=definidoPor%></p></td>
                                                        <td class="text-center">
                                                            <% if ("A".equals(estadoCorte)) { %>
                                                                <span class="badge badge-sm bg-gradient-success">VIGENTE</span>
                                                            <% } else { %>
                                                                <span class="badge badge-sm bg-gradient-secondary">INACTIVA</span>
                                                            <% } %>
                                                        </td>
                                                        <td class="text-center">
                                                            <a class="btn btn-xs btn-outline-success py-1" href="../AUD_ReportePDF?mes=<%=mesParam%>&estado=PAGADO" target="_blank">
                                                                <i class="fa fa-eye"></i> Ver pagados
                                                            </a>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay4) {
                                                    %>
                                                    <tr><td colspan="4" class="text-center text-muted py-4">No hay fechas de corte registradas.</td></tr>
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

<%-- Modal: definir fecha de corte --%>
<div class="modal fade" id="modalFechaCorte" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../AUD_InsertarFechaCorte" method="post">
                <div class="modal-header" style="background:#343a40;">
                    <h5 class="modal-title text-white"><i class="fa fa-calendar me-2"></i>Definir Fecha de Corte</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-xs text-muted">Solo se permite una fecha de corte activa por mes.</p>
                    <div class="form-group mb-0">
                        <label>Fecha de corte</label>
                        <input type="date" name="corte" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-dark btn-sm"><i class="fa fa-save me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Modal: editar solicitud --%>
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
                        <input type="number" step="0.01" min="0.01" name="anticipo" id="editMontoAnticipo" class="form-control" required>
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

<%-- Modal: asignar sueldo --%>
<div class="modal fade" id="modalSueldo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../AUD_AsignarSueldo" method="post">
                <input type="hidden" name="idEjecutivo" id="sueldoIdEjecutivo">
                <div class="modal-header" style="background:#17a2b8;">
                    <h5 class="modal-title text-white"><i class="fa fa-dollar-sign me-2"></i>Asignar Sueldo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm mb-3">Ejecutivo: <strong id="sueldoNombreEjecutivo"></strong></p>
                    <div class="form-group mb-0">
                        <label>Sueldo</label>
                        <input type="number" step="0.01" min="0" name="sueldo" id="sueldoMonto" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-info btn-sm"><i class="fa fa-save me-1"></i>Guardar</button>
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
    document.querySelectorAll('.btn-editar-sueldo').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('sueldoIdEjecutivo').value = this.getAttribute('data-id');
            document.getElementById('sueldoNombreEjecutivo').textContent = this.getAttribute('data-nombre');
            document.getElementById('sueldoMonto').value = this.getAttribute('data-sueldo');
            new bootstrap.Modal(document.getElementById('modalSueldo')).show();
        });
    });
</script>
</body>
</html>
