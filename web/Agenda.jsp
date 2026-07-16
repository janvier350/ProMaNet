<%--
    Document   : Agenda
    Author     : Jquinde (original) / rediseño Argon
--%>
<%@page import=" java.util.Date"
        import="java.sql.*" %>

<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String(""+ip);
    int conta = 0;
    boolean esAdmin = cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE");
    int totalCitas = 0, totalPendientes = 0, totalAtrasadas = 0;
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if (!COMUN.PermisoHelper.tiene(session, "AGENDA_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
    <link rel="icon" type="image/png" href="assets/img/favicon.png">
    <title>ProMaNet - Agenda</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link href="assets/css/nucleo-icons.css" rel="stylesheet" />
    <link href="assets/css/nucleo-svg.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        .fila-agenda.d-none{display:none !important;}
        .btn-icon-sm{width:2.2rem;height:2.2rem;padding:0;display:inline-flex;align-items:center;justify-content:center;}
        .badge-estado{padding:.4em .75em;border-radius:.5rem;font-size:.75rem;font-weight:600;}
        .badge-TERMINADO{background:#d1e7dd;color:#0f5132;}
        .badge-PENDIENTE{background:#fff3cd;color:#856404;}
        .badge-ATRASADO{background:#ffe5b4;color:#8a5a00;}
        .badge-CANCELADO{background:#f8d7da;color:#842029;}
        .badge-colega{background:#f0f2f5;color:#495057;font-size:.7rem;padding:.25em .6em;border-radius:.4rem;display:inline-flex;align-items:center;gap:.35rem;}
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
            <li class="nav-item">
                <a class="nav-link" href="Contactos.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-single-02 text-success text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Contactos</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="Agenda.jsp">
                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                        <i class="ni ni-calendar-grid-58 text-info text-sm opacity-10"></i>
                    </div>
                    <span class="nav-link-text ms-1">Agenda</span>
                </a>
            </li>
        </ul>
    </div>
    <div class="sidenav-footer mx-3">
        <div class="card card-plain shadow-none" id="sidenavCard">
            <img class="w-50 mx-auto" src="assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
            <div class="card-body text-center p-3 w-100 pt-0">
                <div class="docs-info">
                    <h6 class="mb-0">Agenda de reuniones</h6>
                    <p class="text-xs font-weight-bold mb-0">Citas del mes en curso</p>
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
                    <li class="breadcrumb-item text-sm text-white active" aria-current="page">Agenda</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Agenda</h6>
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
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Citas este mes</p>
                                    <h5 class="font-weight-bolder mb-0" id="statTotal">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                    <i class="ni ni-calendar-grid-58 text-lg opacity-10" aria-hidden="true"></i>
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
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Pendientes</p>
                                    <h5 class="font-weight-bolder mb-0" id="statPendientes">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-warning shadow text-center border-radius-md">
                                    <i class="ni ni-time-alarm text-lg opacity-10" aria-hidden="true"></i>
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
                                    <p class="text-sm mb-0 text-capitalize font-weight-bold">Atrasadas</p>
                                    <h5 class="font-weight-bolder mb-0" id="statAtrasadas">-</h5>
                                </div>
                            </div>
                            <div class="col-4 text-end">
                                <div class="icon icon-shape bg-gradient-danger shadow text-center border-radius-md">
                                    <i class="ni ni-bell-55 text-lg opacity-10" aria-hidden="true"></i>
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
                        <label class="form-label text-sm mb-1">Buscar cita</label>
                        <input type="text" class="form-control" id="buscarAgenda" placeholder="Ejecutivo, cliente, departamento...">
                    </div>
                    <% if (esAdmin) { %>
                    <div class="pt-4">
                        <a href="Agenda_history.jsp" class="btn btn-outline-secondary mb-0" title="Historial de todas las citas">
                            <i class="fa fa-history me-1"></i>Historial
                        </a>
                        <button type="button" class="btn bg-gradient-primary mb-0" data-bs-toggle="modal" data-bs-target="#modalNuevaCita">
                            <i class="fa fa-calendar-plus-o me-1"></i>Nueva Cita
                        </button>
                        <a href="NewServlet" class="btn btn-outline-secondary mb-0" title="Imprimir">
                            <i class="fa fa-print me-1"></i>Imprimir
                        </a>
                        <a href="https://youtu.be/kwTs6jv27h0" target="_blank" class="btn btn-outline-danger mb-0" title="Tutorial Agenda">
                            <i class="fa fa-youtube-play me-1"></i>Tutorial
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="card mt-4">
            <div class="table-responsive">
                <table class="table align-items-center mb-0">
                    <thead>
                        <tr>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7 ps-4">#</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Estado</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Fecha / Hora</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Ejecutivo</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Departamento</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Cliente</th>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7">Observaci&oacute;n</th>
                            <% if (esAdmin) { %>
                            <th class="text-uppercase text-xs font-weight-bolder opacity-7 text-end pe-4">Acciones</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody id="myTable">
                    <%
                    try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn = DriverManager.getConnection(url, user, pass);
                        String sql = "SELECT "
                        + "a.id_adm_cab_agenda,"
                        + "TO_CHAR(a.fecha_age_ini, 'yyyy-MM-dd'),"
                       + " a.hora_age_ini,"
    + "a.hora_age_fin,"
   + " c.nombre ||' '|| c.apellidos,"
   + " b.cliente,"
   + " a.observacion,"
    + "a.estado,"
    + "a.id_cliente,"
   + " a.estado_agenda,"
   + " a.area,"
   + " a.id_usuario,"
    + "TO_CHAR(a.fecha_age_ini, 'Month', 'nls_date_language=spanish') AS MES,"
   + " TO_CHAR(a.fecha_age_ini, 'DAY', 'nls_date_language=spanish') AS DIA "
+ "FROM "
 + "   adm_cab_agenda a "
+ "INNER JOIN "
 + "   cliente b ON a.id_cliente = b.idcliente "
+ "INNER JOIN "
 + "   usuario c ON a.id_usuario = c.idusuario "
+ "WHERE "
  + "  a.ESTADO = 'A' "
  + "  AND EXTRACT(MONTH FROM a.fecha_age_ini) = EXTRACT(MONTH FROM CURRENT_DATE) "
+ "ORDER BY 10";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();
                        while (rs.next()) {
                        conta++;
                        totalCitas++;
                        String estadoAgenda = rs.getString(10);
                        if ("PENDIENTE".equals(estadoAgenda)) totalPendientes++;
                        if ("ATRASADO".equals(estadoAgenda)) totalAtrasadas++;
                        String textoFila = (rs.getString(5) + " " + rs.getString(6) + " " + rs.getString(11) + " " + rs.getString(7)).toLowerCase();
                    %>
                    <tr class="fila-agenda" data-search="<%=textoFila%>">
                        <td class="ps-4"><span class="text-sm"><%=conta%></span></td>
                        <td><span class="badge-estado badge-<%=estadoAgenda%>"><%=estadoAgenda%></span></td>
                        <td>
                            <span class="text-sm font-weight-bold d-block"><%=rs.getString(2)%></span>
                            <span class="text-xs text-secondary d-block"><%=rs.getString(3)%> - <%=rs.getString(4)%></span>
                        </td>
                        <td>
                            <span class="text-sm d-block"><%=rs.getString(5)%></span>
                            <%
                                String detalleAgenda = "select apellidos, nombres, departamento, id_usuario, id_adm_det_agenda from adm_det_agenda where id_adm_cab_agenda = ? and estado = 'A'";
                                try{
                                    Connection cn3 = DriverManager.getConnection(url, user, pass);
                                    PreparedStatement st3 = cn3.prepareStatement(detalleAgenda);
                                    st3.setInt(1, Integer.parseInt(rs.getString(1)));
                                    ResultSet rs3 = st3.executeQuery();
                                    while (rs3.next()){
                            %>
                            <span class="badge-colega mt-1">
                                <%=rs3.getString(2)%> <%=rs3.getString(1)%>
                                <% if (cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")) { %>
                                <a href="ADM_EliminarColega.jsp?idColega=<%=rs3.getString(5)%>" title="Eliminar colega" class="text-danger"><i class="fa fa-times"></i></a>
                                <% } %>
                            </span>
                            <%
                                    }
                                    rs3.close(); st3.close(); cn3.close();
                                } catch (Exception e3) { e3.printStackTrace(); }
                            %>
                        </td>
                        <td><span class="text-sm"><%=rs.getString(11)%></span></td>
                        <td><span class="text-sm"><%=rs.getString(6)%></span></td>
                        <td><span class="text-xs text-secondary text-truncate d-inline-block" style="max-width:220px;" title="<%=rs.getString(7)%>"><%=rs.getString(7)%></span></td>
                        <% if (esAdmin) { %>
                        <td class="text-end pe-4 text-nowrap">
                            <a href="Agenda_Editar_Cab.jsp?idRegistroAgenda=<%=rs.getString(1)%>&observacion=<%=rs.getString(7)%>&h_inicio=<%=rs.getString(3)%>&h_fin=<%=rs.getString(4)%>&fechaAgenda=<%=rs.getString(2)%>&idClienteAsig=<%=rs.getString(9)%>&nombreCliente=<%=rs.getString(6)%>&nombreDepartamento=<%=rs.getString(11)%>&idEjecutivo=<%=rs.getString(12)%>&nombreEjecutivo=<%=rs.getString(5)%>" class="btn btn-icon-sm btn-outline-warning me-1" title="Editar cita">
                                <i class="fa fa-pencil"></i>
                            </a>
                            <a href="Agenda_Agregar_Colega.jsp?idRegistroAgenda=<%=rs.getString(1)%>" class="btn btn-icon-sm btn-outline-info me-1" title="Agregar colega">
                                <i class="fa fa-user-plus"></i>
                            </a>
                            <a href="ADM_TerminarAgenda.jsp?idRegistroAgenda=<%=rs.getString(1)%>" class="btn btn-icon-sm btn-outline-success me-1" title="Terminar">
                                <i class="fa fa-check"></i>
                            </a>
                            <a href="ADM_EliminarAgenda.jsp?idRegistroAgenda=<%=rs.getString(1)%>" class="btn btn-icon-sm btn-outline-danger" title="Eliminar" onclick="return confirm('¿Eliminar esta cita?');">
                                <i class="fa fa-trash"></i>
                            </a>
                        </td>
                        <% } %>
                    </tr>
                    <%
                        }
                        rs.close(); st.close(); cn.close();
                    }catch(Exception e){
                        e.printStackTrace();
                    %>
                    <tr><td colspan="8" class="text-danger ps-4">Error: <%=e.getMessage()%></td></tr>
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

<!-- Modal: Nueva Cita -->
<div class="modal fade" id="modalNuevaCita" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <form action="ADM_Insert_Agenda.jsp" method="POST">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-calendar-plus-o me-2"></i>Nuevo Registro Agenda</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Ejecutivo</label>
                                <select class="form-control" id="idEjecutivo" name="idEjecutivo">
                                    <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection cnEje = DriverManager.getConnection(url, user, pass);
                                        String sqlEje = "select * from Usuario where estado = 'a' order by 2";
                                        PreparedStatement stEje = cnEje.prepareStatement(sqlEje);
                                        ResultSet rsEje = stEje.executeQuery();
                                        while (rsEje.next()) {
                                        %>
                                    <option value="<%=rsEje.getString(1)%>"><%=rsEje.getString(2)%> <%=rsEje.getString(3)%></option>
                                        <%
                                            }
                                            rsEje.close(); stEje.close(); cnEje.close();
                                        }catch(Exception e){ e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Fecha</label>
                                <input type="date" name="fechAgenda" id="fechAgenda" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Hora inicio</label>
                                <input type="time" name="h_inicio" id="h_inicio" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Hora fin</label>
                                <input type="time" name="h_fin" id="h_fin" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Cliente</label>
                                <select class="form-control" id="cliente" name="cliente">
                                    <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection cnCli = DriverManager.getConnection(url, user, pass);
                                        String sqlCli = "select * from Cliente where estado = 'a' order by 2";
                                        PreparedStatement stCli = cnCli.prepareStatement(sqlCli);
                                        ResultSet rsCli = stCli.executeQuery();
                                        while (rsCli.next()) {
                                        %>
                                    <option value="<%=rsCli.getString(1)%>"><%=rsCli.getString(2)%></option>
                                        <%
                                            }
                                            rsCli.close(); stCli.close(); cnCli.close();
                                        }catch(Exception e){ e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label class="form-label">Departamento</label>
                                <select class="form-control" name="grupo">
                                    <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection cnGru = DriverManager.getConnection(url, user, pass);
                                        String sqlGru = "select A.IDTODOCABGRUPO, A.NOMBREGRUPO, A.ESTADO from TODOCABGRUPO A where A.IDTODOCABGRUPO>1 AND ESTADO = 'A' ORDER BY 2";
                                        PreparedStatement stGru = cnGru.prepareStatement(sqlGru);
                                        ResultSet rsGru = stGru.executeQuery();
                                        while (rsGru.next()) {
                                        %>
                                    <option value="<%=rsGru.getString(2)%>"><%=rsGru.getString(2)%></option>
                                        <%
                                            }
                                            rsGru.close(); stGru.close(); cnGru.close();
                                        }catch(Exception e){ e.printStackTrace(); }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="mb-3">
                                <label class="form-label">Observaci&oacute;n</label>
                                <textarea class="form-control" id="observacion" name="observacion" rows="3"></textarea>
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

<script src="assets/js/core/popper.min.js"></script>
<script src="assets/js/core/bootstrap.min.js"></script>
<script src="assets/js/plugins/perfect-scrollbar.min.js"></script>
<script src="assets/js/plugins/smooth-scrollbar.min.js"></script>
<script src="assets/js/argon-dashboard.min.js?v=2.0.4"></script>
<script>
document.getElementById('statTotal').textContent = '<%=totalCitas%>';
document.getElementById('statPendientes').textContent = '<%=totalPendientes%>';
document.getElementById('statAtrasadas').textContent = '<%=totalAtrasadas%>';

var inputBuscar = document.getElementById('buscarAgenda');
inputBuscar.addEventListener('input', function() {
    var q = this.value.trim().toLowerCase();
    document.querySelectorAll('.fila-agenda').forEach(function(row) {
        var match = !q || row.getAttribute('data-search').indexOf(q) !== -1;
        row.classList.toggle('d-none', !match);
    });
});
</script>
</body>
</html>
