<%--
    Document   : HOR_Cobertura
    Vista semanal de cobertura: cuantas personas del equipo NO estan disponibles por clases en cada franja de una hora, de lunes a
    sabado. Solo horarios aprobados cuya vigencia cubre ese dia. Entran jefe directo y administracion (mismo alcance que HOR_Gestion).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.*"%>
<%@page import="HORARIOS.HOR_Helper"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    String nombre = (String) session.getAttribute("nombre"), apellidos = (String) session.getAttribute("apellidos");
    int yo = -1;
    try { yo = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (yo <= 0) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("sidenav_active", "hor_gest");

    LocalDate hoy = LocalDate.now();
    LocalDate lunes = hoy.minusDays(hoy.getDayOfWeek().getValue() - 1);
    try { LocalDate p = LocalDate.parse(request.getParameter("semana")); lunes = p.minusDays(p.getDayOfWeek().getValue() - 1); } catch (Exception ignore) { }
    String depto = request.getParameter("depto") == null ? "" : request.getParameter("depto");

    HOR_Helper.Cobertura cob = new HOR_Helper.Cobertura();
    String err = null;
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (!HOR_Helper.puedeEntrarGestion(session, cn, yo)) { response.sendRedirect("../sesionInvalida.jsp"); return; }
        cob = HOR_Helper.cobertura(session, cn, yo, lunes, depto);
    } catch (Exception e) { e.printStackTrace(); err = "No se pudo cargar. ¿Se ejecutó el script 056? (" + e.getMessage() + ")"; }

    // Columnas (lunes a sabado; domingo solo si hay algo) y rango de horas (por defecto 07-18, se amplia si hay datos fuera)
    boolean hayDomingo = false; int hMin = 7, hMax = 18, maxN = 0;
    for (Map.Entry<String, TreeSet<String>> e : cob.celdas.entrySet()) {
        String[] k = e.getKey().split("\\|"); int d = Integer.parseInt(k[0]), h = Integer.parseInt(k[1]);
        if (d == 7) hayDomingo = true;
        hMin = Math.min(hMin, h); hMax = Math.max(hMax, h); maxN = Math.max(maxN, e.getValue().size());
    }
    int ndias = hayDomingo ? 7 : 6;
    DateTimeFormatter fm = DateTimeFormatter.ofPattern("dd/MM");
    DateTimeFormatter fl = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String qDepto = depto.isEmpty() ? "" : "&depto=" + java.net.URLEncoder.encode(depto, "UTF-8");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Cobertura semanal</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .cob { border-collapse:separate; border-spacing:3px; width:100%; table-layout:fixed; }
    .cob th { font-size:.75rem; text-align:center; color:#67748e; font-weight:600; padding:4px 2px; }
    .cob th.hoy { color:#344767; border-bottom:2px solid #5e72e4; }
    .cob td.h { width:60px; font-size:.72rem; color:#67748e; text-align:right; padding-right:6px; }
    .cob td.c { height:30px; text-align:center; font-size:.8rem; font-weight:700; border-radius:6px; background:#f1f3f5; color:#344767; cursor:default; }
</style>
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="HOR_Gestion.jsp">Horarios del equipo</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Cobertura</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Cobertura semanal por clases</h6>
            </nav>
            <div class="ms-auto"><span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%></span></div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (err != null) { %><div class="alert alert-danger text-white py-2"><%= esc(err) %></div><% } %>
        <div class="card">
            <div class="card-header pb-0">
                <div class="d-flex flex-wrap justify-content-between align-items-center">
                    <div>
                        <h5 class="mb-0">Semana del <%= fl.format(lunes) %> al <%= fl.format(lunes.plusDays(6)) %></h5>
                        <p class="text-sm text-secondary mb-0">Cada celda muestra cu&aacute;ntas personas no est&aacute;n disponibles por clases en esa hora. Pasa el mouse para ver qui&eacute;nes.</p>
                    </div>
                    <div class="d-flex flex-wrap gap-2 align-items-center mt-2 mt-md-0">
                        <form method="get" class="m-0">
                            <input type="hidden" name="semana" value="<%= lunes %>">
                            <select name="depto" class="form-control form-control-sm" onchange="this.form.submit()">
                                <option value="">Todos los departamentos</option>
                                <% for (String d : cob.departamentos) { %><option value="<%= esc(d) %>" <%= d.equals(depto) ? "selected" : "" %>><%= esc(d) %></option><% } %>
                            </select>
                        </form>
                        <a class="btn btn-sm btn-outline-secondary mb-0" href="HOR_Cobertura.jsp?semana=<%= lunes.minusDays(7) %><%= qDepto %>">&laquo; Anterior</a>
                        <a class="btn btn-sm btn-outline-secondary mb-0" href="HOR_Cobertura.jsp?semana=<%= hoy %><%= qDepto %>">Esta semana</a>
                        <a class="btn btn-sm btn-outline-secondary mb-0" href="HOR_Cobertura.jsp?semana=<%= lunes.plusDays(7) %><%= qDepto %>">Siguiente &raquo;</a>
                    </div>
                </div>
            </div>
            <div class="card-body">
                <% if (cob.celdas.isEmpty()) { %>
                <p class="text-sm text-secondary mb-0">Nadie de tu equipo tiene clases esta semana<%= depto.isEmpty() ? "" : " en " + esc(depto) %>.</p>
                <% } else { %>
                <div class="table-responsive">
                <table class="cob">
                    <thead><tr><th></th>
                        <% for (int d = 1; d <= ndias; d++) { LocalDate f = lunes.plusDays(d - 1); %><th class="<%= f.equals(hoy) ? "hoy" : "" %>"><%= HOR_Helper.DIAS_CORTO[d] %> <%= fm.format(f) %></th><% } %>
                    </tr></thead>
                    <tbody>
                    <% for (int h = hMin; h <= hMax; h++) { %>
                    <tr><td class="h"><%= String.format("%02d:00", h) %></td>
                        <% for (int d = 1; d <= ndias; d++) {
                               TreeSet<String> n = cob.celdas.get(d + "|" + h);
                               int cnt = n == null ? 0 : n.size();
                               String estilo = cnt == 0 ? "" : "background:rgba(94,114,228," + String.format(java.util.Locale.US, "%.2f", 0.25 + 0.75 * cnt / (double) maxN) + ");color:" + (cnt * 2 >= maxN ? "#fff" : "#344767") + ";";
                        %><td class="c" style="<%= estilo %>" <%= cnt > 0 ? "title=\"" + esc(String.join(", ", n)) + "\"" : "" %>><%= cnt > 0 ? String.valueOf(cnt) : "" %></td><% } %>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
                <p class="text-xs text-secondary mt-3 mb-0"><b><%= cob.personas.size() %></b> <%= cob.personas.size() == 1 ? "persona tiene" : "personas tienen" %> clases esta semana. El color m&aacute;s fuerte indica m&aacute;s personas fuera a la vez (m&aacute;ximo: <%= maxN %>).</p>
                <% } %>
            </div>
        </div>
    </div>
</main>
<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
</body>
</html>
