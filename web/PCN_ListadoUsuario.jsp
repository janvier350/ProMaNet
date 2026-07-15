<%--
    Document   : Panel de Sistemas - Listado de Usuarios
    Author     : Jquinde (original) / rediseño Argon
--%>
<%@page contentType="text/html"
        import ="java.sql.Connection"
        import ="java.sql.DriverManager"
        import ="java.sql.ResultSet"
        import ="java.sql.Statement"
        import ="java.sql.SQLException"
        import="java.sql.*"
        import=" java.util.Date"
        %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%   String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String(""+ip);
    String idUser = request.getParameter("id");
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

    int totalUsuarios = 0;

    String idUserDigits = (idUser == null) ? "" : idUser.replaceAll("[^0-9]", "");
    if (idUserDigits.isEmpty()) idUserDigits = "0";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="assets/img/favicon.png">
    <title>ProMaNet - Panel de Sistemas</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        .fila-usuario.d-none{display:none !important;}
        .btn-icon-sm{width:2.2rem;height:2.2rem;padding:0;display:inline-flex;align-items:center;justify-content:center;}
    </style>
</head>
<body class="g-sidenav-show bg-gray-100">
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4" id="sidenav-main">
    <div class="sidenav-header">
        <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
        <a class="navbar-brand m-0" href="Proyectos/PRO_Dashboard.jsp">
            <img src="assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
            <span class="ms-1 font-weight-bold">ProMaNet</span>
        </a>
    </div>
    <hr class="horizontal dark mt-0">
    <div class="collapse navbar-collapse w-auto" id="sidenav-collapse-main">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="Proyectos/PRO_Dashboard.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Dashboard</span>
                </a>
            </li>
            <li class="nav-item mt-3">
                <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Panel de Sistemas</h6>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="PCN_ListadoUsuario.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-single-02 text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Usuarios</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="PCN_GestionPermisosDepartamento.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-shop text-success text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Permisos por Departamento</span>
                </a>
            </li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <div class="card card-plain shadow-none" id="sidenavCard">
            <img class="w-50 mx-auto" src="assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
            <div class="card-body text-center p-3 w-100 pt-0">
                <div class="docs-info">
                    <h6 class="mb-0">Acceso restringido</h6>
                    <p class="text-xs font-weight-bold mb-0">Departamento de Sistemas / IT</p>
                </div>
            </div>
        </div>
        <a href="cerrar.jsp" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesi&oacute;n</a>
    </div>
</aside>

<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" data-scroll="false">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Panel de Sistemas</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Panel de Sistemas &mdash; Usuarios</h6>
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
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Usuarios activos</p>
                                    <h5 class="font-weight-bolder mb-0" id="statUsuarios">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                    <i class="ni ni-single-02 text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Permisos por usuario</p>
                                    <h6 class="mb-0"><i class="fa fa-unlock-alt me-1"></i>Ajusta excepciones puntuales</h6>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center border-radius-md">
                                    <i class="ni ni-badge text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 mb-xl-0 mb-4">
                <div class="card">
                    <div class="card-body p-3">
                        <div class="row">
                            <div class="col-8">
                                <div class="numbers">
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Permisos por departamento</p>
                                    <h6 class="mb-0"><i class="fa fa-building me-1"></i>Reglas para todo un depto.</h6>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-info shadow text-center border-radius-md">
                                    <i class="ni ni-shop text-lg opacity-10" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mt-4">
            <div class="card-body p-3">
                <div class="d-flex flex-wrap align-items-center" style="gap:14px;">
                    <div class="flex-grow-1" style="min-width:220px;">
                        <label class="form-label text-sm mb-1">Buscar usuario</label>
                        <input type="text" class="form-control" id="buscarUsuario" placeholder="Nombre, email, departamento...">
                    </div>
                    <div class="pt-4">
                        <button type="button" class="btn bg-gradient-primary mb-0" data-bs-toggle="modal" data-bs-target="#myModal">
                            <i class="fa fa-user-plus me-1"></i>Nuevo Usuario
                        </button>
                        <a href="PCN_GestionPermisosDepartamento.jsp" class="btn btn-outline-secondary mb-0">
                            <i class="fa fa-building me-1"></i>Permisos por Depto.
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mt-4">
            <div class="table-responsive">
                <table class="table align-items-center mb-0">
                    <thead>
                        <tr>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7 ps-4">Id</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Departamento</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Nombres / Email</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Compania</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Rol-TD</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7 text-end pe-4">Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="myTable">
                    <%
                    try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn = DriverManager.getConnection(url, user, pass);

                        PreparedStatement stCountUser = cn.prepareStatement("SELECT COUNT(*) FROM USUARIO WHERE ESTADO = 'a'");
                        ResultSet rsCountUser = stCountUser.executeQuery();
                        if (rsCountUser.next()) totalUsuarios = rsCountUser.getInt(1);
                        rsCountUser.close(); stCountUser.close();

                        String sql = "select A.IDUSUARIO, A.NOMBRE||' '||A.APELLIDOS AS NOMBRES, A.EMAIL, A.IDCOMPANIA, B.COMPANIA, A.IDROL, C.CARGO , A.IDROLTODO, d.cargotodo, e.departamento"
                                + ", A.NOMBRE, A.APELLIDOS, A.TELEFONO, A.USUARIO, A.CONTRASENA, A.ID_ADM_DEPARTAMENTO"
                                + " from USUARIO A, COMPANIA B, ROL C, todorol D, adm_departamento E "
                                + " WHERE A.IDCOMPANIA = B.IDCOMPANIA AND A.IDROL = C.IDROL AND A.ESTADO='a' AND a.idroltodo = d.idroltodo AND a.id_adm_departamento = e.id_departamento ORDER BY 2";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();
                        while (rs.next()) {
                            String textoFila = (rs.getString(10) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(5) + " " + rs.getString(7) + " " + rs.getString(9)).toLowerCase();
                    %>
                    <tr class="fila-usuario" data-search="<%=textoFila%>">
                        <td class="ps-4"><span class="text-sm"><%=rs.getString(1)%></span></td>
                        <td><span class="text-sm"><%=rs.getString(10)%></span></td>
                        <td>
                            <span class="text-sm font-weight-bold d-block"><%=rs.getString(2)%></span>
                            <span class="text-xs text-secondary d-block text-truncate" style="max-width:260px;" title="<%=rs.getString(3)%>"><%=rs.getString(3)%></span>
                        </td>
                        <td><span class="text-sm"><%=rs.getString(5)%></span></td>
                        <td><span class="text-sm"><%=rs.getString(9)%></span></td>
                        <td class="text-end pe-4 text-nowrap">
                            <button type="button" class="btn btn-icon-sm btn-outline-info me-1" title="Editar"
                                data-id="<%=rs.getString(1)%>"
                                data-nombre="<%=esc(rs.getString(11))%>"
                                data-apellido="<%=esc(rs.getString(12))%>"
                                data-telefono="<%=esc(rs.getString(13))%>"
                                data-email="<%=esc(rs.getString(3))%>"
                                data-usuario="<%=esc(rs.getString(14))%>"
                                data-pass="<%=esc(rs.getString(15))%>"
                                data-idcia="<%=rs.getString(4)%>"
                                data-idrol="<%=rs.getString(6)%>"
                                data-idroltodo="<%=rs.getString(8)%>"
                                data-iddepartamento="<%=rs.getString(16)%>"
                                onclick="abrirEditar(this)">
                                <i class="fa fa-pencil"></i>
                            </button>
                            <a href="PCN_GestionPermisosUsuario.jsp?idUser=<%=rs.getString(1)%>" class="btn btn-icon-sm btn-outline-warning me-1" title="Permisos">
                                <i class="fa fa-unlock-alt"></i>
                            </a>
                            <a href="PCN_EliminarUsuario.jsp?idUser=<%=rs.getString(1)%>" class="btn btn-icon-sm btn-outline-danger" title="Eliminar" onclick="return confirm('¿Eliminar este usuario?');">
                                <i class="fa fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <%
                        }
                        rs.close(); st.close(); cn.close();
                    }catch(Exception e){
                        e.printStackTrace();
                    %>
                    <tr><td colspan="6" class="text-danger ps-4">Error: <%=e.getMessage()%></td></tr>
                    <%
                    }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer class="footer pt-3">
        <div class="container-fluid">
            <div class="row align-items-center justify-content-lg-between">
                <div class="col-12 text-center">
                    <div class="copyright text-center text-sm text-muted">
                        &copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0
                    </div>
                </div>
            </div>
        </div>
    </footer>
</main>

<!-- Modal: Nuevo Usuario -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <form action="PCN_InsertarUsuario.jsp" method="POST">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-user-plus me-2"></i>Agregar Nuevo Usuario</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Nombres</label>
                                <input type="text" name="nombre" id="nombre" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Apellidos</label>
                                <input type="text" name="apellido" id="apellido" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Sueldo</label>
                                <input type="number" name="sueldo" id="sueldo" class="form-control" value="0" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Telefono</label>
                                <input type="text" name="telefono" id="telefono" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="text" name="email" id="email" class="form-control" value="N/A" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Usuario</label>
                                <input type="text" name="usuario" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Contrasena</label>
                                <input type="password" name="pass" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Rol</label>
                                <select class="form-control" id="idRol" name="idRol">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnRol = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stRol = cnRol.prepareStatement("select * from ROL where estado = 'a' order by 2");
                                            ResultSet rsRol = stRol.executeQuery();
                                            while (rsRol.next()) {
                                    %>
                                    <option value="<%=rsRol.getString(1)%>"><%=rsRol.getString(2)%></option>
                                    <%
                                            }
                                            rsRol.close(); stRol.close(); cnRol.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Compania</label>
                                <select class="form-control" id="idCia" name="idCia">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnCia = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stCia = cnCia.prepareStatement("select * from COMPANIA where estado = 'a' order by 2");
                                            ResultSet rsCia = stCia.executeQuery();
                                            while (rsCia.next()) {
                                    %>
                                    <option value="<%=rsCia.getString(1)%>"><%=rsCia.getString(3)%></option>
                                    <%
                                            }
                                            rsCia.close(); stCia.close(); cnCia.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Rol para TO-DO</label>
                                <select class="form-control" id="idRolTodo" name="idRolTodo">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnRolTodo = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stRolTodo = cnRolTodo.prepareStatement("select * from TODOROL where estado = 'A' order by 2");
                                            ResultSet rsRolTodo = stRolTodo.executeQuery();
                                            while (rsRolTodo.next()) {
                                    %>
                                    <option value="<%=rsRolTodo.getString(1)%>"><%=rsRolTodo.getString(2)%></option>
                                    <%
                                            }
                                            rsRolTodo.close(); stRolTodo.close(); cnRolTodo.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Departamento</label>
                                <select class="form-control" id="departamento" name="departamento">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnDepto = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stDepto = cnDepto.prepareStatement("select * from ADM_DEPARTAMENTO where estado = 'A' order by 2");
                                            ResultSet rsDepto = stDepto.executeQuery();
                                            while (rsDepto.next()) {
                                    %>
                                    <option value="<%=rsDepto.getString(1)%>"><%=rsDepto.getString(2)%></option>
                                    <%
                                            }
                                            rsDepto.close(); stDepto.close(); cnDepto.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-check me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Editar Usuario -->
<div class="modal fade" id="modalEditar" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <form id="formEditar" action="PCN_EditarUsuario.jsp" method="POST">
                <input type="hidden" name="idUser" id="editIdUser">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-pencil me-2"></i>Editar Usuario</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Nombres</label>
                                <input type="text" name="nombre" id="editNombre" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Apellidos</label>
                                <input type="text" name="apellido" id="editApellido" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Telefono</label>
                                <input type="text" name="telefono" id="editTelefono" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="text" name="email" id="editEmail" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Usuario</label>
                                <input type="text" name="usuario" id="editUsuario" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Contrasena</label>
                                <input type="password" name="contrasena" id="editPass" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Compania</label>
                                <select class="form-control" id="editIdCia" name="idCia">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnCiaEdit = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stCiaEdit = cnCiaEdit.prepareStatement("select * from COMPANIA where estado = 'a' order by 2");
                                            ResultSet rsCiaEdit = stCiaEdit.executeQuery();
                                            while (rsCiaEdit.next()) {
                                    %>
                                    <option value="<%=rsCiaEdit.getString(1)%>"><%=rsCiaEdit.getString(3)%></option>
                                    <%
                                            }
                                            rsCiaEdit.close(); stCiaEdit.close(); cnCiaEdit.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Rol</label>
                                <select class="form-control" id="editIdRol" name="idRol">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnRolEdit = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stRolEdit = cnRolEdit.prepareStatement("select * from ROL where estado = 'a' order by 2");
                                            ResultSet rsRolEdit = stRolEdit.executeQuery();
                                            while (rsRolEdit.next()) {
                                    %>
                                    <option value="<%=rsRolEdit.getString(1)%>"><%=rsRolEdit.getString(2)%></option>
                                    <%
                                            }
                                            rsRolEdit.close(); stRolEdit.close(); cnRolEdit.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Rol para TO-DO</label>
                                <select class="form-control" id="editIdRolTodo" name="idRolTodo">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnRolTodoEdit = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stRolTodoEdit = cnRolTodoEdit.prepareStatement("select * from TODOROL where estado = 'A' order by 2");
                                            ResultSet rsRolTodoEdit = stRolTodoEdit.executeQuery();
                                            while (rsRolTodoEdit.next()) {
                                    %>
                                    <option value="<%=rsRolTodoEdit.getString(1)%>"><%=rsRolTodoEdit.getString(2)%></option>
                                    <%
                                            }
                                            rsRolTodoEdit.close(); stRolTodoEdit.close(); cnRolTodoEdit.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Departamento</label>
                                <select class="form-control" id="editIdDepartamento" name="idDepartamento">
                                    <%
                                        try {
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection cnDeptoEdit = DriverManager.getConnection(url, user, pass);
                                            PreparedStatement stDeptoEdit = cnDeptoEdit.prepareStatement("select * from ADM_DEPARTAMENTO where estado = 'A' order by 2");
                                            ResultSet rsDeptoEdit = stDeptoEdit.executeQuery();
                                            while (rsDeptoEdit.next()) {
                                    %>
                                    <option value="<%=rsDeptoEdit.getString(1)%>"><%=rsDeptoEdit.getString(2)%></option>
                                    <%
                                            }
                                            rsDeptoEdit.close(); stDeptoEdit.close(); cnDeptoEdit.close();
                                        } catch (Exception e) { e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn bg-gradient-primary btn-sm"><i class="fa fa-check me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Jefe asignado -->
<div class="modal fade" id="myModalJEFE" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fa fa-user-circle me-2"></i>Jefe Asignado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table table-sm">
                    <thead>
                        <tr>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Id</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Nombre Jefe</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (!"0".equals(idUserDigits)) {
                            try {
                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                Connection cn2 = DriverManager.getConnection(url, user, pass);
                                PreparedStatement st2 = cn2.prepareStatement(
                                    "select a.idusuario, b.nombre||' '||b.apellidos AS JEFE from REPGASASIG A, USUARIO B " +
                                    "WHERE a.idusuario = ? AND a.idusuarioasig=b.idusuario");
                                st2.setInt(1, Integer.parseInt(idUserDigits));
                                ResultSet rs2 = st2.executeQuery();
                                while (rs2.next()) {
                    %>
                        <tr>
                            <td><%=rs2.getString(1)%></td>
                            <td><%=rs2.getString(2)%></td>
                        </tr>
                    <%
                                }
                                rs2.close(); st2.close(); cn2.close();
                            } catch (Exception e) { e.printStackTrace(); }
                        }
                    %>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/core/bootstrap.min.js"></script>
<script src="assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script>
document.getElementById('statUsuarios').textContent = '<%=totalUsuarios%>';

var idUserVerJefe = <%=idUserDigits%>;
if (idUserVerJefe > 0) {
    new bootstrap.Modal(document.getElementById('myModalJEFE')).show();
}

var modalEditar = new bootstrap.Modal(document.getElementById('modalEditar'));
function abrirEditar(btn) {
    document.getElementById('editIdUser').value = btn.dataset.id;
    document.getElementById('editNombre').value = btn.dataset.nombre;
    document.getElementById('editApellido').value = btn.dataset.apellido;
    document.getElementById('editTelefono').value = btn.dataset.telefono;
    document.getElementById('editEmail').value = btn.dataset.email;
    document.getElementById('editUsuario').value = btn.dataset.usuario;
    document.getElementById('editPass').value = btn.dataset.pass;
    document.getElementById('editIdCia').value = btn.dataset.idcia;
    document.getElementById('editIdRol').value = btn.dataset.idrol;
    document.getElementById('editIdRolTodo').value = btn.dataset.idroltodo;
    document.getElementById('editIdDepartamento').value = btn.dataset.iddepartamento;
    modalEditar.show();
}

var inputBuscar = document.getElementById('buscarUsuario');
inputBuscar.addEventListener('input', function() {
    var q = this.value.trim().toLowerCase();
    document.querySelectorAll('.fila-usuario').forEach(function(row) {
        var match = !q || row.getAttribute('data-search').indexOf(q) !== -1;
        row.classList.toggle('d-none', !match);
    });
});
</script>
</body>
</html>
