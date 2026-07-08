<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.util.Date, java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%
    String cargo   = (String) session.getAttribute("cargo");
    String nombre  = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String user    = (String) session.getAttribute("userDB");
    String pass    = (String) session.getAttribute("passDB");
    String ip      = (String) session.getAttribute("ipDB");
    String url     = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_VER_TODAS")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeDespachar = COMUN.PermisoHelper.tiene(session, "INVENTARIO_DESPACHAR");

    String compania = "";
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cnComp = DriverManager.getConnection(url, user, pass);
        PreparedStatement stComp = cnComp.prepareStatement("SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsComp = stComp.executeQuery();
        if (rsComp.next()) compania = rsComp.getString(1);
        rsComp.close(); stComp.close(); cnComp.close();
    } catch (Exception e) { e.printStackTrace(); }

    String filtroEstado = request.getParameter("estado");
    if (filtroEstado == null) filtroEstado = "PENDIENTE";
    String whereEstado = "TODOS".equals(filtroEstado) ? "" : "WHERE e.ESTADO_SOLICITUD = '" + filtroEstado + "'";
    String sqlLista =
        "SELECT e.ID_SUMINISTRO_EGRESO_CAB, e.FECHA_SOLICITUD, e.ESTADO_SOLICITUD, " +
        "       d.DEPARTAMENTO, u.NOMBRE || ' ' || u.APELLIDOS AS SOLICITANTE, " +
        "       ua.NOMBRE || ' ' || ua.APELLIDOS AS AUTORIZADOR, " +
        "       (SELECT COUNT(*) FROM INV_SUMINISTRO_EGRESO_DET dt " +
        "        WHERE dt.ID_SUMINISTRO_EGRESO_CAB = e.ID_SUMINISTRO_EGRESO_CAB) AS NUM_ITEMS " +
        "FROM INV_SUMINISTRO_EGRESO_CAB e " +
        "LEFT JOIN ADM_DEPARTAMENTO d  ON TO_CHAR(e.ID_DEPARTAMENTO) = d.ID_DEPARTAMENTO " +
        "LEFT JOIN USUARIO u           ON e.ID_USUARIO      = u.IDUSUARIO " +
        "LEFT JOIN USUARIO ua          ON e.ID_USUARIO_AUTO = ua.IDUSUARIO " +
        whereEstado + " ORDER BY e.FECHA_SOLICITUD DESC";
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Solicitudes de Suministros</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        body{background:#f4f6f9;font-family:'Segoe UI',Arial,sans-serif;margin:0;}
        .topbar{background:#3d5a99;color:#fff;padding:10px 20px;display:flex;justify-content:space-between;align-items:center;}
        .topbar .brand{font-size:1.1rem;font-weight:700;letter-spacing:1px;}
        .topbar .user-info{font-size:0.85rem;text-align:right;}
        .sidebar{width:220px;min-height:100vh;background:#fff;border-right:1px solid #e0e0e0;position:fixed;top:44px;left:0;}
        .sidebar .nav-link{color:#444;padding:10px 20px;font-size:0.88rem;}
        .sidebar .nav-link:hover,.sidebar .nav-link.active{background:#eef2fb;color:#3d5a99;font-weight:600;}
        .sidebar .nav-section{padding:10px 20px 4px;font-size:0.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;}
        .main-content{margin-left:220px;padding:0;}
        .page-header{background:linear-gradient(135deg,#3d5a99,#5b7fc4);color:#fff;padding:18px 28px 14px;}
        .page-header .breadcrumb{background:transparent;padding:0;margin:0 0 4px;font-size:0.8rem;}
        .page-header .breadcrumb-item a{color:rgba(255,255,255,0.75);}
        .page-header .breadcrumb-item.active{color:#fff;}
        .page-header h4{margin:0;font-weight:600;}
        .content-area{padding:24px;}
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:14px 20px;}
        .table th{background:#f8f9fb;font-size:0.78rem;text-transform:uppercase;color:#666;letter-spacing:0.5px;border-bottom:2px solid #eee;}
        .table td{vertical-align:middle;font-size:0.88rem;}
        .badge-pendiente{background:#fff3cd;color:#856404;padding:4px 10px;border-radius:12px;font-size:0.75rem;font-weight:600;}
        .badge-entregado{background:#d1e7dd;color:#0f5132;padding:4px 10px;border-radius:12px;font-size:0.75rem;font-weight:600;}
        .stock-ok{color:#198754;font-weight:600;}
        .stock-fail{color:#dc3545;font-weight:600;}
        .footer{margin-left:220px;padding:12px 24px;font-size:0.78rem;color:#aaa;border-top:1px solid #eee;}
    </style>
</head>
<body>
<div class="topbar">
    <span class="brand"><i class="fa fa-th-large mr-2"></i>INVENTARIOS</span>
    <span class="user-info"><%=compania%><br><strong><%=nombre%> <%=apellidos%></strong></span>
</div>
<div class="sidebar">
    <nav class="nav flex-column pt-3">
        <% if (puedeDespachar) { %>
        <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
        <% } %>
        <a class="nav-link active" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
        <% if (puedeDespachar) { %>
        <a class="nav-link" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
        <% } %>
        <a class="nav-link" href="INV_Historial_Solicitudes_Departamento.jsp"><i class="fa fa-building mr-2"></i>Historial por Departamento</a>
        <% if (puedeDespachar) { %>
        <div class="nav-section">Ingresos</div>
        <a class="nav-link" href="INV_Ingreso_Suministro2.jsp"><i class="fa fa-plus-circle mr-2"></i>Registrar ingreso</a>
        <% } %>
        <div class="nav-section">Panel de control</div>
        <a class="nav-link" href="../Proyectos/Perfil.jsp"><i class="fa fa-user mr-2"></i>Perfil</a>
        <a class="nav-link" href="../cerrar.jsp"><i class="fa fa-sign-out mr-2"></i>Cerrar Sesi&oacute;n</a>
    </nav>
</div>
<div class="main-content">
    <div class="page-header">
        <ol class="breadcrumb"><li class="breadcrumb-item"><a href="#">Menu</a></li><li class="breadcrumb-item"><a href="#">Inventario</a></li><li class="breadcrumb-item active">Solicitudes de suministros</li></ol>
        <h4><i class="fa fa-inbox mr-2"></i>Solicitudes de Suministros</h4>
    </div>
    <div class="content-area">

        <% if (msgExito != null) { %>
        <div class="alert alert-success alert-dismissible">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="fa fa-check-circle mr-1"></i><%=msgExito%>
        </div>
        <% } %>
        <% if (msgError != null) { %>
        <div class="alert alert-danger alert-dismissible">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="fa fa-exclamation-triangle mr-1"></i><%=msgError%>
        </div>
        <% } %>

        <div class="card mb-3">
            <div class="card-body py-2">
                <form method="get" class="form-inline">
                    <label class="mr-2 text-muted" style="font-size:.85rem;">Filtrar por estado:</label>
                    <select name="estado" class="form-control form-control-sm mr-2" onchange="this.form.submit()">
                        <option value="PENDIENTE" <%=request.getParameter("estado")==null||"PENDIENTE".equals(request.getParameter("estado"))?"selected":""%>>Pendientes</option>
                        <option value="ENTREGADO"  <%="ENTREGADO".equals(request.getParameter("estado"))?"selected":""%>>Entregados</option>
                        <option value="TODOS"      <%="TODOS".equals(request.getParameter("estado"))?"selected":""%>>Todos</option>
                    </select>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span class="font-weight-bold" style="font-size:.95rem;"><i class="fa fa-clipboard mr-1"></i>Solicitudes &mdash;
                    <% if("PENDIENTE".equals(filtroEstado)){ %><span class="text-warning">Pendientes</span>
                    <% } else if("ENTREGADO".equals(filtroEstado)){ %><span class="text-success">Entregadas</span>
                    <% } else { %><span class="text-secondary">Todas</span><% } %>
                </span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead><tr><th class="pl-3">#</th><th>Fecha</th><th>Departamento</th><th>Solicitante</th><th>Autorizado por</th><th class="text-center">&Iacute;tems</th><th class="text-center">Estado</th><th class="text-center">Acciones</th></tr></thead>
                        <tbody>
                        <%
                            try {
                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                Connection cn = DriverManager.getConnection(url, user, pass);
                                PreparedStatement st = cn.prepareStatement(sqlLista);
                                ResultSet rs = st.executeQuery();
                                boolean hayRegistros = false;
                                while (rs.next()) {
                                    hayRegistros = true;
                                    int idCab    = rs.getInt(1);
                                    String fecha = rs.getDate(2) != null ? sdf.format(rs.getDate(2)) : "—";
                                    String estado= rs.getString(3) != null ? rs.getString(3) : "";
                                    String depto = rs.getString(4) != null ? rs.getString(4) : "Sin depto.";
                                    String solic = rs.getString(5) != null ? rs.getString(5) : "—";
                                    String autor = rs.getString(6) != null ? rs.getString(6) : "—";
                                    int    items = rs.getInt(7);
                        %>
                            <tr>
                                <td class="pl-3 font-weight-bold text-secondary"><%=idCab%></td>
                                <td><%=fecha%></td><td><%=depto%></td><td><%=solic%></td><td><%=autor%></td>
                                <td class="text-center"><span class="badge badge-secondary"><%=items%></span></td>
                                <td class="text-center">
                                    <% if ("PENDIENTE".equals(estado)) { %>
                                        <span class="badge-pendiente"><i class="fa fa-clock-o mr-1"></i>Pendiente</span>
                                    <% } else { %>
                                        <span class="badge-entregado"><i class="fa fa-check mr-1"></i>Entregado</span>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <button type="button" class="btn btn-sm btn-outline-primary"
                                            data-toggle="modal" data-target="#modalDetalle"
                                            data-id="<%=idCab%>" data-estado="<%=estado%>"
                                            data-depto="<%=depto%>" data-solic="<%=solic%>" data-fecha="<%=fecha%>">
                                        <i class="fa fa-eye"></i> Ver
                                    </button>
                                    <% if ("PENDIENTE".equals(estado) && puedeDespachar) { %>
                                    <a href="INV_Despachar_Suministro.jsp?id=<%=idCab%>" class="btn btn-sm btn-success ml-1">
                                        <i class="fa fa-check"></i> Despachar
                                    </a>
                                    <% } else if (!"PENDIENTE".equals(estado)) { %>
                                    <a href="INV_Comprobante_Egreso.jsp?id=<%=idCab%>" target="_blank"
                                       class="btn btn-sm btn-info ml-1" title="Imprimir comprobante de entrega">
                                        <i class="fa fa-print"></i> Comprobante
                                    </a>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hayRegistros) {
                        %>
                            <tr><td colspan="8" class="text-center text-muted py-4"><i class="fa fa-inbox fa-2x mb-2 d-block"></i>No hay solicitudes.</td></tr>
                        <%  }
                                rs.close(); st.close(); cn.close();
                            } catch (Exception ex) { ex.printStackTrace();
                        %>
                            <tr><td colspan="8" class="text-center text-danger py-3"><i class="fa fa-exclamation-triangle mr-1"></i>Error: <%=ex.getMessage()%></td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal detalle -->
<div class="modal fade" id="modalDetalle" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-list-alt mr-2"></i>Detalle Solicitud #<span id="modalId"></span></h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="row mb-3">
                    <div class="col-md-4"><small class="text-muted">Fecha</small><div id="modalFecha" class="font-weight-bold"></div></div>
                    <div class="col-md-4"><small class="text-muted">Departamento</small><div id="modalDepto" class="font-weight-bold"></div></div>
                    <div class="col-md-4"><small class="text-muted">Solicitante</small><div id="modalSolic" class="font-weight-bold"></div></div>
                </div>
                <hr class="my-2">
                <p class="text-muted mb-2" style="font-size:.85rem;"><strong>Productos solicitados:</strong></p>
                <div id="modalProductos"><div class="text-center text-muted py-3"><i class="fa fa-spinner fa-spin mr-1"></i>Cargando...</div></div>
            </div>
            <div class="modal-footer">
                <span id="modalAccionBtn"></span>
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0</footer>
<script>
var puedeDespachar = <%=puedeDespachar%>;
$('#modalDetalle').on('show.bs.modal', function(event) {
    var btn=$(event.relatedTarget), id=btn.data('id'), estado=btn.data('estado'),
        depto=btn.data('depto'), solic=btn.data('solic'), fecha=btn.data('fecha');
    $('#modalId').text(id); $('#modalFecha').text(fecha); $('#modalDepto').text(depto); $('#modalSolic').text(solic);
    if (estado==='PENDIENTE' && puedeDespachar) {
        $('#modalAccionBtn').html('<a href="INV_Despachar_Suministro.jsp?id='+id+'" class="btn btn-success btn-sm"><i class="fa fa-check mr-1"></i>Despachar</a>');
    } else if (estado==='PENDIENTE') {
        $('#modalAccionBtn').html('<span class="badge-pendiente"><i class="fa fa-clock-o mr-1"></i>Pendiente de despacho</span>');
    } else {
        $('#modalAccionBtn').html('<a href="INV_Comprobante_Egreso.jsp?id='+id+'" target="_blank" class="btn btn-info btn-sm"><i class="fa fa-print mr-1"></i>Imprimir Comprobante</a>');
    }
    $('#modalProductos').html('<div class="text-center text-muted py-3"><i class="fa fa-spinner fa-spin mr-1"></i>Cargando...</div>');
    $.get('INV_Detalle_Egreso_Ajax.jsp?id='+id, function(data){ $('#modalProductos').html(data); })
     .fail(function(){ $('#modalProductos').html('<div class="text-center text-muted py-2">No se pudieron cargar los productos.</div>'); });
});
</script>
</body>
</html>
