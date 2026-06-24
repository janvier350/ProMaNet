<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = "" + ip;

    String idSuministroIngresoCab = request.getParameter("ID_SUMINISTRO_INGRESO_CAB");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR"))) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String compania = "";
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cnComp = DriverManager.getConnection(url, user, pass);
        PreparedStatement stComp = cnComp.prepareStatement("SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsComp = stComp.executeQuery();
        if (rsComp.next()) compania = rsComp.getString(1);
        rsComp.close(); stComp.close(); cnComp.close();
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Detalle de Ingreso</title>
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
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);margin-bottom:20px;}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:14px 20px;}
        .card-header.azul{background:#3d5a99;color:#fff;border-radius:8px 8px 0 0;}
        .table th{background:#f8f9fb;font-size:0.78rem;text-transform:uppercase;color:#666;letter-spacing:0.5px;border-bottom:2px solid #eee;}
        .table td{vertical-align:middle;font-size:0.88rem;}
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
        <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
        <a class="nav-link" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
        <a class="nav-link" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
        <a class="nav-link" href="INV_Historial_Solicitudes_Departamento.jsp"><i class="fa fa-building mr-2"></i>Historial por Departamento</a>
        <div class="nav-section">Ingresos</div>
        <a class="nav-link active" href="INV_Ingreso_Suministro2.jsp"><i class="fa fa-plus-circle mr-2"></i>Registrar ingreso</a>
        <div class="nav-section">Panel de control</div>
        <a class="nav-link" href="../Proyectos/Perfil.jsp"><i class="fa fa-user mr-2"></i>Perfil</a>
        <a class="nav-link" href="../cerrar.jsp"><i class="fa fa-sign-out mr-2"></i>Cerrar Sesi&oacute;n</a>
    </nav>
</div>
<div class="main-content">
    <div class="page-header">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="#">Menu</a></li>
            <li class="breadcrumb-item"><a href="INV_Dashboard_Suministro.jsp">Inventario</a></li>
            <li class="breadcrumb-item"><a href="INV_Ingreso_Suministro2.jsp">Registrar ingreso</a></li>
            <li class="breadcrumb-item active">Detalle de factura</li>
        </ol>
        <h4><i class="fa fa-cart-plus mr-2"></i>Detalle de Ingreso de Suministros</h4>
    </div>
    <div class="content-area">

        <div class="card">
            <div class="card-header azul d-flex justify-content-between align-items-center">
                <strong><i class="fa fa-file-text-o mr-2"></i>Informaci&oacute;n de la Factura</strong>
                <span class="badge badge-light">Pedido N&deg; <%=idSuministroIngresoCab%></span>
            </div>
            <div class="card-body">
                <%
                    try {
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn = DriverManager.getConnection(url, user, pass);
                        PreparedStatement st = cn.prepareStatement(
                            "SELECT to_char(a.FECHA_COMPRA,'DD/MON/YYYY'), to_char(a.FECHA_PEDIDO,'DD/MON/YYYY'), to_char(a.FECHA_RECIBIDO,'DD/MON/YYYY'), " +
                            "a.NUMERO_FACTURA, b.RAZON_SOCIAL " +
                            "FROM inv_suministro_ingreso_cab a INNER JOIN inv_proveedor b ON a.id_inv_proveedor = b.id_proveedor " +
                            "WHERE a.id_suministro_ingreso_cab = ?");
                        st.setInt(1, Integer.parseInt(idSuministroIngresoCab));
                        ResultSet rs = st.executeQuery();
                        while (rs.next()) {
                %>
                <div class="form-row">
                    <div class="form-group col-md-3">
                        <label>Fecha Compra</label>
                        <input class="form-control" type="text" value="<%=rs.getString(1)%>" disabled>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Fecha Pedido</label>
                        <input class="form-control" type="text" value="<%=rs.getString(2)%>" disabled>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Fecha Recibido</label>
                        <input class="form-control" type="text" value="<%=rs.getString(3)%>" disabled>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Factura #</label>
                        <input class="form-control" type="text" value="<%=rs.getString(4)%>" disabled>
                    </div>
                    <div class="form-group col-md-6">
                        <label>Raz&oacute;n Social</label>
                        <input class="form-control" type="text" value="<%=rs.getString(5)%>" disabled>
                    </div>
                </div>
                <%
                        }
                        rs.close(); st.close(); cn.close();
                    } catch (Exception e) { e.printStackTrace(); }
                %>
            </div>
        </div>

        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                <strong><i class="fa fa-cubes mr-1"></i>Registrar Suministro</strong>
                <div>
                    <a href="INV_Ingreso_Suministro2.jsp" class="btn btn-sm btn-warning">
                        <i class="fa fa-arrow-left mr-1"></i>Volver
                    </a>
                    <button type="button" class="btn btn-sm btn-primary" data-toggle="modal" data-target="#exampleModalSignUpAgregar">
                        <i class="fa fa-plus mr-1"></i>Agregar Producto
                    </button>
                    <button type="button" class="btn btn-sm btn-success" data-toggle="modal" data-target="#exampleModalSignUpTerminarRegistro">
                        <i class="fa fa-check mr-1"></i>Terminar
                    </button>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead><tr>
                            <th class="pl-3">#</th><th>Producto</th><th>Cantidad</th><th>Presentaci&oacute;n</th><th>Unidad</th>
                            <th class="text-center">Quitar</th>
                        </tr></thead>
                        <tbody>
                        <%
                            try {
                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                Connection cn = DriverManager.getConnection(url, user, pass);
                                PreparedStatement st = cn.prepareStatement(
                                    "SELECT a.id_suministro_ingreso_det, b.descripcion, a.cantidad, u.unidad, u.descripcion " +
                                    "FROM inv_suministro_ingreso_det a " +
                                    "INNER JOIN inv_producto b ON a.id_producto = b.id_producto " +
                                    "INNER JOIN inv_unidad_medida u ON b.id_unidad = u.id_unidad_medida " +
                                    "WHERE a.id_suministro_ingreso_cab = ?");
                                st.setInt(1, Integer.parseInt(idSuministroIngresoCab));
                                ResultSet rs = st.executeQuery();
                                boolean hayDatos = false;
                                while (rs.next()) {
                                    hayDatos = true;
                        %>
                            <tr>
                                <td class="pl-3"><%=rs.getString(1)%></td>
                                <td><%=rs.getString(2)%></td>
                                <td><%=rs.getString(3)%></td>
                                <td><%=rs.getString(4)%></td>
                                <td><%=rs.getString(5)%></td>
                                <td class="text-center">
                                    <a href="../INV_DeleteProducto?idProducto=<%=rs.getString(1)%>&ID_SUMINISTRO_INGRESO_CAB=<%=idSuministroIngresoCab%>" class="btn btn-sm btn-danger" title="Eliminar"
                                       onclick="return confirm('&iquest;Est&aacute; seguro de que desea quitar este producto?');">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hayDatos) {
                        %>
                            <tr><td colspan="6" class="text-center text-muted py-4"><i class="fa fa-inbox fa-2x mb-2 d-block"></i>No hay productos registrados.</td></tr>
                        <%
                                }
                                rs.close(); st.close(); cn.close();
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- Modal: Agregar Producto -->
<div class="modal fade" id="exampleModalSignUpAgregar" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-cart-plus mr-2"></i>Agregar Producto</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_InsertAgregarProductoDetalle">
                <div class="modal-body">
                    <input type="hidden" name="idSuministroIngresoCab" value="<%=idSuministroIngresoCab%>">
                    <div class="form-group">
                        <label>Cantidad</label>
                        <input type="number" class="form-control" name="cantidad" placeholder="Cantidad de productos" required>
                    </div>
                    <div class="form-group">
                        <label>Producto</label>
                        <select class="form-control" name="idProducto" required>
                            <%
                                try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnP = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement stP = cnP.prepareStatement(
                                        "SELECT p.id_producto, p.descripcion, u.unidad, u.descripcion " +
                                        "FROM inv_producto p INNER JOIN inv_unidad_medida u ON p.id_unidad = u.id_unidad_medida " +
                                        "ORDER BY 2");
                                    ResultSet rsP = stP.executeQuery();
                                    while (rsP.next()) {
                            %>
                            <option value="<%=rsP.getString(1)%>"><%=rsP.getString(2)%> - <%=rsP.getString(3)%> <%=rsP.getString(4)%></option>
                            <%
                                    }
                                    rsP.close(); stP.close(); cnP.close();
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary">Agregar a la lista</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Terminar registro -->
<div class="modal fade" id="exampleModalSignUpTerminarRegistro" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-check-circle mr-2"></i>Terminar registro</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_Terminar_Ingreso">
                <div class="modal-body">
                    <input type="hidden" name="idSuministroIngresoCab" value="<%=idSuministroIngresoCab%>">
                    <p>&iquest;Est&aacute; seguro de terminar de registrar productos?</p>
                    <p class="text-muted mb-0">Una vez cerrado, no podr&aacute; registrar m&aacute;s productos a este ingreso.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-success">Terminar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0</footer>
</body>
</html>
