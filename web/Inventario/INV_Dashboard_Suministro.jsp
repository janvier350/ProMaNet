<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.util.Date, java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%
    String cargo    = (String) session.getAttribute("cargo");
    String nombre   = (String) session.getAttribute("nombre");
    String apellidos= (String) session.getAttribute("apellidos");
    String user     = (String) session.getAttribute("userDB");
    String pass     = (String) session.getAttribute("passDB");
    String ip       = (String) session.getAttribute("ipDB");
    String url      = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR"))) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String compania      = "";
    int totalPendiente   = 0;
    int entregadosMes    = 0;
    int productosSinStock= 0;
    int totalProductos   = 0;
    int totalSolicitudes = 0;

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    StringBuilder filasRecientes  = new StringBuilder();
    StringBuilder filasBajoStock  = new StringBuilder();

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        PreparedStatement stC = cn.prepareStatement(
            "SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsC = stC.executeQuery();
        if (rsC.next()) compania = rsC.getString(1);
        rsC.close(); stC.close();

        PreparedStatement stP = cn.prepareStatement(
            "SELECT COUNT(*) FROM INV_SUMINISTRO_EGRESO_CAB WHERE ESTADO_SOLICITUD='PENDIENTE'");
        ResultSet rsP = stP.executeQuery();
        if (rsP.next()) totalPendiente = rsP.getInt(1);
        rsP.close(); stP.close();

        PreparedStatement stE = cn.prepareStatement(
            "SELECT COUNT(*) FROM INV_SUMINISTRO_EGRESO_CAB " +
            "WHERE ESTADO_SOLICITUD='ENTREGADO' AND TRUNC(FECHA_SOLICITUD,'MM')=TRUNC(SYSDATE,'MM')");
        ResultSet rsE = stE.executeQuery();
        if (rsE.next()) entregadosMes = rsE.getInt(1);
        rsE.close(); stE.close();

        PreparedStatement stTS = cn.prepareStatement(
            "SELECT COUNT(*) FROM INV_SUMINISTRO_EGRESO_CAB");
        ResultSet rsTS = stTS.executeQuery();
        if (rsTS.next()) totalSolicitudes = rsTS.getInt(1);
        rsTS.close(); stTS.close();

        PreparedStatement stSS = cn.prepareStatement(
            "SELECT COUNT(*) FROM INV_SUMINISTRO_EXISTENCIA WHERE NVL(EXISTENCIA,0) = 0");
        ResultSet rsSS = stSS.executeQuery();
        if (rsSS.next()) productosSinStock = rsSS.getInt(1);
        rsSS.close(); stSS.close();

        PreparedStatement stTP = cn.prepareStatement(
            "SELECT COUNT(*) FROM INV_PRODUCTO");
        ResultSet rsTP = stTP.executeQuery();
        if (rsTP.next()) totalProductos = rsTP.getInt(1);
        rsTP.close(); stTP.close();

        String sqlRecientes =
            "SELECT * FROM (" +
            "  SELECT e.ID_SUMINISTRO_EGRESO_CAB, e.FECHA_SOLICITUD, e.ESTADO_SOLICITUD, " +
            "         d.DEPARTAMENTO, u.NOMBRE||' '||u.APELLIDOS AS SOLIC " +
            "  FROM INV_SUMINISTRO_EGRESO_CAB e " +
            "  LEFT JOIN ADM_DEPARTAMENTO d ON TO_CHAR(e.ID_DEPARTAMENTO)=d.ID_DEPARTAMENTO " +
            "  LEFT JOIN USUARIO u ON e.ID_USUARIO=u.IDUSUARIO " +
            "  ORDER BY e.FECHA_SOLICITUD DESC" +
            ") WHERE ROWNUM <= 5";
        PreparedStatement stR = cn.prepareStatement(sqlRecientes);
        ResultSet rsR = stR.executeQuery();
        SimpleDateFormat sdfCorta = new SimpleDateFormat("dd/MM/yyyy");
        while (rsR.next()) {
            int    id     = rsR.getInt(1);
            String fecha  = rsR.getDate(2) != null ? sdfCorta.format(rsR.getDate(2)) : "—";
            String est    = rsR.getString(3) != null ? rsR.getString(3) : "";
            String dep    = rsR.getString(4) != null ? rsR.getString(4) : "—";
            String sol    = rsR.getString(5) != null ? rsR.getString(5) : "—";
            String badgeCls = "PENDIENTE".equals(est)
                ? "style=\"background:#fff3cd;color:#856404;padding:2px 8px;border-radius:10px;font-size:.75rem;\""
                : "style=\"background:#d1e7dd;color:#0f5132;padding:2px 8px;border-radius:10px;font-size:.75rem;\"";
            filasRecientes.append("<tr>")
                .append("<td class='pl-3 font-weight-bold text-primary'>#").append(id).append("</td>")
                .append("<td>").append(fecha).append("</td>")
                .append("<td>").append(dep).append("</td>")
                .append("<td>").append(sol).append("</td>")
                .append("<td class='text-center'><span ").append(badgeCls).append(">").append(est).append("</span></td>")
                .append("<td class='text-center'>")
                .append("<a href='INV_Lista_Solicitudes_Suministro.jsp' class='btn btn-xs btn-outline-secondary' style='font-size:.75rem;padding:2px 8px;'>Ver</a>")
                .append("</td></tr>");
        }
        rsR.close(); stR.close();

        String sqlBajo =
            "SELECT * FROM (" +
            "  SELECT p.DESCRIPCION, p.UNIDAD, e.EXISTENCIA " +
            "  FROM INV_SUMINISTRO_EXISTENCIA e " +
            "  JOIN INV_PRODUCTO p ON e.ID_PRODUCTO=p.ID_PRODUCTO " +
            "  WHERE e.EXISTENCIA > 0 AND e.EXISTENCIA <= 5 " +
            "  ORDER BY e.EXISTENCIA ASC" +
            ") WHERE ROWNUM <= 8";
        PreparedStatement stBajo = cn.prepareStatement(sqlBajo);
        ResultSet rsBajo = stBajo.executeQuery();
        while (rsBajo.next()) {
            String desc    = rsBajo.getString(1);
            String unidad  = rsBajo.getString(2) != null ? rsBajo.getString(2) : "";
            int    exis    = rsBajo.getInt(3);
            String color   = exis <= 2 ? "#dc3545" : "#fd7e14";
            filasBajoStock.append("<tr>")
                .append("<td>").append(desc).append(" <small class='text-muted'>(").append(unidad).append(")</small></td>")
                .append("<td class='text-center font-weight-bold' style='color:").append(color).append(";'>").append(exis).append("</td>")
                .append("<td class='text-center'>")
                .append(exis <= 2
                    ? "<span class='badge badge-danger'>Crítico</span>"
                    : "<span class='badge badge-warning'>Bajo</span>")
                .append("</td></tr>");
        }
        rsBajo.close(); stBajo.close();
        cn.close();
    } catch (Exception ex) { ex.printStackTrace(); }

    String ahora = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Dashboard Suministros</title>
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
        .sidebar .nav-section{padding:10px 20px 4px;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;}
        .main-content{margin-left:220px;}
        .page-header{background:linear-gradient(135deg,#3d5a99,#5b7fc4);color:#fff;padding:18px 28px 14px;}
        .page-header .breadcrumb{background:transparent;padding:0;margin:0 0 4px;font-size:.8rem;}
        .page-header .breadcrumb-item a{color:rgba(255,255,255,.75);}
        .page-header .breadcrumb-item.active{color:#fff;}
        .page-header h4{margin:0;font-weight:600;}
        .content-area{padding:24px;}
        .metric-card{border:none;border-radius:10px;padding:18px 20px;color:#fff;display:flex;align-items:center;justify-content:space-between;box-shadow:0 3px 10px rgba(0,0,0,.15);}
        .metric-card .metric-icon{font-size:2rem;opacity:.7;}
        .metric-card .metric-val{font-size:2rem;font-weight:700;line-height:1;}
        .metric-card .metric-lbl{font-size:.78rem;opacity:.9;margin-top:2px;}
        .bg-azul{background:linear-gradient(135deg,#3d5a99,#5b7fc4);}
        .bg-verde{background:linear-gradient(135deg,#1b7a4e,#28a870);}
        .bg-naranja{background:linear-gradient(135deg,#c75a00,#fd7e14);}
        .bg-gris{background:linear-gradient(135deg,#495057,#6c757d);}
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:13px 18px;font-weight:600;font-size:.92rem;}
        .table th{background:#f8f9fb;font-size:.76rem;text-transform:uppercase;color:#666;letter-spacing:.5px;}
        .table td{vertical-align:middle;font-size:.87rem;}
        .footer{margin-left:220px;padding:12px 24px;font-size:.78rem;color:#aaa;border-top:1px solid #eee;}
        .fecha-act{font-size:.78rem;color:rgba(255,255,255,.7);margin-top:4px;}
    </style>
</head>
<body>
<div class="topbar">
    <span class="brand"><i class="fa fa-th-large mr-2"></i>INVENTARIOS</span>
    <span class="user-info"><%=compania%><br><strong><%=nombre%> <%=apellidos%></strong></span>
</div>
<div class="sidebar">
    <nav class="nav flex-column pt-3">
        <a class="nav-link active" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
        <a class="nav-link" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
        <a class="nav-link" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
        <a class="nav-link" href="INV_Historial_Solicitudes_Departamento.jsp"><i class="fa fa-building mr-2"></i>Historial por Departamento</a>
        <div class="nav-section">Ingresos</div>
        <a class="nav-link" href="INV_Ingreso_Suministro2.jsp"><i class="fa fa-plus-circle mr-2"></i>Registrar ingreso</a>
        <div class="nav-section">Panel de control</div>
        <a class="nav-link" href="../Proyectos/Perfil.jsp"><i class="fa fa-user mr-2"></i>Perfil</a>
        <a class="nav-link" href="../cerrar.jsp"><i class="fa fa-sign-out mr-2"></i>Cerrar Sesi&oacute;n</a>
    </nav>
</div>
<div class="main-content">
    <div class="page-header">
        <ol class="breadcrumb"><li class="breadcrumb-item"><a href="#">Menu</a></li><li class="breadcrumb-item active">Dashboard Suministros</li></ol>
        <h4><i class="fa fa-tachometer mr-2"></i>Dashboard &mdash; Suministros de Oficina</h4>
        <div class="fecha-act"><i class="fa fa-refresh mr-1"></i>Actualizado: <%=ahora%></div>
    </div>
    <div class="content-area">
        <% if (totalPendiente > 0) { %>
        <div class="alert alert-warning d-flex align-items-center py-2 mb-3">
            <i class="fa fa-bell fa-lg mr-3 text-warning"></i>
            <div>Tienes <strong><%=totalPendiente%> solicitud<%=totalPendiente>1?"es":""%> pendiente<%=totalPendiente>1?"s":""%></strong> de despacho.
            <a href="INV_Lista_Solicitudes_Suministro.jsp" class="ml-2 font-weight-bold">Ver ahora &rarr;</a></div>
        </div>
        <% } %>
        <div class="row mb-4">
            <div class="col-md-3 mb-3"><div class="metric-card bg-azul"><div><div class="metric-val"><%=totalPendiente%></div><div class="metric-lbl">Solicitudes pendientes</div></div><i class="fa fa-clock-o metric-icon"></i></div></div>
            <div class="col-md-3 mb-3"><div class="metric-card bg-verde"><div><div class="metric-val"><%=entregadosMes%></div><div class="metric-lbl">Despachadas este mes</div></div><i class="fa fa-check-circle metric-icon"></i></div></div>
            <div class="col-md-3 mb-3"><div class="metric-card bg-naranja"><div><div class="metric-val"><%=productosSinStock%></div><div class="metric-lbl">Productos sin stock</div></div><i class="fa fa-exclamation-triangle metric-icon"></i></div></div>
            <div class="col-md-3 mb-3"><div class="metric-card bg-gris"><div><div class="metric-val"><%=totalProductos%></div><div class="metric-lbl">Total productos registrados</div></div><i class="fa fa-list metric-icon"></i></div></div>
        </div>
        <div class="row">
            <div class="col-md-7">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="fa fa-history mr-2 text-primary"></i>&#218;ltimas solicitudes</span>
                        <a href="INV_Lista_Solicitudes_Suministro.jsp?estado=TODOS" class="btn btn-sm btn-outline-primary" style="font-size:.78rem;">Ver todas</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead><tr><th class="pl-3">#</th><th>Fecha</th><th>Departamento</th><th>Solicitante</th><th class="text-center">Estado</th><th class="text-center">Acci&oacute;n</th></tr></thead>
                                <tbody>
                                    <% if (filasRecientes.length() == 0) { %>
                                    <tr><td colspan="6" class="text-center text-muted py-3">Sin solicitudes a&uacute;n.</td></tr>
                                    <% } else { %><%=filasRecientes.toString()%><% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-5">
                <div class="card">
                    <div class="card-header"><i class="fa fa-exclamation-circle mr-2 text-warning"></i>Stock bajo <small class="text-muted ml-1">(&le; 5 unidades)</small></div>
                    <div class="card-body p-0">
                        <% if (filasBajoStock.length() == 0) { %>
                        <div class="text-center text-muted py-4"><i class="fa fa-check-circle fa-2x text-success d-block mb-2"></i>Stock suficiente en todos los productos.</div>
                        <% } else { %>
                        <div class="table-responsive"><table class="table table-hover mb-0"><thead><tr><th class="pl-3">Producto</th><th class="text-center">Existencia</th><th class="text-center">Nivel</th></tr></thead><tbody><%=filasBajoStock.toString()%></tbody></table></div>
                        <% } %>
                    </div>
                </div>
                <div class="card">
                    <div class="card-header"><i class="fa fa-bolt mr-2 text-secondary"></i>Accesos r&aacute;pidos</div>
                    <div class="card-body">
                        <a href="INV_Lista_Solicitudes_Suministro.jsp" class="btn btn-warning btn-sm btn-block mb-2"><i class="fa fa-inbox mr-1"></i>Ver pendientes<% if(totalPendiente>0){ %> <span class="badge badge-dark"><%=totalPendiente%></span><% } %></a>
                        <a href="INV_Ingreso_Suministro2.jsp" class="btn btn-primary btn-sm btn-block mb-2"><i class="fa fa-plus mr-1"></i>Registrar ingreso</a>
                        <a href="INV_Existencias_Dashboard.jsp" class="btn btn-success btn-sm btn-block mb-2"><i class="fa fa-bar-chart mr-1"></i>Existencias y Alertas</a>
                        <a href="INV_Lista_Solicitudes_Suministro.jsp?estado=ENTREGADO" class="btn btn-secondary btn-sm btn-block"><i class="fa fa-check-circle mr-1"></i>Historial de despachos</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0 &nbsp;|&nbsp; M&oacute;dulo: Inventario de Suministros</footer>
</body>
</html>
