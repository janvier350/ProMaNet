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
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_SOLICITAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    // Ser jefe directo de alguien es un dato (no un permiso): se muestra
    // la tarjeta de Aprobaciones solo si hoy tiene gente a cargo.
    boolean esJefeDirecto = false;
    try (java.sql.Connection cnJefe = Servlets.Conexion.getConnection()) {
        if (cnJefe != null) {
            String miIdStr = (String) session.getAttribute("cod");
            try (java.sql.PreparedStatement stJefe = cnJefe.prepareStatement(
                    "SELECT COUNT(*) FROM VAC_CONFIG_USUARIO WHERE ID_JEFE_DIRECTO = ?")) {
                stJefe.setString(1, miIdStr);
                try (java.sql.ResultSet rsJefe = stJefe.executeQuery()) {
                    if (rsJefe.next()) esJefeDirecto = rsJefe.getInt(1) > 0;
                }
            }
        }
    } catch (Exception exJefe) { exJefe.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Vacaciones</title>
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
                <a class="nav-link active" href="VAC_MiPanel.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-umbrella-13 text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Vacaciones</span>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Vacaciones</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Vacaciones</h6>
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
        <div class="row">
            <div class="col-xl-3 col-sm-6 mb-4">
                <div class="card">
                    <a href="VAC_MiSaldo.jsp">
                        <div class="card-body p-3">
                            <div class="row">
                                <div class="col-8">
                                    <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Solicitar</p>
                                        <h5 class="font-weight-bolder">MIS VACACIONES</h5>
                                        <p class="mb-0">
                                            <span class="text-warning text-sm font-weight-bolder">Consulte su saldo y</span>
                                            <b class="text-warning"> solicite vacaciones.</b>
                                        </p>
                                    </div>
                                </div>
                                <div class="col-4 text-end">
                                    <div class="icon icon-shape bg-gradient-warning shadow-warning text-center rounded-circle">
                                        <i class="fa fa-umbrella-beach text-lg opacity-10" aria-hidden="true"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>

            <% if (esJefeDirecto) { %>
            <div class="col-xl-3 col-sm-6 mb-4">
                <div class="card">
                    <a href="VAC_AprobacionesJefe.jsp">
                        <div class="card-body p-3">
                            <div class="row">
                                <div class="col-8">
                                    <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Gestionar</p>
                                        <h5 class="font-weight-bolder">APROBACIONES</h5>
                                        <p class="mb-0">
                                            <span class="text-info text-sm font-weight-bolder">Apruebe o rechace a</span>
                                            <b class="text-info"> su equipo a cargo.</b>
                                        </p>
                                    </div>
                                </div>
                                <div class="col-4 text-end">
                                    <div class="icon icon-shape bg-gradient-info shadow-info text-center rounded-circle">
                                        <i class="fa fa-user-check text-lg opacity-10" aria-hidden="true"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            <% } %>
        </div>

        <%-- ===== Calendario del anio (estilo "contribuciones"): dias de vacaciones gozadas / en tramite / permisos ===== --%>
        <%
            java.time.LocalDate _vhHoy = java.time.LocalDate.now();
            int _vhAnio = _vhHoy.getYear();
            try { _vhAnio = Integer.parseInt(request.getParameter("anio")); } catch (Exception ignoreAnio) { }
            if (_vhAnio < _vhHoy.getYear() - 3 || _vhAnio > _vhHoy.getYear() + 1) _vhAnio = _vhHoy.getYear();
            java.time.LocalDate _vhIni = java.time.LocalDate.of(_vhAnio, 1, 1), _vhFin = java.time.LocalDate.of(_vhAnio, 12, 31);
            java.util.Map<java.time.LocalDate, String> _vhDias = new java.util.HashMap<>();   // dia -> V | P | T
            boolean _vhError = false;
            try (java.sql.Connection _vhCn = Servlets.Conexion.getConnection()) {
                int _vhUid = Integer.parseInt(((String) session.getAttribute("cod")).trim());
                String _vhSql =
                    "SELECT 'V', FECHA_DESDE, FECHA_HASTA, 1 FROM VAC_SOLICITUD WHERE ID_USUARIO = ? AND ESTADO IN ('APROBADO','RECIBIDO') " +
                    "UNION ALL SELECT 'V', FECHA_DESDE, FECHA_HASTA, 1 FROM VAC_HISTORICO_AJUSTE WHERE ID_USUARIO = ? AND ID_PERMISO IS NULL AND FECHA_DESDE IS NOT NULL AND FECHA_HASTA IS NOT NULL " +
                    "UNION ALL SELECT 'P', FECHA_DESDE, FECHA_HASTA, 2 FROM VAC_HISTORICO_AJUSTE WHERE ID_USUARIO = ? AND ID_PERMISO IS NOT NULL AND FECHA_DESDE IS NOT NULL AND FECHA_HASTA IS NOT NULL " +
                    "UNION ALL SELECT 'T', FECHA_DESDE, FECHA_HASTA, 3 FROM VAC_SOLICITUD WHERE ID_USUARIO = ? AND ESTADO IN ('PENDIENTE_JEFE','PENDIENTE_ADMIN')";
                try (java.sql.PreparedStatement _vhSt = _vhCn.prepareStatement(
                        "SELECT * FROM (" + _vhSql + ") WHERE FECHA_HASTA >= ? AND FECHA_DESDE <= ?")) {
                    for (int _i = 1; _i <= 4; _i++) _vhSt.setInt(_i, _vhUid);
                    _vhSt.setDate(5, java.sql.Date.valueOf(_vhIni)); _vhSt.setDate(6, java.sql.Date.valueOf(_vhFin));
                    try (java.sql.ResultSet _vhRs = _vhSt.executeQuery()) {
                        while (_vhRs.next()) {
                            String _t = _vhRs.getString(1); int _prio = _vhRs.getInt(4);
                            java.time.LocalDate _d = _vhRs.getDate(2).toLocalDate(), _h = _vhRs.getDate(3).toLocalDate();
                            if (_d.isBefore(_vhIni)) _d = _vhIni;
                            if (_h.isAfter(_vhFin)) _h = _vhFin;
                            for (java.time.LocalDate _x = _d; !_x.isAfter(_h); _x = _x.plusDays(1)) {
                                String _prev = _vhDias.get(_x);
                                int _pp = _prev == null ? 9 : ("V".equals(_prev) ? 1 : ("P".equals(_prev) ? 2 : 3));
                                if (_prio < _pp) _vhDias.put(_x, _t);
                            }
                        }
                    }
                }
            } catch (Exception _vhEx) { _vhEx.printStackTrace(); _vhError = true; }

            int _vhV = 0, _vhP = 0, _vhT = 0;   // dias de lunes a viernes
            for (java.util.Map.Entry<java.time.LocalDate, String> _e : _vhDias.entrySet()) {
                int _dow = _e.getKey().getDayOfWeek().getValue();
                if (_dow > 5) continue;
                if ("V".equals(_e.getValue())) _vhV++; else if ("P".equals(_e.getValue())) _vhP++; else _vhT++;
            }
            String[] _vhMeses = {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"};
            int _vhOffset = _vhIni.getDayOfWeek().getValue() - 1;                      // columnas vacias al inicio (semana empieza lunes)
            int _vhSemanas = (_vhOffset + _vhIni.lengthOfYear() + 6) / 7;
        %>
        <style>
            .vh-grid { display:grid; grid-template-rows:repeat(7, 13px); grid-auto-flow:column; grid-auto-columns:13px; gap:3px; }
            .vh-meses { display:grid; grid-template-columns:repeat(<%= _vhSemanas %>, 13px); column-gap:3px; height:16px; font-size:.68rem; color:#67748e; }
            .vh-c { width:13px; height:13px; border-radius:3px; background:#ebedf0; }
            .vh-c.fin { background:#f4f5f7; }
            .vh-c.V { background:#2dce89; } .vh-c.T { background:#fb6340; } .vh-c.P { background:#11cdef; }
            .vh-c.hoy { outline:2px solid #344767; outline-offset:-1px; }
            .vh-leyenda span.sw { display:inline-block; width:12px; height:12px; border-radius:3px; vertical-align:-2px; margin:0 4px 0 12px; }
        </style>
        <div class="row mt-2">
            <div class="col-12">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="d-flex flex-wrap justify-content-between align-items-center mb-2">
                            <div>
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Mi calendario de vacaciones <%= _vhAnio %></p>
                                <p class="text-xs text-secondary mb-0">
                                    <b class="text-success"><%= _vhV %></b> d&iacute;as con vacaciones &middot;
                                    <b class="text-warning"><%= _vhT %></b> en tr&aacute;mite &middot;
                                    <b class="text-info"><%= _vhP %></b> de permisos <span class="text-secondary">(lunes a viernes)</span>
                                </p>
                            </div>
                            <div class="mt-1">
                                <a href="VAC_MiPanel.jsp?anio=<%= _vhAnio - 1 %>" class="btn btn-sm btn-outline-secondary mb-0 <%= _vhAnio <= _vhHoy.getYear() - 3 ? "disabled" : "" %>">&laquo; <%= _vhAnio - 1 %></a>
                                <a href="VAC_MiPanel.jsp?anio=<%= _vhAnio + 1 %>" class="btn btn-sm btn-outline-secondary mb-0 <%= _vhAnio >= _vhHoy.getYear() + 1 ? "disabled" : "" %>"><%= _vhAnio + 1 %> &raquo;</a>
                            </div>
                        </div>
                        <% if (_vhError) { %>
                        <p class="text-sm text-danger mb-0">No se pudo cargar el calendario.</p>
                        <% } else { %>
                        <div style="overflow-x:auto;">
                            <div style="display:inline-block; min-width:max-content;">
                                <div class="vh-meses">
                                    <%
                                        int _mesPrev = -1;
                                        for (int _w = 0; _w < _vhSemanas; _w++) {
                                            java.time.LocalDate _primero = _vhIni.plusDays((long) _w * 7 - _vhOffset);   // lunes de esa semana
                                            java.time.LocalDate _ref = _primero.isBefore(_vhIni) ? _vhIni : _primero;
                                            if (_ref.getYear() == _vhAnio && _ref.getMonthValue() != _mesPrev) {
                                                _mesPrev = _ref.getMonthValue();
                                    %><span style="grid-column:<%= _w + 1 %>;"><%= _vhMeses[_mesPrev - 1] %></span><%
                                            }
                                        }
                                    %>
                                </div>
                                <div class="vh-grid">
                                    <% for (int _b = 0; _b < _vhOffset; _b++) { %><div></div><% } %>
                                    <%
                                        java.time.format.DateTimeFormatter _fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
                                        for (java.time.LocalDate _d = _vhIni; !_d.isAfter(_vhFin); _d = _d.plusDays(1)) {
                                            String _t = _vhDias.get(_d);
                                            boolean _fin = _d.getDayOfWeek().getValue() > 5;
                                            String _txt = _fmt.format(_d) + ("V".equals(_t) ? " - Vacaciones" : ("P".equals(_t) ? " - Permiso" : ("T".equals(_t) ? " - Solicitud en tr\u00e1mite" : "")));
                                    %><div class="vh-c <%= _t != null ? _t : "" %> <%= _fin && _t == null ? "fin" : "" %> <%= _d.equals(_vhHoy) ? "hoy" : "" %>" title="<%= _txt %>"></div><%
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                        <div class="vh-leyenda text-xs text-secondary mt-2">
                            <span class="sw" style="background:#2dce89;margin-left:0"></span>Vacaciones
                            <span class="sw" style="background:#fb6340"></span>En tr&aacute;mite
                            <span class="sw" style="background:#11cdef"></span>Permiso
                            <span class="sw" style="background:#ebedf0"></span>Sin registro
                        </div>
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

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script src="../assets/js/custom-sidenav-toggle.js"></script>
</body>
</html>
