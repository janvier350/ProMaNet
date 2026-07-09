<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String departamento = (String) session.getAttribute("departamento");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!(departamento.equals("MARKETING") || departamento.equals("TECNOLOGÍA") || departamento.equals("ADMINISTRACIÓN"))) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS")) {
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
    <title>ProMaNet - Registrar Ingreso</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        body{background:#f4f6f9;font-family:'Segoe UI',Arial,sans-serif;margin:0;}
        .topbar{background:#3d5a99;color:#fff;padding:10px 20px;display:flex;justify-content:space-between;align-items:center;}
        .topbar .brand{font-size:1.1rem;font-weight:700;}
        .topbar .user-info{font-size:0.85rem;text-align:right;}
        .sidebar{width:220px;min-height:100vh;background:#fff;border-right:1px solid #e0e0e0;position:fixed;top:44px;left:0;}
        .sidebar .nav-link{color:#444;padding:10px 20px;font-size:0.88rem;}
        .sidebar .nav-link:hover,.sidebar .nav-link.active{background:#eef2fb;color:#3d5a99;font-weight:600;}
        .sidebar .nav-section{padding:10px 20px 4px;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;}
        .main-content{margin-left:220px;}
        .page-header{background:linear-gradient(135deg,#3d5a99,#5b7fc4);color:#fff;padding:18px 28px 14px;}
        .page-header .breadcrumb{background:transparent;padding:0;margin:0 0 4px;font-size:.8rem;}
        .page-header .breadcrumb-item a{color:rgba(255,255,255,0.75);} .page-header .breadcrumb-item.active{color:#fff;}
        .page-header h4{margin:0;font-weight:600;} .content-area{padding:24px;}
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.08);margin-bottom:20px;}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:14px 20px;}
        .card-header.azul{background:#3d5a99;color:#fff;border-radius:8px 8px 0 0;}
        .table th{background:#f8f9fb;font-size:.78rem;text-transform:uppercase;color:#666;}
        .table td{vertical-align:middle;font-size:.88rem;}
        .badge-procesado{background:#d1e7dd;color:#0f5132;padding:4px 10px;border-radius:12px;font-size:.75rem;font-weight:600;}
        .footer{margin-left:220px;padding:12px 24px;font-size:.78rem;color:#aaa;border-top:1px solid #eee;}
    </style>
</head>
<body>
<div class="topbar"><span class="brand"><i class="fa fa-th-large mr-2"></i>INVENTARIOS</span>
<span class="user-info"><%=compania%><br><strong><%=nombre%> <%=apellidos%></strong></span></div>
<div class="sidebar"><nav class="nav flex-column pt-3">
    <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
    <a class="nav-link" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
    <a class="nav-link" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
    <a class="nav-link" href="INV_Historial_Solicitudes_Departamento.jsp"><i class="fa fa-building mr-2"></i>Historial por Departamento</a>
    <div class="nav-section">Ingresos</div>
    <a class="nav-link active" href="INV_Ingreso_Suministro2.jsp"><i class="fa fa-plus-circle mr-2"></i>Registrar ingreso</a>
    <div class="nav-section">Panel de control</div>
    <a class="nav-link" href="../Proyectos/Perfil.jsp"><i class="fa fa-user mr-2"></i>Perfil</a>
    <a class="nav-link" href="../cerrar.jsp"><i class="fa fa-sign-out mr-2"></i>Cerrar Sesi&oacute;n</a>
</nav></div>
<div class="main-content">
    <div class="page-header">
        <ol class="breadcrumb"><li class="breadcrumb-item"><a href="#">Menu</a></li><li class="breadcrumb-item"><a href="INV_Dashboard_Suministro.jsp">Inventario</a></li><li class="breadcrumb-item active">Registrar ingreso</li></ol>
        <h4><i class="fa fa-plus-circle mr-2"></i>Registro de Ingreso de Suministros</h4>
    </div>
    <div class="content-area">

        <%
            String error = request.getParameter("error");
            if (error != null) {
                String mensajeError;
                switch (error) {
                    case "proveedor_dup": mensajeError = "Ya existe un proveedor registrado con esa identificaci&oacute;n."; break;
                    case "unidad_dup": mensajeError = "Ya existe una unidad de medida con ese nombre."; break;
                    case "categoria_dup": mensajeError = "Ya existe una categor&iacute;a con ese nombre."; break;
                    case "producto_dup": mensajeError = "Ya existe un producto registrado con esa descripci&oacute;n."; break;
                    case "factura_dup": mensajeError = "Ya existe una factura registrada con ese n&uacute;mero para el proveedor seleccionado."; break;
                    case "factura_procesada": mensajeError = "No se puede eliminar esta factura porque ya fue procesada."; break;
                    default: mensajeError = "No se pudo completar el registro porque ya existe un registro igual."; break;
                }
        %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa fa-exclamation-triangle mr-2"></i><%=mensajeError%>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
        <% } %>

        <div class="card">
            <div class="card-header"><strong><i class="fa fa-cogs mr-1"></i>Funciones para productos</strong></div>
            <div class="card-body">
                <button type="button" class="btn btn-primary mr-2 mb-2" data-toggle="modal" data-target="#exampleModalSignProveedor"><i class="fa fa-truck mr-1"></i>Nuevo Proveedor</button>
                <button type="button" class="btn btn-primary mr-2 mb-2" data-toggle="modal" data-target="#exampleModalSignUpUnidades"><i class="fa fa-balance-scale mr-1"></i>Nueva Unidad de Medida</button>
                <button type="button" class="btn btn-primary mr-2 mb-2" data-toggle="modal" data-target="#exampleModalSignUp2"><i class="fa fa-tags mr-1"></i>Nueva Categor&iacute;a</button>
                <button type="button" class="btn btn-primary mr-2 mb-2" data-toggle="modal" data-target="#exampleModalSignUp"><i class="fa fa-cube mr-1"></i>Nuevo Producto</button>
            </div>
        </div>

        <div class="card">
            <div class="card-header azul"><i class="fa fa-file-text-o mr-2"></i><strong>Informaci&oacute;n de la Factura</strong></div>
            <div class="card-body">
                <form action="../INV_Insert_Ingreso_Suministro_Cab" method="post">
                    <div class="form-row">
                        <div class="form-group col-md-3">
                            <label>Fecha Compra</label>
                            <input class="form-control" type="date" name="fechaCompra" required>
                        </div>
                        <div class="form-group col-md-3">
                            <label>Fecha Pedido</label>
                            <input class="form-control" type="date" name="fechaPedido" required>
                        </div>
                        <div class="form-group col-md-3">
                            <label>Fecha Recibido</label>
                            <input class="form-control" type="date" name="fechaRecibido" required>
                        </div>
                        <div class="form-group col-md-3">
                            <label>N&uacute;mero de Factura</label>
                            <input class="form-control" type="text" placeholder="001-001-00000123" name="numero_factura" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Proveedor</label>
                        <select class="form-control" name="idProveedor" required>
                            <%
                                try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnP = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement stP = cnP.prepareStatement("select * from inv_proveedor where estado = 'A' order by 3");
                                    ResultSet rsP = stP.executeQuery();
                                    while (rsP.next()) {
                            %>
                            <option value="<%=rsP.getString(1)%>"><%=rsP.getString(2) + " - " + rsP.getString(3)%></option>
                            <%
                                    }
                                    rsP.close(); stP.close(); cnP.close();
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-success"><i class="fa fa-check mr-1"></i>Generar Documento</button>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><strong><i class="fa fa-list mr-1"></i>Facturas de Suministros</strong></div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead><tr>
                            <th class="pl-3">Compra</th><th>Pedido</th><th>Recibido</th><th>Factura</th>
                            <th>Raz&oacute;n Social</th><th>Identificaci&oacute;n</th><th>Usuario</th><th class="text-center">Acciones</th>
                        </tr></thead>
                        <tbody>
                        <%
                            try {
                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                Connection cn = DriverManager.getConnection(url, user, pass);
                                String query = "SELECT a.id_suministro_ingreso_cab AS id_ingreso, " +
                                    "to_char(a.fecha_compra,'DD/MON/YYYY'), to_char(a.fecha_pedido,'DD/MON/YYYY'), to_char(a.fecha_recibido,'DD/MON/YYYY'), " +
                                    "a.numero_factura, b.razon_social AS proveedor, b.identificacion AS ruc_proveedor, c.usuario AS nombre_usuario, a.estado " +
                                    "FROM inv_suministro_ingreso_cab a " +
                                    "INNER JOIN inv_proveedor b ON a.id_inv_proveedor = b.id_proveedor " +
                                    "INNER JOIN usuario c ON a.id_usuario = c.idusuario " +
                                    "WHERE a.estado IN ('A','C') ORDER BY a.fecha_compra DESC";
                                PreparedStatement st = cn.prepareStatement(query);
                                ResultSet rs = st.executeQuery();
                                boolean hayRegistros = false;
                                while (rs.next()) {
                                    hayRegistros = true;
                                    String idIngreso = rs.getString(1);
                                    String estado = rs.getString(9);
                        %>
                            <tr>
                                <td class="pl-3"><%=rs.getString(2)%></td>
                                <td><%=rs.getString(3)%></td>
                                <td><%=rs.getString(4)%></td>
                                <td><%=rs.getString(5)%></td>
                                <td><%=rs.getString(6)%></td>
                                <td><%=rs.getString(7)%></td>
                                <td><%=rs.getString(8)%></td>
                                <td class="text-center">
                                    <button type="button" class="btn btn-sm btn-outline-primary" data-toggle="modal" data-target="#modalListaTareas" data-id="<%=idIngreso%>" title="Ver productos">
                                        <i class="fa fa-eye"></i>
                                    </button>
                                    <% if ("C".equals(estado)) { %>
                                        <span class="badge-procesado ml-1"><i class="fa fa-check mr-1"></i>Procesado</span>
                                    <% } else { %>
                                        <a href="INV_Ingreso_Suministro_Detalle.jsp?ID_SUMINISTRO_INGRESO_CAB=<%=idIngreso%>" class="btn btn-sm btn-primary ml-1" title="Registrar productos">
                                            <i class="fa fa-cart-plus"></i>
                                        </a>
                                    <% } %>
                                    <% if (!"C".equals(estado)) { %>
                                    <a href="../INV_Delete_Suministro_Cab?ID_SUMINISTRO_INGRESO_CAB=<%=idIngreso%>" class="btn btn-sm btn-danger ml-1" title="Eliminar"
                                       onclick="return confirm('¿Está seguro de que desea eliminar este registro?');">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hayRegistros) {
                        %>
                            <tr><td colspan="8" class="text-center text-muted py-4"><i class="fa fa-inbox fa-2x mb-2 d-block"></i>No hay facturas registradas.</td></tr>
                        <%
                                }
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

<!-- Modal: Nuevo Producto -->
<div class="modal fade" id="exampleModalSignUp" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-cube mr-2"></i>Registrar Producto</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_InsertProducto" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Producto</label>
                        <input type="text" class="form-control" id="descripcion" name="descripcion" required>
                    </div>
                    <div class="form-group">
                        <label>Unidad de medida</label>
                        <select class="form-control" id="unidad" name="id_unidad" required>
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
                    <div class="form-group">
                        <label>Categor&iacute;a</label>
                        <select class="form-control" id="idCategoria" name="idCategoria" required>
                            <%
                                try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnC = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement stC = cnC.prepareStatement("select * from INV_CATEGORIA where estado = 'A' order by 2");
                                    ResultSet rsC = stC.executeQuery();
                                    while (rsC.next()) {
                            %>
                            <option value="<%=rsC.getString(1)%>"><%=rsC.getString(2)%></option>
                            <%
                                    }
                                    rsC.close(); stC.close(); cnC.close();
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Nueva Unidad de Medida -->
<div class="modal fade" id="exampleModalSignUpUnidades" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-balance-scale mr-2"></i>Registrar Unidad de Medida</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_InsertUnidadesMedida" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Unidad</label>
                        <input type="text" class="form-control" name="unidad" placeholder="Paquete, frasco, cart&oacute;n, ..." required>
                    </div>
                    <div class="form-group">
                        <label>Descripci&oacute;n</label>
                        <input type="text" class="form-control" name="descripcion" placeholder="12 unidades, 450 gr, 12 paquetes,..." required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Nueva Categoria -->
<div class="modal fade" id="exampleModalSignUp2" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-tags mr-2"></i>Registrar Categor&iacute;a</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_InsertCategoria" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Categor&iacute;a</label>
                        <input type="text" class="form-control" name="categoria" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Nuevo Proveedor -->
<div class="modal fade" id="exampleModalSignProveedor" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-truck mr-2"></i>Registrar Proveedor</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="../INV_InsertProveedor" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Identificaci&oacute;n</label>
                        <input type="text" class="form-control" name="identificacion" placeholder="0923000000" required>
                    </div>
                    <div class="form-group">
                        <label>Raz&oacute;n Social</label>
                        <input type="text" class="form-control" name="razonSocial" placeholder="Nombre comercial" required>
                    </div>
                    <div class="form-group">
                        <label>Direcci&oacute;n</label>
                        <input type="text" class="form-control" name="direccion" placeholder="Av. Calle">
                    </div>
                    <div class="form-group">
                        <label>Tel&eacute;fonos</label>
                        <input type="text" class="form-control" name="telefono" placeholder="0994154441 - 6003701">
                    </div>
                    <div class="form-group">
                        <label>Correo</label>
                        <input type="email" class="form-control" name="correo" placeholder="nombre@negocio.com">
                    </div>
                    <div class="form-group">
                        <label>Contacto</label>
                        <input type="text" class="form-control" name="contacto" placeholder="Nombre del contacto de compras">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Detalle de productos de la factura -->
<div class="modal fade" id="modalListaTareas" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-list-alt mr-2"></i>Detalle de Productos</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-0">
                <input type="hidden" id="id_cabecera_modal" name="id_cabecera_modal" value="">
                <iframe id="iframeProductos" src="" width="100%" height="400" frameborder="0"></iframe>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0</footer>
<script>
$('#modalListaTareas').on('show.bs.modal', function (event) {
    var boton = $(event.relatedTarget);
    var idCabecera = boton.data('id');
    $('#id_cabecera_modal').val(idCabecera);
    $('#iframeProductos').attr('src', '../Inventario/productos_modal.jsp?id=' + idCabecera);
});
</script>
</body>
</html>
