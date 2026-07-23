<%--
 Document   : LEG_ControlSeguimiento
 Created on : 22 jul 2026
 Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<!DOCTYPE html>
<%!
    // Escapa texto libre antes de insertarlo en HTML (evita XSS almacenado).
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String("" + ip);
    String departamento = (String) session.getAttribute("departamento");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "LEGAL_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp");
        return;
    }

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");

    StringBuilder opcionesDelito = new StringBuilder();
    StringBuilder filasIP = new StringBuilder();
    int totalIP = 0;

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        // Catalogo de delitos activos, para el <select> del modal.
        PreparedStatement stDel = cn.prepareStatement(
                "SELECT ID_DELITO, DESCRIPCION FROM LEGAL_DELITO WHERE ESTADO='A' ORDER BY DESCRIPCION");
        ResultSet rsDel = stDel.executeQuery();
        while (rsDel.next()) {
            opcionesDelito.append("<option value='").append(rsDel.getInt(1)).append("'>")
                    .append(rsDel.getString(2)).append("</option>\n");
        }
        rsDel.close();
        stDel.close();

        // Seguimientos, agrupados en memoria por ID_LEGAL_IP para embeber
        // en cada fila (evita una consulta por fila).
        Map<Integer, StringBuilder> mapaSeg = new HashMap<Integer, StringBuilder>();
        Map<Integer, Integer> conteoSeg = new HashMap<Integer, Integer>();
        PreparedStatement stSeg = cn.prepareStatement(
                "SELECT s.ID_LEGAL_IP, s.DESCRIPCION, TO_CHAR(s.FECHA_CREACION,'DD/MM/YYYY HH24:MI'), " +
                "u.NOMBRE||' '||u.APELLIDOS " +
                "FROM LEGAL_IP_SEGUIMIENTO s JOIN USUARIO u ON s.ID_USUARIO_CREA = u.IDUSUARIO " +
                "ORDER BY s.ID_LEGAL_IP, s.FECHA_CREACION");
        ResultSet rsSeg = stSeg.executeQuery();
        while (rsSeg.next()) {
            int idIp = rsSeg.getInt(1);
            String descSeg = rsSeg.getString(2) != null ? rsSeg.getString(2) : "";
            String fechaSeg = rsSeg.getString(3);
            String userSeg = rsSeg.getString(4) != null ? rsSeg.getString(4) : "";

            String descEsc = descSeg.replace("\\", "\\\\").replace("\"", "\\\"")
                    .replace("\n", " ").replace("\r", "");
            String userEsc = userSeg.replace("\\", "\\\\").replace("\"", "\\\"");

            StringBuilder sb = mapaSeg.get(idIp);
            if (sb == null) {
                sb = new StringBuilder();
                mapaSeg.put(idIp, sb);
            }
            if (sb.length() > 0) sb.append(",");
            sb.append("{\"descripcion\":\"").append(descEsc).append("\",\"fecha\":\"")
              .append(fechaSeg).append("\",\"usuario\":\"").append(userEsc).append("\"}");

            Integer c = conteoSeg.get(idIp);
            conteoSeg.put(idIp, c == null ? 1 : c + 1);
        }
        rsSeg.close();
        stSeg.close();

        // Listado principal de Investigaciones Previas.
        PreparedStatement stIP = cn.prepareStatement(
                "SELECT ip.ID_LEGAL_IP, ip.PROCESADO, ip.VICTIMA, ip.PROCESO, d.DESCRIPCION, " +
                "ip.FISCALIA, ip.UBICACION, u.NOMBRE||' '||u.APELLIDOS, " +
                "TO_CHAR(ip.FECHA_CREACION,'DD/MM/YYYY HH24:MI') " +
                "FROM LEGAL_IP ip " +
                "LEFT JOIN LEGAL_DELITO d ON ip.ID_DELITO = d.ID_DELITO " +
                "JOIN USUARIO u ON ip.ID_USUARIO_CREA = u.IDUSUARIO " +
                "WHERE ip.ESTADO = 'A' " +
                "ORDER BY ip.FECHA_CREACION DESC");
        ResultSet rsIP = stIP.executeQuery();
        while (rsIP.next()) {
            totalIP++;
            int idIp = rsIP.getInt(1);
            String procesado = rsIP.getString(2) != null ? rsIP.getString(2) : "";
            String victima = rsIP.getString(3) != null ? rsIP.getString(3) : "";
            String proceso = rsIP.getString(4) != null ? rsIP.getString(4) : "—";
            String delito = rsIP.getString(5) != null ? rsIP.getString(5) : "—";
            String fiscalia = rsIP.getString(6) != null ? rsIP.getString(6) : "—";
            String ubicacion = rsIP.getString(7) != null ? rsIP.getString(7) : "—";
            String creador = rsIP.getString(8);
            String fechaCrea = rsIP.getString(9);

            StringBuilder segSb = mapaSeg.get(idIp);
            String segJson = "[" + (segSb != null ? segSb.toString() : "") + "]";
            String segAttr = segJson.replace("\"", "&quot;");
            Integer cantSegObj = conteoSeg.get(idIp);
            int cantSeg = cantSegObj != null ? cantSegObj : 0;

            String buscaIdx = (procesado + " " + victima + " " + delito).toLowerCase().replace("'", "");

            filasIP.append("<tr data-desc='").append(buscaIdx).append("'>")
                    .append("<td>").append(esc(procesado))
                    .append("<br><small class='text-muted'>Registrado por ").append(esc(creador))
                    .append(" &middot; ").append(fechaCrea).append("</small></td>")
                    .append("<td>").append(esc(victima)).append("</td>")
                    .append("<td>").append(esc(proceso)).append("</td>")
                    .append("<td><span class='badge badge-secondary'>").append(esc(delito)).append("</span></td>")
                    .append("<td>").append(esc(fiscalia)).append("</td>")
                    .append("<td>").append(esc(ubicacion)).append("</td>")
                    .append("<td class='text-center'>")
                    .append("<button type='button' class='btn btn-xs btn-outline-info btn-ver-seg' ")
                    .append("data-id='").append(idIp).append("' data-seg=\"").append(segAttr).append("\">")
                    .append("<i class='fa fa-list-ul'></i> ").append(cantSeg).append("</button>")
                    .append("</td></tr>\n");
        }
        rsIP.close();
        stIP.close();
        cn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>ProMaNet | Control y Seguimiento Legal</title>
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
        <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
        <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    </head>
    <body class="g-sidenav-show   bg-gray-100">
        <div class="min-height-300 bg-primary position-absolute w-100"></div>
        <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
            <div class="sidenav-header">
                <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
                <a class="navbar-brand m-0" href=" #" target="_blank">
                    <img src="../assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
                    <span class="ms-1 font-weight-bold">ProMaNet </span>
                </a>
            </div>
            <hr class="horizontal dark mt-0">
            <div class="collapse navbar-collapse  w-auto " id="sidenav-collapse-main">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/PRO_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Legal/LEG_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-paper-diploma text-info text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Legal</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../Legal/LEG_ControlSeguimiento.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-collection text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Control y Seguimiento</span>
                        </a>
                    </li>

                    <li class="nav-item mt-3">
                        <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Panel de control</h6>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/Perfil.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Perfil</span>
                        </a>
                    </li>
                </ul>
            </div>
            <div class="sidenav-footer mx-3 ">
                <div class="card card-plain shadow-none" id="sidenavCard">
                    <img class="w-50 mx-auto" src="../assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
                    <div class="card-body text-center p-3 w-100 pt-0">
                        <div class="docs-info">
                            <h6 class="mb-0">Necesitas ayuda?</h6>
                            <p class="text-xs font-weight-bold mb-0">Visita nuestro Tutorial</p>
                        </div>
                    </div>
                </div>
                <a href="../cerrar.jsp"  class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesión</a>
            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Legal/LEG_Dashboard.jsp">Legal</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Control y Seguimiento</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Control y Seguimiento</h6>
                    </nav>
                    <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                        <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                            <div class="input-group">
                                <span class=" text-body text-white-50"><i class="fa fa-home" ></i> <%=compania%></span>
                            </div>
                        </div>
                        <ul class="navbar-nav  justify-content-end">
                            <li class="nav-item d-flex align-items-center">
                                <a href="../Proyectos/Perfil.jsp" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-user me-sm-1"></i>
                                    <span class="d-sm-inline d-none"><b> <%=nombre%> <%=apellidos%> </b></span>
                                </a>
                            </li>
                            <li class="nav-item d-xl-none ps-3 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                                    <div class="sidenav-toggler-inner">
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                    </div>
                                </a>
                            </li>
                            <li class="nav-item d-flex align-items-center">
                                <a href="../cerrar.jsp" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-power-off me-sm-1"></i>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="container-fluid py-4">

                <% if (msgExito != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%=msgExito%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>
                <% if (msgError != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%=msgError%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>

                <%-- Tarjeta boton: Investigacion Previa --%>
                <div class="row">
                    <div class="col-xl-3 col-sm-6 mb-4">
                        <div class="card" style="cursor:pointer;" onclick="modalNuevaIP.show()">
                            <div class="card-body p-3">
                                <div class="row">
                                    <div class="col-8">
                                        <div class="numbers">
                                            <p class="text-sm mb-0 text-uppercase font-weight-bold">Registrar</p>
                                            <h5 class="font-weight-bolder">
                                                INVESTIGACION PREVIA
                                            </h5>
                                            <p class="mb-0">
                                                <span class="text-info text-sm font-weight-bolder">Nuevo</span>
                                                <b class="text-info"> registro de IP.</b>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="col-4 text-end">
                                        <div class="icon icon-shape bg-gradient-info shadow-info text-center rounded-circle">
                                            <i class="ni ni-single-copy-04 text-lg opacity-10" aria-hidden="true"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Tabla de Investigaciones Previas --%>
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="fa fa-table mr-2 text-secondary"></i>Investigaciones Previas
                            <span class="badge badge-secondary ml-2"><%=totalIP%> registros</span>
                        </span>
                        <input type="text" id="buscarIP" class="form-control form-control-sm"
                               placeholder="Buscar..." style="width:220px;">
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0" id="tablaIP">
                                <thead>
                                    <tr>
                                        <th>Procesado</th>
                                        <th>Victima</th>
                                        <th>Proceso</th>
                                        <th>Delito</th>
                                        <th>Fiscalia</th>
                                        <th>Ubicacion</th>
                                        <th class="text-center" style="width:110px;">Seguimiento IP</th>
                                    </tr>
                                </thead>
                                <tbody>
<%=filasIP.length() > 0 ? filasIP.toString() : "<tr><td colspan='7' class='text-center text-muted py-4'><i class='fa fa-inbox fa-2x d-block mb-2'></i>No hay investigaciones previas registradas.</td></tr>"%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>

            <footer class="footer pt-3  ">
                <div class="container-fluid">
                    <div class="row align-items-center justify-content-lg-between">
                        <div class="col-lg-6 mb-lg-0 mb-4">
                            <div class="copyright text-center text-sm text-muted text-lg-start">
                                © <script>document.write(new Date().getFullYear())</script>,
                                Creado  <i class="fa fa-clock"></i> por
                                <a href="https://www.overclocking.com.ec" class="font-weight-bold" target="_blank">Overclocking</a>
                                for a better web.
                            </div>
                        </div>
                    </div>
                </div>
            </footer>
        </main>

        <%-- Modal: Nueva Investigacion Previa --%>
        <div class="modal fade" id="modalNuevaIP" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="../LEG_InsertarIP" method="post">
                        <div class="modal-header" style="background:#17a2b8;color:#fff;">
                            <h5 class="modal-title"><i class="fa fa-search mr-2"></i>Investigacion Previa</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group mb-2">
                                <label>Procesado</label>
                                <input type="text" name="procesado" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Victima</label>
                                <input type="text" name="victima" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Proceso</label>
                                <input type="text" name="proceso" class="form-control" maxlength="500" placeholder="No. de proceso / expediente">
                            </div>
                            <div class="form-group mb-2">
                                <label>Delito</label>
                                <div class="input-group">
                                    <select name="idDelito" id="selDelito" class="form-control">
                                        <option value="">-- Seleccione --</option>
<%=opcionesDelito.toString()%>
                                    </select>
                                    <button type="button" class="btn btn-outline-secondary" id="btnNuevoDelito" title="Nuevo delito">
                                        <i class="fa fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Fiscalia</label>
                                <input type="text" name="fiscalia" class="form-control" maxlength="300">
                            </div>
                            <div class="form-group mb-0">
                                <label>Ubicacion</label>
                                <input type="text" name="ubicacion" class="form-control" maxlength="150">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-info btn-sm text-white"><i class="fa fa-save mr-1"></i>Guardar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Nuevo Delito (quick-add, AJAX) --%>
        <div class="modal fade" id="modalNuevoDelito" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#6c757d;color:#fff;">
                        <h5 class="modal-title"><i class="fa fa-gavel mr-2"></i>Nuevo Delito</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group mb-0">
                            <label>Nombre del delito</label>
                            <input type="text" id="nuevoDelitoDesc" class="form-control" maxlength="200">
                            <small id="nuevoDelitoMsg" class="text-danger"></small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-dark btn-sm" id="btnGuardarDelito"><i class="fa fa-save mr-1"></i>Guardar</button>
                    </div>
                </div>
            </div>
        </div>

        <%-- Modal: Seguimiento IP --%>
        <div class="modal fade" id="modalSeguimiento" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#3d5a99;color:#fff;">
                        <h5 class="modal-title"><i class="fa fa-list-ul mr-2"></i>Seguimiento IP</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div id="listaSeguimientos" style="max-height:260px;overflow-y:auto;" class="mb-3"></div>
                        <form action="../LEG_InsertarSeguimiento" method="post">
                            <input type="hidden" name="idLegalIp" id="segIdLegalIp">
                            <div class="form-group mb-2">
                                <label>Nuevo seguimiento</label>
                                <textarea name="descripcion" class="form-control" rows="3" required maxlength="1000"></textarea>
                            </div>
                            <div class="modal-footer px-0 pb-0">
                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                                <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-plus mr-1"></i>Agregar seguimiento</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script src="../assets/js/core/popper.min.js"></script>
        <script src="../assets/js/core/bootstrap.min.js"></script>
        <script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
        <script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
        <script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
        <script>
            var ctx = '<%=request.getContextPath()%>';

            function escapeHtml(s) {
                return String(s == null ? '' : s)
                    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }

            var modalNuevaIP = new bootstrap.Modal(document.getElementById('modalNuevaIP'));
            var modalNuevoDelito = new bootstrap.Modal(document.getElementById('modalNuevoDelito'));
            var modalSeguimiento = new bootstrap.Modal(document.getElementById('modalSeguimiento'));

            var buscarIP = document.getElementById('buscarIP');
            if (buscarIP) {
                buscarIP.addEventListener('input', function () {
                    var q = this.value.toLowerCase().trim();
                    document.querySelectorAll('#tablaIP tbody tr').forEach(function (tr) {
                        var d = tr.getAttribute('data-desc') || '';
                        tr.style.display = (!q || d.indexOf(q) !== -1) ? '' : 'none';
                    });
                });
            }

            document.getElementById('btnNuevoDelito').addEventListener('click', function () {
                document.getElementById('nuevoDelitoDesc').value = '';
                document.getElementById('nuevoDelitoMsg').textContent = '';
                modalNuevoDelito.show();
            });

            document.getElementById('btnGuardarDelito').addEventListener('click', function () {
                var desc = document.getElementById('nuevoDelitoDesc').value.trim();
                var msgEl = document.getElementById('nuevoDelitoMsg');
                if (!desc) {
                    msgEl.textContent = 'Escriba el nombre del delito.';
                    return;
                }
                var fd = new FormData();
                fd.append('descripcion', desc);
                fetch(ctx + '/LEG_InsertarDelito', {method: 'POST', body: fd})
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (!data.ok) {
                            msgEl.textContent = data.mensaje || 'No se pudo guardar.';
                            return;
                        }
                        var sel = document.getElementById('selDelito');
                        var yaExiste = false;
                        for (var i = 0; i < sel.options.length; i++) {
                            if (sel.options[i].value == data.id) {
                                yaExiste = true;
                                sel.selectedIndex = i;
                                break;
                            }
                        }
                        if (!yaExiste) {
                            var opt = document.createElement('option');
                            opt.value = data.id;
                            opt.textContent = data.descripcion;
                            sel.appendChild(opt);
                            sel.value = data.id;
                        }
                        modalNuevoDelito.hide();
                    })
                    .catch(function () {
                        msgEl.textContent = 'Error de conexion.';
                    });
            });

            document.querySelectorAll('.btn-ver-seg').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var idIp = this.getAttribute('data-id');
                    var seguimientos = [];
                    try {
                        seguimientos = JSON.parse(this.getAttribute('data-seg'));
                    } catch (e) {
                        seguimientos = [];
                    }
                    document.getElementById('segIdLegalIp').value = idIp;
                    var cont = document.getElementById('listaSeguimientos');
                    if (seguimientos.length === 0) {
                        cont.innerHTML = '<p class="text-muted text-center py-3 mb-0"><i class="fa fa-inbox mr-1"></i>Sin seguimientos registrados.</p>';
                    } else {
                        var html = '';
                        seguimientos.forEach(function (s) {
                            html += '<div class="border-bottom pb-2 mb-2">'
                                    + '<div class="small text-muted">' + escapeHtml(s.fecha) + ' &middot; ' + escapeHtml(s.usuario) + '</div>'
                                    + '<div>' + escapeHtml(s.descripcion) + '</div>'
                                    + '</div>';
                        });
                        cont.innerHTML = html;
                    }
                    modalSeguimiento.show();
                });
            });
        </script>
    </body>
</html>
