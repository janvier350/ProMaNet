<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashMap"%>
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

    // Catalogo de empleados activos, para el select de "Jefe directo".
    List<Map<String,String>> empleados = new ArrayList<>();
    try (Connection cnCat = Servlets.Conexion.getConnection()) {
        if (cnCat != null) {
            try (PreparedStatement st = cnCat.prepareStatement(
                    "SELECT IDUSUARIO, NOMBRE||' '||APELLIDOS FROM USUARIO WHERE ESTADO = 'a' ORDER BY NOMBRE, APELLIDOS");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String,String> m = new LinkedHashMap<>();
                    m.put("id", rs.getString(1));
                    m.put("nombre", rs.getString(2));
                    empleados.add(m);
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
    <title>ProMaNet - Configuracion de Vacaciones</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
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
                <a class="nav-link active" href="VAC_ConfigUsuarios.jsp">
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Vacaciones - Configuracion</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Vacaciones - Fecha de Ingreso y Jefe Directo</h6>
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

        <div class="alert alert-info">
            <i class="fa fa-info-circle me-2"></i>
            Esta pantalla es la <strong>Fase 1</strong> del modulo de Vacaciones: aqui se carga la
            <strong>fecha de ingreso real</strong> (no la del Aviso de Entrada del IESS si son distintas)
            y el <strong>jefe directo</strong> de cada empleado. Estos dos datos son la base para calcular
            el saldo de vacaciones y enrutar las aprobaciones en las siguientes fases.
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header d-flex flex-column flex-md-row justify-content-between align-items-md-center">
                        <span class="mb-2 mb-md-0"><i class="fa fa-users mr-2 text-secondary"></i>Empleados
                            <span class="badge ml-2" style="background:#6c757d;color:#fff;"><%=empleados.size()%> registros</span>
                        </span>
                        <input type="text" id="buscarEmpleado" class="form-control form-control-sm" placeholder="Buscar..." style="max-width:220px;">
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0" id="tablaConfig">
                                <thead>
                                    <tr>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Empleado</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Compania</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Departamento</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Ingreso</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Antiguedad</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Jefe Directo</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn = Servlets.Conexion.getConnection()) {
                                            if (cn != null) {
                                                try (PreparedStatement st = cn.prepareStatement(
                                                        "SELECT u.IDUSUARIO, u.NOMBRE||' '||u.APELLIDOS, c.COMPANIA, d.DEPARTAMENTO, " +
                                                        "TO_CHAR(vc.FECHA_INGRESO,'YYYY-MM-DD'), TO_CHAR(vc.FECHA_INGRESO,'DD/MM/YYYY'), " +
                                                        "vc.ID_JEFE_DIRECTO, jefe.NOMBRE||' '||jefe.APELLIDOS " +
                                                        "FROM USUARIO u " +
                                                        "LEFT JOIN COMPANIA c ON u.IDCOMPANIA = c.IDCOMPANIA " +
                                                        "LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO " +
                                                        "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
                                                        "LEFT JOIN USUARIO jefe ON jefe.IDUSUARIO = vc.ID_JEFE_DIRECTO " +
                                                        "WHERE u.ESTADO = 'a' " +
                                                        "ORDER BY c.COMPANIA, u.NOMBRE, u.APELLIDOS")) {
                                                    try (ResultSet rs = st.executeQuery()) {
                                                        while (rs.next()) {
                                                            String idE = rs.getString(1);
                                                            String nombreE = rs.getString(2);
                                                            String companiaE = rs.getString(3) != null ? rs.getString(3) : "-";
                                                            String deptoE = rs.getString(4) != null ? rs.getString(4) : "-";
                                                            String fechaIso = rs.getString(5);
                                                            String fechaDisplay = rs.getString(6);
                                                            String idJefeE = rs.getString(7);
                                                            String jefeNombreE = rs.getString(8);

                                                            String antiguedadTxt;
                                                            String badgeClase;
                                                            if (fechaIso == null) {
                                                                antiguedadTxt = "Sin definir";
                                                                badgeClase = "bg-gradient-secondary";
                                                            } else {
                                                                java.sql.Date fIngreso = rs.getDate(5);
                                                                long dias = (new java.util.Date().getTime() - fIngreso.getTime()) / (1000L * 60 * 60 * 24);
                                                                double anios = dias / 365.25;
                                                                antiguedadTxt = String.format("%.1f años", anios);
                                                                badgeClase = anios >= 1.0 ? "bg-gradient-success" : "bg-gradient-warning";
                                                            }
                                                    %>
                                                    <tr>
                                                        <td><p class="text-xs font-weight-bold mb-0"><%=nombreE%></p></td>
                                                        <td><p class="text-xs mb-0"><%=companiaE%></p></td>
                                                        <td><p class="text-xs mb-0"><%=deptoE%></p></td>
                                                        <td><p class="text-xs mb-0"><%=fechaDisplay != null ? fechaDisplay : "-"%></p></td>
                                                        <td class="text-center"><span class="badge badge-sm <%=badgeClase%>"><%=antiguedadTxt%></span></td>
                                                        <td><p class="text-xs mb-0"><%=jefeNombreE != null ? jefeNombreE : "-"%></p></td>
                                                        <td class="text-center">
                                                            <div class="d-flex justify-content-center gap-1">
                                                                <button type="button" class="btn btn-xs btn-outline-primary py-1 btn-editar-config"
                                                                        data-id="<%=idE%>" data-nombre="<%=nombreE%>"
                                                                        data-fecha="<%=fechaIso != null ? fechaIso : ""%>"
                                                                        data-idjefe="<%=idJefeE != null ? idJefeE : ""%>">
                                                                    <i class="fa fa-pencil"></i> Editar
                                                                </button>
                                                                <a class="btn btn-xs btn-outline-success py-1" href="VAC_SaldoUsuario.jsp?id=<%=idE%>">
                                                                    <i class="fa fa-calculator"></i> Ver Saldo
                                                                </a>
                                                            </div>
                                                        </td>
                                                    </tr>
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

<%-- Modal: editar fecha de ingreso / jefe directo --%>
<div class="modal fade" id="modalConfig" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="../VAC_GuardarConfigUsuario" method="post">
                <input type="hidden" name="idEmpleado" id="configIdEmpleado">
                <div class="modal-header" style="background:#f0ad4e;">
                    <h5 class="modal-title text-white"><i class="fa fa-umbrella-beach me-2"></i>Configurar Vacaciones</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                </div>
                <div class="modal-body">
                    <p class="text-sm mb-3">Empleado: <strong id="configNombreEmpleado"></strong></p>
                    <div class="form-group mb-3">
                        <label>Fecha de ingreso real</label>
                        <input type="date" name="fechaIngreso" id="configFechaIngreso" class="form-control" required>
                    </div>
                    <div class="form-group mb-0">
                        <label>Jefe directo</label>
                        <select class="chosen-select form-control select2-modal" id="configIdJefe" name="idJefe">
                            <option value="">-- Sin definir --</option>
                            <% for (Map<String,String> e : empleados) { %>
                            <option value="<%=e.get("id")%>"><%=e.get("nombre")%></option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning btn-sm"><i class="fa fa-save me-1"></i>Guardar</button>
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
    var modalConfig = new bootstrap.Modal(document.getElementById('modalConfig'));
    $('#configIdJefe').select2({theme: 'bootstrap-5', width: '100%', dropdownParent: $('#modalConfig'), allowClear: true, placeholder: '-- Sin definir --'});

    document.querySelectorAll('.btn-editar-config').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('configIdEmpleado').value = this.getAttribute('data-id');
            document.getElementById('configNombreEmpleado').textContent = this.getAttribute('data-nombre');
            document.getElementById('configFechaIngreso').value = this.getAttribute('data-fecha');
            $('#configIdJefe').val(this.getAttribute('data-idjefe')).trigger('change');
            modalConfig.show();
        });
    });

    var buscarEmpleado = document.getElementById('buscarEmpleado');
    buscarEmpleado.addEventListener('input', function () {
        var q = this.value.toLowerCase().trim();
        document.querySelectorAll('#tablaConfig tbody tr').forEach(function (tr) {
            var texto = tr.textContent.toLowerCase();
            tr.style.display = (!q || texto.indexOf(q) !== -1) ? '' : 'none';
        });
    });
</script>
</body>
</html>
