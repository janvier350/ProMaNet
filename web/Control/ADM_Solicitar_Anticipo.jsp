<%-- 
    Document   : ADM_Solicitar_Anticipo
    Created on : 3 oct 2023, 20:32:28
    Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page contentType="text/html" 
        import=" java.util.Date"
        %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>
<!DOCTYPE html>
<%
String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String roltodo = (String) session.getAttribute("roltodo");
    String cabTrab = request.getParameter("idCabTrab");
    String DetTrab = request.getParameter("DetTrab");
    String DetTrabAC = "";
    String NombreAsig= request.getParameter("asis");
   
    String idSuministroIngresoCab = request.getParameter("ID_SUMINISTRO_INGRESO_CAB");
    String departamento = (String) session.getAttribute("departamento");
    String sueldo = (String) session.getAttribute("sueldo");
    
    String jefeAsignado= request.getParameter("jefeAsignado");
     String idCabTarea =  request.getParameter("idCabTarea");
     
     String idDepartamento = (String) session.getAttribute("idDepartamento");  
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String NombreTarea="";
    int p =0;
    int t =0;
    int r=0;
    int avance = 0;
     int retomar =0;
    String fechaFormateada = ""; // Variable para guardar el valor del input
    String corte = "";
    String corteTexto = ""; // corte, pero legible en espanol, solo para mostrar en pantalla
    String ultimoDiaTexto = ""; // un dia antes de corte: el ultimo dia real en que si se puede solicitar
    
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if(!COMUN.PermisoHelper.tiene(session, "CONTROL_ACCESO")){
                    response.sendRedirect("../sesionInvalida.jsp");
                    return;
             }

            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn3 = DriverManager.getConnection(url, user, pass);

            String fecha_corte = "SELECT ID_FECHA_CORTE, FECHA_CORTE, ESTADO FROM (SELECT ID_FECHA_CORTE, FECHA_CORTE, ESTADO FROM CTRL_FECHA_CORTE_ANTICIPO WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1";

            PreparedStatement st3 = cn3.prepareStatement(fecha_corte);
            ResultSet rs3 = st3.executeQuery();

            int validacionFecha = 0;
            java.util.Date hoy = new java.util.Date();

            if (rs3.next()) {
                int id = rs3.getInt("ID_FECHA_CORTE");
                java.sql.Date fecha = rs3.getDate("FECHA_CORTE");
                String estado = rs3.getString("ESTADO");

                System.out.println("ID: " + id + " - Fecha Corte: " + fecha);

                if (fecha != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    corte = sdf.format(fecha);
                    java.text.SimpleDateFormat sdfEs = new java.text.SimpleDateFormat("d 'de' MMMM 'del' yyyy", new java.util.Locale("es", "ES"));
                    corteTexto = sdfEs.format(fecha);

                    java.util.Calendar calUltimoDia = java.util.Calendar.getInstance();
                    calUltimoDia.setTime(fecha);
                    calUltimoDia.add(java.util.Calendar.DAY_OF_MONTH, -1);
                    ultimoDiaTexto = sdfEs.format(calUltimoDia.getTime());

                    if (hoy.after(fecha)) {
                        validacionFecha = 1;
                    } else {
                        validacionFecha = 2;
                    }
                }
            }

// Ahora puedes usar 'validacionFecha' para bloquear el formulario o mostrar alertas
System.out.println("Estado del corte: " + validacionFecha);





%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>
            ProMaNet | Solicitud anticipos de sueldo
        </title>
        <!--     Fonts and icons     -->
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
        <!-- Nucleo Icons -->
        <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <!-- Font Awesome Icons -->
        <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <!-- CSS Files -->
        <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />


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
                        <a class="nav-link active" href="../Proyectos/PRO_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="#">
                            <!--<a class="nav-link " href="../Proyectos/PRO_Lista.jsp">-->
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Lista de proyectos</span>
                        </a>
                    </li>

                    <% 
 if(departamento.equals("ADMINISTRACIÓN")||COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL")){%>
                    <li class="nav-item">
                        <a class="nav-link " href="../Control/ADM_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-user-run text-bg-light text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Talento Humano</span>
                        </a>
                    </li>
                    <%
                                   }else{
                   
                                }
             
                    %>

                    <li class="nav-item">
                        <a class="nav-link " href="../TODO_Cab_Trabajo.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-bullet-list-67 text-bg-light text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">TO - DO</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/PRO_Contactos.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="fa fa-users text-success text-sm opacity-10"></i>
                                <!--ni ni-single-copy-04-->
                            </div> 
                            <span class="nav-link-text ms-1">Contactos</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Agenda.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-calendar-grid-58 text-info text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Agenda</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/Recursos.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-archive-2 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Recursos</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../ReporteGastos/ReporteGastosIndivi.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-books text-danger text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Reporte de Gastos</span>
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
                        <!--control de acceso--> 
                        <%if(usuario.equals("uparrales")){%>
                        <%}else if(COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")){%>
                        <a class="nav-link " href="../Control/ADM_Atrasos_ALL.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-archive-2 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Reportes de atrasos</span>
                        </a>
                        <!--             <a class="nav-link " href="../Inventario/INV_Equipos.jsp">-->
                        <a class="nav-link " href="../Inventario/INV_Inventarios.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-laptop text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Inventario</span>
                        </a>
                        <a class="nav-link " href="../Soportes/SOP_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-collection text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Soportes Sistemas</span>
                        </a>
                        <%}%>

                        <a class="nav-link " href="../cerrar.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-button-power text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Cerrar sesión</span>
                        </a>
                    </li>
                    <!--        <li class="nav-item">
                              <a class="nav-link " href="../pages/sign-in.html">
                                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                  <i class="ni ni-single-copy-04 text-warning text-sm opacity-10"></i>
                                </div>
                                <span class="nav-link-text ms-1">Sign In</span>
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link " href="../pages/sign-up.html">
                                <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                  <i class="ni ni-collection text-info text-sm opacity-10"></i>
                                </div>
                                <span class="nav-link-text ms-1">Sign Up</span>
                              </a>
                            </li>-->
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
                <a href="https://www.youtube.com/watch?v=1bAjqT_-p_E" target="_blank" class="btn btn-danger btn-sm w-100 mb-3">Video Tutorial</a>
                <a href="../cerrar.jsp"  class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesión</a>

            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <!-- Navbar -->
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Menu</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Control</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Solicitar anticipo</h6>
                    </nav>
                    <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                        <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                            <div class="input-group">
                                <span class=" text-body text-white-50"><i class="fas fa-home" ></i> <%=compania%></span>

                            </div>
                        </div>
                        <ul class="navbar-nav  justify-content-end">
                            <li class="nav-item d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-user me-sm-1"></i>
                                    <span class="d-sm-inline d-none"><%=nombre%> <%=apellidos%> </span>
                                </a>
                            </li>
                            <li class="nav-item d-xl-none ps-3 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                                    <div class="sidenav-toggler-inner">
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                    </div>
                                </a>
                            </li>
                            <li class="nav-item px-3 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0">
                                    <i class="fa fa-cog fixed-plugin-button-nav cursor-pointer"></i>
                                </a>
                            </li>
                            <li class="nav-item dropdown pe-2 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fa fa-bell cursor-pointer"></i>
                                </a>
                                <ul class="dropdown-menu  dropdown-menu-end  px-2 py-3 me-sm-n4" aria-labelledby="dropdownMenuButton">
                                    <li class="mb-2">
                                        <a class="dropdown-item border-radius-md" href="javascript:;">
                                            <div class="d-flex py-1">
                                                <div class="my-auto">
                                                    <img src="../assets/img/team-2.jpg" class="avatar avatar-sm  me-3 ">
                                                </div>
                                                <div class="d-flex flex-column justify-content-center">
                                                    <h6 class="text-sm font-weight-normal mb-1">
                                                        <span class="font-weight-bold">New message</span> from Laur
                                                    </h6>
                                                    <p class="text-xs text-secondary mb-0">
                                                        <i class="fa fa-clock me-1"></i>
                                                        13 minutes ago
                                                    </p>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <li class="mb-2">
                                        <a class="dropdown-item border-radius-md" href="javascript:;">
                                            <div class="d-flex py-1">
                                                <div class="my-auto">
                                                    <img src="../assets/img/small-logos/logo-spotify.svg" class="avatar avatar-sm bg-gradient-dark  me-3 ">
                                                </div>
                                                <div class="d-flex flex-column justify-content-center">
                                                    <h6 class="text-sm font-weight-normal mb-1">
                                                        <span class="font-weight-bold">New album</span> by Travis Scott
                                                    </h6>
                                                    <p class="text-xs text-secondary mb-0">
                                                        <i class="fa fa-clock me-1"></i>
                                                        1 day
                                                    </p>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item border-radius-md" href="javascript:;">
                                            <div class="d-flex py-1">
                                                <div class="avatar avatar-sm bg-gradient-secondary  me-3  my-auto">
                                                    <svg width="12px" height="12px" viewBox="0 0 43 36" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                                                    <title>credit-card</title>
                                                    <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                                                    <g transform="translate(-2169.000000, -745.000000)" fill="#FFFFFF" fill-rule="nonzero">
                                                    <g transform="translate(1716.000000, 291.000000)">
                                                    <g transform="translate(453.000000, 454.000000)">
                                                    <path class="color-background" d="M43,10.7482083 L43,3.58333333 C43,1.60354167 41.3964583,0 39.4166667,0 L3.58333333,0 C1.60354167,0 0,1.60354167 0,3.58333333 L0,10.7482083 L43,10.7482083 Z" opacity="0.593633743"></path>
                                                    <path class="color-background" d="M0,16.125 L0,32.25 C0,34.2297917 1.60354167,35.8333333 3.58333333,35.8333333 L39.4166667,35.8333333 C41.3964583,35.8333333 43,34.2297917 43,32.25 L43,16.125 L0,16.125 Z M19.7083333,26.875 L7.16666667,26.875 L7.16666667,23.2916667 L19.7083333,23.2916667 L19.7083333,26.875 Z M35.8333333,26.875 L28.6666667,26.875 L28.6666667,23.2916667 L35.8333333,23.2916667 L35.8333333,26.875 Z"></path>
                                                    </g>
                                                    </g>
                                                    </g>
                                                    </g>
                                                    </svg>
                                                </div>
                                                <div class="d-flex flex-column justify-content-center">
                                                    <h6 class="text-sm font-weight-normal mb-1">
                                                        Payment successfully completed
                                                    </h6>
                                                    <p class="text-xs text-secondary mb-0">
                                                        <i class="fa fa-clock me-1"></i>
                                                        2 days
                                                    </p>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            <!-- End Navbar -->



            <div class="container-fluid py-4">
                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4">
                            <div class="card-header pb-0">
                                <div class="row">
                                    <label for="example-text-input" class="form-control-label">  </label>



                                </div>
                                <hr class="horizontal dark">
                                <p>Puede solicitar su anticipo de sueldo <strong>hasta el <%= ultimoDiaTexto %></strong>. A partir del <strong><%= corteTexto %></strong> ya no se aceptan solicitudes.</p>

                                <% if (validacionFecha == 1) { %>
                                <div class="alert alert-danger d-flex align-items-center" role="alert" style="border-radius:8px;color:#fff;">
                                    <i class="fa fa-exclamation-triangle me-3" style="font-size:1.5rem;"></i>
                                    <div style="color:#fff;">
                                        <strong style="color:#fff;">Plazo vencido.</strong> El último día para solicitar anticipos fue el <strong style="color:#fff;"><%= ultimoDiaTexto %></strong>. Desde el <strong style="color:#fff;"><%= corteTexto %></strong> ya no es posible realizar nuevas solicitudes.
                                    </div>
                                </div>
                                <% } else { %>
                                <form action="../CTRL_Insert_Anticipo" method="post" onsubmit="return validarAnticipo()"> 

                                    <div class="col-md-6">
                                        <div class="form-group pass_show">
                                            <label class="form-control-label">Valor </label>
                                            <input class="form-control" type="number" name="anticipo" id="anticipo" step="0.01" required>
                                        </div>
                                    </div>

                                    <div class="col-md-6" style="display:none;"> 
                                        <input type="hidden" name="idUsuario" id="idUsuario" value="<%=codigo %>">
                                        <input type="hidden" name="idDepartamento" id="idDepartamento" value="<%=idDepartamento %>">
                                        <input type="hidden" name="sueldo" id="sueldo" value="<%=sueldo%>">
                                    </div>

                                    <div class="form-group">
                                        <button type="submit" class="btn btn-success">
                                            <i class="fa fa-save" aria-hidden="true"></i> Solicitar
                                        </button>
                                    </div>
                                </form>
                                <% } %>

                                <!--<p class="text-uppercase text-sm">Cambiar Contraseña</p>-->   
                                <!--                                <form action="../Insert_Solicitud_Anticipo.jsp" method="post"> 
                                
                                                                        <div class="col-md-6">
                                                                            <div class="form-group pass_show">
                                                                                <label for="example-text-input" class="form-control-label">Valor </label>
                                                                                <input class="form-control " type="number" name="anticipo" id="anticipo"  >
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <div class="form-group pass_show">
                                                                                <label for="example-text-input" class="form-control-label">Id Solicitante </label>
                                                                                
                                                                                <input class="form-control " type="text" name="idUsuario" id="idUsuario" value =" <%=codigo %>" >
                                                                                <input class="form-control " type="text" name="idDepartamento" id="idDepartamento" value =" <%=idDepartamento %>" >
                                                                                <input class="form-control " type="text" name="departamento" id="departamento" value =" <%=departamento %>" >
                                                                                <input class="form-control " type="text" name="corte" id="corte" value =" <%=corte %>" >
                                                                                <input class="form-control " type="text" name="sueldo" id="sueldo" value ="<%=sueldo%>" placeholder="sueldo de usuario" >
                                                                            </div>
                                                                        </div>
                                                                        <div class="form-group">
                                                                            <button type="submit"  class="btn btn-success">
                                                                                <i class="fa fa-save" aria-hidden="true"></i>Solictar</button>
                                                                        </div>
                                                                     
                                                                    </form>-->
                            </div>

                            <div class="card-body px-0 pt-0 pb-2">
                                <hr class="horizontal dark">

                            </div>
                        </div>


                        <div class="row">
                            <div class="col-12">
                                <div class="card mb-4">
                                    <div class="card-header pb-0">


                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <h6>Lista de anticipos solicitados</h6><label for="example-text-input" class="form-control-label"><%=departamento%></label>
                                            </div>
                                        </div>                                    </div>
                                    <div class="card-body px-0 pt-0 pb-2">
                                        <div class="table-responsive p-0">
                                            <table class="table align-items-center justify-content-center mb-0" id="tablaProductos">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <!--<th>Sueldo</th>-->
                                                        <th>Fecha solicitud</th>
                                                        <th>Anticipo</th>
                                                        <th>Estado</th>
                                                        <th>Departamento</th>
                                                        <th>Acciones</th>
                                                        <th></th>
                                                    </tr>
                                                </thead>
                                                <tbody id="tablaProductosBody">
                                                    <% 
                                                        try {
                                                          DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                          Connection cna5 = DriverManager.getConnection(url, user, pass);   
                                                          String TDO = "SELECT a.sueldo, a.fecha_solicitud, a.anticipo, a.estado, b.departamento, a.id_ctrl_anticipo  FROM ctrl_anticipos a , adm_departamento b WHERE   b.id_departamento = a.id_departamento and id_usuario = "+codigo+"" ;           
                                                          PreparedStatement sta5 = cna5.prepareStatement(TDO);
                                                          ResultSet rsa5 = sta5.executeQuery();       
                                                          while (rsa5.next()) {
                                                    %>

                                                    <tr>
                                                        <td>
                                                            <div class="d-flex px-2">
                                                                <div>
                                                                    <img src="../assets/img/small-logos/Atraso3.svg" class="avatar avatar-sm rounded-circle me-2" alt="spotify">
                                                                </div>
                                                                <div class="my-auto">

                                                                </div>
                                                            </div>
                                                        </td>

                                                        <!--          <td>
                                                                    <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(1)%> </p>
                                                                    <p class="text-sm font-weight mb-0"><%=rsa5.getString(3)%> </p>
                                                                  </td>-->
                                                        <td class="text-wrap">
                                                            <p class="text-xs font-weight-bold mb-0"><%=rsa5.getString(2)%></p>
                                                        </td>
                                                        <td>
                                                            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(3)%> </p>
                                                        </td>
                                                        <td>
                                                            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(4)%> </p>
                                                        </td>
                                                        <td class="text-wrap">
                                                            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(5)%> </p>
                                                        </td>
                                                        <td>
                                                        <% if (validacionFecha != 1) { %>
                                                        <button type="button" class="btn btn-sm shadow-none bg-gradient-warning mb-0 px-3"
                                                                style="text-transform: none; border-radius: 0.5rem;"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#modalEditarAnticipo"
                                                                onclick="prepararEdicion('<%=rsa5.getString(6)%>')">
                                                            <i class="fa fa-edit text-info me-1"></i> <span class="text-xs">Editar</span>
                                                        </button>
                                                        <% } else { %>
                                                        <button type="button" class="btn btn-sm shadow-none bg-secondary mb-0 px-3" disabled
                                                                style="text-transform: none; border-radius: 0.5rem; opacity:0.6;"
                                                                title="No se puede editar: el plazo para solicitar/editar anticipos ya vencio.">
                                                            <i class="fa fa-lock me-1"></i> <span class="text-xs">Editar</span>
                                                        </button>
                                                        <% } %>
                                                    </td>

                                                    </tr>
                                                    <% 
                                                        } 
                                                        rsa5.close();
                                                        sta5.close();
                                                        cna5.close();
                                                      } catch(Exception e) {
                                                        e.printStackTrace();
                                                      } 
                                                    %>
                                                    
                                                    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script> <script>
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        
        // Si existe un parámetro de error
        if (urlParams.has('error')) {
            const mensajeError = urlParams.get('error');
            
            // Opción A: Alert estándar de navegador
            alert("⚠️ Validación de Monto: " + mensajeError);
            
            // Opción B: Si usas SweetAlert2 (recomendado por estética)
            /*
            Swal.fire({
                icon: 'error',
                title: 'Límite excedido',
                text: mensajeError,
                confirmButtonColor: '#3085d6'
            });
            */
        }

        // Si existe un parámetro de éxito (msj)
        if (urlParams.has('msj')) {
            alert("✅ Éxito: " + urlParams.get('msj'));
        }
    };
</script>
                                                </tbody>
                                            </table>

                                        </div>
                                        <br>
                                    </div>

                                </div>
                            </div>
                        </div>

                        <div class="row">

                        </div>

                        <footer class="footer pt-3  ">
                            <div class="container-fluid">
                                <div class="row align-items-center justify-content-lg-between">
                                    <div class="col-lg-6 mb-lg-0 mb-4">
                                        <div class="copyright text-center text-sm text-muted text-lg-start">
                                            © <script>
                                                document.write(new Date().getFullYear())
                                            </script>,
                                            Creado  <i class="fa fa-clock"></i> por
                                            <a href="https://www.overclocking.com.ec" class="font-weight-bold" target="_blank">Overclocking</a>
                                            for a better web.
                                            <b>   <%Date  fecha = new Date();%> </b>
                                            <%=fecha%>
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <ul class="nav nav-footer justify-content-center justify-content-lg-end">
                                            <li class="nav-item">
                                                <a href="#" class="nav-link text-muted" target="_blank"></a>
                                            </li>
                                            <li class="nav-item">
                                                <a href="#" class="nav-link text-muted" target="_blank"></a>
                                            </li>
                                            <li class="nav-item">
                                                <a href="" class="nav-link text-muted" target="_blank"></a>
                                            </li>
                                            <li class="nav-item">
                                                <a href="#" class="nav-link pe-0 text-muted" target="_blank"></a>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </footer>
                    </div>


                    </main>
                                        <div class="modal fade" id="modalEditarAnticipo" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                                        <div class="modal-dialog">
                                          <div class="modal-content">
                                            <div class="modal-header">
                                              <h5 class="modal-title" id="exampleModalLabel">Editar Valor de Anticipo</h5>
                                              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                              
                                            <form action="../CTRL_Editar_Anticipo" method="POST">
                                                <div class="modal-content">
                                                    <input type="hidden" id="id_ctrl_anticipo" name="id_ctrl_anticipo">
                                                  <div class="modal-body">
                                                      <div class="form-group">
                                                          <label for="nuevoAnticipo">Monto del Anticipo</label>
                                                          <input type="number" step="0.01" class="form-control" id="nuevoAnticipo" name="nuevoAnticipo" required>
                                                      </div>
                                                  </div>
                                                  <div class="modal-footer">
                                                      <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                      <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                                                  </div>
                                                </div>
                                            </form>
                                          </div>
                                        </div>
                                      </div>
                                        <script>
                                        function prepararEdicion(valorActual) {
                                            // Limpiamos el valor de caracteres no numéricos si los hay
                                            const valorLimpio = valorActual.replace(/[^0-9.]/g, '');
                                            document.getElementById('nuevoAnticipo').value = valorLimpio;
                                        }
                                        </script>
                    <div class="fixed-plugin">
                        <a class="fixed-plugin-button text-dark position-fixed px-3 py-2">
                            <i class="fa fa-cog py-2"> </i>
                        </a>
                        <div class="card shadow-lg">
                            <div class="card-header pb-0 pt-3 ">
                                <div class="float-start">
                                    <h5 class="mt-3 mb-0">Configuración</h5>
                                    <p>Cambia los tonos de color.</p>
                                </div>
                                <div class="float-end mt-4">
                                    <button class="btn btn-link text-dark p-0 fixed-plugin-close-button">
                                        <i class="fa fa-close"></i>
                                    </button>
                                </div>
                                <!-- End Toggle Button -->
                            </div>
                            <hr class="horizontal dark my-1">
                            <div class="card-body pt-sm-3 pt-0 overflow-auto">
                                <!-- Sidebar Backgrounds -->
                                <div>
                                    <h6 class="mb-0">Sidebar Colors</h6>
                                </div>
                                <a href="javascript:void(0)" class="switch-trigger background-color">
                                    <div class="badge-colors my-2 text-start">
                                        <span class="badge filter bg-gradient-primary active" data-color="primary" onclick="sidebarColor(this)"></span>
                                        <span class="badge filter bg-gradient-dark" data-color="dark" onclick="sidebarColor(this)"></span>
                                        <span class="badge filter bg-gradient-info" data-color="info" onclick="sidebarColor(this)"></span>
                                        <span class="badge filter bg-gradient-success" data-color="success" onclick="sidebarColor(this)"></span>
                                        <span class="badge filter bg-gradient-warning" data-color="warning" onclick="sidebarColor(this)"></span>
                                        <span class="badge filter bg-gradient-danger" data-color="danger" onclick="sidebarColor(this)"></span>
                                    </div>
                                </a>
                                <!-- Sidenav Type -->
                                <!--        <div class="mt-3">
                                          <h6 class="mb-0">Sidenav Type</h6>
                                          <p class="text-sm">Choose between 2 different sidenav types.</p>
                                        </div>
                                        <div class="d-flex">
                                          <button class="btn bg-gradient-primary w-100 px-3 mb-2 active me-2" data-class="bg-white" onclick="sidebarType(this)">White</button>
                                          <button class="btn bg-gradient-primary w-100 px-3 mb-2" data-class="bg-default" onclick="sidebarType(this)">Dark</button>
                                        </div>
                                        <p class="text-sm d-xl-none d-block mt-2">You can change the sidenav type just on desktop view.</p>-->
                                <!-- Navbar Fixed -->
                                <div class="d-flex my-3">
                                    <h6 class="mb-0">Navbar Fixed</h6>
                                    <div class="form-check form-switch ps-0 ms-auto my-auto">
                                        <input class="form-check-input mt-1 ms-auto" type="checkbox" id="navbarFixed" onclick="navbarFixed(this)">
                                    </div>
                                </div>
                                <hr class="horizontal dark my-sm-4">
                                <div class="mt-2 mb-5 d-flex">
                                    <h6 class="mb-0">Light / Dark</h6>
                                    <div class="form-check form-switch ps-0 ms-auto my-auto">
                                        <input class="form-check-input mt-1 ms-auto" type="checkbox" id="dark-version" onclick="darkMode(this)">
                                    </div>
                                </div>
                                <!--        <a class="btn bg-gradient-dark w-100" href="https://www.creative-tim.com/product/argon-dashboard">Free Download</a>
                                        <a class="btn btn-outline-dark w-100" href="https://www.creative-tim.com/learning-lab/bootstrap/license/argon-dashboard">View documentation</a>
                                        <div class="w-100 text-center">
                                          <a class="github-button" href="https://github.com/creativetimofficial/argon-dashboard" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star creativetimofficial/argon-dashboard on GitHub">Star</a>
                                          <h6 class="mt-3">Thank you for sharing!</h6>
                                          <a href="https://twitter.com/intent/tweet?text=Check%20Argon%20Dashboard%20made%20by%20%40CreativeTim%20%23webdesign%20%23dashboard%20%23bootstrap5&amp;url=https%3A%2F%2Fwww.creative-tim.com%2Fproduct%2Fargon-dashboard" class="btn btn-dark mb-0 me-2" target="_blank">
                                            <i class="fab fa-twitter me-1" aria-hidden="true"></i> Tweet
                                          </a>
                                          <a href="https://www.facebook.com/sharer/sharer.php?u=https://www.creative-tim.com/product/argon-dashboard" class="btn btn-dark mb-0 me-2" target="_blank">
                                            <i class="fab fa-facebook-square me-1" aria-hidden="true"></i> Share
                                          </a>-->
                            </div>
                        </div>
                    </div>
                </div>
                <!--   Core JS Files   -->
                <script src="../assets/js/core/popper.min.js"></script>
                <script src="../assets/js/core/bootstrap.min.js"></script>
                <script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
                <script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>

                <script>
                                            var win = navigator.platform.indexOf('Win') > -1;
                                            if (win && document.querySelector('#sidenav-scrollbar')) {
                                                var options = {
                                                    damping: '0.5'
                                                }
                                                Scrollbar.init(document.querySelector('#sidenav-scrollbar'), options);
                                            }
                </script>
                <!-- Github buttons -->
                <script async defer src="https://buttons.github.io/buttons.js"></script>
                <!-- Control Center for Soft Dashboard: parallax effects, scripts for the example pages etc -->
                <script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
                <script>
                                            function validarAnticipo() {
                                                // 1. Obtenemos los valores de los inputs
                                                const valorAnticipo = parseFloat(document.getElementById('anticipo').value);
                                                const sueldoUsuario = parseFloat(document.getElementById('sueldo').value);

                                                // 2. Calculamos el límite (50%)
                                                const limite = sueldoUsuario * 0.40;

                                                // 3. Validamos
                                                if (valorAnticipo > limite) {
                                                    alert("¡Error! El anticipo solicitado ($" + valorAnticipo + ") supera el 40% de su sueldo ($" + limite + ").");
                                                    return false; // Bloquea el envío del formulario
                                                }

                                                if (valorAnticipo <= 0) {
                                                    alert("Por favor, ingrese un valor mayor a 0.");
                                                    return false;
                                                }

                                                return true; // Permite el envío si todo está bien
                                            }
                
                function prepararEdicion(id) {
    // Buscamos el input oculto por su ID y le asignamos el valor que viene de la tabla
    document.getElementById('id_ctrl_anticipo').value = id;
}
                </script>
                </body>
                </html>
