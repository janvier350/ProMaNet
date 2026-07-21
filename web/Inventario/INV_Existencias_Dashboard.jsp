<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.util.Date,java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%
    String cargo     = (String) session.getAttribute("cargo");
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String user      = (String) session.getAttribute("userDB");
    String pass      = (String) session.getAttribute("passDB");
    String ip        = (String) session.getAttribute("ipDB");
    String url       = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EXISTENCIAS")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean puedeRegistrarIngreso = COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS");

    // Stock thresholds (configurable)
    int UMBRAL_BAJO = 10;

    String compania       = "";
    int    totalProductos = 0;
    long   totalUnidades  = 0;
    int    sinStockCnt    = 0;
    int    bajoCnt        = 0;
    int    despachosMes   = 0;

    StringBuilder filasProd    = new StringBuilder();
    StringBuilder filasAlertas = new StringBuilder();
    StringBuilder jMesLbl  = new StringBuilder();
    StringBuilder jMesDat  = new StringBuilder();
    StringBuilder jTopLbl  = new StringBuilder();
    StringBuilder jTopDat  = new StringBuilder();
    StringBuilder jDeptLbl = new StringBuilder();
    StringBuilder jDeptDat = new StringBuilder();

    String ahora = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        // Company name
        PreparedStatement stC = cn.prepareStatement(
                "SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsC = stC.executeQuery();
        if (rsC.next()) compania = rsC.getString(1);
        rsC.close(); stC.close();

        // Despachos this month
        PreparedStatement stDM = cn.prepareStatement(
                "SELECT COUNT(*) FROM INV_SUMINISTRO_EGRESO_CAB " +
                "WHERE ESTADO_SOLICITUD='ENTREGADO' AND TRUNC(FECHA_SOLICITUD,'MM')=TRUNC(SYSDATE,'MM')");
        ResultSet rsDM = stDM.executeQuery();
        if (rsDM.next()) despachosMes = rsDM.getInt(1);
        rsDM.close(); stDM.close();

        // All products with current stock (SUM in case of multiple rows per product)
        PreparedStatement stProd = cn.prepareStatement(
                "SELECT p.ID_PRODUCTO, p.DESCRIPCION, p.UNIDAD, NVL(SUM(e.EXISTENCIA),0) AS STOCK, p.ID_UNIDAD " +
                "FROM INV_PRODUCTO p " +
                "LEFT JOIN INV_SUMINISTRO_EXISTENCIA e ON p.ID_PRODUCTO = e.ID_PRODUCTO " +
                "WHERE NVL(p.ESTADO,'A') = 'A' " +
                "GROUP BY p.ID_PRODUCTO, p.DESCRIPCION, p.UNIDAD, p.ID_UNIDAD " +
                "ORDER BY STOCK ASC, p.DESCRIPCION");
        ResultSet rsProd = stProd.executeQuery();
        while (rsProd.next()) {
            totalProductos++;
            int    idP       = rsProd.getInt(1);
            String desc      = rsProd.getString(2) != null ? rsProd.getString(2) : "";
            String unidadVal = rsProd.getString(3) != null ? rsProd.getString(3) : "";
            String unidad    = unidadVal.isEmpty() ? "—" : unidadVal;
            long   stock     = rsProd.getLong(4);
            String idUnidadProd = rsProd.getString(5) != null ? rsProd.getString(5) : "";
            totalUnidades += stock;

            String nivel, badgeCls, rowCls;
            if (stock == 0) {
                sinStockCnt++;
                nivel = "SIN STOCK"; badgeCls = "badge badge-danger"; rowCls = "bg-danger-light";
            } else if (stock <= UMBRAL_BAJO) {
                bajoCnt++;
                nivel = "BAJO"; badgeCls = "badge badge-warning"; rowCls = "bg-warning-light";
            } else {
                nivel = "OK"; badgeCls = "badge badge-success"; rowCls = "";
            }

            String descAttr   = desc.replace("&","&amp;").replace("\"","&quot;").replace("'","&#39;");
            String unidadAttr = unidadVal.replace("&","&amp;").replace("\"","&quot;").replace("'","&#39;");

            filasProd.append("<tr class='"  ).append(rowCls)
                      .append("' data-desc='").append(desc.toLowerCase().replace("'",""))
                      .append("'>")
                      .append("<td class='text-center text-muted small'>").append(idP).append("</td>")
                      .append("<td>").append(desc).append("</td>")
                      .append("<td class='text-center'>").append(unidad).append("</td>")
                      .append("<td class='text-center font-weight-bold'>").append(stock).append("</td>")
                      .append("<td class='text-center'><span class='"   ).append(badgeCls)
                      .append("' style='font-size:.73rem;padding:3px 8px;'>").append(nivel)
                      .append("</span></td>")
                      .append("<td class='text-center'>")
                      .append("<button type='button' class='btn btn-xs btn-outline-primary btn-editar-prod' style='font-size:.73rem;padding:2px 8px;' ")
                      .append("data-id='").append(idP).append("' ")
                      .append("data-desc=\"").append(descAttr).append("\" ")
                      .append("data-unidad=\"").append(unidadAttr).append("\" ")
                      .append("data-idunidad=\"").append(idUnidadProd).append("\">")
                      .append("<i class='fa fa-pencil'></i> Editar</button>")
                      .append("</td></tr>\n");

            if (stock <= UMBRAL_BAJO) {
                String urg    = stock == 0 ? "URGENTE" : (stock <= 3 ? "Alta" : "Media");
                String urgCls = stock == 0 ? "badge-danger" : (stock <= 3 ? "badge-warning" : "badge-secondary");
                String color  = stock == 0 ? "#dc3545" : (stock <= 3 ? "#e07000" : "#6c757d");
                filasAlertas.append("<tr>")
                    .append("<td class='pl-3'>").append(desc)
                    .append(" <small class='text-muted'>(").append(unidad).append(")</small></td>")
                    .append("<td class='text-center font-weight-bold' style='color:").append(color).append(";'>")
                    .append(stock).append("</td>")
                    .append("<td class='text-center'><span class='badge ").append(urgCls).append("'>")
                    .append(urg).append("</span></td>")
                    .append("<td>").append(stock == 0
                        ? "<i class='fa fa-exclamation-triangle text-danger mr-1'></i><strong>Reabastecer de inmediato</strong>"
                        : "<i class='fa fa-bell text-warning mr-1'></i>Programar compra pronto")
                    .append("</td></tr>\n");
            }
        }
        rsProd.close(); stProd.close();

        // Top 10 most consumed products
        PreparedStatement stTop = cn.prepareStatement(
                "SELECT * FROM (" +
                "  SELECT p.DESCRIPCION, SUM(d.CANTIDAD) AS TOTAL " +
                "  FROM INV_SUMINISTRO_EGRESO_DET d " +
                "  JOIN INV_PRODUCTO p ON d.ID_PRODUCTO = p.ID_PRODUCTO " +
                "  JOIN INV_SUMINISTRO_EGRESO_CAB c ON d.ID_SUMINISTRO_EGRESO_CAB = c.ID_SUMINISTRO_EGRESO_CAB " +
                "  WHERE c.ESTADO_SOLICITUD = 'ENTREGADO' " +
                "  GROUP BY p.DESCRIPCION ORDER BY TOTAL DESC" +
                ") WHERE ROWNUM <= 10");
        ResultSet rsTop = stTop.executeQuery();
        while (rsTop.next()) {
            String d = rsTop.getString(1).replace("\\", "\\\\").replace("\"", "\\\"");
            jTopLbl.append("\"").append(d).append("\",");
            jTopDat.append(rsTop.getLong(2)).append(",");
        }
        rsTop.close(); stTop.close();

        // Consumo por mes (last 6 months)
        PreparedStatement stMes = cn.prepareStatement(
                "SELECT TO_CHAR(c.FECHA_SOLICITUD,'MM/YYYY') AS MES, " +
                "       TO_CHAR(c.FECHA_SOLICITUD,'YYYYMM') AS ORDEN, " +
                "       SUM(d.CANTIDAD) AS TOTAL " +
                "FROM INV_SUMINISTRO_EGRESO_DET d " +
                "JOIN INV_SUMINISTRO_EGRESO_CAB c ON d.ID_SUMINISTRO_EGRESO_CAB = c.ID_SUMINISTRO_EGRESO_CAB " +
                "WHERE c.ESTADO_SOLICITUD = 'ENTREGADO' " +
                "  AND c.FECHA_SOLICITUD >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -5) " +
                "GROUP BY TO_CHAR(c.FECHA_SOLICITUD,'MM/YYYY'), TO_CHAR(c.FECHA_SOLICITUD,'YYYYMM') " +
                "ORDER BY ORDEN");
        ResultSet rsMes = stMes.executeQuery();
        while (rsMes.next()) {
            jMesLbl.append("\"").append(rsMes.getString(1)).append("\",");
            jMesDat.append(rsMes.getLong(3)).append(",");
        }
        rsMes.close(); stMes.close();

        // Consumo por departamento
        PreparedStatement stDpt = cn.prepareStatement(
                "SELECT NVL(d.DEPARTAMENTO,'Sin Depto.') AS DEPTO, SUM(det.CANTIDAD) AS TOTAL " +
                "FROM INV_SUMINISTRO_EGRESO_DET det " +
                "JOIN INV_SUMINISTRO_EGRESO_CAB c ON det.ID_SUMINISTRO_EGRESO_CAB = c.ID_SUMINISTRO_EGRESO_CAB " +
                "LEFT JOIN ADM_DEPARTAMENTO d ON TO_CHAR(c.ID_DEPARTAMENTO) = d.ID_DEPARTAMENTO " +
                "WHERE c.ESTADO_SOLICITUD = 'ENTREGADO' " +
                "GROUP BY NVL(d.DEPARTAMENTO,'Sin Depto.') " +
                "ORDER BY TOTAL DESC");
        ResultSet rsDpt = stDpt.executeQuery();
        while (rsDpt.next()) {
            String d = rsDpt.getString(1).replace("\\", "\\\\").replace("\"", "\\\"");
            jDeptLbl.append("\"").append(d).append("\",");
            jDeptDat.append(rsDpt.getLong(2)).append(",");
        }
        rsDpt.close(); stDpt.close();

        cn.close();
    } catch (Exception ex) { ex.printStackTrace(); }

    String sTopL  = jTopLbl.length()  > 0 ? jTopLbl.substring(0,  jTopLbl.length()-1)  : "";
    String sTopD  = jTopDat.length()  > 0 ? jTopDat.substring(0,  jTopDat.length()-1)  : "";
    String sMesL  = jMesLbl.length()  > 0 ? jMesLbl.substring(0,  jMesLbl.length()-1)  : "";
    String sMesD  = jMesDat.length()  > 0 ? jMesDat.substring(0,  jMesDat.length()-1)  : "";
    String sDptL  = jDeptLbl.length() > 0 ? jDeptLbl.substring(0, jDeptLbl.length()-1) : "";
    String sDptD  = jDeptDat.length() > 0 ? jDeptDat.substring(0, jDeptDat.length()-1) : "";

    int totalAlertas = sinStockCnt + bajoCnt;

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
    <title>ProMaNet - Existencias y Alertas</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
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
        .page-header{background:linear-gradient(135deg,#1b5e3b,#28a870);color:#fff;padding:18px 28px 14px;}
        .page-header .breadcrumb{background:transparent;padding:0;margin:0 0 4px;font-size:.8rem;}
        .page-header .breadcrumb-item a{color:rgba(255,255,255,.75);}
        .page-header .breadcrumb-item.active{color:#fff;}
        .page-header h4{margin:0;font-weight:600;}
        .fecha-act{font-size:.78rem;color:rgba(255,255,255,.7);margin-top:4px;}
        .content-area{padding:24px;}
        .metric-card{border:none;border-radius:10px;padding:18px 20px;color:#fff;display:flex;align-items:center;justify-content:space-between;box-shadow:0 3px 10px rgba(0,0,0,.15);}
        .metric-card .metric-icon{font-size:2rem;opacity:.7;}
        .metric-card .metric-val{font-size:2rem;font-weight:700;line-height:1;}
        .metric-card .metric-lbl{font-size:.78rem;opacity:.9;margin-top:2px;}
        .bg-azul   {background:linear-gradient(135deg,#3d5a99,#5b7fc4);}
        .bg-verde  {background:linear-gradient(135deg,#1b7a4e,#28a870);}
        .bg-rojo   {background:linear-gradient(135deg,#8b0000,#dc3545);}
        .bg-naranja{background:linear-gradient(135deg,#c75a00,#fd7e14);}
        .bg-gris   {background:linear-gradient(135deg,#3d4f5a,#607d8b);}
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:13px 18px;font-weight:600;font-size:.92rem;}
        .table th{background:#f8f9fb;font-size:.74rem;text-transform:uppercase;color:#666;letter-spacing:.5px;}
        .table td{vertical-align:middle;font-size:.86rem;}
        .bg-danger-light {background:rgba(220,53,69,.07);}
        .bg-warning-light{background:rgba(255,193,7,.07);}
        .footer{margin-left:220px;padding:12px 24px;font-size:.78rem;color:#aaa;border-top:1px solid #eee;}
        .empty-chart{display:flex;flex-direction:column;align-items:center;justify-content:center;height:200px;color:#bbb;font-size:.9rem;}
    </style>
</head>
<body>

<div class="topbar">
    <span class="brand"><i class="fa fa-th-large mr-2"></i>INVENTARIOS</span>
    <span class="user-info"><%=compania%><br><strong><%=nombre%> <%=apellidos%></strong></span>
</div>

<div class="sidebar">
    <nav class="nav flex-column pt-3">
        <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
        <a class="nav-link" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
        <a class="nav-link active" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
        <% if (COMUN.PermisoHelper.tiene(session, "INVENTARIO_SOLICITAR")) { %>
        <a class="nav-link" href="INV_Solicitar_Suministro_Detalle.jsp"><i class="fa fa-plus-circle mr-2"></i>Solicitar Suministro</a>
        <% } %>
        <a class="nav-link" href="INV_Historial_Solicitudes_Departamento.jsp"><i class="fa fa-building mr-2"></i>Historial por Departamento</a>
        <% if (puedeRegistrarIngreso) { %>
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
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="#">Men&uacute;</a></li>
            <li class="breadcrumb-item"><a href="INV_Dashboard_Suministro.jsp">Inventario</a></li>
            <li class="breadcrumb-item active">Existencias y Alertas</li>
        </ol>
        <h4><i class="fa fa-bar-chart mr-2"></i>Dashboard de Existencias &amp; Alertas de Compra</h4>
        <div class="fecha-act"><i class="fa fa-refresh mr-1"></i>Actualizado: <%=ahora%></div>
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

        <%-- Alert banner --%>
        <% if (sinStockCnt > 0) { %>
        <div class="alert alert-danger d-flex align-items-center py-2 mb-3">
            <i class="fa fa-exclamation-triangle fa-lg mr-3"></i>
            <div>
                <strong>&#9888; <%=sinStockCnt%> producto<%=sinStockCnt>1?"s":"" %> SIN STOCK</strong>
                &mdash; Requiere compra inmediata.
                <a href="#alertasCompra" class="ml-2 font-weight-bold">Ver detalle &darr;</a>
            </div>
        </div>
        <% } else if (bajoCnt > 0) { %>
        <div class="alert alert-warning d-flex align-items-center py-2 mb-3">
            <i class="fa fa-bell fa-lg mr-3"></i>
            <div>
                <strong><%=bajoCnt%> producto<%=bajoCnt>1?"s tienen":" tiene" %> stock bajo</strong>
                &mdash; Programa una compra pronto.
                <a href="#alertasCompra" class="ml-2 font-weight-bold">Ver detalle &darr;</a>
            </div>
        </div>
        <% } %>

        <%-- Metric cards --%>
        <div class="row mb-4">
            <div class="col mb-3">
                <div class="metric-card bg-azul">
                    <div><div class="metric-val"><%=totalProductos%></div><div class="metric-lbl">Total productos</div></div>
                    <i class="fa fa-cubes metric-icon"></i>
                </div>
            </div>
            <div class="col mb-3">
                <div class="metric-card bg-verde">
                    <div><div class="metric-val"><%=totalUnidades%></div><div class="metric-lbl">Unidades en stock</div></div>
                    <i class="fa fa-archive metric-icon"></i>
                </div>
            </div>
            <div class="col mb-3">
                <div class="metric-card bg-rojo">
                    <div><div class="metric-val"><%=sinStockCnt%></div><div class="metric-lbl">Sin stock (0 ud.)</div></div>
                    <i class="fa fa-times-circle metric-icon"></i>
                </div>
            </div>
            <div class="col mb-3">
                <div class="metric-card bg-naranja">
                    <div><div class="metric-val"><%=bajoCnt%></div><div class="metric-lbl">Stock bajo (&le;<%=UMBRAL_BAJO%>)</div></div>
                    <i class="fa fa-exclamation-circle metric-icon"></i>
                </div>
            </div>
            <div class="col mb-3">
                <div class="metric-card bg-gris">
                    <div><div class="metric-val"><%=despachosMes%></div><div class="metric-lbl">Despachos este mes</div></div>
                    <i class="fa fa-truck metric-icon"></i>
                </div>
            </div>
        </div>

        <%-- Charts row 1: consumo mensual + por departamento --%>
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header"><i class="fa fa-line-chart mr-2 text-primary"></i>Consumo mensual &mdash; &uacute;ltimos 6 meses</div>
                    <div class="card-body">
                        <% if (sMesL.isEmpty()) { %>
                        <div class="empty-chart"><i class="fa fa-bar-chart fa-2x mb-2"></i>Sin datos de consumo a&uacute;n.</div>
                        <% } else { %>
                        <div style="position:relative;height:220px;"><canvas id="chartMes"></canvas></div>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header"><i class="fa fa-pie-chart mr-2 text-success"></i>Consumo por departamento</div>
                    <div class="card-body">
                        <% if (sDptL.isEmpty()) { %>
                        <div class="empty-chart"><i class="fa fa-pie-chart fa-2x mb-2"></i>Sin datos a&uacute;n.</div>
                        <% } else { %>
                        <div style="position:relative;height:220px;"><canvas id="chartDept"></canvas></div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <%-- Charts row 2: top 10 consumidos --%>
        <div class="card">
            <div class="card-header"><i class="fa fa-trophy mr-2 text-warning"></i>Top 10 &mdash; Productos m&aacute;s consumidos (historial total)</div>
            <div class="card-body">
                <% if (sTopL.isEmpty()) { %>
                <div class="empty-chart"><i class="fa fa-trophy fa-2x mb-2"></i>No hay despachos registrados a&uacute;n.</div>
                <% } else { %>
                <div style="position:relative;height:<%=Math.max(200, jTopLbl.toString().split(",").length * 36)%>px;"><canvas id="chartTop"></canvas></div>
                <% } %>
            </div>
        </div>

        <%-- Products table --%>
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fa fa-table mr-2 text-secondary"></i>Inventario de Existencias &mdash;
                    <small class="text-muted">ordenado por stock (menor primero)</small>
                    <span class="badge badge-secondary ml-2"><%=totalProductos%> productos</span>
                </span>
                <input type="text" id="buscarProd" class="form-control form-control-sm"
                       placeholder="Buscar producto..." style="width:220px;">
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="tablaProd">
                        <thead>
                            <tr>
                                <th class="text-center" style="width:55px;">ID</th>
                                <th>Producto</th>
                                <th class="text-center">Unidad</th>
                                <th class="text-center">Existencia</th>
                                <th class="text-center" style="width:120px;">Estado</th>
                                <th class="text-center" style="width:90px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
<%=filasProd.length() > 0 ? filasProd.toString() : "<tr><td colspan='6' class='text-center text-muted py-4'><i class='fa fa-inbox fa-2x d-block mb-2'></i>No hay productos registrados.</td></tr>"%>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer text-muted" style="font-size:.78rem;">
                <i class="fa fa-info-circle mr-1"></i>
                Leyenda: <span class="badge badge-success">OK</span> &gt; <%=UMBRAL_BAJO%> ud. &nbsp;
                <span class="badge badge-warning">BAJO</span> 1 &ndash; <%=UMBRAL_BAJO%> ud. &nbsp;
                <span class="badge badge-danger">SIN STOCK</span> 0 ud.
            </div>
        </div>

        <%-- Purchase alerts --%>
        <% if (filasAlertas.length() > 0) { %>
        <div class="card" id="alertasCompra">
            <div class="card-header d-flex align-items-center" style="background:#fff8e1;border-bottom:2px solid #ffc107;">
                <i class="fa fa-shopping-cart mr-2 text-danger fa-lg"></i>
                <span class="font-weight-bold">Alertas de Compra &mdash; Productos que necesitan reabastecimiento</span>
                <span class="badge badge-danger ml-auto"><%=totalAlertas%> producto<%=totalAlertas>1?"s":""%></span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th class="pl-3">Producto</th>
                                <th class="text-center" style="width:110px;">Stock actual</th>
                                <th class="text-center" style="width:100px;">Urgencia</th>
                                <th>Acci&oacute;n recomendada</th>
                            </tr>
                        </thead>
                        <tbody><%=filasAlertas.toString()%></tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer" style="font-size:.78rem;background:#fffde7;">
                <i class="fa fa-lightbulb-o mr-1 text-warning"></i>
                Puedes registrar el ingreso de nuevos productos en
                <a href="INV_Ingreso_Suministro2.jsp">Registrar ingreso</a>.
            </div>
        </div>
        <% } else if (totalProductos > 0) { %>
        <div class="alert alert-success d-flex align-items-center py-2" id="alertasCompra">
            <i class="fa fa-check-circle fa-lg mr-3"></i>
            <div><strong>Todos los productos tienen stock suficiente.</strong> No se requiere ning&uacute;n pedido de compra en este momento.</div>
        </div>
        <% } %>

    </div>
</div>

<!-- Modal: Editar producto -->
<div class="modal fade" id="modalEditarProducto" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form action="<%=request.getContextPath()%>/INV_ActualizarProducto" method="post">
                <div class="modal-header" style="background:#3d5a99;color:#fff;">
                    <h5 class="modal-title"><i class="fa fa-pencil mr-2"></i>Editar Producto</h5>
                    <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="idProducto" id="editIdProducto">
                    <div class="form-group">
                        <label>Nombre del producto</label>
                        <input type="text" name="descripcion" id="editDescripcion" class="form-control" required maxlength="200">
                    </div>
                    <div class="form-group mb-0">
                        <label>Unidad de medida</label>
                        <select name="id_unidad" id="editUnidad" class="form-control" required>
                            <option value="">-- Sin unidad --</option>
                            <%
                                try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnU = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement stU = cnU.prepareStatement("select * from INV_UNIDAD_MEDIDA where estado = 'A' order by 2");
                                    ResultSet rsU = stU.executeQuery();
                                    while (rsU.next()) {
                            %>
                            <option value="<%=rsU.getString(1) + "," + rsU.getString(3)%>"><%=rsU.getString(2)%> - <%=rsU.getString(3)%></option>
                            <%
                                    }
                                    rsU.close(); stU.close(); cnU.close();
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-save mr-1"></i>Guardar cambios</button>
                </div>
            </form>
        </div>
    </div>
</div>

<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0 &nbsp;|&nbsp; M&oacute;dulo: Inventario &mdash; Existencias</footer>

<script>
<% if (!sMesL.isEmpty()) { %>
(function(){
    new Chart(document.getElementById('chartMes').getContext('2d'), {
        type: 'bar',
        data: {
            labels: [<%=sMesL%>],
            datasets: [{
                label: 'Unidades despachadas',
                data:  [<%=sMesD%>],
                backgroundColor: 'rgba(61,90,153,0.75)',
                borderColor:     'rgba(61,90,153,1)',
                borderWidth: 1, borderRadius: 4
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
        }
    });
})();
<% } %>

<% if (!sDptL.isEmpty()) { %>
(function(){
    new Chart(document.getElementById('chartDept').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: [<%=sDptL%>],
            datasets: [{
                data: [<%=sDptD%>],
                backgroundColor: [
                    'rgba(61,90,153,.85)','rgba(40,168,105,.85)','rgba(253,126,20,.85)',
                    'rgba(220,53,69,.85)','rgba(23,162,184,.85)','rgba(255,193,7,.85)',
                    'rgba(111,66,193,.85)','rgba(32,201,151,.85)','rgba(96,125,139,.85)','rgba(241,100,100,.85)'
                ]
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom', labels: { font: { size:11 }, padding:10 } } }
        }
    });
})();
<% } %>

<% if (!sTopL.isEmpty()) { %>
(function(){
    new Chart(document.getElementById('chartTop').getContext('2d'), {
        type: 'bar',
        data: {
            labels: [<%=sTopL%>],
            datasets: [{
                label: 'Unidades consumidas',
                data:  [<%=sTopD%>],
                backgroundColor: 'rgba(40,168,105,.75)',
                borderColor:     'rgba(40,168,105,1)',
                borderWidth: 1, borderRadius: 4
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
        }
    });
})();
<% } %>

document.getElementById('buscarProd').addEventListener('input', function(){
    var q = this.value.toLowerCase().trim();
    document.querySelectorAll('#tablaProd tbody tr').forEach(function(tr){
        var d = tr.getAttribute('data-desc') || '';
        tr.style.display = (!q || d.indexOf(q) !== -1) ? '' : 'none';
    });
});

document.querySelectorAll('.btn-editar-prod').forEach(function(btn){
    btn.addEventListener('click', function(){
        document.getElementById('editIdProducto').value = this.getAttribute('data-id');
        document.getElementById('editDescripcion').value = this.getAttribute('data-desc');
        var idUnidad = this.getAttribute('data-idunidad');
        var sel = document.getElementById('editUnidad');
        sel.selectedIndex = 0;
        for (var i = 0; i < sel.options.length; i++) {
            if (idUnidad && sel.options[i].value.split(',')[0] === idUnidad) {
                sel.selectedIndex = i;
                break;
            }
        }
        $('#modalEditarProducto').modal('show');
    });
});
</script>
</body>
</html>
