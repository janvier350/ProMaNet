<%--
    Document   : SOP_Dashboard (rediseñado)
    Reemplaza a los dos dashboards legacy (uno de 1379 lineas con la
    lista pendientes/atendidos adentro + un duplicado SOP_Dashboard_1).
    Ahora el dashboard es solo KPIs + graficos. La lista detallada vive
    en SOP_ListaTickets.jsp.

    Permisos:
      - SOPORTES_ACCESO para entrar.
      - Las tarjetas que llevan a la lista aparecen segun los permisos
        de ver pendientes / atendidos / historial.
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
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeVerPendientes = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_PENDIENTES");
    boolean puedeVerAtendidos  = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_ATENDIDOS");
    boolean puedeVerHistorial  = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_HISTORIAL");
    boolean puedeVerMetricas   = COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_METRICAS");
    boolean puedeAtender       = COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER");

    // KPIs ------------------------------------------------------------
    long pendientes = 0, enProgreso = 0, atendidosHoy = 0, atendidosMes = 0;
    long muchaEspera = 0, atendidosAnio = 0;
    double promedioHoras = 0.0;
    Map<String, Long> porMes = new LinkedHashMap<>();
    Map<String, Long> porPrioridad = new LinkedHashMap<>();
    List<String[]> topEquipos = new ArrayList<>();
    List<String[]> topSolicitantes = new ArrayList<>();

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT " +
                    "  SUM(CASE WHEN ESTADO = 'PENDIENTE' THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'EN_PROGRESO' THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'ATENDIDO' AND TRUNC(FECHA_REPORTE)=TRUNC(SYSDATE) THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'ATENDIDO' AND TRUNC(FECHA_REPORTE,'MM')=TRUNC(SYSDATE,'MM') THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') AND TRUNC(SYSDATE-FECHA_SOLICITUD) >= 3 THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'ATENDIDO' AND TRUNC(FECHA_REPORTE,'YYYY')=TRUNC(SYSDATE,'YYYY') THEN 1 ELSE 0 END) " +
                    "FROM SOP_SOPORTE_CAB");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    pendientes    = rs.getLong(1);
                    enProgreso    = rs.getLong(2);
                    atendidosHoy  = rs.getLong(3);
                    atendidosMes  = rs.getLong(4);
                    muchaEspera   = rs.getLong(5);
                    atendidosAnio = rs.getLong(6);
                }
            }

            // Promedio de horas de atencion (tickets atendidos los
            // ultimos 90 dias, para ser representativo del momento actual).
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT AVG((FECHA_REPORTE - FECHA_SOLICITUD) * 24) " +
                    "FROM SOP_SOPORTE_CAB " +
                    "WHERE ESTADO = 'ATENDIDO' AND FECHA_REPORTE >= SYSDATE - 90");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) promedioHoras = rs.getDouble(1);
            }

            // Tickets por mes (ultimos 6 meses)
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT TO_CHAR(FECHA_SOLICITUD,'YYYY-MM') M, COUNT(*) C " +
                    "FROM SOP_SOPORTE_CAB WHERE FECHA_SOLICITUD >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -5) " +
                    "GROUP BY TO_CHAR(FECHA_SOLICITUD,'YYYY-MM') ORDER BY 1");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) porMes.put(rs.getString(1), rs.getLong(2));
            }

            // Tickets por prioridad (ultimos 90 dias)
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(PRIORIDAD,'-') P, COUNT(*) C " +
                    "FROM SOP_SOPORTE_CAB WHERE FECHA_SOLICITUD >= SYSDATE - 90 " +
                    "GROUP BY PRIORIDAD ORDER BY 2 DESC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) porPrioridad.put(rs.getString(1), rs.getLong(2));
            }

            // Top 5 equipos con mas tickets (ultimos 90 dias)
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM ( " +
                    "  SELECT e.MARCA || ' ' || e.MODELO EQUIPO, NVL(e.SERIAL,'-') SN, COUNT(*) C " +
                    "  FROM SOP_SOPORTE_CAB s LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = s.IDEQUIPO " +
                    "  WHERE s.FECHA_SOLICITUD >= SYSDATE - 90 AND e.IDINVEQUIPO IS NOT NULL " +
                    "  GROUP BY e.MARCA || ' ' || e.MODELO, e.SERIAL ORDER BY 3 DESC) WHERE ROWNUM <= 5");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) topEquipos.add(new String[]{rs.getString(1), rs.getString(2), String.valueOf(rs.getLong(3))});
            }

            // Top 5 solicitantes (ultimos 90 dias)
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM ( " +
                    "  SELECT u.NOMBRE || ' ' || u.APELLIDOS, COUNT(*) C " +
                    "  FROM SOP_SOPORTE_CAB s LEFT JOIN USUARIO u ON u.IDUSUARIO = s.IDUSUARIO " +
                    "  WHERE s.FECHA_SOLICITUD >= SYSDATE - 90 " +
                    "  GROUP BY u.NOMBRE || ' ' || u.APELLIDOS ORDER BY 2 DESC) WHERE ROWNUM <= 5");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) topSolicitantes.add(new String[]{rs.getString(1), String.valueOf(rs.getLong(2))});
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Serializacion para charts
    StringBuilder sbML = new StringBuilder(), sbMV = new StringBuilder();
    for (Map.Entry<String,Long> e : porMes.entrySet()) {
        if (sbML.length() > 0) { sbML.append(","); sbMV.append(","); }
        sbML.append("\"").append(e.getKey()).append("\"");
        sbMV.append(e.getValue());
    }
    StringBuilder sbPL = new StringBuilder(), sbPV = new StringBuilder();
    for (Map.Entry<String,Long> e : porPrioridad.entrySet()) {
        if (sbPL.length() > 0) { sbPL.append(","); sbPV.append(","); }
        sbPL.append("\"").append(e.getKey().replace("\"","'")).append("\"");
        sbPV.append(e.getValue());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Dashboard Soportes</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
<link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
<link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
                    <li class="breadcrumb-item text-sm text-white active">Soportes</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Dashboard Soportes</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

        <!-- Tarjetas KPI -->
        <div class="row">
            <div class="col-lg-3 col-sm-6 mb-4">
                <a href="SOP_ListaTickets.jsp?filtrar=1&fEstado=PENDIENTE&fEstado=EN_PROGRESO&fEstado=REASIGNADO" class="text-decoration-none">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Pendientes</p>
                                <h5 class="font-weight-bolder mb-0"><%=pendientes + enProgreso%></h5>
                                <p class="mb-0 text-xs text-secondary"><%=pendientes%> sin tomar &middot; <%=enProgreso%> en progreso</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center rounded-circle">
                                    <i class="fas fa-exclamation text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </a>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <a href="SOP_ListaTickets.jsp?filtrar=1&fEsperaMas=3" class="text-decoration-none">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Mucha espera</p>
                                <h5 class="font-weight-bolder mb-0 text-danger"><%=muchaEspera%></h5>
                                <p class="mb-0 text-xs text-secondary">abiertos hace 3+ dias</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-danger shadow text-center rounded-circle">
                                    <i class="fas fa-clock text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </a>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <a href="SOP_ListaTickets.jsp?filtrar=1&fEstado=ATENDIDO" class="text-decoration-none">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Atendidos</p>
                                <h5 class="font-weight-bolder mb-0"><%=atendidosMes%></h5>
                                <p class="mb-0 text-xs text-secondary"><%=atendidosHoy%> hoy &middot; <%=atendidosAnio%> en el año</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-success shadow text-center rounded-circle">
                                    <i class="fas fa-check text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </a>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Tiempo medio</p>
                                <h5 class="font-weight-bolder mb-0"><%=String.format(java.util.Locale.US,"%.1f",promedioHoras)%> h</h5>
                                <p class="mb-0 text-xs text-secondary">atencion ultimos 90d</p>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-info shadow text-center rounded-circle">
                                    <i class="fas fa-stopwatch text-white opacity-10" style="line-height:3rem;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts -->
        <div class="row">
            <div class="col-lg-7 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Tickets por mes (ultimos 6 meses)</h6></div>
                    <div class="card-body p-3"><canvas id="chartMes" height="90"></canvas></div>
                </div>
            </div>
            <div class="col-lg-5 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Por prioridad (ultimos 90 dias)</h6></div>
                    <div class="card-body p-3"><canvas id="chartPrio" height="130"></canvas></div>
                </div>
            </div>
        </div>

        <!-- Tops -->
        <div class="row">
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Top 5 equipos con mas tickets (90d)</h6></div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <table class="table align-items-center mb-0">
                            <thead><tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Equipo</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">S/N</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tickets</th>
                            </tr></thead>
                            <tbody>
                            <% if (topEquipos.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center text-muted py-3">Sin datos.</td></tr>
                            <% } else { for (String[] e : topEquipos) { %>
                                <tr>
                                    <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(e[0])%></p></td>
                                    <td><p class="text-xxs text-muted mb-0"><%=esc(e[1])%></p></td>
                                    <td class="text-center"><span class="badge bg-gradient-primary"><%=e[2]%></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Top 5 solicitantes (90d)</h6></div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <table class="table align-items-center mb-0">
                            <thead><tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Usuario</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tickets</th>
                            </tr></thead>
                            <tbody>
                            <% if (topSolicitantes.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center text-muted py-3">Sin datos.</td></tr>
                            <% } else { for (String[] s : topSolicitantes) { %>
                                <tr>
                                    <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(s[0])%></p></td>
                                    <td class="text-center"><span class="badge bg-gradient-primary"><%=s[1]%></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
$(document).ready(function(){
    var ctxM = document.getElementById('chartMes').getContext('2d');
    new Chart(ctxM, {
        type: 'line',
        data: {
            labels: [<%=sbML.toString()%>],
            datasets: [{
                label: 'Tickets',
                data: [<%=sbMV.toString()%>],
                borderColor: '#5e72e4',
                backgroundColor: 'rgba(94,114,228,0.1)',
                tension: 0.3, fill: true, pointRadius: 3
            }]
        },
        options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    });

    var ctxP = document.getElementById('chartPrio').getContext('2d');
    new Chart(ctxP, {
        type: 'doughnut',
        data: {
            labels: [<%=sbPL.toString()%>],
            datasets: [{
                data: [<%=sbPV.toString()%>],
                backgroundColor: ['#f5365c','#fb6340','#11cdef','#2dce89','#8898aa']
            }]
        },
        options: { plugins: { legend: { position: 'bottom' } } }
    });
});
</script>
</body>
</html>
