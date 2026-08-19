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

    int idUsuarioSesion = -1;
    try { idUsuarioSesion = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

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
    <title>ProMaNet - Aprobaciones de Vacaciones</title>
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
                <a class="nav-link " href="VAC_MiSaldo.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-umbrella-beach text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Mis Vacaciones</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="VAC_AprobacionesJefe.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-user-check text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Aprobaciones (Jefe)</span>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Aprobaciones (Jefe)</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Vacaciones - Aprobaciones de mi Equipo</h6>
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
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Pendientes de mi aprobacion</h6>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Solicitante</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Solicitud</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Desde</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hasta</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dias</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Reincorporacion</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn = Servlets.Conexion.getConnection()) {
                                            if (cn != null) {
                                                try (PreparedStatement st = cn.prepareStatement(
                                                        "SELECT s.ID_SOLICITUD, u.NOMBRE||' '||u.APELLIDOS, TO_CHAR(s.FECHA_SOLICITUD,'DD/MM/YYYY'), " +
                                                        "TO_CHAR(s.FECHA_DESDE,'DD/MM/YYYY'), TO_CHAR(s.FECHA_HASTA,'DD/MM/YYYY'), s.DIAS_SOLICITADOS, " +
                                                        "TO_CHAR(s.FECHA_REINCORPORACION,'DD/MM/YYYY') " +
                                                        "FROM VAC_SOLICITUD s JOIN USUARIO u ON s.ID_USUARIO = u.IDUSUARIO " +
                                                        "WHERE s.ID_JEFE_DIRECTO = ? AND s.ESTADO = 'PENDIENTE_JEFE' " +
                                                        "ORDER BY s.FECHA_SOLICITUD ASC")) {
                                                    st.setInt(1, idUsuarioSesion);
                                                    try (ResultSet rs = st.executeQuery()) {
                                                        boolean hay = false;
                                                        while (rs.next()) {
                                                            hay = true;
                                                            String idSol = rs.getString(1);
                                                            String solicitante = rs.getString(2);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=solicitante%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs.getString(3)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs.getString(4)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs.getString(5)%></p></td>
                                                        <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=rs.getInt(6)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs.getString(7)%></p></td>
                                                        <td class="text-center">
                                                            <div class="d-flex justify-content-center gap-1">
                                                                <form action="../VAC_GestionarSolicitudJefe" method="post" class="d-inline"
                                                                      onsubmit="return confirm('¿Aprobar la solicitud de <%=solicitante%>?');">
                                                                    <input type="hidden" name="idSolicitud" value="<%=idSol%>">
                                                                    <input type="hidden" name="accion" value="APROBAR">
                                                                    <button type="submit" class="btn btn-xs btn-outline-success py-1">
                                                                        <i class="fa fa-check"></i> Aprobar
                                                                    </button>
                                                                </form>
                                                                <button type="button" class="btn btn-xs btn-outline-danger py-1 btn-rechazar-jefe"
                                                                        data-id="<%=idSol%>" data-nombre="<%=solicitante%>">
                                                                    <i class="fa fa-times"></i> Rechazar
                                                                </button>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay) {
                                                    %>
                                                    <tr><td colspan="7" class="text-center text-muted py-4">No tienes solicitudes pendientes de aprobar.</td></tr>
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
                        <h6>Historial gestionado por mi</h6>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Solicitante</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Desde</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hasta</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Gestion</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn2 = Servlets.Conexion.getConnection()) {
                                            if (cn2 != null) {
                                                try (PreparedStatement st2 = cn2.prepareStatement(
                                                        "SELECT u.NOMBRE||' '||u.APELLIDOS, TO_CHAR(s.FECHA_DESDE,'DD/MM/YYYY'), " +
                                                        "TO_CHAR(s.FECHA_HASTA,'DD/MM/YYYY'), TO_CHAR(s.FECHA_APROBACION_JEFE,'DD/MM/YYYY'), s.ESTADO " +
                                                        "FROM VAC_SOLICITUD s JOIN USUARIO u ON s.ID_USUARIO = u.IDUSUARIO " +
                                                        "WHERE s.ID_JEFE_DIRECTO = ? AND s.ESTADO != 'PENDIENTE_JEFE' " +
                                                        "ORDER BY s.FECHA_APROBACION_JEFE DESC")) {
                                                    st2.setInt(1, idUsuarioSesion);
                                                    try (ResultSet rs2 = st2.executeQuery()) {
                                                        boolean hay2 = false;
                                                        while (rs2.next()) {
                                                            hay2 = true;
                                                            String estadoHist = rs2.getString(5);
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=rs2.getString(1)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs2.getString(2)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs2.getString(3)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs2.getString(4)%></p></td>
                                                        <td class="text-center">
                                                            <% if ("RECHAZADO_JEFE".equals(estadoHist)) { %>
                                                            <span class="badge badge-sm bg-gradient-danger">Rechazado por mi</span>
                                                            <% } else { %>
                                                            <span class="badge badge-sm bg-gradient-success">Aprobado por mi</span>
                                                            <% } %>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay2) {
                                                    %>
                                                    <tr><td colspan="5" class="text-center text-muted py-4">Sin historial todavia.</td></tr>
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

<%-- Modal: rechazar solicitud (requiere motivo) --%>
<div class="modal fade" id="modalRechazar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../VAC_GestionarSolicitudJefe" method="post">
                <input type="hidden" name="idSolicitud" id="rechazarIdSolicitud">
                <input type="hidden" name="accion" value="RECHAZAR">
                <div class="modal-header" style="background:#dc3545;">
                    <h5 class="modal-title text-white"><i class="fa fa-times-circle me-2"></i>Rechazar Solicitud</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm mb-3">Solicitante: <strong id="rechazarNombreSolicitante"></strong></p>
                    <div class="form-group mb-0">
                        <label>Motivo del rechazo</label>
                        <textarea name="comentario" class="form-control" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-danger btn-sm"><i class="fa fa-times me-1"></i>Rechazar</button>
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
    document.querySelectorAll('.btn-rechazar-jefe').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('rechazarIdSolicitud').value = this.getAttribute('data-id');
            document.getElementById('rechazarNombreSolicitante').textContent = this.getAttribute('data-nombre');
            new bootstrap.Modal(document.getElementById('modalRechazar')).show();
        });
    });
</script>
</body>
</html>
