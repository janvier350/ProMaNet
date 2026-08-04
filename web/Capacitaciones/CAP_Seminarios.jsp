<%--
 Document   : CAP_Seminarios
 Created on : 28 jul 2026
 Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
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
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String("" + ip);

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "CAPACITACIONES_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp");
        return;
    }

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");

    boolean verEliminados = "1".equals(request.getParameter("eliminados"));

    StringBuilder opcionesEmpresa = new StringBuilder();
    StringBuilder opcionesCompania = new StringBuilder();
    StringBuilder filasSem = new StringBuilder();
    int totalSem = 0;

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        // Catalogo de empresas capacitadoras: <option> para el select
        // Select2 (con busqueda) de los modales Nueva/Editar Capacitacion.
        PreparedStatement stEmp = cn.prepareStatement(
                "SELECT ID_EMPRESA, DESCRIPCION FROM CAPACITACIONES_EMPRESA WHERE ESTADO='A' ORDER BY DESCRIPCION");
        ResultSet rsEmp = stEmp.executeQuery();
        while (rsEmp.next()) {
            opcionesEmpresa.append("<option value=\"").append(rsEmp.getInt(1)).append("\">")
                    .append(esc(rsEmp.getString(2))).append("</option>");
        }
        rsEmp.close();
        stEmp.close();

        // Catalogo real de companias del grupo (misma tabla que usa el
        // resto del sistema) para elegir la Compania Facturada.
        PreparedStatement stComp = cn.prepareStatement(
                "SELECT IDCOMPANIA, COMPANIA FROM COMPANIA WHERE ESTADO='a' ORDER BY COMPANIA");
        ResultSet rsComp = stComp.executeQuery();
        while (rsComp.next()) {
            opcionesCompania.append("<option value=\"").append(rsComp.getInt(1)).append("\">")
                    .append(esc(rsComp.getString(2))).append("</option>");
        }
        rsComp.close();
        stComp.close();

        // Listado principal de capacitaciones.
        PreparedStatement stSem = cn.prepareStatement(
                "SELECT s.ID_SEMINARIO, s.ID_EMPRESA, e.DESCRIPCION, s.NOMBRE_SEMINARIO, s.ESTADO_PAGO, " +
                "s.FORMA_PAGO, s.APROBACION, s.HORARIO, s.FECHA_CAPACITACION, s.DURACION_HORAS, s.MODALIDAD, " +
                "s.UBICACION, s.NO_PARTICIPANTES, s.NOMBRE_PARTICIPANTES, s.SUBTOTAL, s.IVA_PORCENTAJE, " +
                "s.IVA_VALOR, s.TOTAL_FACTURA, s.RETENCION, s.TOTAL_PAGADO, s.ID_COMPANIA_FACTURA, c.COMPANIA, " +
                "TO_CHAR(s.FECHA_FACTURA,'YYYY-MM-DD'), TO_CHAR(s.FECHA_FACTURA,'DD/MM/YYYY'), s.ACTIVO " +
                "FROM CAPACITACIONES_SEMINARIO s " +
                "LEFT JOIN CAPACITACIONES_EMPRESA e ON s.ID_EMPRESA = e.ID_EMPRESA " +
                "LEFT JOIN COMPANIA c ON s.ID_COMPANIA_FACTURA = c.IDCOMPANIA " +
                (verEliminados ? "" : "WHERE s.ACTIVO = 'A' ") +
                "ORDER BY s.FECHA_FACTURA DESC NULLS LAST, s.FECHA_CREACION DESC");
        ResultSet rsSem = stSem.executeQuery();
        while (rsSem.next()) {
            totalSem++;
            int idSem = rsSem.getInt(1);
            String idEmpresaRaw = rsSem.getString(2) != null ? rsSem.getString(2) : "";
            String empresa = rsSem.getString(3) != null ? rsSem.getString(3) : "—";
            String nombreSeminario = rsSem.getString(4) != null ? rsSem.getString(4) : "";
            String estadoPago = rsSem.getString(5) != null ? rsSem.getString(5) : "";
            String formaPago = rsSem.getString(6) != null ? rsSem.getString(6) : "";
            String aprobacion = rsSem.getString(7) != null ? rsSem.getString(7) : "";
            String horario = rsSem.getString(8) != null ? rsSem.getString(8) : "";
            String fechaCapacitacion = rsSem.getString(9) != null ? rsSem.getString(9) : "";
            String duracionHoras = rsSem.getString(10) != null ? rsSem.getString(10) : "";
            String modalidad = rsSem.getString(11) != null ? rsSem.getString(11) : "";
            String ubicacion = rsSem.getString(12) != null ? rsSem.getString(12) : "";
            String noParticipantes = rsSem.getString(13) != null ? rsSem.getString(13) : "";
            String nombreParticipantes = rsSem.getString(14) != null ? rsSem.getString(14) : "";
            String subtotal = rsSem.getString(15) != null ? rsSem.getString(15) : "0";
            String ivaPorcentaje = rsSem.getString(16) != null ? rsSem.getString(16) : "15";
            String ivaValor = rsSem.getString(17) != null ? rsSem.getString(17) : "0";
            String totalFactura = rsSem.getString(18) != null ? rsSem.getString(18) : "0";
            String retencion = rsSem.getString(19) != null ? rsSem.getString(19) : "0";
            String totalPagado = rsSem.getString(20) != null ? rsSem.getString(20) : "0";
            String idCompaniaFacturaRaw = rsSem.getString(21) != null ? rsSem.getString(21) : "";
            String companiaFactura = rsSem.getString(22) != null ? rsSem.getString(22) : "";
            String fechaFacturaIso = rsSem.getString(23) != null ? rsSem.getString(23) : "";
            String fechaFacturaDisplay = rsSem.getString(24) != null ? rsSem.getString(24) : "";
            boolean eliminado = "I".equals(rsSem.getString(25));

            String buscaIdx = (nombreSeminario + " " + empresa + " " + companiaFactura + " " + aprobacion + " " + nombreParticipantes).toLowerCase().replace("'", "");

            String nombreSeminarioAttr = esc(nombreSeminario).replace("'", "&#39;");
            String aprobacionAttr = esc(aprobacion).replace("'", "&#39;");
            String horarioAttr = esc(horario).replace("'", "&#39;");
            String fechaCapacitacionAttr = esc(fechaCapacitacion).replace("'", "&#39;");
            String ubicacionAttr = esc(ubicacion).replace("'", "&#39;");
            String nombreParticipantesAttr = esc(nombreParticipantes).replace("'", "&#39;");

            filasSem.append("<tr data-desc='").append(buscaIdx).append("'>")
                    .append("<td class='celda-info'><strong>").append(esc(nombreSeminario)).append("</strong>")
                    .append(eliminado ? " <span class='badge' style='background:#dc3545;color:#fff;'>ELIMINADO</span>" : "")
                    .append("<br><small class='text-muted'>").append(esc(empresa)).append("</small></td>")
                    .append("<td>").append(esc(modalidad)).append("</td>")
                    .append("<td class='celda-info'>").append(esc(fechaCapacitacion)).append("</td>")
                    .append("<td class='celda-info'>").append(esc(aprobacion)).append("</td>")
                    .append("<td class='celda-info'>").append(esc(nombreParticipantes)).append("</td>")
                    .append("<td class='celda-info'>").append(esc(companiaFactura)).append("</td>")
                    .append("<td>").append(fechaFacturaDisplay).append("</td>")
                    .append("<td class='text-end'>").append(totalFactura).append("</td>")
                    .append("<td class='text-end'>").append(totalPagado).append("</td>")
                    .append("<td class='text-center'>")
                    .append("<div class='d-flex justify-content-center align-items-center' style='gap:4px;'>")
                    .append("<button type='button' class='btn btn-sm btn-outline-primary btn-editar-sem' style='padding:3px 8px;' ")
                    .append("data-id='").append(idSem).append("' ")
                    .append("data-idempresa='").append(idEmpresaRaw).append("' ")
                    .append("data-nombreseminario='").append(nombreSeminarioAttr).append("' ")
                    .append("data-estadopago='").append(estadoPago).append("' ")
                    .append("data-formapago='").append(formaPago).append("' ")
                    .append("data-aprobacion='").append(aprobacionAttr).append("' ")
                    .append("data-horario='").append(horarioAttr).append("' ")
                    .append("data-fechacapacitacion='").append(fechaCapacitacionAttr).append("' ")
                    .append("data-duracionhoras='").append(duracionHoras).append("' ")
                    .append("data-modalidad='").append(modalidad).append("' ")
                    .append("data-ubicacion='").append(ubicacionAttr).append("' ")
                    .append("data-noparticipantes='").append(noParticipantes).append("' ")
                    .append("data-nombreparticipantes='").append(nombreParticipantesAttr).append("' ")
                    .append("data-subtotal='").append(subtotal).append("' ")
                    .append("data-ivaporcentaje='").append(ivaPorcentaje).append("' ")
                    .append("data-retencion='").append(retencion).append("' ")
                    .append("data-idcompaniafactura='").append(idCompaniaFacturaRaw).append("' ")
                    .append("data-fechafactura='").append(fechaFacturaIso).append("'>")
                    .append("<i class='fa fa-pencil'></i></button>")
                    .append(eliminado
                        ? "<button type='button' class='btn btn-sm btn-outline-success' style='padding:3px 8px;' onclick=\"cambiarEstadoSem(" + idSem + ",'restaurar')\"><i class='fa fa-undo'></i></button>"
                        : "<button type='button' class='btn btn-sm btn-outline-danger' style='padding:3px 8px;' onclick=\"cambiarEstadoSem(" + idSem + ",'eliminar')\"><i class='fa fa-trash'></i></button>")
                    .append("</div></td></tr>\n");
        }
        rsSem.close();
        stSem.close();
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
        <title>ProMaNet | Capacitaciones</title>
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
        <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
        <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
        <style>
            #tablaSem td, #tablaSem th { font-size: 0.8125rem; white-space: nowrap; vertical-align: middle; }
            #tablaSem td.celda-info {
                white-space: normal;
                word-break: break-word;
                min-width: 160px;
            }
        </style>
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
                        <a class="nav-link active" href="../Capacitaciones/CAP_Seminarios.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-hat-3 text-primary text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Capacitaciones</span>
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
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Capacitaciones</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Capacitaciones</h6>
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
                            <li class="nav-item ps-3 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                                    <div class="sidenav-toggler-inner">
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                    </div>
                                </a>
                            </li>
                            <li class="nav-item ps-3 d-flex align-items-center">
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

                <%-- Tarjeta boton: Nueva Capacitacion --%>
                <div class="row">
                    <div class="col-xl-3 col-sm-6 mb-4">
                        <div class="card" style="cursor:pointer;" onclick="modalNuevaSem.show()">
                            <div class="card-body p-3">
                                <div class="row">
                                    <div class="col-8">
                                        <div class="numbers">
                                            <p class="text-sm mb-0 text-uppercase font-weight-bold">Registrar</p>
                                            <h5 class="font-weight-bolder">
                                                CAPACITACION
                                            </h5>
                                            <p class="mb-0">
                                                <span class="text-primary text-sm font-weight-bolder">Nuevo</span>
                                                <b class="text-primary"> registro de seminario.</b>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="col-4 text-end">
                                        <div class="icon icon-shape bg-gradient-primary shadow-primary text-center rounded-circle">
                                            <i class="ni ni-hat-3 text-lg opacity-10" aria-hidden="true"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Tabla de Capacitaciones --%>
                <div class="card">
                    <div class="card-header d-flex flex-column flex-md-row justify-content-between align-items-md-center">
                        <span class="mb-2 mb-md-0"><i class="fa fa-table mr-2 text-secondary"></i>Capacitaciones
                            <span class="badge ml-2" style="background:#6c757d;color:#fff;"><%=totalSem%> registros</span>
                        </span>
                        <div class="d-flex flex-column flex-sm-row align-items-stretch align-items-sm-center">
                            <a href="CAP_Seminarios.jsp<%= verEliminados ? "" : "?eliminados=1" %>"
                               class="btn btn-sm <%= verEliminados ? "btn-secondary" : "btn-outline-secondary" %> mb-2 mb-sm-0 mr-sm-2 text-center"
                               style="white-space:nowrap;">
                                <i class="fa fa-eye<%= verEliminados ? "-slash" : "" %> mr-1"></i><%= verEliminados ? "Ocultar eliminados" : "Ver eliminados" %>
                            </a>
                            <input type="text" id="buscarSem" class="form-control form-control-sm"
                                   placeholder="Buscar..." style="width:100%;max-width:220px;">
                        </div>
                    </div>
                    <div class="card-header border-top py-2">
                        <div class="d-flex flex-wrap align-items-center justify-content-end" style="gap:16px;row-gap:8px;">
                            <div class="d-flex align-items-center" style="gap:6px;">
                                <label class="text-xs text-secondary mb-0" style="white-space:nowrap;">Factura desde</label>
                                <input type="date" id="filtroFechaDesde" class="form-control form-control-sm" style="width:150px;">
                                <label class="text-xs text-secondary mb-0" style="white-space:nowrap;">hasta</label>
                                <input type="date" id="filtroFechaHasta" class="form-control form-control-sm" style="width:150px;">
                            </div>
                            <div class="d-flex align-items-center" style="gap:8px;">
                                <button type="button" class="btn btn-sm btn-outline-success mb-0" id="btnExportarExcel">
                                    <i class="fa fa-file-excel-o mr-1"></i>Excel
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger mb-0" id="btnExportarPDF">
                                    <i class="fa fa-file-pdf-o mr-1"></i>PDF
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0" id="tablaSem">
                                <thead>
                                    <tr>
                                        <th>Seminario</th>
                                        <th>Modalidad</th>
                                        <th>Fecha</th>
                                        <th>Aprobacion</th>
                                        <th>Participantes</th>
                                        <th>Compania Facturada</th>
                                        <th>Fecha Factura</th>
                                        <th class="text-end">Total Factura</th>
                                        <th class="text-end">Total Pagado</th>
                                        <th class="text-center" style="width:90px;">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
<%=filasSem.length() > 0 ? filasSem.toString() : "<tr><td colspan='10' class='text-center text-muted py-4'><i class='fa fa-inbox fa-2x d-block mb-2'></i>No hay capacitaciones registradas.</td></tr>"%>
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

        <%-- Modal: Nueva Capacitacion --%>
        <div class="modal fade" id="modalNuevaSem" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <form action="../CAP_InsertarSeminario" method="post">
                        <div class="modal-header" style="background:#5e72e4;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-hat-cowboy mr-2"></i>Nueva Capacitacion</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 form-group mb-2">
                                    <label>Empresa Capacitadora</label>
                                    <div class="d-flex align-items-start" style="gap:6px;">
                                        <div class="flex-grow-1">
                                            <select name="idEmpresa" id="crIdEmpresa" class="form-control select2-modal">
                                                <option value=""></option>
<%=opcionesEmpresa.toString()%>
                                            </select>
                                        </div>
                                        <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nueva-empresa" title="Nueva empresa"><i class="fa fa-plus"></i></button>
                                    </div>
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Nombre del Seminario</label>
                                    <input type="text" name="nombreSeminario" class="form-control" required maxlength="500">
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Estado</label>
                                    <select name="estadoPago" class="form-control" required>
                                        <option value="PAGADO">PAGADO</option>
                                    </select>
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Forma de Pago</label>
                                    <select name="formaPago" class="form-control">
                                        <option value=""></option>
                                        <option value="EFECTIVO">EFECTIVO</option>
                                        <option value="TRANSFERENCIA">TRANSFERENCIA</option>
                                        <option value="CHEQUE/DEPOSITO">CHEQUE/DEPOSITO</option>
                                        <option value="CANJE">CANJE</option>
                                    </select>
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Aprobacion</label>
                                    <input type="text" name="aprobacion" class="form-control" maxlength="200">
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Modalidad</label>
                                    <select name="modalidad" class="form-control">
                                        <option value=""></option>
                                        <option value="PRESENCIAL">PRESENCIAL</option>
                                        <option value="ONLINE">ONLINE</option>
                                    </select>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Horario</label>
                                    <input type="text" name="horario" class="form-control" maxlength="100" placeholder="Ej. 09:00 - 17:00">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Duracion (horas)</label>
                                    <input type="number" step="0.5" name="duracionHoras" class="form-control" maxlength="10">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>No. Participantes</label>
                                    <input type="number" name="noParticipantes" class="form-control">
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Fecha(s) de la Capacitacion</label>
                                    <input type="text" name="fechaCapacitacion" class="form-control" maxlength="300" placeholder="Ej. 9 y 10 de enero, o varias fechas">
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Ubicacion</label>
                                    <input type="text" name="ubicacion" class="form-control" maxlength="300" placeholder="N/A si es online">
                                </div>
                                <div class="col-md-12 form-group mb-2">
                                    <label>Nombre de los Participantes</label>
                                    <textarea name="nombreParticipantes" class="form-control" rows="2" maxlength="1000"></textarea>
                                </div>
                                <div class="col-12"><hr class="my-2"></div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Subtotal</label>
                                    <input type="number" step="0.01" name="subtotal" id="crSubtotal" class="form-control campo-calculo">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>% IVA</label>
                                    <input type="number" step="0.01" name="ivaPorcentaje" id="crIvaPorcentaje" class="form-control campo-calculo" value="15">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>IVA</label>
                                    <input type="number" step="0.01" name="ivaValor" id="crIvaValor" class="form-control" readonly>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Total Factura</label>
                                    <input type="number" step="0.01" name="totalFactura" id="crTotalFactura" class="form-control" readonly>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Retencion</label>
                                    <input type="number" step="0.01" name="retencion" id="crRetencion" class="form-control campo-calculo">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Total a Pagar</label>
                                    <input type="number" step="0.01" name="totalPagado" id="crTotalPagado" class="form-control" readonly>
                                </div>
                                <div class="col-md-8 form-group mb-2">
                                    <label>Compania Facturada</label>
                                    <select name="idCompaniaFactura" id="crIdCompaniaFactura" class="form-control select2-modal">
                                        <option value=""></option>
<%=opcionesCompania.toString()%>
                                    </select>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Fecha de Factura</label>
                                    <input type="date" name="fechaFactura" class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-save mr-1"></i>Guardar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Editar Capacitacion --%>
        <div class="modal fade" id="modalEditarSem" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <form action="../CAP_ActualizarSeminario" method="post">
                        <input type="hidden" name="idSeminario" id="editIdSeminario">
                        <div class="modal-header" style="background:#3d5a99;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-pencil mr-2"></i>Editar Capacitacion</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 form-group mb-2">
                                    <label>Empresa Capacitadora</label>
                                    <div class="d-flex align-items-start" style="gap:6px;">
                                        <div class="flex-grow-1">
                                            <select name="idEmpresa" id="editIdEmpresa" class="form-control select2-modal">
                                                <option value=""></option>
<%=opcionesEmpresa.toString()%>
                                            </select>
                                        </div>
                                        <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nueva-empresa" title="Nueva empresa"><i class="fa fa-plus"></i></button>
                                    </div>
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Nombre del Seminario</label>
                                    <input type="text" name="nombreSeminario" id="editNombreSeminario" class="form-control" required maxlength="500">
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Estado</label>
                                    <select name="estadoPago" id="editEstadoPago" class="form-control" required>
                                        <option value="PAGADO">PAGADO</option>
                                    </select>
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Forma de Pago</label>
                                    <select name="formaPago" id="editFormaPago" class="form-control">
                                        <option value=""></option>
                                        <option value="EFECTIVO">EFECTIVO</option>
                                        <option value="TRANSFERENCIA">TRANSFERENCIA</option>
                                        <option value="CHEQUE/DEPOSITO">CHEQUE/DEPOSITO</option>
                                        <option value="CANJE">CANJE</option>
                                    </select>
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Aprobacion</label>
                                    <input type="text" name="aprobacion" id="editAprobacion" class="form-control" maxlength="200">
                                </div>
                                <div class="col-md-3 form-group mb-2">
                                    <label>Modalidad</label>
                                    <select name="modalidad" id="editModalidad" class="form-control">
                                        <option value=""></option>
                                        <option value="PRESENCIAL">PRESENCIAL</option>
                                        <option value="ONLINE">ONLINE</option>
                                    </select>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Horario</label>
                                    <input type="text" name="horario" id="editHorario" class="form-control" maxlength="100">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Duracion (horas)</label>
                                    <input type="number" step="0.5" name="duracionHoras" id="editDuracionHoras" class="form-control">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>No. Participantes</label>
                                    <input type="number" name="noParticipantes" id="editNoParticipantes" class="form-control">
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Fecha(s) de la Capacitacion</label>
                                    <input type="text" name="fechaCapacitacion" id="editFechaCapacitacion" class="form-control" maxlength="300">
                                </div>
                                <div class="col-md-6 form-group mb-2">
                                    <label>Ubicacion</label>
                                    <input type="text" name="ubicacion" id="editUbicacion" class="form-control" maxlength="300">
                                </div>
                                <div class="col-md-12 form-group mb-2">
                                    <label>Nombre de los Participantes</label>
                                    <textarea name="nombreParticipantes" id="editNombreParticipantes" class="form-control" rows="2" maxlength="1000"></textarea>
                                </div>
                                <div class="col-12"><hr class="my-2"></div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Subtotal</label>
                                    <input type="number" step="0.01" name="subtotal" id="editSubtotal" class="form-control campo-calculo">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>% IVA</label>
                                    <input type="number" step="0.01" name="ivaPorcentaje" id="editIvaPorcentaje" class="form-control campo-calculo">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>IVA</label>
                                    <input type="number" step="0.01" name="ivaValor" id="editIvaValor" class="form-control" readonly>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Total Factura</label>
                                    <input type="number" step="0.01" name="totalFactura" id="editTotalFactura" class="form-control" readonly>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Retencion</label>
                                    <input type="number" step="0.01" name="retencion" id="editRetencion" class="form-control campo-calculo">
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Total a Pagar</label>
                                    <input type="number" step="0.01" name="totalPagado" id="editTotalPagado" class="form-control" readonly>
                                </div>
                                <div class="col-md-8 form-group mb-2">
                                    <label>Compania Facturada</label>
                                    <select name="idCompaniaFactura" id="editIdCompaniaFactura" class="form-control select2-modal">
                                        <option value=""></option>
<%=opcionesCompania.toString()%>
                                    </select>
                                </div>
                                <div class="col-md-4 form-group mb-2">
                                    <label>Fecha de Factura</label>
                                    <input type="date" name="fechaFactura" id="editFechaFactura" class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-save mr-1"></i>Guardar cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Nueva Empresa Capacitadora (quick-add, AJAX) --%>
        <div class="modal fade" id="modalNuevaEmpresa" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#6c757d;">
                        <h5 class="modal-title" style="color:#fff;"><i class="fa fa-building mr-2"></i>Nueva Empresa Capacitadora</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group mb-0">
                            <label>Nombre de la empresa</label>
                            <input type="text" id="nuevaEmpresaDesc" class="form-control" maxlength="300">
                            <small id="nuevaEmpresaMsg" class="text-danger"></small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-dark btn-sm" id="btnGuardarEmpresa"><i class="fa fa-save mr-1"></i>Guardar</button>
                    </div>
                </div>
            </div>
        </div>

        <form id="formEstadoSem" method="post" action="../CAP_ActualizarSeminario" style="display:none;">
            <input type="hidden" name="accion" id="semAccion">
            <input type="hidden" name="idSeminario" id="semAccionId">
        </form>

        <script src="../assets/js/core/popper.min.js"></script>
        <script src="../assets/js/core/bootstrap.min.js"></script>
        <script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
        <script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
        <script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
        <script src="../assets/js/custom-sidenav-toggle.js"></script>
        <script>
            var ctx = '<%=request.getContextPath()%>';

            var modalNuevaSem = new bootstrap.Modal(document.getElementById('modalNuevaSem'));
            var modalEditarSem = new bootstrap.Modal(document.getElementById('modalEditarSem'));
            var modalNuevaEmpresa = new bootstrap.Modal(document.getElementById('modalNuevaEmpresa'));

            document.querySelectorAll('.modal').forEach(function (modalEl) {
                var $modal = $(modalEl);
                var $selects = $modal.find('.select2-modal');
                if ($selects.length) {
                    $selects.select2({theme: 'bootstrap-5', width: '100%', dropdownParent: $modal, allowClear: true, placeholder: ''});
                }
            });

            // Bootstrap 5 no soporta bien modales apilados (uno sobre otro):
            // el modal de "Nueva Empresa" se abre reemplazando temporalmente
            // al modal de origen (Nueva/Editar Capacitacion), y al cerrarse
            // vuelve a mostrar ese modal de origen (los campos no se pierden,
            // solo se oculta/muestra el mismo formulario).
            var origenModalEmpresa = null;
            document.getElementById('modalNuevaEmpresa').addEventListener('hidden.bs.modal', function () {
                if (origenModalEmpresa) {
                    origenModalEmpresa.show();
                    origenModalEmpresa = null;
                }
            });

            document.querySelectorAll('.btn-nueva-empresa').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var $modalActual = $(this).closest('.modal');
                    origenModalEmpresa = $modalActual.attr('id') === 'modalNuevaSem' ? modalNuevaSem : modalEditarSem;
                    document.getElementById('nuevaEmpresaDesc').value = '';
                    document.getElementById('nuevaEmpresaMsg').textContent = '';
                    origenModalEmpresa.hide();
                    modalNuevaEmpresa.show();
                });
            });

            document.getElementById('btnGuardarEmpresa').addEventListener('click', function () {
                var desc = document.getElementById('nuevaEmpresaDesc').value.trim();
                var msgEl = document.getElementById('nuevaEmpresaMsg');
                if (!desc) {
                    msgEl.textContent = 'Escriba el nombre de la empresa.';
                    return;
                }
                var fd = new URLSearchParams();
                fd.append('descripcion', desc);
                fetch(ctx + '/CAP_InsertarEmpresa', {method: 'POST', body: fd})
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (!data.ok) {
                            msgEl.textContent = data.mensaje || 'No se pudo guardar.';
                            return;
                        }
                        var targetId = origenModalEmpresa === modalNuevaSem ? 'crIdEmpresa' : 'editIdEmpresa';
                        var $sel = $('#' + targetId);
                        if ($sel.find('option[value="' + data.id + '"]').length === 0) {
                            $sel.append(new Option(data.descripcion, data.id, false, false));
                        }
                        $sel.val(data.id).trigger('change');
                        modalNuevaEmpresa.hide();
                    })
                    .catch(function () {
                        msgEl.textContent = 'Error de conexion.';
                    });
            });

            // --- Calculo automatico de IVA / Total Factura / Total a Pagar ---
            function recalcular(prefijo) {
                var subtotal = parseFloat(document.getElementById(prefijo + 'Subtotal').value) || 0;
                var ivaPct = parseFloat(document.getElementById(prefijo + 'IvaPorcentaje').value);
                if (isNaN(ivaPct)) ivaPct = 15;
                var retencion = parseFloat(document.getElementById(prefijo + 'Retencion').value) || 0;

                var ivaValor = Math.round((subtotal * ivaPct / 100) * 100) / 100;
                var totalFactura = Math.round((subtotal + ivaValor) * 100) / 100;
                var totalPagado = Math.round((totalFactura - retencion) * 100) / 100;

                document.getElementById(prefijo + 'IvaValor').value = ivaValor.toFixed(2);
                document.getElementById(prefijo + 'TotalFactura').value = totalFactura.toFixed(2);
                document.getElementById(prefijo + 'TotalPagado').value = totalPagado.toFixed(2);
            }
            ['cr', 'edit'].forEach(function (prefijo) {
                document.querySelectorAll('#modal' + (prefijo === 'cr' ? 'NuevaSem' : 'EditarSem') + ' .campo-calculo').forEach(function (input) {
                    input.addEventListener('input', function () { recalcular(prefijo); });
                });
            });

            var buscarSem = document.getElementById('buscarSem');
            if (buscarSem) {
                buscarSem.addEventListener('input', function () {
                    var q = this.value.toLowerCase().trim();
                    document.querySelectorAll('#tablaSem tbody tr').forEach(function (tr) {
                        var d = tr.getAttribute('data-desc') || '';
                        tr.style.display = (!q || d.indexOf(q) !== -1) ? '' : 'none';
                    });
                });
            }

            // --- Editar Capacitacion ---
            document.querySelectorAll('.btn-editar-sem').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    document.getElementById('editIdSeminario').value = this.getAttribute('data-id');
                    document.getElementById('editNombreSeminario').value = this.getAttribute('data-nombreseminario');
                    document.getElementById('editEstadoPago').value = this.getAttribute('data-estadopago');
                    document.getElementById('editFormaPago').value = this.getAttribute('data-formapago');
                    document.getElementById('editAprobacion').value = this.getAttribute('data-aprobacion');
                    document.getElementById('editHorario').value = this.getAttribute('data-horario');
                    document.getElementById('editFechaCapacitacion').value = this.getAttribute('data-fechacapacitacion');
                    document.getElementById('editDuracionHoras').value = this.getAttribute('data-duracionhoras');
                    document.getElementById('editModalidad').value = this.getAttribute('data-modalidad');
                    document.getElementById('editUbicacion').value = this.getAttribute('data-ubicacion');
                    document.getElementById('editNoParticipantes').value = this.getAttribute('data-noparticipantes');
                    document.getElementById('editNombreParticipantes').value = this.getAttribute('data-nombreparticipantes');
                    document.getElementById('editSubtotal').value = this.getAttribute('data-subtotal');
                    document.getElementById('editIvaPorcentaje').value = this.getAttribute('data-ivaporcentaje');
                    document.getElementById('editRetencion').value = this.getAttribute('data-retencion');
                    document.getElementById('editFechaFactura').value = this.getAttribute('data-fechafactura');

                    $('#editIdEmpresa').val(this.getAttribute('data-idempresa') || '').trigger('change');
                    $('#editIdCompaniaFactura').val(this.getAttribute('data-idcompaniafactura') || '').trigger('change');

                    recalcular('edit');
                    modalEditarSem.show();
                });
            });

            // --- Exportar (Excel / PDF) respetando el filtro de fecha de factura ---
            function construirUrlExportar(servlet) {
                var desde = document.getElementById('filtroFechaDesde').value;
                var hasta = document.getElementById('filtroFechaHasta').value;
                var params = [];
                if (desde) params.push('fechaDesde=' + encodeURIComponent(desde));
                if (hasta) params.push('fechaHasta=' + encodeURIComponent(hasta));
                return ctx + '/' + servlet + (params.length ? '?' + params.join('&') : '');
            }
            document.getElementById('btnExportarExcel').addEventListener('click', function () {
                window.location.href = construirUrlExportar('CAP_ExportarExcel');
            });
            document.getElementById('btnExportarPDF').addEventListener('click', function () {
                window.location.href = construirUrlExportar('CAP_ExportarPDF');
            });

            // --- Eliminar / Restaurar (soft-delete) ---
            window.cambiarEstadoSem = function (id, accion) {
                var msg = (accion === 'eliminar')
                    ? '¿Eliminar esta capacitacion? Podras restaurarla luego con "Ver eliminados".'
                    : '¿Restaurar esta capacitacion para que vuelva a la lista?';
                if (!confirm(msg)) return;
                document.getElementById('semAccion').value = accion;
                document.getElementById('semAccionId').value = id;
                document.getElementById('formEstadoSem').submit();
            };
        </script>
    </body>
</html>
