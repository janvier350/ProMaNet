<%--
    Document   : Asignar periferico a un usuario
    Se pide usuario, motivo (obligatorio), observacion del motivo (solo
    obligatoria si el motivo es OTRO). Opcionalmente se puede indicar que
    esta entrega REEMPLAZA a otro periferico -- en ese caso la asignacion
    anterior se cierra y el periferico reemplazado se marca como baja al
    guardar.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%!
    private String esc(String s) {
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
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String idPeriferico = request.getParameter("idPeriferico");
    if (idPeriferico == null || idPeriferico.trim().isEmpty()) {
        response.sendRedirect("INV_Perifericos.jsp?error=Falta periferico"); return;
    }

    // Datos del periferico para mostrar en el header del formulario.
    String pTipo = "", pMarca = "", pModelo = "", pSerial = "", pEstadoActual = "";
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT t.DESCRIPCION, p.MARCA, p.MODELO, p.SERIAL, p.ESTADO " +
                    "FROM INV_PERIFERICO p JOIN INV_PERIFERICO_TIPO t ON t.ID_TIPO = p.ID_TIPO " +
                    "WHERE p.ID_PERIFERICO = ? AND p.ESTADO_AI = 'A'")) {
                st.setString(1, idPeriferico);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        pTipo         = rs.getString(1) != null ? rs.getString(1) : "";
                        pMarca        = rs.getString(2) != null ? rs.getString(2) : "";
                        pModelo       = rs.getString(3) != null ? rs.getString(3) : "";
                        pSerial       = rs.getString(4) != null ? rs.getString(4) : "";
                        pEstadoActual = rs.getString(5) != null ? rs.getString(5) : "";
                    } else {
                        response.sendRedirect("INV_Perifericos.jsp?error=No existe"); return;
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Bloquea si ya esta asignado -- primero devolver.
    if ("A".equals(pEstadoActual)) {
        response.sendRedirect("INV_Perifericos.jsp?error=Ya asignado, devolver primero"); return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Asignar periferico</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="INV_Perifericos.jsp">Perifericos</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Asignar</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Asignar periferico</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
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
        <div class="row">
            <div class="col-lg-8">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Entrega #<%=esc(idPeriferico)%></h6>
                        <p class="text-sm text-secondary mb-0">
                            <b><%=esc(pTipo)%></b> &middot; <%=esc(pMarca)%> <%=esc(pModelo)%>
                            <% if (!pSerial.isEmpty()) { %>&middot; Serial: <%=esc(pSerial)%><% } %>
                        </p>
                    </div>
                    <div class="card-body">
                        <form action="../INV_Periferico_Asignar_Guardar" method="post" id="formAsignar">
                            <input type="hidden" name="idPeriferico" value="<%=esc(idPeriferico)%>">

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label">Entregar a *</label>
                                        <select class="form-control" name="idUsuario" required>
                                            <option value="">-- Elija un usuario --</option>
                                            <%
                                                try (Connection cnU = Servlets.Conexion.getConnection()) {
                                                    if (cnU != null) {
                                                        try (PreparedStatement stU = cnU.prepareStatement(
                                                                "SELECT IDUSUARIO, NOMBRE || ' ' || APELLIDOS " +
                                                                "FROM USUARIO WHERE UPPER(ESTADO) = 'A' " +
                                                                "ORDER BY NOMBRE, APELLIDOS");
                                                             ResultSet rsU = stU.executeQuery()) {
                                                            while (rsU.next()) {
                                            %>
                                            <option value="<%=rsU.getString(1)%>"><%=esc(rsU.getString(2))%></option>
                                            <% } } } } catch (Exception e) { e.printStackTrace(); } %>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label">Motivo de la entrega *</label>
                                        <select class="form-control" name="idMotivo" id="idMotivo" required>
                                            <option value="">-- Elija el motivo --</option>
                                            <%
                                                try (Connection cnM = Servlets.Conexion.getConnection()) {
                                                    if (cnM != null) {
                                                        try (PreparedStatement stM = cnM.prepareStatement(
                                                                "SELECT ID_MOTIVO, CODIGO, DESCRIPCION FROM INV_PERIFERICO_MOTIVO " +
                                                                "WHERE ESTADO = 'A' ORDER BY ID_MOTIVO");
                                                             ResultSet rsM = stM.executeQuery()) {
                                                            while (rsM.next()) {
                                                                String idM   = rsM.getString(1);
                                                                String codM  = rsM.getString(2);
                                                                String descM = rsM.getString(3);
                                            %>
                                            <option value="<%=idM%>" data-codigo="<%=esc(codM)%>"><%=esc(descM)%></option>
                                            <% } } } } catch (Exception e) { e.printStackTrace(); } %>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" id="lblObservacion">Observacion del motivo</label>
                                        <textarea class="form-control" name="observacionMotivo" id="observacionMotivo" rows="2" maxlength="500"></textarea>
                                        <small class="text-muted" id="hintObs">Obligatoria si el motivo es "Otro" o si es prestamo temporal (para poner la fecha estimada de devolucion).</small>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label">Reemplaza a (opcional)</label>
                                        <select class="form-control" name="idPerifericoReemplaza">
                                            <option value="">-- No reemplaza a otro --</option>
                                            <%
                                                // Se muestra la asignacion activa del usuario del mismo tipo, y ademas
                                                // cualquier periferico dado de baja del mismo tipo que este ubicado
                                                // igual, para poder trazar reemplazos por daño/perdida.
                                                try (Connection cnR = Servlets.Conexion.getConnection()) {
                                                    if (cnR != null) {
                                                        try (PreparedStatement stR = cnR.prepareStatement(
                                                                "SELECT p.ID_PERIFERICO, p.MARCA, p.MODELO, p.SERIAL, p.ESTADO " +
                                                                "FROM INV_PERIFERICO p " +
                                                                "WHERE p.ID_TIPO = (SELECT ID_TIPO FROM INV_PERIFERICO WHERE ID_PERIFERICO = ?) " +
                                                                "  AND p.ID_PERIFERICO <> ? " +
                                                                "  AND p.ESTADO IN ('A','F','X') " +
                                                                "  AND p.ESTADO_AI = 'A' " +
                                                                "ORDER BY p.ID_PERIFERICO DESC")) {
                                                            stR.setString(1, idPeriferico);
                                                            stR.setString(2, idPeriferico);
                                                            try (ResultSet rsR = stR.executeQuery()) {
                                                                while (rsR.next()) {
                                                                    String idR = rsR.getString(1);
                                                                    String mR  = rsR.getString(2) != null ? rsR.getString(2) : "";
                                                                    String moR = rsR.getString(3) != null ? rsR.getString(3) : "";
                                                                    String sR  = rsR.getString(4) != null ? rsR.getString(4) : "";
                                                                    String eR  = rsR.getString(5);
                                            %>
                                            <option value="<%=idR%>">#<%=idR%> - <%=esc(mR)%> <%=esc(moR)%> <% if(!sR.isEmpty()){ %>(<%=esc(sR)%>)<% } %> [<%=esc(eR)%>]</option>
                                            <% } } } } } catch (Exception e) { e.printStackTrace(); } %>
                                        </select>
                                        <small class="text-muted">Si se llena, la asignacion anterior se cierra y el periferico anterior se marca segun el motivo (daño = F, robo/perdida = X).</small>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between mt-3">
                                <a href="INV_Perifericos.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                    <i class="fa fa-arrow-left me-1"></i> Cancelar
                                </a>
                                <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">
                                    <i class="fa fa-check me-1"></i> Registrar entrega
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script>
    // Validacion cliente: si el motivo es OTRO o PRESTAMO_TEMPORAL,
    // observacion obligatoria. La validacion definitiva la hace el servlet.
    (function(){
        var sel = document.getElementById('idMotivo');
        var obs = document.getElementById('observacionMotivo');
        var lbl = document.getElementById('lblObservacion');
        function refrescar(){
            var opt = sel.options[sel.selectedIndex];
            var cod = opt ? (opt.getAttribute('data-codigo') || '') : '';
            var obliga = (cod === 'OTRO' || cod === 'PRESTAMO_TEMPORAL');
            obs.required = obliga;
            lbl.innerHTML = 'Observacion del motivo' + (obliga ? ' *' : '');
        }
        sel.addEventListener('change', refrescar);
        document.getElementById('formAsignar').addEventListener('submit', function(ev){
            refrescar();
            if (obs.required && !obs.value.trim()) {
                ev.preventDefault();
                alert('Debe ingresar la observacion del motivo.');
                obs.focus();
            }
        });
    })();
</script>
</body>
</html>
