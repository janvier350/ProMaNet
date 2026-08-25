<%--
    Document   : Matriz de accesos -- vista general de que usuario tiene
    acceso a que modulo, calculada con la misma logica de 3 capas que usa
    COMUN.PermisoHelper (rol -> departamento -> excepcion individual, la
    individual siempre gana). Es de SOLO LECTURA: para cambiar algo hay
    que ir a Permisos por Usuario o Permisos por Departamento -- esta
    pantalla es para auditar/corroborar, no para editar.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet,java.util.LinkedHashMap,java.util.ArrayList,java.util.List"%>
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
            case "VACACIONES": return "fa-umbrella-beach";
            case "ANTICIPOS_AUDITORIA": return "fa-hand-holding-usd";
            default: return "fa-cog";
        }
    }

    // Fila de la matriz: un usuario y, por cada modulo con al menos un
    // permiso activo, la lista de CODIGOs concretos que efectivamente
    // tiene (para el tooltip). superAdmin marca si tiene
    // SUPERADMIN_ACCESO_TOTAL -- eso pasa por encima de todo lo demas.
    class FilaUsuario {
        int id;
        String nombre, apellidos, usuario, cargo;
        boolean superAdmin = false;
        java.util.Map<String, java.util.List<String>> porModulo = new java.util.LinkedHashMap<>();
    }
%>
<%
    String userDB = (String) session.getAttribute("userDB");
    String passDB = (String) session.getAttribute("passDB");
    String ip     = (String) session.getAttribute("ipDB");
    String url    = "" + ip;
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

    List<String> modulos = new ArrayList<>();
    LinkedHashMap<Integer, FilaUsuario> filas = new LinkedHashMap<>();
    int totalUsuariosActivos = 0;
    int totalPermisosActivos = 0;
    int totalSuperAdmins = 0;

    Connection cn = null;
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        cn = DriverManager.getConnection(url, userDB, passDB);

        try (PreparedStatement stMod = cn.prepareStatement(
                "SELECT DISTINCT MODULO FROM APP_PERMISO WHERE ESTADO = 'A' ORDER BY MODULO");
             ResultSet rsMod = stMod.executeQuery()) {
            while (rsMod.next()) modulos.add(rsMod.getString(1));
        }

        try (PreparedStatement stTot = cn.prepareStatement("SELECT COUNT(*) FROM USUARIO WHERE ESTADO = 'a'");
             ResultSet rsTot = stTot.executeQuery()) {
            if (rsTot.next()) totalUsuariosActivos = rsTot.getInt(1);
        }
        try (PreparedStatement stTot = cn.prepareStatement("SELECT COUNT(*) FROM APP_PERMISO WHERE ESTADO = 'A'");
             ResultSet rsTot = stTot.executeQuery()) {
            if (rsTot.next()) totalPermisosActivos = rsTot.getInt(1);
        }

        // Un solo query trae, por cada (usuario, permiso) que EFECTIVAMENTE
        // esta concedido (ya resuelta la capa de rol, departamento y
        // excepcion individual -- la misma prioridad que
        // PermisoHelper.cargarPermisos), el modulo y codigo. Si no aparece
        // aqui, ese usuario no tiene ese permiso, sin importar la capa.
        String sql =
            "SELECT u.IDUSUARIO, u.NOMBRE, u.APELLIDOS, u.USUARIO, r.CARGO, p.CODIGO, p.MODULO " +
            "FROM USUARIO u " +
            "JOIN ROL r ON r.IDROL = u.IDROL " +
            "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
            "JOIN APP_PERMISO p ON p.ESTADO = 'A' " +
            "LEFT JOIN APP_ROL_PERMISO arp ON arp.IDROL = u.IDROL AND arp.ID_PERMISO = p.ID_PERMISO " +
            "LEFT JOIN APP_DEPARTAMENTO_PERMISO adp ON UPPER(adp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO) AND adp.ID_PERMISO = p.ID_PERMISO " +
            "LEFT JOIN APP_USUARIO_PERMISO aup ON aup.IDUSUARIO = u.IDUSUARIO AND aup.ID_PERMISO = p.ID_PERMISO " +
            "WHERE u.ESTADO = 'a' " +
            "AND (CASE WHEN aup.TIPO IS NOT NULL THEN aup.TIPO " +
            "          WHEN adp.TIPO IS NOT NULL THEN adp.TIPO " +
            "          WHEN arp.IDROL IS NOT NULL THEN 'G' " +
            "          ELSE 'D' END) = 'G' " +
            "ORDER BY u.APELLIDOS, u.NOMBRE, p.MODULO, p.CODIGO";

        try (PreparedStatement st = cn.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                int idUsuario = rs.getInt(1);
                String codigo = rs.getString(6);
                String modulo = rs.getString(7);

                FilaUsuario f = filas.get(idUsuario);
                if (f == null) {
                    f = new FilaUsuario();
                    f.id = idUsuario;
                    f.nombre = rs.getString(2);
                    f.apellidos = rs.getString(3);
                    f.usuario = rs.getString(4);
                    f.cargo = rs.getString(5);
                    filas.put(idUsuario, f);
                }
                if ("SUPERADMIN_ACCESO_TOTAL".equals(codigo)) f.superAdmin = true;
                f.porModulo.computeIfAbsent(modulo, k -> new ArrayList<>()).add(codigo);
            }
        }

        for (FilaUsuario f : filas.values()) if (f.superAdmin) totalSuperAdmins++;
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (cn != null) cn.close(); } catch (Exception e2) {}
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="assets/img/favicon.png">
    <title>ProMaNet - Matriz de Accesos</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        .matriz-wrap{max-height:70vh;overflow:auto;}
        table.matriz{border-collapse:separate;border-spacing:0;}
        table.matriz th, table.matriz td{white-space:nowrap;}
        table.matriz thead th{position:sticky;top:0;background:#fff;z-index:2;}
        table.matriz td.col-usuario, table.matriz th.col-usuario{position:sticky;left:0;background:#fff;z-index:1;border-right:1px solid #e9ecef;}
        table.matriz thead th.col-usuario{z-index:3;}
        .celda-modulo{text-align:center;min-width:64px;}
        .celda-si{color:#2dce89;font-size:1rem;}
        .celda-si-super{color:#fbb034;font-size:1rem;}
        .celda-no{color:#dee2e6;font-size:.85rem;}
        .fila-usuario.d-none{display:none !important;}
        .badge-superadmin{background:#fbb034;color:#fff;}
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
                <a class="nav-link active" href="PCN_MatrizAccesos.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-app text-primary text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Matriz de Accesos</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="PCN_GestionPermisosDepartamento.jsp">
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
                    <h6 class="mb-0">Solo lectura</h6>
                    <p class="text-xs font-weight-bold mb-0">Editar desde Permisos por Usuario</p>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Matriz de Accesos</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Matriz de Accesos</h6>
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

        <div class="row">
            <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Usuarios activos</p>
                                    <h5 class="font-weight-bolder mb-0"><%=totalUsuariosActivos%></h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                    <i class="ni ni-single-02 text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Permisos activos</p>
                                    <h5 class="font-weight-bolder mb-0"><%=totalPermisosActivos%></h5>
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
            <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Modulos</p>
                                    <h5 class="font-weight-bolder mb-0"><%=modulos.size()%></h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-dark shadow text-center border-radius-md">
                                    <i class="ni ni-app text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Super Admin</p>
                                    <h5 class="font-weight-bolder mb-0"><%=totalSuperAdmins%></h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center border-radius-md">
                                    <i class="ni ni-badge text-lg opacity-10" aria-hidden="true"></i>
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
                    <div class="flex-grow-1" style="min-width:220px;">
                        <label class="form-label text-sm mb-1">Buscar usuario</label>
                        <input type="text" class="form-control" id="buscarUsuario" placeholder="Nombre, usuario o cargo...">
                    </div>
                </div>
                <div class="alert alert-info mt-3 mb-0 py-2 px-3" role="alert">
                    <i class="fa fa-info-circle me-1"></i>
                    <small>
                        <span class="celda-si"><i class="fa fa-check-circle"></i></span> acceso efectivo a ese modulo (por cargo, departamento o excepcion individual) &middot;
                        <span class="celda-si-super"><i class="fa fa-star"></i></span> <b>Super Admin</b>: pasa cualquier chequeo de permiso, sin importar el modulo &middot;
                        <span class="celda-no"><i class="fa fa-minus"></i></span> sin acceso.
                        Pasa el mouse sobre un check para ver el permiso puntual. Esta pantalla es solo de consulta -- para cambiar un acceso entra a <b>Permisos por Usuario</b> desde el boton de cada fila.
                    </small>
                </div>
            </div>
        </div>

        <div class="card mt-4">
            <div class="card-body p-0">
                <div class="matriz-wrap">
                    <table class="table table-sm align-items-center mb-0 matriz">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-xs font-weight-bolder opacity-7 ps-3 col-usuario">Usuario</th>
                                <th class="text-uppercase text-xs font-weight-bolder opacity-7">Cargo</th>
                                <% for (String modulo : modulos) { %>
                                <th class="text-uppercase text-xs font-weight-bolder opacity-7 celda-modulo" title="<%=modulo%>">
                                    <i class="fa <%=iconoModulo(modulo)%>"></i><br><%=modulo%>
                                </th>
                                <% } %>
                                <th class="text-uppercase text-xs font-weight-bolder opacity-7 text-center">Editar</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (filas.isEmpty()) { %>
                            <tr><td colspan="<%=modulos.size() + 3%>" class="text-center text-muted py-4">No hay usuarios activos.</td></tr>
                            <% } %>
                            <% for (FilaUsuario f : filas.values()) {
                                   String busqueda = (f.nombre + " " + f.apellidos + " " + f.usuario + " " + (f.cargo != null ? f.cargo : "")).toLowerCase();
                            %>
                            <tr class="fila-usuario" data-search="<%=busqueda.replace("\"","")%>">
                                <td class="col-usuario">
                                    <p class="text-xs font-weight-bold mb-0"><%=f.nombre%> <%=f.apellidos%>
                                    <% if (f.superAdmin) { %>
                                    <span class="badge badge-sm badge-superadmin ms-1">Super Admin</span>
                                    <% } %>
                                    </p>
                                    <p class="text-xs text-secondary mb-0">@<%=f.usuario%></p>
                                </td>
                                <td><p class="text-xs mb-0"><%=f.cargo != null ? f.cargo : "-"%></p></td>
                                <% for (String modulo : modulos) {
                                       List<String> codigos = f.porModulo.get(modulo);
                                       boolean tieneAlgo = f.superAdmin || (codigos != null && !codigos.isEmpty());
                                       String tooltip = f.superAdmin ? "Acceso total (Super Admin)" : (codigos != null ? String.join(", ", codigos) : "");
                                %>
                                <td class="celda-modulo" title="<%=tooltip%>">
                                    <% if (f.superAdmin) { %>
                                    <i class="fa fa-star celda-si-super"></i>
                                    <% } else if (tieneAlgo) { %>
                                    <i class="fa fa-check-circle celda-si"></i>
                                    <% } else { %>
                                    <i class="fa fa-minus celda-no"></i>
                                    <% } %>
                                </td>
                                <% } %>
                                <td class="text-center">
                                    <a class="btn btn-xs btn-outline-primary py-1" href="PCN_GestionPermisosUsuario.jsp?idUser=<%=f.id%>">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
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

<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/core/bootstrap.min.js"></script>
<script src="assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script>
var inputBuscar = document.getElementById('buscarUsuario');
if (inputBuscar) {
    inputBuscar.addEventListener('input', function() {
        var q = this.value.trim().toLowerCase();
        document.querySelectorAll('.fila-usuario').forEach(function(row) {
            var match = !q || row.getAttribute('data-search').indexOf(q) !== -1;
            row.classList.toggle('d-none', !match);
        });
    });
}
</script>
</body>
</html>
