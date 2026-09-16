<%--
    Document   : Devolver periferico
    Cierra la asignacion activa del periferico y devuelve el periferico
    al pool con el estado que el usuario indique (Disponible, Backup,
    Fuera de servicio, Baja).
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

    String pTipo = "", pMarca = "", pModelo = "", pSerial = "", pEstadoActual = "";
    String asignadoA = "", desde = "";
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT t.DESCRIPCION, p.MARCA, p.MODELO, p.SERIAL, p.ESTADO, " +
                    "  (SELECT u.NOMBRE || ' ' || u.APELLIDOS FROM INV_PERIFERICO_ASIGNACION a " +
                    "     JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
                    "    WHERE a.ID_PERIFERICO = p.ID_PERIFERICO AND a.ESTADO = 'A' AND ROWNUM = 1), " +
                    "  (SELECT TO_CHAR(a.FECHAASIGNACION,'DD/MM/YYYY') FROM INV_PERIFERICO_ASIGNACION a " +
                    "    WHERE a.ID_PERIFERICO = p.ID_PERIFERICO AND a.ESTADO = 'A' AND ROWNUM = 1) " +
                    "FROM INV_PERIFERICO p JOIN INV_PERIFERICO_TIPO t ON t.ID_TIPO = p.ID_TIPO " +
                    "WHERE p.ID_PERIFERICO = ? AND p.ESTADO_AI = 'A'")) {
                st.setString(1, idPeriferico);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        pTipo         = nz(rs.getString(1));
                        pMarca        = nz(rs.getString(2));
                        pModelo       = nz(rs.getString(3));
                        pSerial       = nz(rs.getString(4));
                        pEstadoActual = nz(rs.getString(5));
                        asignadoA     = nz(rs.getString(6));
                        desde         = nz(rs.getString(7));
                    } else {
                        response.sendRedirect("INV_Perifericos.jsp?error=No existe"); return;
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    if (!"A".equals(pEstadoActual)) {
        response.sendRedirect("INV_Perifericos.jsp?error=No esta asignado"); return;
    }
%>
<%!
    private static String nz(String s) { return s == null ? "" : s; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Devolver periferico</title>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Devolver</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Devolver periferico</h6>
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
                        <h6>Devolver #<%=esc(idPeriferico)%></h6>
                        <p class="text-sm text-secondary mb-0">
                            <b><%=esc(pTipo)%></b> &middot; <%=esc(pMarca)%> <%=esc(pModelo)%>
                            <% if (!pSerial.isEmpty()) { %>&middot; Serial: <%=esc(pSerial)%><% } %>
                        </p>
                        <p class="text-xs text-muted mb-0">
                            Actualmente asignado a <b><%=esc(asignadoA)%></b> desde <%=esc(desde)%>.
                        </p>
                    </div>
                    <div class="card-body">
                        <form action="../INV_Periferico_Devolver_Guardar" method="post">
                            <input type="hidden" name="idPeriferico" value="<%=esc(idPeriferico)%>">

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label">Nuevo estado del periferico *</label>
                                        <select class="form-control" name="nuevoEstado" required>
                                            <option value="D">Disponible (vuelve al pool)</option>
                                            <option value="BK">Backup Oficina</option>
                                            <option value="F">Fuera de servicio</option>
                                            <option value="X">Baja</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label">Observacion (opcional)</label>
                                        <textarea class="form-control" name="observacion" rows="2" maxlength="500"></textarea>
                                        <small class="text-muted">Se guarda en el historial de la asignacion.</small>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between mt-3">
                                <a href="INV_Perifericos.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                    <i class="fa fa-arrow-left me-1"></i> Cancelar
                                </a>
                                <button type="submit" class="btn bg-gradient-warning btn-sm mb-0">
                                    <i class="fa fa-undo me-1"></i> Registrar devolucion
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
</body>
</html>
