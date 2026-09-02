<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.List"%>
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
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String idEmpleado = request.getParameter("id");
    if (idEmpleado == null || idEmpleado.trim().isEmpty()) {
        response.sendRedirect("VAC_ConfigUsuarios.jsp"); return;
    }

    String nombreEmpleado = "";
    VAC_CalculoSaldo.Saldo saldo = new VAC_CalculoSaldo.Saldo();

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NOMBRE||' '||APELLIDOS FROM USUARIO WHERE IDUSUARIO = ?")) {
                st.setString(1, idEmpleado);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) nombreEmpleado = rs.getString(1);
                }
            }
            saldo = VAC_CalculoSaldo.calcular(cn, Integer.parseInt(idEmpleado));
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
    <title>ProMaNet - Saldo de Vacaciones</title>
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
                <a class="nav-link " href="VAC_ConfigUsuarios.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-umbrella-beach text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Vacaciones - Configuracion</span>
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="VAC_ConfigUsuarios.jsp">Vacaciones</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Saldo</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Saldo de Vacaciones - <%=nombreEmpleado%></h6>
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
            Este empleado todavia no tiene fecha de ingreso configurada.
            <a href="VAC_ConfigUsuarios.jsp">Vuelve a Configuracion</a> para cargarla primero.
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
                        <p class="text-sm mb-1 text-uppercase font-weight-bold text-white">Total disponible</p>
                        <h4 class="mb-0 text-white"><%=saldo.totalDisponible%> dias</h4>
                        <p class="text-xs text-white mb-0"><%=saldo.periodos.size()%> periodo(s) cumplido(s)</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <div class="card-body">
                        <p class="text-sm mb-1 text-uppercase font-weight-bold">Cargar consumo historico</p>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="button" class="btn btn-outline-dark btn-sm mb-0" id="btnNuevoAjuste">
                                <i class="fa fa-plus me-1"></i> Nuevo ajuste
                            </button>
                            <a class="btn btn-outline-primary btn-sm mb-0" href="../VAC_ImprimirSaldo?id=<%=idEmpleado%>" target="_blank">
                                <i class="fa fa-print me-1"></i> Imprimir
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Periodos acumulados</h6>
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
                                    <tr><td colspan="6" class="text-center text-muted py-4">Todavia no cumple 1 año de trabajo -- sin periodos acumulados.</td></tr>
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
                        <h6>Ajustes historicos registrados</h6>
                        <p class="text-xs text-secondary mb-0">Consumo cargado manualmente (previo a este modulo).</p>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Periodo</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dias</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Desde</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Hasta</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Observaciones</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn2 = Servlets.Conexion.getConnection()) {
                                            if (cn2 != null) {
                                                try (PreparedStatement st2 = cn2.prepareStatement(
                                                        "SELECT ID_AJUSTE, NUM_PERIODO, DIAS_GOZADOS, TO_CHAR(FECHA_DESDE,'DD/MM/YYYY'), " +
                                                        "TO_CHAR(FECHA_HASTA,'DD/MM/YYYY'), OBSERVACIONES, " +
                                                        "TO_CHAR(FECHA_DESDE,'YYYY-MM-DD'), TO_CHAR(FECHA_HASTA,'YYYY-MM-DD') " +
                                                        "FROM VAC_HISTORICO_AJUSTE WHERE ID_USUARIO = ? ORDER BY NUM_PERIODO, FECHA_REGISTRO")) {
                                                    st2.setString(1, idEmpleado);
                                                    try (ResultSet rs2 = st2.executeQuery()) {
                                                        boolean hay2 = false;
                                                        while (rs2.next()) {
                                                            hay2 = true;
                                                            String idAjuste = rs2.getString(1);
                                                            String obs = rs2.getString(6);
                                                    %>
                                                    <tr>
                                                        <td class="text-center"><p class="text-xs mb-0"><%=rs2.getString(2)%></p></td>
                                                        <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=rs2.getString(3)%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs2.getString(4) != null ? rs2.getString(4) : "-"%></p></td>
                                                        <td><p class="text-xs mb-0"><%=rs2.getString(5) != null ? rs2.getString(5) : "-"%></p></td>
                                                        <td><p class="text-xs mb-0"><%=obs != null ? obs : "-"%></p></td>
                                                        <td class="text-center">
                                                            <div class="d-flex justify-content-center gap-1">
                                                                <button type="button" class="btn btn-xs btn-outline-primary py-1 btn-editar-ajuste"
                                                                        data-id="<%=idAjuste%>" data-numperiodo="<%=rs2.getString(2)%>"
                                                                        data-dias="<%=rs2.getString(3)%>"
                                                                        data-fechadesde="<%=rs2.getString(7) != null ? rs2.getString(7) : ""%>"
                                                                        data-fechahasta="<%=rs2.getString(8) != null ? rs2.getString(8) : ""%>"
                                                                        data-observaciones="<%=obs != null ? obs.replace("\"","&quot;") : ""%>">
                                                                    <i class="fa fa-pencil"></i>
                                                                </button>
                                                                <form action="../VAC_EliminarAjusteHistorico" method="post" class="d-inline"
                                                                      onsubmit="return confirm('¿Eliminar este ajuste historico? Esta accion no se puede deshacer.');">
                                                                    <input type="hidden" name="idEmpleado" value="<%=idEmpleado%>">
                                                                    <input type="hidden" name="idAjuste" value="<%=idAjuste%>">
                                                                    <button type="submit" class="btn btn-xs btn-outline-danger py-1">
                                                                        <i class="fa fa-trash"></i>
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                        }
                                                        if (!hay2) {
                                                    %>
                                                    <tr><td colspan="6" class="text-center text-muted py-4">Sin ajustes registrados.</td></tr>
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

<%-- Modal: nuevo ajuste historico --%>
<div class="modal fade" id="modalAjuste" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../VAC_GuardarAjusteHistorico" method="post" id="formAjuste">
                <input type="hidden" name="idEmpleado" value="<%=idEmpleado%>">
                <input type="hidden" name="idAjuste" id="ajusteIdAjuste" value="">
                <div class="modal-header" style="background:#343a40;">
                    <h5 class="modal-title text-white" id="modalAjusteTitulo"><i class="fa fa-history me-2"></i>Registrar Ajuste Historico</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-xs text-muted">Registra dias ya gozados antes de este modulo, tal como aparecen en el reporte de vacaciones historico del empleado.</p>
                    <div class="form-group mb-3">
                        <label>Numero de periodo (1er año = 1, 2do año = 2, etc.)</label>
                        <input type="number" min="1" step="1" name="numPeriodo" id="ajusteNumPeriodo" class="form-control" required>
                    </div>
                    <div class="form-group mb-3">
                        <label>Dias gozados en ese periodo</label>
                        <input type="number" min="1" max="30" step="1" name="diasGozados" id="ajusteDiasGozados" class="form-control" required>
                        <small class="text-muted">El periodo 1-5 acumula 15 dias; desde el 6to año se suma 1 dia extra por año, hasta 30.</small>
                    </div>
                    <div class="row">
                        <div class="col-6 form-group mb-3">
                            <label>Fecha desde (opcional)</label>
                            <input type="date" name="fechaDesde" id="ajusteFechaDesde" class="form-control">
                        </div>
                        <div class="col-6 form-group mb-3">
                            <label>Fecha hasta (opcional)</label>
                            <input type="date" name="fechaHasta" id="ajusteFechaHasta" class="form-control">
                        </div>
                    </div>
                    <div class="form-group mb-0">
                        <label>Observaciones (opcional)</label>
                        <textarea name="observaciones" id="ajusteObservaciones" class="form-control" rows="2"></textarea>
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

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script src="../assets/js/custom-sidenav-toggle.js"></script>
<script>
    var modalAjuste = new bootstrap.Modal(document.getElementById('modalAjuste'));
    var modalAjusteTitulo = document.getElementById('modalAjusteTitulo');

    function limpiarFormAjuste() {
        document.getElementById('ajusteIdAjuste').value = '';
        document.getElementById('ajusteNumPeriodo').value = '';
        document.getElementById('ajusteDiasGozados').value = '';
        document.getElementById('ajusteFechaDesde').value = '';
        document.getElementById('ajusteFechaHasta').value = '';
        document.getElementById('ajusteObservaciones').value = '';
    }

    document.getElementById('btnNuevoAjuste').addEventListener('click', function () {
        limpiarFormAjuste();
        modalAjusteTitulo.innerHTML = '<i class="fa fa-history me-2"></i>Registrar Ajuste Historico';
        modalAjuste.show();
    });

    document.querySelectorAll('.btn-editar-ajuste').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('ajusteIdAjuste').value = this.getAttribute('data-id');
            document.getElementById('ajusteNumPeriodo').value = this.getAttribute('data-numperiodo');
            document.getElementById('ajusteDiasGozados').value = this.getAttribute('data-dias');
            document.getElementById('ajusteFechaDesde').value = this.getAttribute('data-fechadesde');
            document.getElementById('ajusteFechaHasta').value = this.getAttribute('data-fechahasta');
            document.getElementById('ajusteObservaciones').value = this.getAttribute('data-observaciones');
            modalAjusteTitulo.innerHTML = '<i class="fa fa-history me-2"></i>Editar Ajuste Historico';
            modalAjuste.show();
        });
    });
</script>
</body>
</html>
