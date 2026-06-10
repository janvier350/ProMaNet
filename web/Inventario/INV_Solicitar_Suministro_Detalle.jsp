<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date"%>
<!DOCTYPE html>
<%
    String compania     = (String) session.getAttribute("compania");
    String cargo        = (String) session.getAttribute("cargo");
    String nombre       = (String) session.getAttribute("nombre");
    String apellidos    = (String) session.getAttribute("apellidos");
    String departamento = (String) session.getAttribute("departamento");
    String idDepartamento = (String) session.getAttribute("idDepartamento");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
            || cargo.equals("ASISTENTE") || cargo.equals("PASANTE")
            || cargo.equals("CONTRALOR") || cargo.equals("JEFE"))) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");
%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="icon" type="image/png" href="../assets/img/favicon.png">
    <title>ProMaNet | Solicitud Suministros</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet"/>
    <link href="../assets/css/nucleo-icons.css" rel="stylesheet"/>
    <link href="../assets/css/nucleo-svg.css" rel="stylesheet"/>
    <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet"/>
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>

<!-- Sidenav -->
<aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4" id="sidenav-main">
    <div class="sidenav-header">
        <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" id="iconSidenav"></i>
        <a class="navbar-brand m-0" href="#">
            <img src="../assets/img/logo-ct-dark.png" class="navbar-brand-img h-100" alt="logo">
            <span class="ms-1 font-weight-bold">INVENTARIOS</span>
        </a>
    </div>
    <hr class="horizontal dark mt-0">
    <div class="collapse navbar-collapse w-auto" id="sidenav-collapse-main">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="../Inventario/INV_Dashboard_Suministro.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="../Inventario/INV_Lista_Solicitudes_Suministro.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Lista de solicitudes suministros</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="../Inventario/INV_Historial_Solicitudes_Departamento.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="fa fa-building text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Historial por Departamento</span>
                </a>
            </li>
            <li class="nav-item mt-3">
                <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">PANEL DE CONTROL</h6>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="../Proyectos/Perfil.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Perfil</span>
                </a>
            </li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <div class="card card-plain shadow-none" id="sidenavCard">
            <img class="w-50 mx-auto" src="../assets/img/illustrations/icon-documentation.svg" alt="">
            <div class="card-body text-center p-3 w-100 pt-0">
                <h6 class="mb-0">Necesitas ayuda?</h6>
                <p class="text-xs font-weight-bold mb-0">Revisa nuestro tutorial</p>
            </div>
        </div>
        <a href="#" class="btn btn-dark btn-sm w-100 mb-3">Video Tutorial</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <!-- Navbar -->
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Inventario</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Solicitud de suministros</h6>
            </nav>
            <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                    <span class="text-body text-white-50"><i class="fas fa-home"></i> <%=compania%></span>
                </div>
                <ul class="navbar-nav justify-content-end">
                    <li class="nav-item d-flex align-items-center">
                        <a href="javascript:;" class="nav-link text-white font-weight-bold px-0">
                            <i class="fa fa-user me-sm-1"></i>
                            <span class="d-sm-inline d-none"><%=nombre%> <%=apellidos%></span>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- End Navbar -->

    <!-- Modal: confirmar terminar solicitud -->
    <div class="modal fade" id="modalTerminarSolicitud" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-md" role="document">
            <div class="modal-content">
                <div class="modal-body p-0">
                    <div class="card card-plain">
                        <div class="card-header pb-0 text-left">
                            <h3 class="font-weight-bolder text-primary text-gradient">Terminar registro</h3>
                        </div>
                        <div class="card-body pb-3">
                            <h5>¿Está seguro de terminar de registrar productos?</h5>
                            <p class="text-muted">Una vez cerrada, no podrá agregar más productos a esta solicitud.</p>
                            <div id="modalMsgError" class="alert alert-warning d-none" role="alert"></div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="button" class="btn bg-gradient-primary" id="btnConfirmarTerminar">Terminar SOLICITUD</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Fin modal confirmar -->

    <!-- Modal: agregar producto -->
    <div class="modal fade" id="modalAgregarProducto" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-md" role="document">
            <div class="modal-content">
                <div class="modal-body p-0">
                    <div class="card card-plain">
                        <div class="card-header pb-0 text-left">
                            <h3 class="font-weight-bolder text-primary text-gradient">Seleccione producto</h3>
                        </div>
                        <div class="card-body pb-3">
                            <form id="formAgregarProducto" onsubmit="return false;">
                                <label>Cantidad</label>
                                <input type="number" class="form-control mb-3" id="cantidad" name="cantidad" placeholder="Cantidad de productos" min="1">
                                <label>Lista de productos</label>
                                <select class="form-control mb-3" id="idProducto" name="idProducto">
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
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                                    <button type="submit" class="btn btn-primary">Agregar a la lista</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Fin modal agregar producto -->

    <div class="container-fluid py-4">

        <% if (msgExito != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa fa-check-circle mr-2"></i> <%=msgExito%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        <% if (msgError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa fa-exclamation-triangle mr-2"></i> <%=msgError%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-12">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h2>Solicitar Suministros de oficina</h2>
                    </div>
                </div>

                <div class="card mb-4">
                    <div class="card-header pb-0">

                        <!-- Formulario principal -->
                        <form id="formSolicitud" action="../INV_InsertarSolicitudEgreso" method="post">
                            <input type="hidden" id="idDepartamento" name="idDepartamento" value="<%=idDepartamento != null ? idDepartamento : "" %>">

                            <div class="col-md-4">
                                <div class="form-group">
                                    <h6>Departamento Solicitante:</h6>
                                    <label class="form-control-label"><%=departamento%></label>

                                    <h6 class="mt-3">Autorizado por:</h6>
                                    <select class="form-control" id="idUsuarioAuto" name="idUsuarioAuto">
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

                                    <div class="d-flex gap-2 mt-3">
                                        <a href="../Inventario/INV_Ingreso_Suministro2.jsp" class="btn btn-warning">
                                            <i class="ni ni-bold-left"></i> Volver
                                        </a>
                                        <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#modalAgregarProducto">
                                            <i class="ni ni-fat-add"></i> Agregar Producto
                                        </button>
                                        <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#modalTerminarSolicitud">
                                            <i class="ni ni-check-bold"></i> Terminar SOLICITUD
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Tabla de productos agregados -->
                            <div class="table-responsive p-0 mt-3">
                                <table class="table align-items-center mb-0" id="tablaProductos">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Producto</th>
                                            <th>Cantidad</th>
                                            <th>Presentación</th>
                                            <th>Unidad</th>
                                            <th>Quitar</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tablaProductosBody"></tbody>
                                </table>
                            </div>
                            <!-- Los hidden inputs prod_id / prod_cant se insertan dinámicamente por JS -->
                        </form>

                    </div>
                </div>
            </div>
        </div>

        <footer class="footer pt-3">
            <div class="container-fluid">
                <div class="row align-items-center justify-content-lg-between">
                    <div class="col-lg-6 mb-lg-0 mb-4">
                        <div class="copyright text-center text-sm text-muted text-lg-start">
                            &copy; <script>document.write(new Date().getFullYear())</script>,
                            Creado por <a href="https://www.overclocking.com.ec" class="font-weight-bold" target="_blank">Overclocking</a>
                            for a better web.
                        </div>
                    </div>
                </div>
            </div>
        </footer>
    </div>
</main>

<script src="../assets/js/core/popper.min.js"></script>
<script src="../assets/js/core/bootstrap.min.js"></script>
<script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>

<script>
const productosAgregados = [];

document.addEventListener('DOMContentLoaded', function () {
    const formAgregar  = document.getElementById('formAgregarProducto');
    const tablaBody    = document.getElementById('tablaProductosBody');
    const formSolicitud = document.getElementById('formSolicitud');

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

        // Fila en la tabla
        const fila = document.createElement('tr');
        fila.setAttribute('data-prod-row', idProducto);
        fila.innerHTML =
            '<td>' + (productosAgregados.length) + '</td>' +
            '<td>' + descripcion + '</td>' +
            '<td>' + cantidad + '</td>' +
            '<td>' + presentacion + '</td>' +
            '<td>' + unidad + '</td>' +
            '<td><button type="button" class="btn btn-danger btn-sm" ' +
                'onclick="eliminarProducto(\'' + idProducto + '\', this)">Eliminar</button></td>';
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

        productoSelect.selectedIndex = 0;
        cantidadInput.value = '';
        bootstrap.Modal.getInstance(document.getElementById('modalAgregarProducto')).hide();
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
    document.querySelectorAll('#tablaProductosBody tr').forEach(function(tr, i){
        tr.cells[0].textContent = (i + 1);
    });
}
</script>

</body>
</html>
