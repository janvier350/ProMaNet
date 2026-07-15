<%--
    Document   : Gestion de permisos por departamento (APP_DEPARTAMENTO_PERMISO)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet"%>
<%!
    private String iconoModulo(String modulo) {
        if (modulo == null) return "fa-cog";
        switch (modulo) {
            case "SISTEMA": return "fa-shield";
            case "TODO": return "fa-tasks";
            case "REPORTE_GASTOS": return "fa-money";
            case "SOPORTES": return "fa-life-ring";
            case "AGENDA": return "fa-calendar";
            case "CONTACTOS": return "fa-address-book";
            case "CLIENTES": return "fa-briefcase";
            case "INVENTARIO": return "fa-cubes";
            case "INVENTARIO_EQUIPOS": return "fa-laptop";
            case "PROYECTOS": return "fa-sitemap";
            case "CONTROL": return "fa-sliders";
            case "MOVILIZACION": return "fa-car";
            default: return "fa-cog";
        }
    }
%>
<%
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;
    String nombreSesion = (String) session.getAttribute("nombre");
    String apellidosSesion = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
        response.sendRedirect("sesionInvalida.jsp"); return;
    }

    String departamento = request.getParameter("depto");

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");

    int totalDepartamentos = 0;
    int totalPermisos = 0;
    int totalExcepciones = 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="assets/img/favicon.png">
    <title>ProMaNet - Permisos por Departamento</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
    <style>
        .permiso-row{transition:background-color .15s ease;}
        .permiso-row:hover{background-color:#f8f9fa;}
        .permiso-row.d-none{display:none !important;}
        .codigo-permiso{font-size:.72rem;background:#f0f2f5;color:#495057;padding:.25em .6em;border-radius:.4rem;}
        .btn-check:checked + label.btn-outline-secondary{background-color:#8898aa;border-color:#8898aa;color:#fff;}
        .btn-check:checked + label.btn-outline-success{background-color:#2dce89;border-color:#2dce89;color:#fff;}
        .btn-check:checked + label.btn-outline-danger{background-color:#f5365c;border-color:#f5365c;color:#fff;}
        .modulo-header{cursor:pointer;}
        .modulo-header .fa-chevron-down{transition:transform .2s ease;}
        .modulo-header.collapsed .fa-chevron-down{transform:rotate(-90deg);}
        #barraGuardar{position:sticky;bottom:0;z-index:5;box-shadow:0 -4px 12px rgba(0,0,0,.06);}
    </style>
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4" id="sidenav-main">
    <div class="sidenav-header">
        <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
        <a class="navbar-brand m-0" href="Proyectos/PRO_Dashboard.jsp">
            <img src="assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
            <span class="ms-1 font-weight-bold">ProMaNet</span>
        </a>
    </div>
    <hr class="horizontal dark mt-0">
    <div class="collapse navbar-collapse w-auto" id="sidenav-collapse-main">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="Proyectos/PRO_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="PCN_ListadoUsuario.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-single-02 text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Usuarios</span>
                </a>
            </li>
            <li class="nav-item mt-3">
                <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Administracion de accesos</h6>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="PCN_ListadoUsuario.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-badge text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Permisos por Usuario</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="PCN_GestionPermisosDepartamento.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-shop text-success text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Permisos por Departamento</span>
                </a>
            </li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <div class="card card-plain shadow-none" id="sidenavCard">
            <img class="w-50 mx-auto" src="assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
            <div class="card-body text-center p-3 w-100 pt-0">
                <div class="docs-info">
                    <h6 class="mb-0">Reglas por departamento</h6>
                    <p class="text-xs font-weight-bold mb-0">Se aplican a todos los cargos por igual</p>
                </div>
            </div>
        </div>
        <a href="cerrar.jsp" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesi&oacute;n</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="PCN_ListadoUsuario.jsp">Usuarios</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Permisos por Departamento</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Permisos por Departamento</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                <ul class="navbar-nav justify-content-end">
                    <li class="nav-item d-flex align-items-center">
                        <span class="nav-link text-white font-weight-bold px-0">
                            <i class="fa fa-user me-sm-1"></i>
                            <span class="d-sm-inline d-none"><b><%=nombreSesion%> <%=apellidosSesion%></b></span>
                        </span>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

        <% if (msgExito != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa fa-check-circle me-2"></i><%=msgExito%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (msgError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa fa-exclamation-triangle me-2"></i><%=msgError%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Departamento</p>
                                    <h5 class="font-weight-bolder mb-0"><%=(departamento != null && !departamento.trim().isEmpty()) ? departamento : "Ninguno"%></h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                    <i class="ni ni-shop text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Excepciones activas</p>
                                    <h5 class="font-weight-bolder mb-0" id="statExcepciones">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center border-radius-md">
                                    <i class="ni ni-settings-gear-65 text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Permisos en el sistema</p>
                                    <h5 class="font-weight-bolder mb-0" id="statTotalPermisos">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-info shadow text-center border-radius-md">
                                    <i class="ni ni-collection text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mt-4">
            <div class="card-body p-3">
                <div class="d-flex flex-wrap align-items-center" style="gap:14px;">
                    <div class="flex-grow-1" style="min-width:260px;max-width:420px;">
                        <label class="form-label text-sm mb-1">Departamento</label>
                        <select id="selDepto" class="form-control" style="width:100%;">
                            <option value="">-- Selecciona un departamento --</option>
                            <%
                                try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnDep = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement stDep = cnDep.prepareStatement(
                                        "select * from ADM_DEPARTAMENTO where estado = 'A' order by 2");
                                    ResultSet rsDep = stDep.executeQuery();
                                    while (rsDep.next()) {
                                        String nombreDep = rsDep.getString(2);
                                        totalDepartamentos++;
                            %>
                            <option value="<%=nombreDep%>" <%=(nombreDep.equals(departamento)) ? "selected" : ""%>><%=nombreDep%></option>
                            <%
                                    }
                                    rsDep.close(); stDep.close();

                                    PreparedStatement stTot = cnDep.prepareStatement("SELECT COUNT(*) FROM APP_PERMISO WHERE ESTADO = 'A'");
                                    ResultSet rsTot = stTot.executeQuery();
                                    if (rsTot.next()) totalPermisos = rsTot.getInt(1);
                                    rsTot.close(); stTot.close();

                                    cnDep.close();
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                    <% if (departamento != null && !departamento.trim().isEmpty()) { %>
                    <div class="flex-grow-1" style="min-width:220px;">
                        <label class="form-label text-sm mb-1">Buscar permiso</label>
                        <input type="text" class="form-control" id="buscarPermiso" placeholder="Codigo o descripcion...">
                    </div>
                    <% } %>
                </div>
                <div class="alert alert-info mt-3 mb-0 py-2 px-3" role="alert">
                    <i class="fa fa-info-circle me-1"></i>
                    <small>Estas reglas aplican a <b>todo el departamento</b>, sin importar el cargo de cada persona. Se resuelven en este orden: <b>rol</b> &rarr; <b>departamento</b> &rarr; <b>excepcion individual del usuario</b> (la individual siempre gana al final). El cambio se aplica la proxima vez que cada persona inicie sesion.</small>
                </div>
            </div>
        </div>

        <% if (departamento != null && !departamento.trim().isEmpty()) { %>
        <form method="post" action="PCN_GuardarPermisosDepartamento" id="formPermisos">
            <input type="hidden" name="departamento" value="<%=departamento%>">
            <%
                try {
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);

                    PreparedStatement stExc = cn.prepareStatement(
                        "SELECT COUNT(*) FROM APP_DEPARTAMENTO_PERMISO WHERE UPPER(DEPARTAMENTO) = UPPER(?)");
                    stExc.setString(1, departamento);
                    ResultSet rsExc = stExc.executeQuery();
                    if (rsExc.next()) totalExcepciones = rsExc.getInt(1);
                    rsExc.close(); stExc.close();

                    PreparedStatement stMod = cn.prepareStatement(
                        "SELECT DISTINCT MODULO FROM APP_PERMISO WHERE ESTADO = 'A' ORDER BY MODULO");
                    ResultSet rsMod = stMod.executeQuery();
                    boolean primerModulo = true;
                    while (rsMod.next()) {
                        String modulo = rsMod.getString(1);
            %>
            <div class="card mt-4">
                <div class="card-header modulo-header d-flex justify-content-between align-items-center" data-bs-toggle="collapse" data-bs-target="#mod-<%=modulo%>" role="button">
                    <div class="d-flex align-items-center">
                        <div class="icon icon-shape icon-sm bg-gradient-dark shadow text-center border-radius-md me-2">
                            <i class="fa <%=iconoModulo(modulo)%> text-white opacity-10 text-xs"></i>
                        </div>
                        <h6 class="mb-0"><%=modulo%></h6>
                    </div>
                    <i class="fa fa-chevron-down text-secondary"></i>
                </div>
                <div class="collapse <%=primerModulo ? "show" : ""%>" id="mod-<%=modulo%>">
                    <div class="table-responsive">
                        <table class="table align-items-center mb-0">
                            <thead>
                                <tr>
                                    <th class="text-uppercase text-xs font-weight-bolder opacity-7 ps-4">Permiso</th>
                                    <th class="text-uppercase text-xs font-weight-bolder opacity-7">Descripcion</th>
                                    <th class="text-uppercase text-xs font-weight-bolder opacity-7 text-end pe-4">Regla para <%=departamento%></th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                primerModulo = false;
                                PreparedStatement stPerm = cn.prepareStatement(
                                    "SELECT ID_PERMISO, CODIGO, DESCRIPCION FROM APP_PERMISO WHERE MODULO = ? AND ESTADO = 'A' ORDER BY ID_PERMISO");
                                stPerm.setString(1, modulo);
                                ResultSet rsPerm = stPerm.executeQuery();
                                while (rsPerm.next()) {
                                    int idPermiso = rsPerm.getInt(1);
                                    String codigo = rsPerm.getString(2);
                                    String descripcion = rsPerm.getString(3);

                                    PreparedStatement stActual = cn.prepareStatement(
                                        "SELECT TIPO FROM APP_DEPARTAMENTO_PERMISO WHERE UPPER(DEPARTAMENTO) = UPPER(?) AND ID_PERMISO = ?");
                                    stActual.setString(1, departamento);
                                    stActual.setInt(2, idPermiso);
                                    ResultSet rsActual = stActual.executeQuery();
                                    String tipoActual = rsActual.next() ? rsActual.getString(1) : "NINGUNA";
                                    rsActual.close(); stActual.close();
                            %>
                                <tr class="permiso-row" data-search="<%=codigo.toLowerCase()%> <%=descripcion.toLowerCase()%>">
                                    <td class="ps-4"><span class="codigo-permiso"><%=codigo%></span></td>
                                    <td><span class="text-sm"><%=descripcion%></span></td>
                                    <td class="text-end pe-4">
                                        <div class="btn-group btn-group-sm" role="group">
                                            <input type="radio" class="btn-check" name="permiso_<%=idPermiso%>" id="p<%=idPermiso%>_n" value="NINGUNA" autocomplete="off" <%=("NINGUNA".equals(tipoActual))?"checked":""%>>
                                            <label class="btn btn-outline-secondary" for="p<%=idPermiso%>_n">Segun cargo</label>

                                            <input type="radio" class="btn-check" name="permiso_<%=idPermiso%>" id="p<%=idPermiso%>_g" value="G" autocomplete="off" <%=("G".equals(tipoActual))?"checked":""%>>
                                            <label class="btn btn-outline-success" for="p<%=idPermiso%>_g">Conceder</label>

                                            <input type="radio" class="btn-check" name="permiso_<%=idPermiso%>" id="p<%=idPermiso%>_d" value="D" autocomplete="off" <%=("D".equals(tipoActual))?"checked":""%>>
                                            <label class="btn btn-outline-danger" for="p<%=idPermiso%>_d">Denegar</label>
                                        </div>
                                    </td>
                                </tr>
                            <%
                                }
                                rsPerm.close(); stPerm.close();
                            %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <%
                    }
                    rsMod.close(); stMod.close();
                    cn.close();
                } catch (Exception e) { e.printStackTrace();
            %>
                <div class="alert alert-danger mt-3">Error: <%=e.getMessage()%></div>
            <%
                }
            %>
            <div class="card mt-4" id="barraGuardar">
                <div class="card-body p-3 d-flex justify-content-between align-items-center flex-wrap" style="gap:10px;">
                    <span class="text-sm text-secondary"><i class="fa fa-info-circle me-1"></i>Los cambios se aplican al guardar, para todas las personas de este departamento.</span>
                    <button type="submit" class="btn bg-gradient-primary mb-0"><i class="fa fa-save me-1"></i>Guardar cambios</button>
                </div>
            </div>
        </form>
        <% } %>
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

<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/core/bootstrap.min.js"></script>
<script src="assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script>
document.getElementById('statTotalPermisos').textContent = '<%=totalPermisos%>';
document.getElementById('statExcepciones').textContent = '<%=totalExcepciones%>';

$('#selDepto').select2({
    theme: 'bootstrap-5',
    width: '100%'
});
$('#selDepto').on('change', function() {
    var v = $(this).val();
    window.location.href = 'PCN_GestionPermisosDepartamento.jsp' + (v ? ('?depto=' + encodeURIComponent(v)) : '');
});

var inputBuscar = document.getElementById('buscarPermiso');
if (inputBuscar) {
    inputBuscar.addEventListener('input', function() {
        var q = this.value.trim().toLowerCase();
        document.querySelectorAll('.permiso-row').forEach(function(row) {
            var match = !q || row.getAttribute('data-search').indexOf(q) !== -1;
            row.classList.toggle('d-none', !match);
        });
        document.querySelectorAll('[id^="mod-"]').forEach(function(modBody) {
            var tieneVisibles = modBody.querySelectorAll('.permiso-row:not(.d-none)').length > 0;
            var card = modBody.closest('.card');
            if (card) card.style.display = (q && !tieneVisibles) ? 'none' : '';
        });
    });
}
</script>
</body>
</html>
