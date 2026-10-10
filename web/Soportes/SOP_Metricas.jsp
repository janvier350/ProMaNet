<%--
    Document   : SOP_Metricas
    Reportes de desempeño del area de Soportes. Pensado para supervisar
    (DNARANJO, admin). Permiso: SOPORTES_VER_METRICAS.

    Secciones:
      1) KPIs principales: tickets abiertos, mucha espera, tiempo medio
         de atencion, % cerrados sin solucion.
      2) Rendimiento por tecnico (ultimos 90 dias): atendidos, tiempo
         promedio, pendientes asignados.
      3) Equipos con mas tickets (ultimos 90 dias) -- "equipos cronicos".
      4) Usuarios que mas tickets abren (ultimos 90 dias).
      5) Tickets abiertos de mas de 3 dias -- lista para accion.
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
    private static String nz(String s, String def) { return s == null ? def : s; }
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_VER_METRICAS")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    request.setAttribute("sidenav_active", "sop_metr");

    // ---- KPIs principales ----
    long totAbiertos = 0, muchaEspera = 0, totSinSol = 0, totAtend90 = 0;
    double promHoras = 0.0, pctSinSol = 0.0;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT " +
                    "  SUM(CASE WHEN ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') AND TRUNC(SYSDATE-FECHA_SOLICITUD) >= 3 THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'CERRADO_SIN_SOLUCION' AND FECHA_REPORTE >= SYSDATE - 90 THEN 1 ELSE 0 END), " +
                    "  SUM(CASE WHEN ESTADO = 'ATENDIDO' AND FECHA_REPORTE >= SYSDATE - 90 THEN 1 ELSE 0 END) " +
                    "FROM SOP_SOPORTE_CAB");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    totAbiertos = rs.getLong(1);
                    muchaEspera = rs.getLong(2);
                    totSinSol   = rs.getLong(3);
                    totAtend90  = rs.getLong(4);
                }
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT AVG((FECHA_REPORTE - FECHA_SOLICITUD) * 24) " +
                    "FROM SOP_SOPORTE_CAB WHERE ESTADO = 'ATENDIDO' AND FECHA_REPORTE >= SYSDATE - 90");
                 ResultSet rs = st.executeQuery()) {
                if (rs.next()) promHoras = rs.getDouble(1);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    long totCerr90 = totAtend90 + totSinSol;
    if (totCerr90 > 0) pctSinSol = (totSinSol * 100.0) / totCerr90;

    // ---- Rendimiento por tecnico (ultimos 90 dias) ----
    List<Object[]> porTecnico = new ArrayList<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO) TECNICO, " +
                    "       COUNT(*) ATENDIDOS, " +
                    "       AVG((s.FECHA_REPORTE - s.FECHA_SOLICITUD) * 24) HRS, " +
                    "       SUM(CASE WHEN s.ESTADO = 'CERRADO_SIN_SOLUCION' THEN 1 ELSE 0 END) SIN_SOL " +
                    "FROM SOP_SOPORTE_CAB s " +
                    "LEFT JOIN USUARIO u ON u.IDUSUARIO = s.ID_TECNICO_ASIGNADO " +
                    "WHERE s.FECHA_REPORTE >= SYSDATE - 90 " +
                    "  AND s.ESTADO IN ('ATENDIDO','CERRADO_SIN_SOLUCION') " +
                    "  AND NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO) IS NOT NULL " +
                    "GROUP BY NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO) " +
                    "ORDER BY 2 DESC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    porTecnico.add(new Object[]{ rs.getString(1), rs.getLong(2), rs.getDouble(3), rs.getLong(4) });
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Pendientes asignados actualmente por tecnico
    Map<String, Long> pendTecnico = new HashMap<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO) TECNICO, COUNT(*) " +
                    "FROM SOP_SOPORTE_CAB s " +
                    "LEFT JOIN USUARIO u ON u.IDUSUARIO = s.ID_TECNICO_ASIGNADO " +
                    "WHERE s.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') " +
                    "  AND NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO) IS NOT NULL " +
                    "GROUP BY NVL(u.NOMBRE || ' ' || u.APELLIDOS, s.TECNICO)");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) pendTecnico.put(rs.getString(1), rs.getLong(2));
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // ---- Top equipos cronicos ----
    List<String[]> topEquipos = new ArrayList<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM ( " +
                    "  SELECT e.IDINVEQUIPO, e.MARCA || ' ' || e.MODELO EQUIPO, NVL(e.SERIAL,'-') SN, " +
                    "         COUNT(*) C " +
                    "  FROM SOP_SOPORTE_CAB s JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = s.IDEQUIPO " +
                    "  WHERE s.FECHA_SOLICITUD >= SYSDATE - 90 " +
                    "  GROUP BY e.IDINVEQUIPO, e.MARCA || ' ' || e.MODELO, e.SERIAL " +
                    "  ORDER BY 4 DESC) WHERE ROWNUM <= 10");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    topEquipos.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3), String.valueOf(rs.getLong(4))});
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // ---- Top usuarios ----
    List<String[]> topUsuarios = new ArrayList<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT * FROM ( " +
                    "  SELECT u.NOMBRE || ' ' || u.APELLIDOS, COUNT(*) " +
                    "  FROM SOP_SOPORTE_CAB s JOIN USUARIO u ON u.IDUSUARIO = s.IDUSUARIO " +
                    "  WHERE s.FECHA_SOLICITUD >= SYSDATE - 90 " +
                    "  GROUP BY u.NOMBRE || ' ' || u.APELLIDOS " +
                    "  ORDER BY 2 DESC) WHERE ROWNUM <= 10");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) topUsuarios.add(new String[]{rs.getString(1), String.valueOf(rs.getLong(2))});
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // ---- Lista mucha espera ----
    List<String[]> esperaLarga = new ArrayList<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT s.IDSOPORTE, TO_CHAR(s.FECHA_SOLICITUD,'YYYY-MM-DD') FSOL, " +
                    "       TRUNC(SYSDATE - s.FECHA_SOLICITUD) DIAS, " +
                    "       u.NOMBRE || ' ' || u.APELLIDOS SOLICITANTE, " +
                    "       e.MARCA || ' ' || e.MODELO EQUIPO, " +
                    "       s.SOPORTE, s.PRIORIDAD, s.ESTADO, " +
                    "       NVL(t.NOMBRE || ' ' || t.APELLIDOS, s.TECNICO) TECNICO " +
                    "FROM SOP_SOPORTE_CAB s " +
                    "LEFT JOIN USUARIO u ON u.IDUSUARIO = s.IDUSUARIO " +
                    "LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = s.IDEQUIPO " +
                    "LEFT JOIN USUARIO t ON t.IDUSUARIO = s.ID_TECNICO_ASIGNADO " +
                    "WHERE s.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') " +
                    "  AND TRUNC(SYSDATE - s.FECHA_SOLICITUD) >= 3 " +
                    "ORDER BY s.FECHA_SOLICITUD ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    esperaLarga.add(new String[]{
                        rs.getString(1), rs.getString(2), String.valueOf(rs.getInt(3)),
                        rs.getString(4), rs.getString(5), rs.getString(6),
                        rs.getString(7), rs.getString(8), rs.getString(9)
                    });
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Metricas Soportes</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="g-sidenav-show bg-gray-100">
<%@ include file="/_sidenav.jspf" %>
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="SOP_Dashboard.jsp">Soportes</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Metricas</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Metricas de Soportes</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

        <!-- KPIs -->
        <div class="row">
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card"><div class="card-body p-3">
                    <p class="text-sm mb-0 text-uppercase font-weight-bold">Abiertos</p>
                    <h5 class="font-weight-bolder mb-0"><%=totAbiertos%></h5>
                    <p class="mb-0 text-xs text-secondary">pendientes + en progreso</p>
                </div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card"><div class="card-body p-3">
                    <p class="text-sm mb-0 text-uppercase font-weight-bold">Mucha espera</p>
                    <h5 class="font-weight-bolder mb-0 text-danger"><%=muchaEspera%></h5>
                    <p class="mb-0 text-xs text-secondary">abiertos hace 3+ dias</p>
                </div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card"><div class="card-body p-3">
                    <p class="text-sm mb-0 text-uppercase font-weight-bold">Tiempo medio</p>
                    <h5 class="font-weight-bolder mb-0"><%=String.format(java.util.Locale.US,"%.1f",promHoras)%> h</h5>
                    <p class="mb-0 text-xs text-secondary">atencion ultimos 90d</p>
                </div></div>
            </div>
            <div class="col-lg-3 col-sm-6 mb-4">
                <div class="card"><div class="card-body p-3">
                    <p class="text-sm mb-0 text-uppercase font-weight-bold">Sin solucion</p>
                    <h5 class="font-weight-bolder mb-0"><%=String.format(java.util.Locale.US,"%.1f",pctSinSol)%>%</h5>
                    <p class="mb-0 text-xs text-secondary"><%=totSinSol%>/<%=totCerr90%> cerrados ult. 90d</p>
                </div></div>
            </div>
        </div>

        <!-- Rendimiento por tecnico -->
        <div class="card mb-4">
            <div class="card-header pb-0"><h6>Rendimiento por tecnico (ultimos 90 dias)</h6>
                <p class="text-xs text-secondary mb-0">Un tiempo promedio alto o % sin solucion alto son señales de alerta.</p>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive">
                    <table class="table align-items-center mb-0">
                        <thead><tr>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Tecnico</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Atendidos</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tiempo medio</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Sin solucion</th>
                            <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Pendientes ahora</th>
                        </tr></thead>
                        <tbody>
                        <% if (porTecnico.isEmpty()) { %>
                            <tr><td colspan="5" class="text-center text-muted py-3">Sin datos todavia.</td></tr>
                        <% } else { for (Object[] t : porTecnico) {
                            String nom = (String) t[0]; long atd = (Long) t[1];
                            double hrs = (Double) t[2]; long sin = (Long) t[3];
                            long pend = pendTecnico.getOrDefault(nom, 0L);
                            String badgeSin;
                            double pctS = atd > 0 ? sin * 100.0 / atd : 0;
                            if (pctS >= 20)      badgeSin = "bg-gradient-danger";
                            else if (pctS >= 10) badgeSin = "bg-gradient-warning";
                            else                 badgeSin = "bg-gradient-success";
                            String badgeHrs;
                            if (hrs > 48)      badgeHrs = "bg-gradient-danger";
                            else if (hrs > 24) badgeHrs = "bg-gradient-warning";
                            else               badgeHrs = "bg-gradient-success";
                        %>
                            <tr>
                                <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(nom)%></p></td>
                                <td class="text-center"><span class="badge bg-gradient-primary"><%=atd%></span></td>
                                <td class="text-center"><span class="badge <%=badgeHrs%>"><%=String.format(java.util.Locale.US,"%.1f",hrs)%> h</span></td>
                                <td class="text-center"><span class="badge <%=badgeSin%>"><%=sin%> (<%=String.format(java.util.Locale.US,"%.0f",pctS)%>%)</span></td>
                                <td class="text-center"><span class="badge <%= pend > 0 ? "bg-gradient-warning" : "bg-gradient-secondary" %>"><%=pend%></span></td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Tops -->
        <div class="row">
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Top 10 equipos con mas tickets (90d)</h6>
                        <p class="text-xs text-secondary mb-0">Equipos cronicos candidatos a reemplazo o revision profunda.</p>
                    </div>
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
                                    <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(e[1])%></p></td>
                                    <td><p class="text-xxs text-muted mb-0"><%=esc(e[2])%></p></td>
                                    <td class="text-center"><span class="badge bg-gradient-danger"><%=e[3]%></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header pb-0"><h6>Top 10 solicitantes (90d)</h6>
                        <p class="text-xs text-secondary mb-0">Usuarios que mas tickets abren -- oportunidad de capacitacion.</p>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <table class="table align-items-center mb-0">
                            <thead><tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">Usuario</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tickets</th>
                            </tr></thead>
                            <tbody>
                            <% if (topUsuarios.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center text-muted py-3">Sin datos.</td></tr>
                            <% } else { for (String[] u : topUsuarios) { %>
                                <tr>
                                    <td class="ps-3"><p class="text-xs font-weight-bold mb-0"><%=esc(u[0])%></p></td>
                                    <td class="text-center"><span class="badge bg-gradient-primary"><%=u[1]%></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mucha espera -->
        <div class="card mb-4">
            <div class="card-header pb-0"><h6>Tickets en espera larga (3+ dias)</h6>
                <p class="text-xs text-secondary mb-0">Casos que requieren atencion urgente -- click en el ticket para abrir.</p>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive">
                    <table class="table align-items-center mb-0">
                        <thead><tr>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-3">#</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Dias</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Solicitante</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Equipo</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Prioridad</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                            <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tecnico</th>
                        </tr></thead>
                        <tbody>
                        <% if (esperaLarga.isEmpty()) { %>
                            <tr><td colspan="8" class="text-center text-success py-3"><i class="fas fa-check-circle me-1"></i>¡Sin tickets en espera larga!</td></tr>
                        <% } else { for (String[] t : esperaLarga) {
                            int diasT = Integer.parseInt(t[2]);
                            String bD = diasT > 7 ? "bg-gradient-danger" : "bg-gradient-warning";
                        %>
                            <tr>
                                <td class="ps-3"><a href="SOP_AtenderTicket.jsp?idSolicitud=<%=esc(t[0])%>" class="text-xs font-weight-bold">#<%=esc(t[0])%></a></td>
                                <td><p class="text-xs mb-0"><%=esc(t[1])%></p></td>
                                <td><span class="badge <%=bD%>"><%=diasT%>d</span></td>
                                <td><p class="text-xs mb-0"><%=esc(t[3])%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(t[4])%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(t[6])%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(t[7])%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(nz(t[8],"sin asignar"))%></p></td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>
</body>
</html>
