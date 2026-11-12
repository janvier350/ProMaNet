<%--
    Document   : VAC_Estadisticas
    Dashboard de Vacaciones: indicadores y graficos de lectura rapida, quien esta de vacaciones este mes / el
    proximo / meses anteriores, y dias tomados por departamento.

    Acceso: VACACIONES_CONFIGURAR o VACACIONES_GESTIONAR. Respeta el alcance por grupo de gestion
    (VAC_Alcance): cada gestor ve solo a su grupo; el administrador global ve todo y puede filtrar por grupo.
    Datos: VAC_EventosHelper (solicitudes aprobadas + ajustes con fechas + permisos que descargan).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.time.*"%>
<%@page import="java.util.*"%>
<%@page import="VACACIONES.VAC_EventosHelper"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private static String js(String s) { return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " "); }
    private static String fmt2(double v) { return String.format(java.util.Locale.US, "%.2f", v); }
    private static final String[] MESES = {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"};
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String compania  = (String) session.getAttribute("compania");
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR") && !COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean esGlobal = VACACIONES.VAC_Alcance.esGlobal(session);

    LocalDate hoy = LocalDate.now();
    int anio = hoy.getYear();
    try { anio = Integer.parseInt(request.getParameter("anio")); } catch (Exception ignore) { }
    if (anio < 2019 || anio > hoy.getYear() + 1) anio = hoy.getYear();
    Integer grupoFiltro = null; String grupoParam = esGlobal ? request.getParameter("grupo") : null;
    if (grupoParam != null && grupoParam.matches("[0-9]+")) grupoFiltro = Integer.parseInt(grupoParam);

    LocalDate iniAnio = LocalDate.of(anio, 1, 1), finAnio = LocalDate.of(anio, 12, 31);
    LocalDate iniMesActual = hoy.withDayOfMonth(1), finMesActual = hoy.withDayOfMonth(hoy.lengthOfMonth());
    LocalDate iniMesSig = iniMesActual.plusMonths(1), finMesSig = iniMesSig.withDayOfMonth(iniMesSig.lengthOfMonth());

    List<VAC_EventosHelper.Evento> eventos = new ArrayList<>();
    List<String[]> catGrupos = new ArrayList<>();
    int[] estados = new int[4];
    String errorCarga = null;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            // Rango: todo el anio elegido + el mes siguiente al actual (puede caer en el anio siguiente) + el mes actual
            LocalDate ini = iniAnio, fin = finAnio;
            if (iniMesActual.isBefore(ini)) ini = iniMesActual;
            if (finMesSig.isAfter(fin)) fin = finMesSig;
            eventos = VAC_EventosHelper.cargar(cn, session, ini, fin, grupoFiltro);
            estados = VAC_EventosHelper.solicitudesPorEstado(cn, session, anio, grupoFiltro);
            if (esGlobal) {
                try (PreparedStatement st = cn.prepareStatement("SELECT ID_GRUPO, NOMBRE FROM VAC_GRUPO WHERE ESTADO = 'A' ORDER BY NOMBRE");
                     ResultSet rs = st.executeQuery()) { while (rs.next()) catGrupos.add(new String[]{rs.getString(1), rs.getString(2)}); }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        errorCarga = "No se pudieron cargar los datos: " + (e.getMessage() == null ? "" : e.getMessage());
    }

    // ---------- Indicadores ----------
    Set<Integer> hoyVac = new HashSet<>(), mesActual = new HashSet<>(), mesSig = new HashSet<>();
    double diasAnio = 0; Set<Integer> personasAnio = new HashSet<>();
    for (VAC_EventosHelper.Evento e : eventos) {
        if (e.esVacacion()) {
            if (!e.desde.isAfter(hoy) && !e.hasta.isBefore(hoy)) hoyVac.add(e.idUsuario);
            if (e.seSolapaCon(iniMesActual, finMesActual)) mesActual.add(e.idUsuario);
            if (e.seSolapaCon(iniMesSig, finMesSig)) mesSig.add(e.idUsuario);
        }
        if (e.desde.getYear() == anio) { diasAnio += e.dias; personasAnio.add(e.idUsuario); }
    }
    // Personas distintas de vacaciones por mes y dias por mes (segun fecha desde)
    int[] personasMes = new int[12]; double[] diasMes = new double[12];
    for (int m = 0; m < 12; m++) {
        LocalDate a = LocalDate.of(anio, m + 1, 1), b = a.withDayOfMonth(a.lengthOfMonth());
        Set<Integer> s = new HashSet<>();
        for (VAC_EventosHelper.Evento e : eventos) if (e.esVacacion() && e.seSolapaCon(a, b)) s.add(e.idUsuario);
        personasMes[m] = s.size();
    }
    Map<String, Double> diasDepto = new TreeMap<>(); Map<String, Set<Integer>> personasDepto = new HashMap<>();
    for (VAC_EventosHelper.Evento e : eventos) {
        if (e.desde.getYear() != anio) continue;
        diasMes[e.desde.getMonthValue() - 1] += e.dias;
        diasDepto.merge(e.departamento, e.dias, Double::sum);
        personasDepto.computeIfAbsent(e.departamento, k -> new HashSet<>()).add(e.idUsuario);
    }
    List<Map.Entry<String, Double>> deptos = new ArrayList<>(diasDepto.entrySet());
    deptos.sort((x, y) -> Double.compare(y.getValue(), x.getValue()));
    StringBuilder dLbl = new StringBuilder(), dVal = new StringBuilder();
    for (Map.Entry<String, Double> en : deptos) {
        dLbl.append(dLbl.length() > 0 ? "," : "").append('"').append(js(en.getKey())).append('"');
        dVal.append(dVal.length() > 0 ? "," : "").append(fmt2(en.getValue()));
    }
    StringBuilder pM = new StringBuilder(), dM = new StringBuilder(), mLbl = new StringBuilder();
    for (int m = 0; m < 12; m++) {
        pM.append(m > 0 ? "," : "").append(personasMes[m]);
        dM.append(m > 0 ? "," : "").append(fmt2(diasMes[m]));
        mLbl.append(m > 0 ? "," : "").append('"').append(MESES[m]).append('"');
    }
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Dashboard de Vacaciones</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
    <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
    <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js"></script>
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
            <li class="nav-item"><a class="nav-link" href="../Proyectos/PRO_Dashboard.jsp">
                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center"><i class="ni ni-tv-2 text-primary text-sm opacity-10"></i></div>
                <span class="nav-link-text ms-1">Dashboard</span></a></li>
            <li class="nav-item"><a class="nav-link" href="VAC_Dashboard.jsp">
                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center"><i class="ni ni-bullet-list-67 text-warning text-sm opacity-10"></i></div>
                <span class="nav-link-text ms-1">Administrar Vacaciones</span></a></li>
            <li class="nav-item"><a class="nav-link active" href="VAC_Estadisticas.jsp">
                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center"><i class="ni ni-chart-bar-32 text-info text-sm opacity-10"></i></div>
                <span class="nav-link-text ms-1">Dashboard de Vacaciones</span></a></li>
            <li class="nav-item"><a class="nav-link" href="../Manuales/MAN_VacacionesGestion.jsp">
                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center"><i class="ni ni-books text-success text-sm opacity-10"></i></div>
                <span class="nav-link-text ms-1">Manual de gestion</span></a></li>
            <li class="nav-item mt-3"><h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Panel de control</h6></li>
            <li class="nav-item"><a class="nav-link" href="../Proyectos/Perfil.jsp">
                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center"><i class="ni ni-single-02 text-dark text-sm opacity-10"></i></div>
                <span class="nav-link-text ms-1">Perfil</span></a></li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <a href="../cerrar.jsp" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesi&oacute;n</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="VAC_Dashboard.jsp">Vacaciones</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Dashboard</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Dashboard de Vacaciones</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                <div class="ms-md-auto pe-md-3 d-flex align-items-center"><span class="text-white-50"><i class="fas fa-home"></i> <%=esc(compania)%></span></div>
                <ul class="navbar-nav justify-content-end">
                    <li class="nav-item d-flex align-items-center"><span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-sm-1"></i><b><%=esc(nombre)%> <%=esc(apellidos)%></b></span></li>
                    <li class="nav-item ps-3 d-flex align-items-center">
                        <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav"><div class="sidenav-toggler-inner">
                            <i class="sidenav-toggler-line bg-white"></i><i class="sidenav-toggler-line bg-white"></i><i class="sidenav-toggler-line bg-white"></i></div></a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (errorCarga != null) { %><div class="alert alert-danger text-white"><%=esc(errorCarga)%></div><% } %>

        <%-- Filtros --%>
        <form method="get" class="row g-2 align-items-center mb-3">
            <div class="col-auto"><select name="anio" class="form-select form-select-sm" onchange="this.form.submit()">
                <% for (int a = hoy.getYear() + 1; a >= 2023; a--) { %><option value="<%=a%>" <%= a == anio ? "selected" : "" %>><%=a%></option><% } %></select></div>
            <% if (esGlobal) { %>
            <div class="col-auto"><select name="grupo" class="form-select form-select-sm" onchange="this.form.submit()">
                <option value="">Todos los grupos</option>
                <% for (String[] g : catGrupos) { %><option value="<%=g[0]%>" <%= g[0].equals(grupoParam) ? "selected" : "" %>><%=esc(g[1])%></option><% } %>
                <option value="0" <%= "0".equals(grupoParam) ? "selected" : "" %>>Sin asignar</option></select></div>
            <% } %>
            <div class="col-auto"><span class="text-white text-sm">Indicadores de <b><%=anio%></b>; las tarjetas de &laquo;hoy&raquo;, mes actual y pr&oacute;ximo son siempre al d&iacute;a de hoy.</span></div>
        </form>

        <%-- KPIs --%>
        <div class="row">
            <div class="col-xl-3 col-sm-6 mb-4"><div class="card"><div class="card-body p-3"><div class="row">
                <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">De vacaciones hoy</p>
                    <h4 class="font-weight-bolder mb-0"><%=hoyVac.size()%></h4><p class="mb-0 text-xs text-secondary">personas ausentes hoy</p></div>
                <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-primary shadow text-center rounded-circle"><i class="fas fa-umbrella-beach text-white" style="line-height:3rem;"></i></div></div></div></div></div></div>
            <div class="col-xl-3 col-sm-6 mb-4"><div class="card"><div class="card-body p-3"><div class="row">
                <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Este mes</p>
                    <h4 class="font-weight-bolder mb-0"><%=mesActual.size()%></h4><p class="mb-0 text-xs text-secondary">personas con vacaciones en <%=MESES[hoy.getMonthValue()-1].toLowerCase()%></p></div>
                <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-success shadow text-center rounded-circle"><i class="fas fa-calendar-day text-white" style="line-height:3rem;"></i></div></div></div></div></div></div>
            <div class="col-xl-3 col-sm-6 mb-4"><div class="card"><div class="card-body p-3"><div class="row">
                <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Pr&oacute;ximo mes</p>
                    <h4 class="font-weight-bolder mb-0"><%=mesSig.size()%></h4><p class="mb-0 text-xs text-secondary">personas con vacaciones en <%=MESES[iniMesSig.getMonthValue()-1].toLowerCase()%></p></div>
                <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-info shadow text-center rounded-circle"><i class="fas fa-calendar-plus text-white" style="line-height:3rem;"></i></div></div></div></div></div></div>
            <div class="col-xl-3 col-sm-6 mb-4"><div class="card"><div class="card-body p-3"><div class="row">
                <div class="col-8"><p class="text-sm mb-0 text-uppercase font-weight-bold">Pendientes</p>
                    <h4 class="font-weight-bolder mb-0 text-warning"><%=estados[0] + estados[1]%></h4><p class="mb-0 text-xs text-secondary"><%=estados[0]%> con el jefe &middot; <%=estados[1]%> con el gestor</p></div>
                <div class="col-4 text-end"><div class="icon icon-shape bg-gradient-warning shadow text-center rounded-circle"><i class="fas fa-hourglass-half text-white" style="line-height:3rem;"></i></div></div></div></div></div></div>
        </div>

        <%-- Graficos --%>
        <div class="row">
            <div class="col-lg-7 mb-4"><div class="card"><div class="card-header pb-0"><h6>Personas de vacaciones por mes (<%=anio%>)</h6>
                <p class="text-xs text-secondary mb-0"><%=personasAnio.size()%> personas distintas en el a&ntilde;o &middot; <%=fmt2(diasAnio)%> d&iacute;as tomados</p></div>
                <div class="card-body p-3"><canvas id="chPersonas" height="110"></canvas></div></div></div>
            <div class="col-lg-5 mb-4"><div class="card"><div class="card-header pb-0"><h6>Solicitudes por estado (<%=anio%>)</h6></div>
                <div class="card-body p-3" style="max-height:310px;"><canvas id="chEstados"></canvas></div></div></div>
        </div>
        <div class="row">
            <div class="col-lg-7 mb-4"><div class="card"><div class="card-header pb-0"><h6>D&iacute;as tomados por departamento (<%=anio%>)</h6>
                <p class="text-xs text-secondary mb-0">Solicitudes aprobadas + ajustes + permisos que descargan a vacaciones</p></div>
                <div class="card-body p-3"><div style="position:relative;height:<%=Math.max(220, deptos.size() * 34)%>px;"><canvas id="chDeptos"></canvas></div></div></div></div>
            <div class="col-lg-5 mb-4"><div class="card"><div class="card-header pb-0"><h6>D&iacute;as tomados por mes (<%=anio%>)</h6></div>
                <div class="card-body p-3"><canvas id="chDias" height="150"></canvas></div></div></div>
        </div>

        <%-- Personas de vacaciones --%>
        <div class="card mb-4">
            <div class="card-header pb-0">
                <div class="d-flex justify-content-between flex-wrap align-items-center">
                    <div><h6 class="mb-0">&iquest;Qui&eacute;n est&aacute; de vacaciones?</h6>
                        <p class="text-xs text-secondary mb-0">Filtra por periodo. &laquo;Anteriores&raquo; muestra los meses pasados del a&ntilde;o <%=anio%>.</p></div>
                    <div class="mt-2 mt-md-0">
                        <button type="button" class="btn btn-sm btn-outline-success mb-0" id="btnExcel"><i class="fas fa-file-excel me-1"></i>Excel</button>
                        <button type="button" class="btn btn-sm btn-outline-danger mb-0" id="btnPdf"><i class="fas fa-file-pdf me-1"></i>PDF</button>
                    </div>
                </div>
                <div class="d-flex flex-wrap gap-2 align-items-center mt-3">
                    <div class="btn-group btn-group-sm" role="group" id="grpPeriodo">
                        <button type="button" class="btn btn-primary mb-0" data-p="MES">Este mes</button>
                        <button type="button" class="btn btn-outline-primary mb-0" data-p="SIG">Pr&oacute;ximo mes</button>
                        <button type="button" class="btn btn-outline-primary mb-0" data-p="ANT">Meses anteriores</button>
                        <button type="button" class="btn btn-outline-primary mb-0" data-p="TODO">Todo el a&ntilde;o</button>
                    </div>
                    <select id="selMes" class="form-select form-select-sm" style="max-width:160px;display:none;">
                        <option value="">Todos los meses</option>
                        <% for (int m = 0; m < 12; m++) { %><option value="<%=m+1%>"><%=MESES[m]%></option><% } %>
                    </select>
                    <div class="form-check mb-0 ms-2"><input class="form-check-input" type="checkbox" id="chkPermisos"><label class="form-check-label text-sm" for="chkPermisos">Incluir permisos de 1 d&iacute;a</label></div>
                </div>
            </div>
            <div class="card-body px-0 pt-2 pb-2">
                <div class="table-responsive p-3">
                    <table class="table align-items-center mb-0" id="tablaPersonas">
                        <thead><tr>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Empleado</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Departamento</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Oficina</th>
                            <% if (esGlobal) { %><th class="text-uppercase text-secondary text-xxs font-weight-bolder">Grupo</th><% } %>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Desde</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Hasta</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder">D&iacute;as</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Tipo</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder">Situaci&oacute;n</th>
                        </tr></thead>
                        <tbody>
                        <% for (VAC_EventosHelper.Evento e : eventos) {
                               String sit, sitCls;
                               if (!e.desde.isAfter(hoy) && !e.hasta.isBefore(hoy)) { sit = "De vacaciones hoy"; sitCls = "bg-gradient-primary"; }
                               else if (e.desde.isAfter(hoy)) { sit = "Programadas"; sitCls = "bg-gradient-info"; }
                               else { sit = "Terminadas"; sitCls = "bg-gradient-secondary"; }
                        %>
                            <tr data-desde="<%=e.desde%>" data-hasta="<%=e.hasta%>" data-permiso="<%= e.esVacacion() ? "0" : "1" %>">
                                <td><p class="text-xs font-weight-bold mb-0"><%=esc(e.nombre)%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(e.departamento)%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(e.oficina.isEmpty() ? "-" : e.oficina)%></p></td>
                                <% if (esGlobal) { %><td><p class="text-xs mb-0"><%=esc(e.grupo)%></p></td><% } %>
                                <td data-order="<%=e.desde%>"><p class="text-xs mb-0"><%=e.desde.format(fmt)%></p></td>
                                <td data-order="<%=e.hasta%>"><p class="text-xs mb-0"><%=e.hasta.format(fmt)%></p></td>
                                <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=fmt2(e.dias)%></p></td>
                                <td><span class="text-xs"><%= "SOLICITUD".equals(e.tipo) ? "Solicitud" : ("AJUSTE".equals(e.tipo) ? "Ajuste" : "Permiso") %></span>
                                    <% if (e.anticipada) { %><span class="badge badge-sm bg-gradient-warning">Anticipada</span><% } %>
                                    <% if (e.retroactiva) { %><span class="badge badge-sm bg-gradient-info">Ya gozadas</span><% } %></td>
                                <td class="text-center"><span class="badge badge-sm <%=sitCls%>"><%=sit%></span></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/custom-sidenav-toggle.js"></script>
<script>
(function () {
    var C = ['#5e72e4', '#2dce89', '#11cdef', '#fb6340', '#f5365c', '#8965e0', '#ffd600', '#344767', '#8392ab', '#17c1e8'];
    var ejes = { grid: { color: '#eef0f6' }, ticks: { color: '#67748e', font: { size: 11 } } };
    new Chart(document.getElementById('chPersonas'), {
        type: 'bar',
        data: { labels: [<%=mLbl%>], datasets: [{ label: 'Personas', data: [<%=pM%>], borderRadius: 6,
            backgroundColor: [<% for (int m = 0; m < 12; m++) { %>'<%= (anio == hoy.getYear() && m == hoy.getMonthValue() - 1) ? "#2dce89" : "#5e72e4" %>'<%= m < 11 ? "," : "" %><% } %>] }] },
        options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 }, grid: ejes.grid }, x: { grid: { display: false } } } }
    });
    new Chart(document.getElementById('chEstados'), {
        type: 'doughnut',
        data: { labels: ['Pendiente jefe', 'Pendiente gestor', 'Aprobadas', 'Rechazadas'],
            datasets: [{ data: [<%=estados[0]%>, <%=estados[1]%>, <%=estados[2]%>, <%=estados[3]%>], backgroundColor: ['#ffd600', '#fb6340', '#2dce89', '#f5365c'], borderWidth: 0 }] },
        options: { maintainAspectRatio: false, cutout: '62%', plugins: { legend: { position: 'bottom' } } }
    });
    new Chart(document.getElementById('chDeptos'), {
        type: 'bar',
        data: { labels: [<%=dLbl%>], datasets: [{ label: 'Dias', data: [<%=dVal%>], borderRadius: 6, backgroundColor: '#5e72e4' }] },
        options: { indexAxis: 'y', maintainAspectRatio: false, plugins: { legend: { display: false } },
            scales: { x: { beginAtZero: true, grid: ejes.grid }, y: { grid: { display: false } } } }
    });
    new Chart(document.getElementById('chDias'), {
        type: 'line',
        data: { labels: [<%=mLbl%>], datasets: [{ label: 'Dias', data: [<%=dM%>], borderColor: '#11cdef', backgroundColor: 'rgba(17,205,239,.15)', fill: true, tension: .35, pointRadius: 3 }] },
        options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, grid: ejes.grid }, x: { grid: { display: false } } } }
    });
})();

$(document).ready(function () {
    var HOY = new Date(<%=hoy.getYear()%>, <%=hoy.getMonthValue()-1%>, <%=hoy.getDayOfMonth()%>);
    function ymd(s) { var p = s.split('-'); return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2])); }
    function rango(y, m) { return [new Date(y, m, 1), new Date(y, m + 1, 0)]; }
    var periodo = 'MES';
    $.fn.dataTable.ext.search.push(function (settings, data, idx) {
        if (settings.nTable.id !== 'tablaPersonas') return true;
        var tr = settings.aoData[idx].nTr;
        if (tr.getAttribute('data-permiso') === '1' && !$('#chkPermisos').is(':checked')) return false;
        var d = ymd(tr.getAttribute('data-desde')), h = ymd(tr.getAttribute('data-hasta'));
        function solapa(a, b) { return h >= a && d <= b; }
        var ini = new Date(<%=anio%>, 0, 1), fin = new Date(<%=anio%>, 11, 31);
        if (periodo === 'MES')  { var r = rango(HOY.getFullYear(), HOY.getMonth()); return solapa(r[0], r[1]); }
        if (periodo === 'SIG')  { var r2 = rango(HOY.getFullYear(), HOY.getMonth() + 1); return solapa(r2[0], r2[1]); }
        if (periodo === 'ANT') {
            var primerMesActual = new Date(HOY.getFullYear(), HOY.getMonth(), 1), tope = (<%=anio%> === HOY.getFullYear()) ? new Date(primerMesActual - 86400000) : fin;
            var mes = parseInt($('#selMes').val(), 10);
            if (mes) { var r3 = rango(<%=anio%>, mes - 1); return solapa(r3[0], r3[1]) && r3[0] <= tope; }
            return h >= ini && d <= tope;
        }
        return solapa(ini, fin);
    });
    var dt = $('#tablaPersonas').DataTable({
        pageLength: 25, order: [[<%= esGlobal ? 4 : 3 %>, 'asc']],
        language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' },
        dom: "<'row'<'col-md-6'l><'col-md-6'f>><'row'<'col-md-12'tr>><'row'<'col-md-5'i><'col-md-7'p>>",
        buttons: [{ extend: 'excelHtml5', title: 'Vacaciones' }, { extend: 'pdfHtml5', title: 'Vacaciones', orientation: 'landscape' }]
    });
    $('#btnExcel').on('click', function () { dt.button(0).trigger(); });
    $('#btnPdf').on('click', function () { dt.button(1).trigger(); });
    $('#grpPeriodo button').on('click', function () {
        periodo = this.getAttribute('data-p');
        $('#grpPeriodo button').removeClass('btn-primary').addClass('btn-outline-primary');
        $(this).removeClass('btn-outline-primary').addClass('btn-primary');
        $('#selMes').toggle(periodo === 'ANT');
        dt.draw();
    });
    $('#selMes, #chkPermisos').on('change', function () { dt.draw(); });
    dt.draw();
});
</script>
</body>
</html>
