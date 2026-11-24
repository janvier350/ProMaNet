<%--
    Document   : HOR_MisClases
    Horario de clases del propio usuario (cualquier usuario logueado, sin permisos especiales): registra los dias y horas de la
    semana en que no estara disponible en la oficina, durante un semestre. La solicitud la aprueba su jefe directo o la
    administracion (gestores de Vacaciones de su grupo). Ver tambien HOR_Gestion.jsp.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.*"%>
<%@page import="HORARIOS.HOR_Helper"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
    private static String[] estado(HOR_Helper.Solicitud s) {   // {texto, color}
        switch (s.estado) {
            case "PENDIENTE":   return new String[]{"Pendiente de aprobación", "warning"};
            case "APROBADO":    return s.vigenteHoy() ? new String[]{"Aprobado · vigente", "success"} : (s.hasta.isBefore(LocalDate.now()) ? new String[]{"Aprobado · terminó", "secondary"} : new String[]{"Aprobado · aún no inicia", "info"});
            case "RECHAZADO":   return new String[]{"Rechazado", "danger"};
            case "CANCELADO":   return new String[]{"Cancelado", "secondary"};
            default:            return new String[]{s.estado, "secondary"};
        }
    }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    String nombre = (String) session.getAttribute("nombre"), apellidos = (String) session.getAttribute("apellidos");
    int yo = -1;
    try { yo = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (yo <= 0) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("sidenav_active", "hor_mis");

    String msg = request.getParameter("msj"), err = null;
    boolean puedeGestion = false;
    List<HOR_Helper.Solicitud> lista = new ArrayList<>();
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    try (Connection cn = Servlets.Conexion.getConnection()) {
        puedeGestion = HOR_Helper.puedeEntrarGestion(session, cn, yo);
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String accion = request.getParameter("accion");
            try {
                if ("crear".equals(accion)) {
                    LocalDate d = LocalDate.parse(request.getParameter("desde")), h = LocalDate.parse(request.getParameter("hasta"));
                    int id = HOR_Helper.crear(cn, yo, yo, d, h, request.getParameter("obs"), HOR_Helper.leerBloques(request), false);
                    COMUN.LogActividad.registrar(request, "HORARIOS", "CREAR", "Registro horario de clases #" + id);
                    response.sendRedirect("HOR_MisClases.jsp?msj=" + java.net.URLEncoder.encode("Solicitud enviada. Queda pendiente de aprobación de tu jefe directo o de administración.", "UTF-8"));
                    return;
                } else if ("cancelar".equals(accion)) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Object[] b = HOR_Helper.datosBasicos(cn, id);
                    if (b == null || (Integer) b[0] != yo) throw new IllegalArgumentException("Solicitud no válida.");
                    HOR_Helper.cancelar(cn, id, false);
                    COMUN.LogActividad.registrar(request, "HORARIOS", "ELIMINAR", "Cancelo horario de clases #" + id);
                    response.sendRedirect("HOR_MisClases.jsp?msj=" + java.net.URLEncoder.encode("Solicitud cancelada.", "UTF-8"));
                    return;
                }
            } catch (IllegalArgumentException | java.time.format.DateTimeParseException ex) {
                err = ex instanceof java.time.format.DateTimeParseException ? "Revisa las fechas." : ex.getMessage();
            }
        }
        lista = HOR_Helper.delUsuario(cn, yo);
    } catch (Exception e) {
        e.printStackTrace();
        err = "No se pudo cargar tu horario. ¿Se ejecutó el script 056? (" + e.getMessage() + ")";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Horario de clases</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
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
                    <li class="breadcrumb-item text-sm text-white active">Horario de clases</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Mi horario de clases</h6>
            </nav>
            <div class="ms-auto"><span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%></span></div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (msg != null) { %><div class="alert alert-success text-white py-2"><i class="fas fa-check-circle me-1"></i><%= esc(msg) %></div><% } %>
        <% if (err != null) { %><div class="alert alert-danger text-white py-2"><i class="fas fa-exclamation-circle me-1"></i><%= esc(err) %></div><% } %>

        <div class="row">
            <div class="col-lg-5 mb-4">
                <div class="card h-100">
                    <div class="card-header pb-0">
                        <h5 class="mb-0">Registrar mi horario</h5>
                        <p class="text-sm text-secondary mb-0">Si estudias, indica los d&iacute;as y horas en que no estar&aacute;s en la oficina. Lo aprueba tu jefe directo o administraci&oacute;n.</p>
                    </div>
                    <div class="card-body">
                        <form method="post">
                            <input type="hidden" name="accion" value="crear">
                            <%@ include file="_hor_bloques.jspf" %>
                            <div class="text-end mt-3"><button class="btn bg-gradient-primary mb-0"><i class="fas fa-paper-plane me-1"></i> Enviar solicitud</button></div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-7 mb-4">
                <div class="card h-100">
                    <div class="card-header pb-0 d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h5 class="mb-0">Mis solicitudes</h5>
                            <p class="text-sm text-secondary mb-0">Si cambia tu horario, registra uno nuevo: el anterior sigue vigente hasta que aprueben el nuevo.</p>
                        </div>
                        <% if (puedeGestion) { %><a href="HOR_Gestion.jsp" class="btn btn-sm btn-outline-primary mb-0"><i class="fas fa-users me-1"></i> Horarios de mi equipo</a><% } %>
                    </div>
                    <div class="card-body">
                        <% if (lista.isEmpty()) { %>
                        <div class="text-center text-secondary py-4"><i class="far fa-calendar fa-2x mb-2"></i><p class="mb-0">A&uacute;n no has registrado un horario de clases.</p></div>
                        <% } %>
                        <% for (HOR_Helper.Solicitud s : lista) { String[] est = estado(s); %>
                        <div class="border rounded p-3 mb-3">
                            <div class="d-flex justify-content-between align-items-start flex-wrap">
                                <div>
                                    <span class="badge bg-gradient-<%= est[1] %>"><%= est[0] %></span>
                                    <span class="text-sm ms-2"><b><%= fmt.format(s.desde) %></b> al <b><%= fmt.format(s.hasta) %></b></span>
                                    <% if (s.registradoPorOtro) { %><span class="text-xs text-secondary ms-2">(registrado por <%= esc(s.registradoPor) %>)</span><% } %>
                                </div>
                                <% if ("PENDIENTE".equals(s.estado)) { %>
                                <form method="post" class="m-0" onsubmit="return confirm('¿Cancelar esta solicitud?');">
                                    <input type="hidden" name="accion" value="cancelar"><input type="hidden" name="id" value="<%= s.id %>">
                                    <button class="btn btn-sm btn-link text-danger mb-0 p-0">Cancelar</button>
                                </form>
                                <% } %>
                            </div>
                            <ul class="mb-1 mt-2 ps-3">
                                <% for (String l : HOR_Helper.resumen(s.bloques)) { %><li class="text-sm"><%= esc(l) %></li><% } %>
                            </ul>
                            <% if (s.observacion != null && !s.observacion.isEmpty()) { %><p class="text-xs text-secondary mb-0"><%= esc(s.observacion) %></p><% } %>
                            <% if ("RECHAZADO".equals(s.estado)) { %><p class="text-xs text-danger mb-0 mt-1">Motivo: <%= esc(s.motivoRechazo) %><%= s.apruebaNombre != null ? " (" + esc(s.apruebaNombre) + ")" : "" %></p><% } %>
                            <% if ("APROBADO".equals(s.estado) && s.apruebaNombre != null) { %><p class="text-xs text-secondary mb-0 mt-1">Aprobado por <%= esc(s.apruebaNombre) %></p><% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
</body>
</html>
