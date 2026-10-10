<%--
    Document   : ADM_ActividadUsuarios
    Dashboard de auditoria: muestra la actividad registrada por
    LOG_ACTIVIDAD (ver docs/permisos/031_log_actividad.sql).

    Fuente de los datos:
      - Vistas de pantallas (automatico, via COMUN.ActividadFilter).
      - Acciones de negocio (manual, via COMUN.LogActividad.registrar).

    Solo accesible a usuarios con AUDIT_VER_ACTIVIDAD (concedido a
    jvaras y smoran por default). No se concede por rol.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.*"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private static String escAttr(String s) { return esc(s); }

    // Convierte un User-Agent crudo en algo corto y util: "Windows 10 / Chrome"
    // o "Android / Chrome Mobile", etc. Usa pattern-matching simple -- no
    // pretende cubrir todos los casos, solo los mas comunes para la vista.
    // El User-Agent crudo queda igual guardado en BD por si se necesita.
    private static String resumirUserAgent(String ua) {
        if (ua == null || ua.isEmpty()) return "-";
        String so, br;
        // OS
        if (ua.contains("Windows NT 10"))      so = "Windows 10/11";
        else if (ua.contains("Windows NT 6.3")) so = "Windows 8.1";
        else if (ua.contains("Windows NT 6.1")) so = "Windows 7";
        else if (ua.contains("Windows"))        so = "Windows";
        else if (ua.contains("Android"))        so = "Android";
        else if (ua.contains("iPhone") || ua.contains("iOS"))       so = "iPhone";
        else if (ua.contains("iPad"))           so = "iPad";
        else if (ua.contains("Mac OS X") || ua.contains("Macintosh")) so = "macOS";
        else if (ua.contains("Linux"))          so = "Linux";
        else                                    so = "Otro";
        // Browser (orden importa: Edge antes que Chrome, etc.)
        if (ua.contains("Edg/"))                br = "Edge";
        else if (ua.contains("OPR/") || ua.contains("Opera")) br = "Opera";
        else if (ua.contains("Firefox"))        br = "Firefox";
        else if (ua.contains("Chrome") && ua.contains("Mobile")) br = "Chrome Mobile";
        else if (ua.contains("Chrome"))         br = "Chrome";
        else if (ua.contains("Safari"))         br = "Safari";
        else                                    br = "Otro";
        return so + " / " + br;
    }

    // Detecta el tipo de dispositivo a partir del User-Agent. Mismo
    // criterio que usa HealthSchedule: Tablet antes que Celular (porque
    // los User-Agent de tablet casi siempre incluyen tambien "Mobile"
    // en Android), y Celular antes que Computadora.
    private static String detectarDispositivo(String ua) {
        if (ua == null || ua.isEmpty()) return "Otro";
        // Tablets: iPad siempre, Android sin "Mobile" tambien (los
        // telefonos Android traen "Mobile", las tablets no).
        if (ua.contains("iPad")) return "Tablet";
        if (ua.contains("Tablet")) return "Tablet";
        if (ua.contains("Android") && !ua.contains("Mobile")) return "Tablet";
        // Celulares
        if (ua.contains("iPhone")) return "Celular";
        if (ua.contains("Android") || ua.contains("Mobile")) return "Celular";
        if (ua.contains("BlackBerry") || ua.contains("Opera Mini")) return "Celular";
        // Computadoras
        if (ua.contains("Windows") || ua.contains("Mac OS X") || ua.contains("Macintosh")
                || ua.contains("Linux") || ua.contains("X11") || ua.contains("CrOS")) {
            return "Computadora";
        }
        return "Otro";
    }

    // Icono FA segun dispositivo.
    private static String iconoDispositivo(String disp) {
        if ("Celular".equals(disp)) return "fas fa-mobile-alt";
        if ("Tablet".equals(disp))  return "fas fa-tablet-alt";
        if ("Computadora".equals(disp)) return "fas fa-desktop";
        return "fas fa-question-circle";
    }
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String compania  = (String) session.getAttribute("compania");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "AUDIT_VER_ACTIVIDAD")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    // Filtros
    String fDesde = request.getParameter("fDesde");
    String fHasta = request.getParameter("fHasta");
    String fUsuario = request.getParameter("fUsuario");
    String fModulo  = request.getParameter("fModulo");
    String fAccion  = request.getParameter("fAccion");

    // Default: ultimos 7 dias
    if (fDesde == null || fDesde.trim().isEmpty()) {
        java.time.LocalDate hoy = java.time.LocalDate.now();
        fDesde = hoy.minusDays(7).toString();
        fHasta = hoy.toString();
    }

    // Resumen rapido (hoy, 7d, 30d) y acciones
    int activosHoy = 0, activos7 = 0, loginsHoy = 0, accionesHoy = 0;
    String moduloTop = "-";
    long moduloTopCnt = 0;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(DISTINCT ID_USUARIO) FROM LOG_ACTIVIDAD WHERE TRUNC(FECHA_HORA) = TRUNC(SYSDATE)");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) activosHoy = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(DISTINCT ID_USUARIO) FROM LOG_ACTIVIDAD WHERE FECHA_HORA >= SYSDATE - 7");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) activos7 = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(*) FROM LOG_ACTIVIDAD WHERE MODULO = 'LOGIN' AND TRUNC(FECHA_HORA) = TRUNC(SYSDATE)");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) loginsHoy = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT COUNT(*) FROM LOG_ACTIVIDAD WHERE TRUNC(FECHA_HORA) = TRUNC(SYSDATE)");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) accionesHoy = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM (SELECT MODULO, COUNT(*) C FROM LOG_ACTIVIDAD " +
                    " WHERE FECHA_HORA >= SYSDATE - 7 GROUP BY MODULO ORDER BY 2 DESC) WHERE ROWNUM = 1");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) { moduloTop = rs.getString(1); moduloTopCnt = rs.getLong(2); }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Agregados para graficos
    LinkedHashMap<String, Long> accionesPorDia = new LinkedHashMap<>();
    LinkedHashMap<String, Long> usoPorModulo = new LinkedHashMap<>();
    List<String[]> topUsuarios = new ArrayList<>();
    // Uso por departamento ultimos 30 dias: departamento, total usuarios
    // activos del depto, usuarios que usaron el sistema, acciones totales.
    // Incluye departamentos SIN actividad para que el admin vea quien no
    // esta usando el sistema.
    List<String[]> usoPorDepto = new ArrayList<>();

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            // Timeline ultimos 30 dias
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT TO_CHAR(FECHA_HORA,'YYYY-MM-DD') D, COUNT(*) C " +
                    "FROM LOG_ACTIVIDAD WHERE FECHA_HORA >= SYSDATE - 30 " +
                    "GROUP BY TO_CHAR(FECHA_HORA,'YYYY-MM-DD') ORDER BY 1");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) accionesPorDia.put(rs.getString(1), rs.getLong(2));
            }
            // Uso por modulo ultimos 30 dias
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT MODULO, COUNT(*) C FROM LOG_ACTIVIDAD " +
                    "WHERE FECHA_HORA >= SYSDATE - 30 GROUP BY MODULO ORDER BY 2 DESC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) usoPorModulo.put(rs.getString(1), rs.getLong(2));
            }
            // Top 10 usuarios activos ultimos 30 dias
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM ( " +
                    "  SELECT NVL(u.NOMBRE || ' ' || u.APELLIDOS, l.USUARIO_LOGIN) NOMBRE, COUNT(*) C " +
                    "  FROM LOG_ACTIVIDAD l LEFT JOIN USUARIO u ON u.IDUSUARIO = l.ID_USUARIO " +
                    "  WHERE l.FECHA_HORA >= SYSDATE - 30 AND l.ID_USUARIO IS NOT NULL " +
                    "  GROUP BY NVL(u.NOMBRE || ' ' || u.APELLIDOS, l.USUARIO_LOGIN) " +
                    "  ORDER BY 2 DESC) WHERE ROWNUM <= 10");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) topUsuarios.add(new String[]{rs.getString(1), String.valueOf(rs.getLong(2))});
            }

            // Uso por departamento ultimos 30 dias (incluye deptos sin
            // actividad). Un LEFT JOIN desde ADM_DEPARTAMENTO garantiza
            // que aparezcan incluso los que tienen 0 acciones -- eso es
            // justamente lo que queremos ver para detectar deptos que no
            // estan aprovechando el sistema.
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT d.DEPARTAMENTO, " +
                    " COUNT(DISTINCT u.IDUSUARIO) AS TOTAL_USUARIOS, " +
                    " COUNT(DISTINCT l.ID_USUARIO) AS USUARIOS_ACTIVOS, " +
                    " COUNT(l.ID_LOG) AS ACCIONES " +
                    "FROM ADM_DEPARTAMENTO d " +
                    "LEFT JOIN USUARIO u ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO AND UPPER(u.ESTADO) = 'A' " +
                    "LEFT JOIN LOG_ACTIVIDAD l ON l.ID_USUARIO = u.IDUSUARIO AND l.FECHA_HORA >= SYSDATE - 30 " +
                    "GROUP BY d.DEPARTAMENTO " +
                    "ORDER BY ACCIONES DESC, TOTAL_USUARIOS DESC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    usoPorDepto.add(new String[]{
                        rs.getString(1),
                        String.valueOf(rs.getLong(2)),
                        String.valueOf(rs.getLong(3)),
                        String.valueOf(rs.getLong(4))
                    });
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Serializar JSON basico para pasar a los charts
    StringBuilder sbDiasL = new StringBuilder(), sbDiasV = new StringBuilder();
    for (Map.Entry<String, Long> e : accionesPorDia.entrySet()) {
        if (sbDiasL.length() > 0) { sbDiasL.append(","); sbDiasV.append(","); }
        sbDiasL.append("\"").append(e.getKey()).append("\"");
        sbDiasV.append(e.getValue());
    }
    StringBuilder sbModL = new StringBuilder(), sbModV = new StringBuilder();
    for (Map.Entry<String, Long> e : usoPorModulo.entrySet()) {
        if (sbModL.length() > 0) { sbModL.append(","); sbModV.append(","); }
        sbModL.append("\"").append(e.getKey()).append("\"");
        sbModV.append(e.getValue());
    }
    StringBuilder sbDepL = new StringBuilder(), sbDepV = new StringBuilder();
    for (String[] d : usoPorDepto) {
        if (sbDepL.length() > 0) { sbDepL.append(","); sbDepV.append(","); }
        sbDepL.append("\"").append(d[0] != null ? d[0].replace("\"", "'") : "").append("\"");
        sbDepV.append(d[3]);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Actividad de Usuarios</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
<link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
<link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body class="g-sidenav-show bg-gray-100">
<%@ include file="/_sidenav.jspf" %>
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Actividad de Usuarios</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Actividad de Usuarios</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <!-- Tarjetas resumen -->
        <div class="row">
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Activos hoy</p>
                                <h5 class="font-weight-bolder mb-0"><%=activosHoy%></h5>
                                <p class="mb-0 text-xs text-secondary">usuarios distintos</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-success shadow text-center rounded-circle">
                                    <i class="fas fa-user-check text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Activos 7 dias</p>
                                <h5 class="font-weight-bolder mb-0"><%=activos7%></h5>
                                <p class="mb-0 text-xs text-secondary">usuarios distintos</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-primary shadow text-center rounded-circle">
                                    <i class="fas fa-users text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Acciones hoy</p>
                                <h5 class="font-weight-bolder mb-0"><%=accionesHoy%></h5>
                                <p class="mb-0 text-xs text-secondary"><%=loginsHoy%> logins hoy</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-info shadow text-center rounded-circle">
                                    <i class="fas fa-mouse-pointer text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Modulo top 7d</p>
                                <h5 class="font-weight-bolder mb-0"><%=esc(moduloTop)%></h5>
                                <p class="mb-0 text-xs text-secondary"><%=moduloTopCnt%> acciones</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center rounded-circle">
                                    <i class="fas fa-trophy text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Graficos -->
        <div class="row">
            <div class="col-lg-7 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Acciones por dia (ultimos 30 dias)</h6></div>
                    <div class="card-body p-3"><canvas id="chartTimeline" height="90"></canvas></div>
                </div>
            </div>
            <div class="col-lg-5 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Uso por modulo (ultimos 30 dias)</h6></div>
                    <div class="card-body p-3"><canvas id="chartModulos" height="130"></canvas></div>
                </div>
            </div>
        </div>

        <!-- Uso por departamento: ayuda a ver que areas se apoyan mas en
             el sistema y cuales todavia no lo adoptan. -->
        <div class="row">
            <div class="col-lg-5 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Uso por departamento (ultimos 30 dias)</h6>
                        <p class="text-xs text-secondary mb-0">Incluye departamentos con 0 acciones -- se ve de un vistazo quien no esta aprovechando el sistema.</p>
                    </div>
                    <div class="card-body p-3"><canvas id="chartDeptos" height="220"></canvas></div>
                </div>
            </div>
            <div class="col-lg-7 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Detalle por departamento</h6></div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive">
                            <table class="table align-items-center mb-0">
                                <thead><tr>
                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Departamento</th>
                                    <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Usuarios activos</th>
                                    <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Adopcion</th>
                                </tr></thead>
                                <tbody>
<%
    if (usoPorDepto.isEmpty()) {
%>
                                    <tr><td colspan="4" class="text-center text-muted py-3">Sin datos todavia.</td></tr>
<%
    } else {
        for (String[] d : usoPorDepto) {
            long totalUsu = Long.parseLong(d[1]);
            long usuAct   = Long.parseLong(d[2]);
            long acciones = Long.parseLong(d[3]);
            // Adopcion: usuarios activos / total usuarios del depto. Si el
            // depto no tiene usuarios, mostramos "-".
            String badgeClase, badgeTxt;
            if (totalUsu == 0) {
                badgeClase = "bg-gradient-secondary"; badgeTxt = "sin usuarios";
            } else {
                long pct = Math.round(100.0 * usuAct / totalUsu);
                if (pct == 0)         { badgeClase = "bg-gradient-danger";    badgeTxt = "0% (inactivo)"; }
                else if (pct < 50)    { badgeClase = "bg-gradient-warning";   badgeTxt = pct + "% bajo"; }
                else if (pct < 100)   { badgeClase = "bg-gradient-info";      badgeTxt = pct + "% medio"; }
                else                  { badgeClase = "bg-gradient-success";   badgeTxt = "100% todos"; }
            }
%>
                                    <tr>
                                        <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(d[0])%></p></td>
                                        <td class="text-center"><p class="text-xs mb-0"><%=usuAct%> / <%=totalUsu%></p></td>
                                        <td class="text-center"><span class="badge badge-sm bg-gradient-primary"><%=acciones%></span></td>
                                        <td class="text-center"><span class="badge badge-sm <%=badgeClase%>"><%=badgeTxt%></span></td>
                                    </tr>
<%
        }
    }
%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-5 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Top 10 usuarios activos (ultimos 30 dias)</h6></div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <table class="table align-items-center mb-0">
                            <thead><tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Usuario</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                            </tr></thead>
                            <tbody>
                            <% if (topUsuarios.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center text-muted py-3">Sin datos todavia.</td></tr>
                            <% } else {
                                 for (String[] u : topUsuarios) { %>
                                <tr>
                                    <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(u[0])%></p></td>
                                    <td class="text-center"><span class="badge badge-sm bg-gradient-primary"><%=u[1]%></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-7 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Filtrar actividad detallada</h6></div>
                    <div class="card-body p-3">
                        <form method="get" class="row g-2">
                            <div class="col-md-3">
                                <label class="text-xxs font-weight-bold text-uppercase">Desde</label>
                                <input type="date" name="fDesde" class="form-control form-control-sm" value="<%=esc(fDesde)%>">
                            </div>
                            <div class="col-md-3">
                                <label class="text-xxs font-weight-bold text-uppercase">Hasta</label>
                                <input type="date" name="fHasta" class="form-control form-control-sm" value="<%=esc(fHasta)%>">
                            </div>
                            <div class="col-md-2">
                                <label class="text-xxs font-weight-bold text-uppercase">Usuario</label>
                                <input type="text" name="fUsuario" class="form-control form-control-sm" placeholder="login o nombre" value="<%=esc(fUsuario != null ? fUsuario : "")%>">
                            </div>
                            <div class="col-md-2">
                                <label class="text-xxs font-weight-bold text-uppercase">Modulo</label>
                                <input type="text" name="fModulo" class="form-control form-control-sm" placeholder="ej. SOPORTES" value="<%=esc(fModulo != null ? fModulo : "")%>">
                            </div>
                            <div class="col-md-2">
                                <label class="text-xxs font-weight-bold text-uppercase">Accion</label>
                                <input type="text" name="fAccion" class="form-control form-control-sm" placeholder="ej. CREAR" value="<%=esc(fAccion != null ? fAccion : "")%>">
                            </div>
                            <div class="col-md-12 text-end mt-2">
                                <a href="ADM_ActividadUsuarios.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                    <i class="fa fa-eraser me-1"></i> Limpiar
                                </a>
                                <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">
                                    <i class="fa fa-search me-1"></i> Aplicar
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tabla de detalle -->
        <div class="card mb-4">
            <div class="card-header pb-0"><h6>Detalle de actividad</h6>
                <p class="text-xs text-secondary mb-0">
                    Resultados segun los filtros de arriba (default: ultimos 7 dias). Maximo 2000 filas.
                </p>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-3">
                    <table id="tablaDetalle" class="table align-items-center mb-0" style="width:100%">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Usuario</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Modulo</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Accion</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Descripcion</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">URL</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">IP</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dispositivo</th>
                            </tr>
                        </thead>
                        <tbody>
<%
    int filas = 0;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            StringBuilder sql = new StringBuilder(
                "SELECT * FROM (SELECT TO_CHAR(l.FECHA_HORA,'YYYY-MM-DD HH24:MI:SS') FH, " +
                " NVL(u.NOMBRE || ' ' || u.APELLIDOS, l.USUARIO_LOGIN) NOM, " +
                " l.USUARIO_LOGIN, l.MODULO, l.ACCION, l.DESCRIPCION, l.URL, l.IP, l.USER_AGENT " +
                "FROM LOG_ACTIVIDAD l LEFT JOIN USUARIO u ON u.IDUSUARIO = l.ID_USUARIO " +
                "WHERE 1 = 1 ");
            List<Object> params = new ArrayList<>();
            if (fDesde != null && !fDesde.trim().isEmpty()) {
                sql.append(" AND l.FECHA_HORA >= TO_DATE(?, 'YYYY-MM-DD') ");
                params.add(fDesde);
            }
            if (fHasta != null && !fHasta.trim().isEmpty()) {
                sql.append(" AND l.FECHA_HORA < TO_DATE(?, 'YYYY-MM-DD') + 1 ");
                params.add(fHasta);
            }
            if (fUsuario != null && !fUsuario.trim().isEmpty()) {
                sql.append(" AND (UPPER(l.USUARIO_LOGIN) LIKE UPPER('%' || ? || '%') ")
                   .append(" OR UPPER(u.NOMBRE || ' ' || u.APELLIDOS) LIKE UPPER('%' || ? || '%')) ");
                params.add(fUsuario); params.add(fUsuario);
            }
            if (fModulo != null && !fModulo.trim().isEmpty()) {
                sql.append(" AND UPPER(l.MODULO) = UPPER(?) ");
                params.add(fModulo);
            }
            if (fAccion != null && !fAccion.trim().isEmpty()) {
                sql.append(" AND UPPER(l.ACCION) = UPPER(?) ");
                params.add(fAccion);
            }
            sql.append(" ORDER BY l.FECHA_HORA DESC) WHERE ROWNUM <= 2000");

            try (PreparedStatement st = cn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) st.setString(i + 1, params.get(i).toString());
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        filas++;
%>
                            <tr>
                                <td><p class="text-xs mb-0"><%=esc(rs.getString(1))%></p></td>
                                <td>
                                    <p class="text-xs font-weight-bold mb-0"><%=esc(rs.getString(2))%></p>
                                    <% if (rs.getString(3) != null) { %><p class="text-xxs text-muted mb-0"><%=esc(rs.getString(3))%></p><% } %>
                                </td>
                                <td><span class="badge badge-sm bg-gradient-info"><%=esc(rs.getString(4))%></span></td>
                                <td><span class="badge badge-sm bg-gradient-secondary"><%=esc(rs.getString(5))%></span></td>
                                <td><p class="text-xs mb-0"><%=esc(rs.getString(6))%></p></td>
                                <td><p class="text-xxs text-muted mb-0"><%=esc(rs.getString(7))%></p></td>
                                <td><p class="text-xxs text-muted mb-0"><%=esc(rs.getString(8))%></p></td>
                                <td>
                                    <%
                                        String uaCrudo = rs.getString(9);
                                        String disp    = detectarDispositivo(uaCrudo);
                                        String icono   = iconoDispositivo(disp);
                                    %>
                                    <p class="text-xs font-weight-bold mb-0" title="<%=escAttr(uaCrudo)%>">
                                        <i class="<%=icono%> me-1 text-secondary"></i><%=esc(disp)%>
                                    </p>
                                    <p class="text-xxs text-muted mb-0"><%=esc(resumirUserAgent(uaCrudo))%></p>
                                </td>
                            </tr>
<%
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    if (filas == 0) {
%>
                            <tr><td colspan="8" class="text-center text-muted py-4">Sin actividad registrada para los filtros aplicados.</td></tr>
<% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    $(document).ready(function(){
        $('#tablaDetalle').DataTable({
            "pageLength": 25,
            "order": [[0, "desc"]],
            "language": { "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json" }
        });

        // Timeline
        var ctxT = document.getElementById('chartTimeline').getContext('2d');
        new Chart(ctxT, {
            type: 'line',
            data: {
                labels: [<%=sbDiasL.toString()%>],
                datasets: [{
                    label: 'Acciones',
                    data: [<%=sbDiasV.toString()%>],
                    borderColor: '#5e72e4',
                    backgroundColor: 'rgba(94,114,228,0.1)',
                    tension: 0.3,
                    fill: true,
                    pointRadius: 2
                }]
            },
            options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
        });

        // Modulos
        var ctxM = document.getElementById('chartModulos').getContext('2d');
        new Chart(ctxM, {
            type: 'bar',
            data: {
                labels: [<%=sbModL.toString()%>],
                datasets: [{
                    label: 'Acciones',
                    data: [<%=sbModV.toString()%>],
                    backgroundColor: ['#5e72e4','#2dce89','#fb6340','#11cdef','#f5365c','#8898aa','#ffd600','#6610f2','#20c997','#e83e8c']
                }]
            },
            options: { indexAxis: 'y', plugins: { legend: { display: false } }, scales: { x: { beginAtZero: true } } }
        });

        // Departamentos (mismo estilo que modulos para consistencia visual).
        var ctxD = document.getElementById('chartDeptos').getContext('2d');
        new Chart(ctxD, {
            type: 'bar',
            data: {
                labels: [<%=sbDepL.toString()%>],
                datasets: [{
                    label: 'Acciones',
                    data: [<%=sbDepV.toString()%>],
                    backgroundColor: '#5e72e4'
                }]
            },
            options: { indexAxis: 'y', plugins: { legend: { display: false } }, scales: { x: { beginAtZero: true } } }
        });
    });
</script>
</body>
</html>
