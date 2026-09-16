<%--
    Document   : Alta / edicion de periferico
    Un solo formulario que sirve para crear y editar (si viene ?idPeriferico
    en la URL, precarga los datos y hace update; si no, es alta).
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
    String compania  = (String) session.getAttribute("compania");
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String idPeriferico = request.getParameter("idPeriferico");
    boolean esEdicion = idPeriferico != null && !idPeriferico.trim().isEmpty();

    String marca = "", modelo = "", serial = "", fcompra = "", oficina = "",
           empresa = "", observaciones = "", estado = "D";
    int idTipo = 0;

    if (esEdicion) {
        try (Connection cn = Servlets.Conexion.getConnection()) {
            if (cn != null) {
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT ID_TIPO, MARCA, MODELO, SERIAL, TO_CHAR(FECHACOMPRA,'YYYY-MM-DD'), " +
                        "UBICACIONOFICINA, EMPRESA, OBSERVACIONES, ESTADO " +
                        "FROM INV_PERIFERICO WHERE ID_PERIFERICO = ? AND ESTADO_AI = 'A'")) {
                    st.setString(1, idPeriferico);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            idTipo        = rs.getInt(1);
                            marca         = rs.getString(2) != null ? rs.getString(2) : "";
                            modelo        = rs.getString(3) != null ? rs.getString(3) : "";
                            serial        = rs.getString(4) != null ? rs.getString(4) : "";
                            fcompra       = rs.getString(5) != null ? rs.getString(5) : "";
                            oficina       = rs.getString(6) != null ? rs.getString(6) : "";
                            empresa       = rs.getString(7) != null ? rs.getString(7) : "";
                            observaciones = rs.getString(8) != null ? rs.getString(8) : "";
                            estado        = rs.getString(9);
                        } else {
                            esEdicion = false; // id no existe, se vuelve un alta
                        }
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Oficinas: mismo listado hardcodeado que usa INV_Equipos.jsp para no
    // divergir.
    String[] oficinas = {"Norte","Kennedy 401","Kennedy 403","Romeria","Magisterio","Outsourcing"};
    // Estados: los que aplican a periferico (no todos los de INV_EQUIPOS
    // aplican -- p.ej. "Infraestructura" no tiene sentido para un mouse).
    String[][] estados = {
        {"D","Disponible"},{"A","Asignado"},{"BK","Backup Oficina"},
        {"F","Fuera de servicio"},{"X","Baja"}
    };
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - <%= esEdicion ? "Editar" : "Nuevo" %> Periferico</title>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page"><%= esEdicion ? "Editar" : "Nuevo" %></li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0"><%= esEdicion ? "Editar Periferico" : "Nuevo Periferico" %></h6>
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
                        <h6>Datos del periferico</h6>
                    </div>
                    <div class="card-body">
                        <form action="../INV_Periferico_Guardar" method="post">
                            <% if (esEdicion) { %>
                            <input type="hidden" name="idPeriferico" value="<%=esc(idPeriferico)%>">
                            <% } %>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label">Tipo *</label>
                                        <select class="form-control" name="idTipo" required>
                                            <option value="">-- Seleccione --</option>
                                            <%
                                                try (Connection cnT = Servlets.Conexion.getConnection()) {
                                                    if (cnT != null) {
                                                        try (PreparedStatement stT = cnT.prepareStatement(
                                                                "SELECT ID_TIPO, DESCRIPCION FROM INV_PERIFERICO_TIPO WHERE ESTADO='A' ORDER BY DESCRIPCION");
                                                             ResultSet rsT = stT.executeQuery()) {
                                                            while (rsT.next()) {
                                                                int idT = rsT.getInt(1);
                                                                String descT = rsT.getString(2);
                                            %>
                                            <option value="<%=idT%>" <%= (idTipo == idT ? "selected" : "") %>><%=esc(descT)%></option>
                                            <% } } } } catch (Exception e) { e.printStackTrace(); } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label">Estado *</label>
                                        <select class="form-control" name="estado" required>
                                            <% for (String[] e : estados) { %>
                                            <option value="<%=e[0]%>" <%= (estado.equals(e[0]) ? "selected" : "") %>><%=e[1]%></option>
                                            <% } %>
                                        </select>
                                        <small class="text-muted">Si se marca como "Asignado", asignelo despues desde el listado.</small>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Marca</label>
                                        <input class="form-control" type="text" name="marca" value="<%=esc(marca)%>" maxlength="100">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Modelo</label>
                                        <input class="form-control" type="text" name="modelo" value="<%=esc(modelo)%>" maxlength="100">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Serial</label>
                                        <input class="form-control" type="text" name="serial" value="<%=esc(serial)%>" maxlength="100">
                                        <small class="text-muted">Opcional (no todo periferico tiene serial).</small>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Fecha de compra</label>
                                        <input class="form-control" type="date" name="fechaCompra" value="<%=esc(fcompra)%>">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Ubicacion / Oficina</label>
                                        <select class="form-control" name="ubicacion">
                                            <option value="">--</option>
                                            <% for (String o : oficinas) { %>
                                            <option value="<%=o%>" <%= (o.equals(oficina) ? "selected" : "") %>><%=o%></option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label">Empresa</label>
                                        <input class="form-control" type="text" name="empresa" value="<%=esc(empresa)%>" maxlength="100">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label">Observaciones</label>
                                        <textarea class="form-control" name="observaciones" rows="3" maxlength="1000"><%=esc(observaciones)%></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between mt-3">
                                <a href="INV_Perifericos.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                    <i class="fa fa-arrow-left me-1"></i> Cancelar
                                </a>
                                <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">
                                    <i class="fa fa-save me-1"></i> <%= esEdicion ? "Actualizar" : "Guardar" %>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <% if (esEdicion) { %>
            <div class="col-lg-4">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h6>Foto del periferico</h6>
                        <p class="text-xs text-secondary mb-0">JPG, JPEG o PNG.</p>
                    </div>
                    <div class="card-body text-center">
                        <img src="../INV_MostrarImagenPeriferico?nombre=perif_<%=esc(idPeriferico)%>"
                             onerror="this.style.display='none';document.getElementById('sinFoto').style.display='';"
                             class="rounded border mb-3"
                             style="max-width:100%;max-height:220px;object-fit:contain;">
                        <p id="sinFoto" class="text-xs text-muted" style="display:none;">Sin foto cargada</p>
                        <form action="../INV_Subir_Imagen_Periferico" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="idPeriferico" value="<%=esc(idPeriferico)%>">
                            <div class="form-group mb-2">
                                <input type="file" name="imagen" class="form-control form-control-sm" accept="image/jpeg,image/jpg,image/png" required>
                            </div>
                            <button type="submit" class="btn btn-outline-primary btn-sm mb-0">
                                <i class="fa fa-upload me-1"></i> Subir foto
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</main>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
</body>
</html>
