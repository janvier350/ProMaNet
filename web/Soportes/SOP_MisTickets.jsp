<%--
    Document   : SOP_MisTickets
    Pantalla para que CUALQUIER usuario logueado consulte sus propios
    tickets de soporte, el estado actual y el avance de la atencion.
    No requiere permisos de Soportes (esos son para gestionar).

    Dos modos en una misma pagina:
      - Sin parametros     -> lista de mis tickets (abiertos primero).
      - ?idSolicitud=N     -> detalle del ticket N con su linea de tiempo.

    Seguridad: toda consulta lleva "AND IDUSUARIO = <usuario de sesion>",
    asi nadie puede abrir el ticket de otro cambiando el id en la URL.
    Solo lectura: no hay botones de atender/reasignar/eliminar.

    Privacidad de la linea de tiempo: el usuario solo ve los eventos
    pensados para el (diagnostico, intentos, cierre, reapertura). Las
    notas internas, escalamientos y reasignaciones entre tecnicos NO se
    muestran.
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
    private static String cortar(String s, int n) {
        if (s == null) return "";
        s = s.replaceAll("\\s+", " ").trim();
        return s.length() <= n ? s : s.substring(0, n) + "...";
    }
    private static String estadoTexto(String e) {
        if (e == null) return "-";
        switch (e) {
            case "PENDIENTE":            return "Recibido - en espera";
            case "EN_PROGRESO":          return "En atencion";
            case "REASIGNADO":           return "En espera de tecnico";
            case "ATENDIDO":             return "Resuelto";
            case "CERRADO_SIN_SOLUCION": return "Cerrado sin solucion";
            case "CANCELADO_USR":        return "Cancelado";
            default:                     return e;
        }
    }
    private static String estadoBadge(String e) {
        if (e == null) return "bg-gradient-secondary";
        switch (e) {
            case "PENDIENTE":            return "bg-gradient-warning";
            case "EN_PROGRESO":          return "bg-gradient-info";
            case "REASIGNADO":           return "bg-gradient-warning";
            case "ATENDIDO":             return "bg-gradient-success";
            case "CERRADO_SIN_SOLUCION": return "bg-gradient-dark";
            default:                     return "bg-gradient-secondary";
        }
    }
    private static String estadoMensaje(String e) {
        if (e == null) return "";
        switch (e) {
            case "PENDIENTE":            return "Tu solicitud fue recibida. El equipo de Sistemas la atendera en cuanto sea posible.";
            case "EN_PROGRESO":          return "Un tecnico ya esta trabajando en tu solicitud.";
            case "REASIGNADO":           return "Tu solicitud esta en cola para ser atendida por un tecnico.";
            case "ATENDIDO":             return "Tu solicitud fue resuelta. Si el problema continua, crea un nuevo ticket indicandolo.";
            case "CERRADO_SIN_SOLUCION": return "El equipo reviso tu solicitud pero no pudo resolverla. Revisa el detalle abajo.";
            case "CANCELADO_USR":        return "Este ticket fue cancelado.";
            default:                     return "";
        }
    }
    // [icono, color, titulo] por tipo de incidencia visible al usuario; null = oculto
    private static String[] tipoVisible(String t) {
        if (t == null) return null;
        switch (t) {
            case "DIAGNOSTICO":         return new String[]{"fa-search", "info", "Diagnostico"};
            case "INTENTO":             return new String[]{"fa-wrench", "warning", "Se realizo una accion"};
            case "CIERRE":              return new String[]{"fa-check", "success", "Resuelto"};
            case "CIERRE_SIN_SOLUCION": return new String[]{"fa-ban", "dark", "Cerrado sin solucion"};
            case "REAPERTURA":          return new String[]{"fa-redo", "warning", "Ticket reabierto"};
            default:                    return null; // NOTA, ESCALAMIENTO, REASIGNACION: internos
        }
    }
%>
<%
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigoStr = (String) session.getAttribute("cod");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    int idUsuario = -1;
    try { idUsuario = Integer.parseInt(codigoStr.trim()); } catch (Exception ignore) {}
    if (idUsuario <= 0) { response.sendRedirect("../sesionInvalida.jsp"); return; }

    request.setAttribute("sidenav_active", "sop_mis");

    int idDetalle = -1;
    try { idDetalle = Integer.parseInt(request.getParameter("idSolicitud").trim()); } catch (Exception ignore) {}
    boolean modoDetalle = idDetalle > 0;

    // ---- Lista ----
    List<String[]> lista = new ArrayList<>();
    // ---- Detalle ----
    String dFecha="", dEquipo="", dSop="", dPrio="", dEstado="", dTecnico="", dReporte="", dFechaRep="";
    boolean dEncontrado = false;
    List<String[]> eventos = new ArrayList<>();

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            if (!modoDetalle) {
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT * FROM (" +
                        " SELECT a.IDSOPORTE, TO_CHAR(a.FECHA_SOLICITUD,'YYYY-MM-DD HH24:MI'), a.SOPORTE, " +
                        "        a.PRIORIDAD, a.ESTADO, e.MARCA || ' ' || e.MODELO, " +
                        "        t.NOMBRE || ' ' || t.APELLIDOS " +
                        " FROM SOP_SOPORTE_CAB a " +
                        " LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDEQUIPO " +
                        " LEFT JOIN USUARIO t ON t.IDUSUARIO = a.ID_TECNICO_ASIGNADO " +
                        " WHERE a.IDUSUARIO = ? " +
                        " ORDER BY CASE WHEN a.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') THEN 0 ELSE 1 END, " +
                        "          a.FECHA_SOLICITUD DESC) " +
                        "WHERE ROWNUM <= 200")) {
                    st.setInt(1, idUsuario);
                    try (ResultSet rs = st.executeQuery()) {
                        while (rs.next()) {
                            lista.add(new String[]{
                                rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4),
                                rs.getString(5), rs.getString(6), rs.getString(7)});
                        }
                    }
                }
            } else {
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT TO_CHAR(a.FECHA_SOLICITUD,'YYYY-MM-DD HH24:MI'), e.MARCA || ' ' || e.MODELO, " +
                        "       a.SOPORTE, a.PRIORIDAD, a.ESTADO, t.NOMBRE || ' ' || t.APELLIDOS, " +
                        "       a.REPORTE, TO_CHAR(a.FECHA_REPORTE,'YYYY-MM-DD HH24:MI') " +
                        "FROM SOP_SOPORTE_CAB a " +
                        "LEFT JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDEQUIPO " +
                        "LEFT JOIN USUARIO t ON t.IDUSUARIO = a.ID_TECNICO_ASIGNADO " +
                        "WHERE a.IDSOPORTE = ? AND a.IDUSUARIO = ? AND ROWNUM = 1")) {
                    st.setInt(1, idDetalle);
                    st.setInt(2, idUsuario);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            dEncontrado = true;
                            dFecha = rs.getString(1); dEquipo = rs.getString(2); dSop = rs.getString(3);
                            dPrio = rs.getString(4); dEstado = rs.getString(5); dTecnico = rs.getString(6);
                            dReporte = rs.getString(7); dFechaRep = rs.getString(8);
                        }
                    }
                }
                if (dEncontrado) {
                    try (PreparedStatement st = cn.prepareStatement(
                            "SELECT TO_CHAR(i.FECHA_HORA,'YYYY-MM-DD HH24:MI'), " +
                            "       NVL(u.NOMBRE || ' ' || u.APELLIDOS, i.USUARIO_LOGIN), i.TIPO, i.DESCRIPCION " +
                            "FROM SOP_SOPORTE_INCIDENCIA i " +
                            "LEFT JOIN USUARIO u ON u.IDUSUARIO = i.ID_USUARIO " +
                            "WHERE i.IDSOPORTE = ? ORDER BY i.FECHA_HORA DESC, i.ID_INCIDENCIA DESC")) {
                        st.setInt(1, idDetalle);
                        try (ResultSet rs = st.executeQuery()) {
                            while (rs.next()) {
                                if (tipoVisible(rs.getString(3)) != null) {
                                    eventos.add(new String[]{rs.getString(1), rs.getString(2),
                                                             rs.getString(3), rs.getString(4)});
                                }
                            }
                        }
                    } catch (Exception ex) {
                        // La tabla de incidencias puede no existir aun: se muestra solo el estado.
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Ticket cerrado sin incidencias registradas (tickets anteriores a la
    // linea de tiempo): se muestra el reporte tecnico guardado en el ticket.
    boolean cerradoSinEventos = eventos.isEmpty() && dReporte != null
            && !dReporte.trim().isEmpty() && !"SIN REPORTE".equalsIgnoreCase(dReporte.trim())
            && ("ATENDIDO".equals(dEstado) || "CERRADO_SIN_SOLUCION".equals(dEstado));
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Mis tickets</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .tl { position: relative; padding-left: 2.6rem; }
    .tl::before { content:''; position:absolute; left:1.05rem; top:0; bottom:0; width:2px; background:#e9ecef; }
    .tl-item { position: relative; margin-bottom: 1.2rem; }
    .tl-dot { position:absolute; left:-2.6rem; top:0; width:2.1rem; height:2.1rem; border-radius:50%;
              display:flex; align-items:center; justify-content:center; color:#fff; font-size:.8rem; }
    .fila-ticket { cursor:pointer; }
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
                    <li class="breadcrumb-item text-sm"><a class="<%= modoDetalle ? "opacity-5 " : "" %>text-white" href="SOP_MisTickets.jsp">Mis tickets</a></li>
                    <% if (modoDetalle) { %><li class="breadcrumb-item text-sm text-white active">Ticket #<%=idDetalle%></li><% } %>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0"><%= modoDetalle ? "Ticket #" + idDetalle : "Mis tickets de soporte" %></h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=esc(nombre)%> <%=esc(apellidos)%>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">

<% if (!modoDetalle) { %>
        <div class="card">
            <div class="card-header pb-0 d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h5 class="mb-0">Mis solicitudes</h5>
                    <p class="text-sm text-secondary mb-0">Aqui ves el estado de los tickets que has creado o que se crearon a tu nombre.</p>
                </div>
                <a href="SOP_NuevoTicket.jsp" class="btn bg-gradient-primary btn-sm mb-0 mt-2 mt-md-0">
                    <i class="fas fa-plus me-1"></i> Nuevo ticket
                </a>
            </div>
            <div class="card-body px-0 pt-3 pb-2">
                <% if (lista.isEmpty()) { %>
                <div class="text-center text-secondary py-5">
                    <i class="far fa-folder-open fa-2x mb-2"></i>
                    <p class="mb-0">Aun no tienes tickets de soporte.</p>
                </div>
                <% } else { %>
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder ps-4"># / Fecha</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Problema</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Equipo</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center">Estado</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder">Atiende</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (String[] r : lista) { %>
                            <tr class="fila-ticket" onclick="location.href='SOP_MisTickets.jsp?idSolicitud=<%=esc(r[0])%>'">
                                <td class="ps-4">
                                    <p class="text-sm font-weight-bold mb-0">#<%=esc(r[0])%></p>
                                    <p class="text-xs text-secondary mb-0"><%=esc(r[1])%></p>
                                </td>
                                <td><p class="text-sm mb-0"><%=esc(cortar(r[2], 90))%></p></td>
                                <td><p class="text-xs mb-0"><%=esc(r[5])%></p></td>
                                <td class="text-center"><span class="badge badge-sm <%=estadoBadge(r[4])%>"><%=esc(estadoTexto(r[4]))%></span></td>
                                <td><p class="text-xs mb-0"><%= (r[6] == null || r[6].trim().isEmpty()) ? "-" : esc(r[6]) %></p></td>
                                <td class="text-end pe-4"><a href="SOP_MisTickets.jsp?idSolicitud=<%=esc(r[0])%>" class="btn btn-link text-secondary mb-0 px-2" title="Ver detalle"><i class="fas fa-eye"></i></a></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>

<% } else if (!dEncontrado) { %>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="fas fa-search fa-2x text-secondary mb-2"></i>
                <h6>No encontramos ese ticket</h6>
                <p class="text-sm text-secondary">No existe o no pertenece a tu usuario.</p>
                <a href="SOP_MisTickets.jsp" class="btn bg-gradient-primary btn-sm">Volver a mis tickets</a>
            </div>
        </div>

<% } else { %>
        <div class="row">
            <div class="col-lg-5 mb-4">
                <div class="card h-100">
                    <div class="card-body">
                        <span class="badge <%=estadoBadge(dEstado)%> mb-2"><%=esc(estadoTexto(dEstado))%></span>
                        <p class="text-sm text-secondary"><%=esc(estadoMensaje(dEstado))%></p>
                        <hr class="horizontal dark my-3">
                        <p class="text-xs text-uppercase text-secondary font-weight-bold mb-1">Lo que reportaste</p>
                        <p class="text-sm" style="white-space:pre-wrap;"><%=esc(dSop)%></p>
                        <ul class="list-unstyled text-sm mb-0">
                            <li class="mb-1"><span class="text-secondary">Fecha:</span> <%=esc(dFecha)%></li>
                            <li class="mb-1"><span class="text-secondary">Equipo:</span> <%= (dEquipo == null || dEquipo.trim().isEmpty()) ? "-" : esc(dEquipo) %></li>
                            <li class="mb-1"><span class="text-secondary">Prioridad:</span> <%=esc(dPrio)%></li>
                            <li class="mb-1"><span class="text-secondary">Atiende:</span> <%= (dTecnico == null || dTecnico.trim().isEmpty()) ? "Aun sin asignar" : esc(dTecnico) %></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="col-lg-7 mb-4">
                <div class="card h-100">
                    <div class="card-header pb-0"><h6 class="mb-0">Avance de la atencion</h6></div>
                    <div class="card-body">
                        <div class="tl">
                            <% for (String[] ev : eventos) { String[] tv = tipoVisible(ev[2]); %>
                            <div class="tl-item">
                                <span class="tl-dot bg-gradient-<%=tv[1]%>"><i class="fas <%=tv[0]%>"></i></span>
                                <h6 class="text-sm mb-0"><%=tv[2]%></h6>
                                <p class="text-xs text-secondary mb-1"><%=esc(ev[0])%> &middot; <%=esc(ev[1])%></p>
                                <p class="text-sm mb-0" style="white-space:pre-wrap;"><%=esc(ev[3])%></p>
                            </div>
                            <% } %>
                            <% if (cerradoSinEventos) { %>
                            <div class="tl-item">
                                <span class="tl-dot bg-gradient-<%= "ATENDIDO".equals(dEstado) ? "success" : "dark" %>"><i class="fas <%= "ATENDIDO".equals(dEstado) ? "fa-check" : "fa-ban" %>"></i></span>
                                <h6 class="text-sm mb-0"><%= "ATENDIDO".equals(dEstado) ? "Resuelto" : "Cerrado sin solucion" %></h6>
                                <p class="text-xs text-secondary mb-1"><%=esc(dFechaRep)%></p>
                                <p class="text-sm mb-0" style="white-space:pre-wrap;"><%=esc(dReporte)%></p>
                            </div>
                            <% } %>
                            <div class="tl-item mb-0">
                                <span class="tl-dot bg-gradient-primary"><i class="fas fa-paper-plane"></i></span>
                                <h6 class="text-sm mb-0">Solicitud recibida</h6>
                                <p class="text-xs text-secondary mb-0"><%=esc(dFecha)%></p>
                            </div>
                        </div>
                        <% if (eventos.isEmpty() && !cerradoSinEventos) { %>
                        <p class="text-xs text-secondary mt-3 mb-0">Aun no hay novedades. Te mostraremos aqui cada avance del tecnico.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <a href="SOP_MisTickets.jsp" class="btn btn-outline-secondary btn-sm"><i class="fas fa-arrow-left me-1"></i> Volver a mis tickets</a>
<% } %>

    </div>
</main>
<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
</body>
</html>
