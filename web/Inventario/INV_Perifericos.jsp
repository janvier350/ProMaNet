<%--
    Document   : Listado de perifericos (mouse, teclado, cargador, etc.)
    Cada periferico es una unidad fisica con identidad propia -- se puede
    entregar, devolver o reemplazar. Se asigna a un USUARIO (no a un
    equipo): si el usuario cambia de laptop, sus perifericos siguen con
    el, que es como funciona en la realidad.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%!
    // Escapa un valor para poder ponerlo dentro de un atributo HTML sin
    // que una comilla, & o < dentro del texto rompa el atributo o el
    // HTML de la fila entera (mismo helper que se uso en INV_Equipos.jsp).
    private String escAttr(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("\"", "&quot;")
                .replace("'", "&#39;").replace("<", "&lt;").replace(">", "&gt;");
    }
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
%>
<%
    String compania  = (String) session.getAttribute("compania");
    String cargo     = (String) session.getAttribute("cargo");
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_VER")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet - Perifericos</title>
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
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="INV_Equipos.jsp">Inventario</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Perifericos</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Perifericos</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                    <span class="text-body text-white-50"><i class="fas fa-home"></i> <%=compania%></span>
                </div>
                <ul class="navbar-nav justify-content-end">
                    <li class="nav-item d-flex align-items-center">
                        <span class="nav-link text-white font-weight-bold px-0">
                            <i class="fa fa-user me-sm-1"></i>
                            <span class="d-sm-inline d-none"><b><%=nombre%> <%=apellidos%></b></span>
                        </span>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <% if (request.getParameter("msj") != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%=esc(request.getParameter("msj"))%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%=esc(request.getParameter("error"))%>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h6 class="mb-0"><i class="fa fa-plug me-2 text-secondary"></i>Lista de Perifericos</h6>
                            <p class="text-xs text-secondary mb-0">Mouse, teclado, cargador, docking, etc. -- se asignan a un usuario, con acta de entrega firmable.</p>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <input type="text" id="buscarPerif" class="form-control form-control-sm" placeholder="Buscar..." style="max-width:220px;">
                            <select id="filtroTipo" class="form-control form-control-sm" style="max-width:180px;">
                                <option value="">Todos los tipos</option>
                                <%
                                    try (Connection cnT = Servlets.Conexion.getConnection()) {
                                        if (cnT != null) {
                                            try (PreparedStatement stT = cnT.prepareStatement(
                                                    "SELECT ID_TIPO, DESCRIPCION FROM INV_PERIFERICO_TIPO WHERE ESTADO='A' ORDER BY DESCRIPCION");
                                                 ResultSet rsT = stT.executeQuery()) {
                                                while (rsT.next()) {
                                %>
                                <option value="<%=esc(rsT.getString(2))%>"><%=esc(rsT.getString(2))%></option>
                                <% } } } } catch (Exception e) { e.printStackTrace(); } %>
                            </select>
                            <select id="filtroEstado" class="form-control form-control-sm" style="max-width:160px;">
                                <option value="">Todos los estados</option>
                                <option value="Disponible">Disponible</option>
                                <option value="Asignado">Asignado</option>
                                <option value="Backup">Backup</option>
                                <option value="Fuera de servicio">Fuera de servicio</option>
                                <option value="Baja">Baja</option>
                            </select>
                            <% if (puedeGestionar) { %>
                            <a class="btn btn-primary btn-sm mb-0" href="INV_Periferico_Editar.jsp">
                                <i class="fa fa-plus me-1"></i> Nuevo periferico
                            </a>
                            <% } %>
                        </div>
                    </div>
                    <div class="card-body px-0 pt-0 pb-2">
                        <div class="table-responsive p-3">
                            <table class="table align-items-center mb-0" id="tablaPerif">
                                <thead>
                                    <tr>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">ID</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tipo</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Marca / Modelo / Serial</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">F. Compra</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Oficina</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Asignado a</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Foto</th>
                                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection cn = Servlets.Conexion.getConnection()) {
                                            if (cn != null) {
                                                try (PreparedStatement st = cn.prepareStatement(
                                                        "SELECT p.ID_PERIFERICO, t.DESCRIPCION AS tipo, p.MARCA, p.MODELO, p.SERIAL, " +
                                                        "TO_CHAR(p.FECHACOMPRA,'DD/MM/YYYY') AS fcompra, p.UBICACIONOFICINA, " +
                                                        "p.ESTADO, p.OBSERVACIONES, " +
                                                        "u.NOMBRE || ' ' || u.APELLIDOS AS asignado, " +
                                                        "a.ID_ASIGNACION, u.IDUSUARIO " +
                                                        "FROM INV_PERIFERICO p " +
                                                        "JOIN INV_PERIFERICO_TIPO t ON t.ID_TIPO = p.ID_TIPO " +
                                                        "LEFT JOIN INV_PERIFERICO_ASIGNACION a ON a.ID_PERIFERICO = p.ID_PERIFERICO AND a.ESTADO = 'A' " +
                                                        "LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
                                                        "WHERE p.ESTADO_AI = 'A' " +
                                                        "ORDER BY p.ID_PERIFERICO DESC");
                                                     ResultSet rs = st.executeQuery()) {
                                                    boolean hay = false;
                                                    while (rs.next()) {
                                                        hay = true;
                                                        String idPerif  = rs.getString(1);
                                                        String tipo     = rs.getString(2);
                                                        String marca    = rs.getString(3) != null ? rs.getString(3) : "";
                                                        String modelo   = rs.getString(4) != null ? rs.getString(4) : "";
                                                        String serial   = rs.getString(5) != null ? rs.getString(5) : "";
                                                        String fcompra  = rs.getString(6);
                                                        String oficina  = rs.getString(7);
                                                        String estado   = rs.getString(8);
                                                        String obs      = rs.getString(9);
                                                        String asignado = rs.getString(10);
                                                        String estadoTxt;
                                                        String badgeClase;
                                                        switch (estado) {
                                                            case "A":  estadoTxt = "Asignado";          badgeClase = "bg-gradient-warning"; break;
                                                            case "D":  estadoTxt = "Disponible";        badgeClase = "bg-gradient-success"; break;
                                                            case "BK": estadoTxt = "Backup";            badgeClase = "bg-gradient-info";    break;
                                                            case "F":  estadoTxt = "Fuera de servicio"; badgeClase = "bg-gradient-danger";  break;
                                                            case "X":  estadoTxt = "Baja";              badgeClase = "bg-gradient-dark";    break;
                                                            default:   estadoTxt = estado;              badgeClase = "bg-gradient-secondary";
                                                        }
                                    %>
                                    <tr class="fila-perif" data-search="<%=escAttr((tipo + " " + marca + " " + modelo + " " + serial + " " + (asignado != null ? asignado : "")).toLowerCase())%>"
                                        data-tipo="<%=escAttr(tipo)%>" data-estado="<%=escAttr(estadoTxt)%>">
                                        <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=idPerif%></p></td>
                                        <td><span class="badge border text-dark text-xxs"><%=esc(tipo)%></span></td>
                                        <td>
                                            <p class="text-xs font-weight-bold mb-0"><%=esc(marca)%> <%=esc(modelo)%></p>
                                            <% if (!serial.isEmpty()) { %>
                                            <p class="text-xxs text-secondary mb-0">S/N: <%=esc(serial)%></p>
                                            <% } %>
                                        </td>
                                        <td><p class="text-xs mb-0"><%=fcompra != null ? fcompra : "-"%></p></td>
                                        <td><p class="text-xs mb-0"><%=esc(oficina != null ? oficina : "-")%></p></td>
                                        <td class="text-center"><span class="badge badge-sm <%=badgeClase%>"><%=estadoTxt%></span></td>
                                        <td>
                                            <p class="text-xs mb-0"><%=asignado != null ? esc(asignado) : "-"%></p>
                                        </td>
                                        <td class="text-center">
                                            <img src="../INV_MostrarImagenPeriferico?nombre=perif_<%=idPerif%>"
                                                 class="rounded border shadow-xs"
                                                 style="height:36px;width:54px;object-fit:cover;cursor:pointer;"
                                                 onerror="this.style.display='none';"
                                                 onclick="window.open(this.src, '_blank')">
                                        </td>
                                        <td class="text-center">
                                            <% if (puedeGestionar) { %>
                                            <div class="d-flex flex-column gap-1 align-items-center">
                                                <a class="btn btn-xs btn-primary mb-0 py-1" href="INV_Periferico_Editar.jsp?idPeriferico=<%=idPerif%>">
                                                    <i class="fa fa-pencil"></i> Editar
                                                </a>
                                                <% if ("D".equals(estado) || "BK".equals(estado)) { %>
                                                <a class="btn btn-xs btn-success mb-0 py-1" href="INV_Periferico_Asignar.jsp?idPeriferico=<%=idPerif%>">
                                                    <i class="fa fa-user-plus"></i> Asignar
                                                </a>
                                                <% } else if ("A".equals(estado)) { %>
                                                <a class="btn btn-xs btn-warning mb-0 py-1" href="INV_Periferico_Devolver.jsp?idPeriferico=<%=idPerif%>">
                                                    <i class="fa fa-undo"></i> Devolver
                                                </a>
                                                <a class="btn btn-xs btn-outline-info mb-0 py-1 btn-imprimir-acta-perif"
                                                   data-id="<%=escAttr(idPerif)%>">
                                                    <i class="fa fa-file-pdf"></i> Acta
                                                </a>
                                                <% } %>
                                            </div>
                                            <% } else { %>
                                            <span class="text-xxs text-secondary">Sin permiso</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                                    }
                                                    if (!hay) {
                                    %>
                                    <tr><td colspan="9" class="text-center text-muted py-4">
                                        <i class="fa fa-plug fa-2x d-block mb-2"></i>
                                        Todavia no hay perifericos registrados.
                                    </td></tr>
                                    <%
                                                    }
                                                }
                                            }
                                        } catch (Exception ex) { ex.printStackTrace(); }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</main>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script src="../assets/js/custom-sidenav-toggle.js"></script>
<script>
    function aplicarFiltros() {
        var q     = (document.getElementById('buscarPerif').value  || '').toLowerCase().trim();
        var tipo  = (document.getElementById('filtroTipo').value    || '').toLowerCase().trim();
        var est   = (document.getElementById('filtroEstado').value  || '').toLowerCase().trim();
        document.querySelectorAll('.fila-perif').forEach(function (tr) {
            var okQ    = !q    || (tr.getAttribute('data-search')   || '').indexOf(q)    !== -1;
            var okTipo = !tipo || (tr.getAttribute('data-tipo')     || '').toLowerCase() === tipo;
            var okEst  = !est  || (tr.getAttribute('data-estado')   || '').toLowerCase() === est;
            tr.style.display = (okQ && okTipo && okEst) ? '' : 'none';
        });
    }
    ['buscarPerif','filtroTipo','filtroEstado'].forEach(function (id) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('input', aplicarFiltros);
        if (el) el.addEventListener('change', aplicarFiltros);
    });

    // Delegado (no bind directo) para que funcione tambien si la tabla se
    // repagina/filtra sin recargar la pagina.
    $(document).on('click', '.btn-imprimir-acta-perif', function () {
        window.open('INV_Periferico_Acta.jsp?idAsignacion=ultima&idPeriferico=' + encodeURIComponent($(this).attr('data-id')), '_blank');
    });
</script>
</body>
</html>
