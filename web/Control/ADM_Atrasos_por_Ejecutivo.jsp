<%-- 
    Document   : INV_Inventario_por_Ejecutivo
    Created on : 14 ago 2024, 14:19:52
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

<%@page import="java.util.List"%>
<%@page import="java.util.Calendar"%>
<!DOCTYPE html>
<%
String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    
     String idUsuari = request.getParameter("idUsuario");
     String ejecutivo = request.getParameter("ejecutivo");
     String nombresEjecutivo = request.getParameter("nombresEjecutivo");
     
 //int idUsuari = 100;
//   
//     if(idUsuario==null||idUsuario.equals(null)){
//      
//    }else{
//        idUsuario = Integer.parseInt(idUsuario);
//    } 
//    

//filtro mes
    String cbm_anio = request.getParameter("cbm_anio");
    String cbm_mes=request.getParameter("cbm_mes");
    int year= 0;
    int mes=0;
    String mesSeleccinado="";
    
     if(cbm_anio==null||cbm_anio.equals(null)||cbm_mes==null||cbm_mes.equals(null)){
        Calendar cal= Calendar.getInstance();
        year= cal.get(Calendar.YEAR);
    }else if(cbm_mes != ""){
        year = Integer.parseInt(cbm_anio);
        mes = Integer.parseInt(cbm_mes);
    }else{
            year = Integer.parseInt(cbm_anio);
            mes = Integer.parseInt(cbm_mes);
        }
    if (request.getParameter("mesSeleccinado")!=null){
        mesSeleccinado=request.getParameter("mesSeleccinado").toUpperCase();
    }
    
    

    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if(!COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")){
                    response.sendRedirect("../sesionInvalida.jsp");
                    return;
             }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>
            ProMaNet | Editar Equipos
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

        <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
        <link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=170d96f69db52446b9aa21d2653da1f4">
        <style type="text/css" class="init"></style>
        <script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
        <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js"></script>
        <script type="text/javascript" language="javascript" src="../resources/demo.js"></script>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css">
        <script type="text/javascript" class="init">
                $(document).ready(function() {
                        $('#example').DataTable();
                } );
                </script>

        <script>
            function cargarDatos() {
                var idUsuario = document.getElementById("idEjecutivo").value;

                var cbm_anio = document.getElementById("cbm_anio").value;
                var cbm_fecha = document.getElementById("cbm_fecha").value;

                var arrayMes = cbm_fecha.split("-");
                if (cbm_anio == "NINGUNO") {
                    alert("Debe seleccionar un Año");
                } else if (cbm_fecha == "NINGUNO") {
                    alert("Debe seleccionar un mes");
                } else {
                    location.href = 'FAC_ReportGasto_Mes_Anio.jsp?cbm_anio=' + cbm_anio + '&cbm_mes=' + arrayMes[0] + '&mesSeleccinado=' + arrayMes[1];
                }

//                location.href = 'INV_Inventario_por_Ejecutivo.jsp?idUsuario=' + idUsuario;
            }
        </script>
    </head>
    <body class="g-sidenav-show   bg-gray-100">
        <div class="min-height-300 bg-primary position-absolute w-100"></div>
        <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
            <div class="sidenav-header">
                <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
                <a class="navbar-brand m-0" href=" # " target="_blank">
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
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Lista de proyectos</span>
                        </a>
                    </li>
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

                        <a class="nav-link " href="../INV_ListadoEquipo.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-laptop text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Inventario</span>
                        </a>
                        <a class="nav-link " href="../Inventario/INV_Equipos.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-laptop text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Inventario</span>
                        </a>

                        <%}%>


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
                <a href="https://www.youtube.com/watch?v=1bAjqT_-p_E" target="_blank" class="btn btn-danger btn-sm w-100 mb-3">Video Tutorial</a>
                <a href="../cerrar.jsp" target="_blank" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesión</a>

            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <!-- Navbar -->
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Inventario</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Equipos</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0"></h6>
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
                            <li class="nav-item d-flex align-items-center">
                                <a href="../cerrar.jsp" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-power-off me-sm-1"></i>
                                    <span class="d-sm-inline d-none"> 
                                    </span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            <!-- End Navbar -->
            <!-- Modal -->
            <div class="modal fade" id="exampleModalSignUp" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-md" role="document">
                    <div class="modal-content">
                        <div class="modal-body p-0">
                            <div class="card card-plain">
                                <div class="card-header pb-0 text-left">
                                    <h3 class="font-weight-bolder text-primary text-gradient">Registrar nuevo Equipo</h3>
                                    <p class="mb-0">Ingresar datos</p>
                                </div>
                                <div class="card-body pb-3">
                                    <form role="form text-left" action="../InsertNuevoEquipo">

                                        <div> 
                                            <input type="hidden" value=""  name="idRepGasCab"> </div>
                                        <label>Fecha Compra</label>
                                        <div class="input-group mb-3">
                                            <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                                            <script>
                                                document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
                                            </script>
                                        </div>
                                        <label>Empresa</label>
                                        <div class="input-group mb-3">
                                            <select class="chosen-select form-control" id="empresa" name ="empresa">

                                                <option value="N/A">N/A</option>
                                                <option value="Latinconsulting">Latinconsulting</option>      
                                                <option value="DK-WORK">DK-WORK</option> 
                                                <option value="Arthurs Audit Global">Arthurs Audit Global</option>  
                                            </select>
                                        </div>
                                        <label>Ubicacion/ Oficina:</label>

                                        <select class="chosen-select form-control" id="ubicacionoficina" name ="ubicacionoficina">                                                     
                                            <option value="Norte">Norte</option>
                                            <option value="Kennedy 401">Kennedy 401</option>    
                                            <option value="Kennedy 403">Kennedy 403</option>          
                                            <option value="Outsourcing">Outsourcing</option>       

                                        </select>

                                        <label>Departamento: </label>
                                        <div class="input-group mb-3">
                                            <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                            <select class="chosen-select form-control" id="departamento" name ="departamento">
                                                <option value="Administración">Administración</option>                                                 
                                                <option value="Auditoría">Auditoría</option> 
                                                <option value="Contabilidad">Contabilidad</option> 
                                                <option value="Commark">Commark</option> 
                                                <option value="Gerencia">Gerencia</option> 
                                                <option value="Impuestos">Impuestos</option>
                                                <option value="Legal">Legal</option>  
                                                <option value="Tecnología">Tecnología</option>

                                            </select>
                                        </div>
                                        <label>Tipo de Dispositivo:</label>
                                        <div class="input-group mb-3">
                                            <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                            <select class="chosen-select form-control" id="dispositivo" name ="dispositivo">

                                                <option value="Laptop">Laptop</option>
                                                <option value="Impresora">Impresora</option>      
                                                <option value="Proyector">Proyector</option> 
                                                <option value="Networking">Networking</option>  
                                                <option value="CCTV">CCTV</option>  
                                                <option value="Periférico">Periférico</option>  
                                            </select>
                                        </div>



                                        <!--                  <div class="form-group">
                                                                    <label class="col-sm-12 control-label" for="Trap" >
                                                                        Cliente
                                                                    </label>
                                                                    <div class="col-lg-12">
                                                                      <select class=" form-control" id="cliente" name ="cliente">
                                        <%
                                          try{
                                          DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                          Connection   cn = DriverManager.getConnection(url, user, pass);
                                          String sql = "select * from Cliente where estado = 'a' order by 1";
                                          PreparedStatement st = cn.prepareStatement(sql);
                                          ResultSet rs = st.executeQuery();       
                                          while (rs.next()) {%>                                                                    
                                              <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                                        <%}     
                                           rs.close();
                                           st.close();
                                           cn.close();
                                        }catch(Exception e){
                                            e.printStackTrace();
                                        }%>                                                                    
                                      </select>
                                  </div>
                              </div>-->
                                        <label>Marca:</label>

                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="marca" name ="marca" value="N/A">
                                        </div>
                                        <label>Modelo:</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="modelo" name ="modelo" value="N/A">
                                        </div>
                                        <label>Serial:</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="serial" name ="serial" value="N/A">
                                        </div>
                                        <label>Procesador:</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="procesador" name ="procesador" >
                                        </div>
                                        <label>Disco Duro:</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="hdd" name ="hdd" value="N/A">
                                        </div>
                                        <label>Memoria RAM</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="ram" name ="ram" value="N/A">
                                        </div>
                                        <label>Pantalla</label>
                                        <div class="input-group mb-3">
                                            <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="pantalla" name ="pantalla" value="N/A">
                                        </div>
                                        <label>Observación</label>
                                        <div class="input-group mb-3">
                                            <textarea class="form-control" id= "Obva"  name="observacion" oninput ="contarLetras()" >Nueva adquisición</textarea>
                                            <!--<input type="text" class="form-control" id="Obva" oninput="contarLetras()">-->

                                            <!--<input type="number" class="form-control" placeholder="Password" aria-label="Password" aria-describedby="password-addon">-->
                                        </div>
                                        <span id="mensaje"></span>
                                        <!--                  <div class="form-check form-check-info text-left">
                                                            <input class="form-check-input" type="checkbox" value="" id="flexCheckDefault" checked="">
                                                            <label class="form-check-label" for="flexCheckDefault">
                                                              I agree the <a href="javascrpt:;" class="text-dark font-weight-bolder">Terms and Conditions</a>
                                                            </label>
                                                          </div>-->
                                        <div class="modal-footer">
                                            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Close</button>
                                            <button type="submit" class="btn bg-gradient-primary">Guardar</button>
                                        </div>
                                        <!--                  <div class="text-center">
                                                            <button type="button" class="btn bg-gradient-primary btn-lg btn-rounded w-100 mt-4 mb-0">Guardar</button>
                                                          </div>-->
                                    </form>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Modal -->
            <div class="container-fluid py-4">
                <div class="row">
                    <div class="col-lg-8">
                        <div class="row">
                            <div class="col-xl-6 mb-xl-0 mb-4">
                                <div class="card bg-transparent shadow-xl">
                                    <div class="overflow-hidden position-relative border-radius-xl" style="background-image: url('https://raw.githubusercontent.com/creativetimofficial/public-assets/master/argon-dashboard-pro/assets/img/card-visa.jpg');">
                                        <span class="mask bg-gradient-dark"></span>
                                        <div class="card-body position-relative z-index-1 p-3">
                                            <i class="fas fa-wifi text-white p-2"></i>
                                            <h5 class="text-white mt-4 mb-5 pb-2">  <%=compania%> 4562&nbsp;&nbsp;&nbsp;1122&nbsp;&nbsp;&nbsp;4594&nbsp;&nbsp;&nbsp;7852</h5>
                                            <div class="d-flex">
                                                <div class="d-flex">
                                                    <div class="me-4">
                                                        <p class="text-white text-sm opacity-8 mb-0">Reporte Gastos</p>
                                                        <h6 class="text-white mb-0"> <%=nombre%> <%=apellidos%> </h6>
                                                    </div>
                                                    <div>
                                                        <p class="text-white text-sm opacity-8 mb-0">Cumpleaños</p>
                                                        <h6 class="text-white mb-0"> / </h6>
                                                    </div>
                                                </div>
                                                <div class="ms-auto w-20 d-flex align-items-end justify-content-end">
                                                    <img class="w-60 mt-2" src="../assets/img/logos/mastercard.png" alt="logo">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-xl-6">
                                <div class="row">


                                    <div class="col-md-4">
                                        <div class="card btn mb-0" data-bs-toggle="modal" data-bs-target="#exampleModalSignUp">
                                            <div class="card-header mx-4 p-3 text-center">
                                                <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                                                    <!--<a href="../generarReporteGastosMes" ><i class="fas fa-calendar-alt opacity-10"></i></a>-->

                                                    <i class="fa fa-cog opacity-10"></i>
                                                    <!--                          <p class="text-white mb-0 " >No disponible</p>
                                                                             
                                                                                      <a href="../AutoGenMes" ><i class="fas fa-calendar-alt opacity-10"></i></a>
                                                                            
                                                    -->
                                                </div>
                                            </div>
                                            <div class="card-body pt-0 p-3 text-center">
                                                <h6 class="text-center mb-0">Registrar</h6>
                                                <span class="text-xs">Nuevo equipo</span>
                                                <hr class="horizontal dark my-3">
                                                <h5 class="text-warning mb-0"> </h5>
                                            </div>
                                        </div>
                                    </div>
                                    <!--mt-md-0 mt-4-->

                                    <div class="col-md-4 ">
                                        <div class="card">
                                            <div class="card-header mx-4 p-3 text-center">
                                                <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                                                    <!--<i class="fab fa-calendar-alt opacity-10"></i>-->
                                                    <a href="#" ><i class="fa fa-users  opacity-10"></i></a>
                                                </div>
                                            </div>
                                            <div class="card-body pt-0 p-3 text-center">
                                                <h6 class="text-center mb-0">Revisar reportes</h6>
                                                <span class="text-xs">Personal Asignado</span>
                                                <hr class="horizontal dark my-3">
                                                <h5 class="mb-0"></h5>
                                            </div>
                                        </div>
                                    </div>
                                    <!--mt-md-0 mt-4-->
                                    <div class="col-md-4 ">
                                        <div class="card">
                                            <div class="card-header mx-4 p-3 text-center">
                                                <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                                                    <!--<i class="fab fa-calendar-alt opacity-10"></i>-->
                                                    <a href="../ReporteGastos/filtroReporteGastos.jsp" ><i class="fa fa-filter  opacity-10"></i></a>
                                                </div>
                                            </div>
                                            <div class="card-body pt-0 p-3 text-center">
                                                <h6 class="text-center mb-0">Filtrar reportes</h6>
                                                <span class="text-xs">Reporte de gastos por fecha</span>
                                                <hr class="horizontal dark my-3">
                                                <h5 class="mb-0"></h5>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>     
                        </div>
                    </div>

                </div>

            </div>

            <div class="container-fluid py-4">






                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4 card-header pb-0">
                            <div class="card-header pb-0">
                                <h6>Elegir Ejecutivo</h6>
                                <label><%=ejecutivo%></label>
                                <label><%=nombresEjecutivo%></label>

                                <div>             
                                    <span class="control-label-addon" for="inputdefault"></span>
                                    <select class="form-control " style="width:50%" id="cbm_anio" name="cbm_anio" onChange='cargarDatos()'>
                                        <option value="NINGUNO">Cambiar Año</option>
                                        <%try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
//                                        String sql = "SELECT COUNT (anio), anio FROM GAS_COMPRA where  estado ='A' and idcliente = "+idcliente+" group by anio ";
                                        String sql = "SELECT TO_CHAR(fecha_notificacion, 'YYYY-MM') AS mes_atraso, COUNT(*) AS total_atrasos FROM rep_biom_atraso WHERE ESTADO = 'A'  AND id_usuario = "+ejecutivo+" GROUP BY TO_CHAR(fecha_notificacion, 'YYYY-MM') ORDER BY mes_atraso";
                                        PreparedStatement st = cn.prepareStatement(sql);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()) {%>                                                                    
                                        <option value="<%=rs.getString(2)%>"><%=rs.getString(1)%> Atrasos <%=rs.getString(2)%></option>
                                        <%} rs.close();st.close();cn.close();
                        }catch(Exception e){ e.printStackTrace();}%>    
                                    </select>               
                                </div>

                            </div>
                            <div class="card-body px-0 pt-0 pb-2">
                                <div class="table-responsive p-0">
                                    <div class="row">

                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <input type="hidden" value="<%=idUsuari%>">
                                            </div>
                                        </div>

                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <div class="form-group">
                                                    <select class="chosen-select form-control" id="idEjecutivo" name ="idEjecutivo"  onChange='cargarDatos()'>
                                                        <option value="">Elija a un ejecutivo</option>  

                                                        <%
                                                            // or estado = 'i' 
                                                            try{
                                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                            Connection   cn4 = DriverManager.getConnection(url, user, pass);
//                                                                              String empresa = "select * from compania where estado = 'a'  order by 2";
                                                              String usuarios = "Select IDUSUARIO, NOMBRE||' '||APELLIDOS as nombre,IDROL,ESTADO From usuario where ESTADO='a'   order by 2";
                                                            PreparedStatement st4 = cn4.prepareStatement(usuarios);
                                                            ResultSet rs4 = st4.executeQuery();       
                                                            while (rs4.next()) {

                                                        %>                    

                                                        <option value="<%=rs4.getString(1)%>"> <%=rs4.getString(2)%></option>
                                                        <%
                                                            }     
                                                            rs4.close();
                                                            st4.close();
                                                            cn4.close();
                                                        }catch(Exception e){
                                                             e.printStackTrace();
                                                        }

                                                        %>       
                                                    </select>
                                                </div>             
                                            </div>
                                        </div>


                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <!-- Encabezados de la tabla -->
                        </thead>
                        <tbody id="historialTable">
                            <!-- Los datos se cargarán aquí -->
                        </tbody>
                    </table>
                </div>
                <!--inicio tabla de asignados historia-->
                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4">
                            <div class="card-header pb-0">
                                <h6>Historia de atrasos por mes</h6>
                            </div>
                            <div class="card-body px-0 pt-0 pb-2">
                                <div class="table-responsive p-0">
                                    <table id= "example" class="table align-items-center mb-0" >
                                        <thead>
                                            <tr>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Día</th>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Motivo</th>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hora</th>
                                                <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Hora</th>-->
                                                <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Fecha Asignación</th>-->
                                                <!--<th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Usuario</th>-->
<!--                                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Devolución</th>
                                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Observaciones</th>-->
                                                <th class="text-secondary opacity-7"></th>
                                            </tr>
                                        </thead>
                                        <tbody >
                                            <% try {
                                                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                              Connection cn3 = DriverManager.getConnection(url, user, pass);
//                                                             String historiaEquipo = "select a.idinvequipo,to_char(b.fechacompra , 'DD/MON/YYYY'), b.dispositivo, b.marca, b.modelo, b.serial, b.estado, b.hdd, b.procesador, b.ram , to_char(a.fechaasignacion , 'DD/MON/YYYY') as asignacion_equipo , to_char(a.fechadevolucion , 'DD/MON/YYYY')  as devolucion_equipo,  c.nombre || c.apellidos, b.observaciones from inv_asignacion a, inv_equipos b,  usuario c where a.idusuario =  "+idUsuari+"  and a.idinvequipo = b.idinvequipo and a.idusuario = c.idusuario  order by a.idinv_asignacion desc ";
                                                           String atrasosMes = "select a.id_usuario,c.nombre, c.apellidos ,to_char(A.fecha_notificacion, 'DD/MON/YYYY'), b.descripcion, to_char(fecha_notificacion, 'HH24:MI') AS minuto,fecha_notificacion from rep_biom_atraso a, reg_biom_motivo b, usuario c  where a.id_rep_biom_motivo = b.id_biom_motivo and a.id_usuario = c.idusuario and a.id_usuario =  "+ejecutivo+" and a.estado = 'A' order by 7  desc";
     
                                                            PreparedStatement st3 = cn3.prepareStatement(atrasosMes);
                                                              ResultSet rs3 = st3.executeQuery();
                                                              while (rs3.next()) { %>
                                            <tr>
                                                <td>
                                                    <p class="text-xs font-weight-bold mb-0"><%= rs3.getString(4) %></p>
                                                    <p class="text-xs text-secondary mb-0"></p>
                                                </td>
                                                <td>
                                                    <p class="text-xs font-weight-bold mb-0"><%= rs3.getString(5) %></p>
                                                    <p class="text-xs text-secondary mb-0"></p>
                                                </td>
                                                <td>
                                                    <div class="d-flex px-2 py-1">
                                                        <!--                                                    <div>
                                                                                                              <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user1">
                                                                                                            </div>-->
                                                        <div class="d-flex flex-column justify-content-center">
                                                            <h6 class="mb-0 text-sm"><%= rs3.getString(6) %></h6>
                                                            <!--<p class="text-xs text-secondary mb-0"> <%= rs3.getString(7) %></p>-->
                                                           
                                                        </div>
                                                    </div>
                                                </td>

                                               

                                                <!--                                                <td class="align-middle text-center text-sm">
                                                                                                  <span class="badge badge-sm bg-gradient-success">Online</span>
                                                                                                </td>-->
                                                <td class="align-middle text-center">
                                                    <!--<p><span class="text-secondary text-xs font-weight-bold mb-0"><%= rs3.getString(6) %></span></p>-->
                                                </td>
                                  
                                            </tr>
                                            <tr>
                                        <style>
                                            .text-wrap {
                                                max-width: 300px;
                                                word-wrap: break-word;
                                                word-break: break-word;
                                                white-space: normal;
                                            }
                                        </style>

                                        </tr>

                                        <% }
                                        rs3.close();
                                        st3.close();
                                        cn3.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } %>


                                        </tbody>
                                    </table>
                                    
                                    
                                    <div class="card mb-4">
            <div class="card-header pb-0">
              <h6>Lista de contactos</h6>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                <table id= "example" class="table align-items-center mb-0 table-striped table-hover">
                  <thead>
                    <tr>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Ubicación</th>
                      <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Departamento</th>
                      <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"></th>
                      <!--<th class="text-secondary opacity-7"></th>-->
                    </tr>
                  </thead>
                  <tbody>
                       <% 
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "select a.IDUSUARIO, a.NOMBRE, a.APELLIDOS, a.EMAIL, b.COMPANIA  , c.departamento from USUARIO a, compania b, adm_departamento c where a.IDCOMPANIA = b.IDCOMPANIA AND a.ESTADO = 'a' AND a.id_adm_departamento =c.id_departamento order by 1";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {%>
                        
                        <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                              <img src="../assets/img/Ejecutivo.jpg" class="avatar avatar-sm me-3" alt="user1">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm"><%=rs.getString(2)%> <%=rs.getString(3)%></h6>
                            <p class="text-xs text-secondary mb-0"> <%=rs.getString(4)%></p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0"><%=rs.getString(5)%></p>
                        <p class="text-xs text-secondary mb-0"></p>
                      </td>
                      <td class="align-middle text-center text-sm">
                          
                        
               
                        
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
<!--                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">tal vez rol</span>
                      </td>-->
<!--                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>-->
                    </tr>
                        <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                    
                    
                    
                  </tbody>
                </table>
              </div>
            </div>
          </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!--INICIO TABLA CONTACTOS-->

                <!--FIN TABLA POSIBLES CONTACTOS-->
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
                    <div class="mt-3">
                        <h6 class="mb-0">Sidenav Type</h6>
                        <p class="text-sm">Choose between 2 different sidenav types.</p>
                    </div>
                    <div class="d-flex">
                        <button class="btn bg-gradient-primary w-100 px-3 mb-2 active me-2" data-class="bg-white" onclick="sidebarType(this)">White</button>
                        <button class="btn bg-gradient-primary w-100 px-3 mb-2" data-class="bg-default" onclick="sidebarType(this)">Dark</button>
                    </div>
                    <p class="text-sm d-xl-none d-block mt-2">You can change the sidenav type just on desktop view.</p>
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
    </body>
</html>

