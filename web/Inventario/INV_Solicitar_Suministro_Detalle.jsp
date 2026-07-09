<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%
    String cargo          = (String) session.getAttribute("cargo");
    String nombre         = (String) session.getAttribute("nombre");
    String apellidos      = (String) session.getAttribute("apellidos");
    String departamento   = (String) session.getAttribute("departamento");
    String idDepartamento = (String) session.getAttribute("idDepartamento");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_SOLICITAR")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    boolean esAdmin = COMUN.PermisoHelper.tiene(session, "INVENTARIO_VER_TODAS");
    boolean puedeRegistrarIngreso = COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS");

    String compania = "";
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cnComp = DriverManager.getConnection(url, user, pass);
        PreparedStatement stComp = cnComp.prepareStatement("SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsComp = stComp.executeQuery();
        if (rsComp.next()) compania = rsComp.getString(1);
        rsComp.close(); stComp.close(); cnComp.close();
    } catch (Exception e) { e.printStackTrace(); }

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
    <title>ProMaNet - Solicitar Suministro</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2-bootstrap-theme/0.1.0-beta.10/select2-bootstrap.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
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
        <% if (esAdmin) { %>
        <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
        <a class="nav-link" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
        <a class="nav-link" href="INV_Existencias_Dashboard.jsp"><i class="fa fa-bar-chart mr-2"></i>Existencias y Alertas</a>
        <% } else { %>
        <a class="nav-link active" href="INV_Solicitar_Suministro_Detalle.jsp"><i class="fa fa-plus-circle mr-2"></i>Solicitar Suministro</a>
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
        <ol class="breadcrumb"><li class="breadcrumb-item"><a href="#">Menu</a></li><li class="breadcrumb-item"><a href="#">Inventario</a></li><li class="breadcrumb-item active">Solicitar Suministro</li></ol>
        <h4><i class="fa fa-plus-circle mr-2"></i>Solicitar Suministros de Oficina</h4>
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

        <form id="formSolicitud" action="../INV_InsertarSolicitudEgreso" method="post">
            <input type="hidden" id="idDepartamento" name="idDepartamento" value="<%=idDepartamento != null ? idDepartamento : ""%>">

            <div class="card mb-3">
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3 mb-2 mb-md-0">
                            <label class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.5px;">Departamento Solicitante</label>
                            <div class="font-weight-bold"><%=departamento%></div>
                        </div>
                        <div class="col-md-4 mb-2 mb-md-0">
                            <label class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.5px;">Autorizado por</label>
                            <select class="form-control form-control-sm" id="idUsuarioAuto" name="idUsuarioAuto">
                                <%
                                  try {
                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                    Connection cnAuto = DriverManager.getConnection(url, user, pass);
                                    String sqlAuto = "SELECT IDUSUARIO, NOMBRE || ' - ' || APELLIDOS FROM USUARIO " +
                                                     "WHERE ESTADO = 'a' AND IDROLTODO = 1 " +
                                                     "AND ID_ADM_DEPARTAMENTO = " + idDepartamento + " ORDER BY 2";
                                    PreparedStatement stAuto = cnAuto.prepareStatement(sqlAuto);
                                    ResultSet rsAuto = stAuto.executeQuery();
                                    while (rsAuto.next()) {
                                %>
                                <option value="<%=rsAuto.getString(1)%>"><%=rsAuto.getString(2)%></option>
                                <%
                                    }
                                    rsAuto.close(); stAuto.close(); cnAuto.close();
                                  } catch(Exception eAuto) { eAuto.printStackTrace(); }
                                %>
                            </select>
                        </div>
                        <div class="col-md-5 text-md-right">
                            <a href="../Proyectos/PRO_Dashboard.jsp" class="btn btn-warning btn-sm">
                                <i class="fa fa-arrow-left mr-1"></i>Volver
                            </a>
                            <button type="button" class="btn btn-outline-info btn-sm" data-toggle="modal" data-target="#modalVideoTutorial">
                                <i class="fa fa-play-circle mr-1"></i>Ver tutorial
                            </button>
                            <button type="button" class="btn btn-warning btn-sm" data-toggle="modal" data-target="#modalAgregarProducto">
                                <i class="fa fa-plus-circle mr-1"></i>Agregar Producto
                            </button>
                            <button type="button" class="btn btn-success btn-sm" data-toggle="modal" data-target="#modalTerminarSolicitud">
                                <i class="fa fa-check mr-1"></i>Terminar SOLICITUD
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span class="font-weight-bold" style="font-size:.95rem;"><i class="fa fa-clipboard mr-1"></i>Productos a solicitar</span>
                    <span class="badge badge-secondary" id="badgeContador">0 producto(s)</span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0" id="tablaProductos">
                            <thead>
                                <tr>
                                    <th class="pl-3">#</th>
                                    <th>Producto</th>
                                    <th>Cantidad</th>
                                    <th>Presentaci&oacute;n</th>
                                    <th>Unidad</th>
                                    <th class="text-center">Quitar</th>
                                </tr>
                            </thead>
                            <tbody id="tablaProductosBody">
                                <tr id="filaVacia">
                                    <td colspan="6" class="text-center text-muted py-4">
                                        <i class="fa fa-inbox fa-2x mb-2 d-block"></i>No ha agregado productos. Use el bot&oacute;n "Agregar Producto".
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <!-- Los hidden inputs prod_id / prod_cant se insertan din&aacute;micamente por JS -->
        </form>

    </div>
</div>

<!-- Modal: agregar producto -->
<div class="modal fade" id="modalAgregarProducto" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-plus-circle mr-2"></i>Agregar Producto</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formAgregarProducto" onsubmit="return false;">
                    <div class="form-group">
                        <label>Cantidad</label>
                        <input type="number" class="form-control" id="cantidad" name="cantidad" placeholder="Cantidad de productos" min="1">
                    </div>
                    <div class="form-group mb-0">
                        <label>Lista de productos</label>
                        <select class="form-control" id="idProducto" name="idProducto">
                            <option value="" disabled selected>Seleccione un producto...</option>
                            <%
                              try {
                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                Connection cnProd = DriverManager.getConnection(url, user, pass);
                                String sqlProd = "SELECT p.ID_PRODUCTO, p.DESCRIPCION, u.UNIDAD, u.DESCRIPCION " +
                                                 "FROM INV_PRODUCTO p " +
                                                 "JOIN INV_UNIDAD_MEDIDA u ON p.ID_UNIDAD = u.ID_UNIDAD_MEDIDA " +
                                                 "ORDER BY 2";
                                PreparedStatement stProd = cnProd.prepareStatement(sqlProd);
                                ResultSet rsProd = stProd.executeQuery();
                                while (rsProd.next()) {
                            %>
                            <option value="<%=rsProd.getString(1)%>"
                                    data-descripcion="<%=rsProd.getString(2)%>"
                                    data-unidad="<%=rsProd.getString(3)%>"
                                    data-presentacion="<%=rsProd.getString(4)%>">
                                <%=rsProd.getString(2)%>
                            </option>
                            <%
                                }
                                rsProd.close(); stProd.close(); cnProd.close();
                              } catch(Exception eProd) { eProd.printStackTrace(); }
                            %>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                <button type="submit" form="formAgregarProducto" class="btn btn-primary btn-sm"><i class="fa fa-plus mr-1"></i>Agregar a la lista</button>
            </div>
        </div>
    </div>
</div>
<!-- Fin modal agregar producto -->

<!-- Modal: confirmar terminar solicitud -->
<div class="modal fade" id="modalTerminarSolicitud" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-check-circle mr-2"></i>Terminar registro</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <p>&iquest;Est&aacute; seguro de terminar de registrar productos?</p>
                <p class="text-muted" style="font-size:.85rem;">Una vez cerrada, no podr&aacute; agregar m&aacute;s productos a esta solicitud.</p>
                <div id="modalMsgError" class="alert alert-warning d-none" style="font-size:.85rem;" role="alert"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success btn-sm" id="btnConfirmarTerminar"><i class="fa fa-check mr-1"></i>Terminar SOLICITUD</button>
            </div>
        </div>
    </div>
</div>
<!-- Fin modal confirmar -->

<!-- Modal: video tutorial -->
<div class="modal fade" id="modalVideoTutorial" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:#3d5a99;color:#fff;">
                <h5 class="modal-title"><i class="fa fa-play-circle mr-2"></i>Tutorial de uso</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-0">
                <div class="embed-responsive embed-responsive-16by9">
                    <iframe id="iframeVideoTutorial" class="embed-responsive-item" src=""
                            allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen frameborder="0"></iframe>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>
<!-- Fin modal video tutorial -->

<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0</footer>

<script>
const productosAgregados = [];

function actualizarContador() {
    const badge = document.getElementById('badgeContador');
    badge.textContent = productosAgregados.length + ' producto(s)';
}

$('#modalVideoTutorial').on('show.bs.modal', function () {
    document.getElementById('iframeVideoTutorial').src = 'https://www.youtube.com/embed/l-y4AR5V-7Y?autoplay=1';
});
$('#modalVideoTutorial').on('hidden.bs.modal', function () {
    document.getElementById('iframeVideoTutorial').src = '';
});

document.addEventListener('DOMContentLoaded', function () {
    const formAgregar   = document.getElementById('formAgregarProducto');
    const tablaBody     = document.getElementById('tablaProductosBody');
    const formSolicitud = document.getElementById('formSolicitud');

    $('#idProducto').select2({
        theme: 'bootstrap',
        dropdownParent: $('#modalAgregarProducto'),
        width: '100%',
        language: {
            noResults: function () { return 'No se encontraron productos'; },
            searching: function () { return 'Buscando...'; }
        }
    });

    formAgregar.addEventListener('submit', function () {
        const productoSelect = document.getElementById('idProducto');
        const cantidadInput  = document.getElementById('cantidad');
        const cantidad = parseInt(cantidadInput.value);
        const option   = productoSelect.options[productoSelect.selectedIndex];

        const idProducto   = option.value;
        const descripcion  = option.getAttribute('data-descripcion');
        const unidad       = option.getAttribute('data-unidad');
        const presentacion = option.getAttribute('data-presentacion');

        if (!idProducto || !cantidad || cantidad <= 0) {
            alert('Debe seleccionar un producto y una cantidad válida.');
            return;
        }
        if (productosAgregados.find(p => p.idProducto === idProducto)) {
            alert('Este producto ya fue agregado.');
            return;
        }

        productosAgregados.push({ idProducto, descripcion, cantidad, unidad, presentacion });

        const filaVacia = document.getElementById('filaVacia');
        if (filaVacia) filaVacia.remove();

        // Fila en la tabla
        const fila = document.createElement('tr');
        fila.setAttribute('data-prod-row', idProducto);
        fila.innerHTML =
            '<td class="pl-3">' + (productosAgregados.length) + '</td>' +
            '<td>' + descripcion + '</td>' +
            '<td>' + cantidad + '</td>' +
            '<td>' + presentacion + '</td>' +
            '<td>' + unidad + '</td>' +
            '<td class="text-center"><button type="button" class="btn btn-sm btn-outline-danger" ' +
                'onclick="eliminarProducto(\'' + idProducto + '\', this)"><i class="fa fa-trash"></i></button></td>';
        tablaBody.appendChild(fila);

        // Hidden inputs para el servlet
        var hId = document.createElement('input');
        hId.type = 'hidden'; hId.name = 'prod_id'; hId.value = idProducto;
        hId.setAttribute('data-for-prod', idProducto);
        formSolicitud.appendChild(hId);

        var hCant = document.createElement('input');
        hCant.type = 'hidden'; hCant.name = 'prod_cant'; hCant.value = cantidad;
        hCant.setAttribute('data-for-cant', idProducto);
        formSolicitud.appendChild(hCant);

        actualizarContador();

        $(productoSelect).val('').trigger('change');
        cantidadInput.value = '';
        $('#modalAgregarProducto').modal('hide');
    });

    // Botón confirmar en modal
    document.getElementById('btnConfirmarTerminar').addEventListener('click', function () {
        if (productosAgregados.length === 0) {
            document.getElementById('modalMsgError').textContent = 'Debe agregar al menos un producto.';
            document.getElementById('modalMsgError').classList.remove('d-none');
            return;
        }
        document.getElementById('formSolicitud').submit();
    });
});

function eliminarProducto(idProducto, boton) {
    const index = productosAgregados.findIndex(p => p.idProducto === idProducto);
    if (index !== -1) productosAgregados.splice(index, 1);

    // Quitar fila de tabla
    boton.closest('tr').remove();

    // Quitar hidden inputs del formulario
    document.querySelectorAll('[data-for-prod="' + idProducto + '"]').forEach(function(el){ el.parentNode.removeChild(el); });
    document.querySelectorAll('[data-for-cant="' + idProducto + '"]').forEach(function(el){ el.parentNode.removeChild(el); });

    // Renumerar filas
    document.querySelectorAll('#tablaProductosBody tr[data-prod-row]').forEach(function(tr, i){
        tr.cells[0].textContent = (i + 1);
    });

    actualizarContador();

    // Restaurar fila vacía si ya no quedan productos
    if (productosAgregados.length === 0 && !document.getElementById('filaVacia')) {
        const tablaBody = document.getElementById('tablaProductosBody');
        const fila = document.createElement('tr');
        fila.id = 'filaVacia';
        fila.innerHTML = '<td colspan="6" class="text-center text-muted py-4"><i class="fa fa-inbox fa-2x mb-2 d-block"></i>No ha agregado productos. Use el botón "Agregar Producto".</td>';
        tablaBody.appendChild(fila);
    }
}
</script>
</body>
</html>
