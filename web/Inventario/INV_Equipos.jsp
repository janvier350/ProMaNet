<%-- 
    Document   : INV_EQUIPOS
    Created on : 3 jUNIO 2024, 20:32:28
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
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
      String idcab = request.getParameter("id");
      
      String departamento = (String) session.getAttribute("departamento");
      
    String url = new String(""+ip);
    
     String idEquipoNew = "";
     
         //validar departamento
             
             if(departamento.equals("TECNOLOGÍA")){
                }else{
                    response.sendRedirect("../sesionInvalida.jsp");
                    return;
             }

    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if(COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_VER")){
                }else{
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
          ProMaNet | Lista Inventario Equipos
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
        <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
        
        <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
        <link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=170d96f69db52446b9aa21d2653da1f4">
        <style type="text/css" class="init"></style>
        <script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
        <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js"></script>
        <script type="text/javascript" language="javascript" src="../resources/demo.js"></script>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css">

<!-- Incluye los estilos y scripts necesarios 

  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.2/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.3.1/jspdf.umd.min.js"></script>
    
-->
  
    
        <script type="text/javascript" class="init">
    $(document).ready(function() {
        // Usamos una pequeña pausa para asegurar que el DOM esté listo tras los scripts de Argon
        setTimeout(function(){
            $('#example').DataTable({
                "destroy": true,
                "responsive": true,
                "autoWidth": false,
                "pageLength": 10,
                "order": [[ 0, "desc" ]], // Ordenar por ID por defecto
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.15/i18n/Spanish.json"
                },
                // El parámetro DOM es clave: 
                // l - length, f - filtering, t - table, i - info, p - pagination
                "dom": '<"row align-items-center"<"col-md-6"l><"col-md-6"f>>' +
                       '<"row"<"col-md-12"tr>>' +
                       '<"row align-items-center"<"col-md-5"i><"col-md-7"p>>',
            });
        }, 500); 
    });
    
    // Lógica del filtro personalizado
    $('#filtroEstado').on('change', function() {
        var estado = $(this).val();
        
        // .column(5) asume que 'Estado' es la sexta columna (empezando desde 0)
        // Ajusta el número si moviste las columnas
        table.column(5).search(estado).draw();
    });
</script>
                
                <script type="text/javascript">
            $('.clockpicker').clockpicker();
        </script>
        <script src="dist/bootstrap-clockpicker.min.js" type="text/javascript"></script>
        <script>
            var id =<%=idcab%>;
                     if(id>0){
                        $(window).load(function(){
                        $('#asignarEquipoUsuario').modal('show');}
                   );
            }  
        </script> 
        
        <style>
           
    /* Asegura que los controles de búsqueda y paginación sean visibles sobre el fondo azul */
    .dataTables_wrapper .dataTables_filter input {
        border: 1px solid #d2d6da !important;
        border-radius: 0.5rem !important;
        padding: 0.4rem 0.75rem !important;
        background-color: white !important;
    }
    
    .dataTables_wrapper .dataTables_length select {
        border: 1px solid #d2d6da !important;
        border-radius: 0.5rem !important;
        padding: 0.2rem 1rem !important;
    }

    /* Evita que la tabla se desborde */
    .table-responsive {
        overflow-x: hidden !important; 
    }
    
    #example {
        width: 100% !important;
    }

    /* Forzar que las celdas de texto largo no empujen la tabla */
    #example td {
        white-space: normal !important; /* Permite saltos de línea */
        vertical-align: middle;
    }

    /* Limitar el ancho de la columna observaciones */
    #example td:nth-child(8) { 
        max-width: 150px;
        font-size: 10px !important;
        line-height: 1.1;
    }

    /* Hacer los botones de acción más compactos para ganar espacio */
    .btn-xs {
        padding: 0.25rem 0.5rem;
        font-size: 0.7rem;
    }

    /* Asegurar que el buscador no se pegue al borde */
    .dataTables_filter {
        text-align: right;
        margin-bottom: 10px;
    }
    
    .dataTables_paginate {
        margin-top: 15px;
    }
</style>
       
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
             <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){%>
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
            
<!--            <a class="nav-link " href="../cerrar.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-button-power text-dark text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Cerrar sesión</span>
          </a>-->
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
            <li class="nav-item ps-3 d-flex align-items-center">
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
                          <p class="text-white text-sm opacity-8 mb-0">Reporte Inventarios</p>
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
                          <!--<p class="text-white mb-0 " >No disponible</p>-->
                         
                                  <!--<a href="../AutoGenMes" ><i class="fas fa-calendar-alt opacity-10"></i></a>-->
                        
                        
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
                     <a href="../Inventario/INV_Inventario_por_Ejecutivo.jsp" >
                  <div class="card">
                    <div class="card-header mx-4 p-3 text-center">
                      <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                        <!--<i class="fab fa-calendar-alt opacity-10"></i>-->
                       <i class="fa fa-users  opacity-10"></i>
                      </div>
                    </div>
                    <div class="card-body pt-0 p-3 text-center">
                      <h6 class="text-center mb-0">Consultar Inventario</h6>
                      <span class="text-xs">Por ejecutivo</span>
                      <hr class="horizontal dark my-3">
                      <h5 class="mb-0"></h5>
                    </div>
                  </div>
                         </a>
                </div>
                    
                    <div class="col-md-4 ">
                     <a href="../Inventario/INV_Equipos_Asignados.jsp" >
                  <div class="card">
                    <div class="card-header mx-4 p-3 text-center">
                      <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                        <!--<i class="fab fa-calendar-alt opacity-10"></i>-->
                       <i class="fa fa-users  opacity-10"></i>
                      </div>
                    </div>
                    <div class="card-body pt-0 p-3 text-center">
                      <h6 class="text-center mb-0">Consultar Asignados</h6>
                      <span class="text-xs">Equipos con sus respectivos custodios</span>
                      <hr class="horizontal dark my-3">
                      <h5 class="mb-0"></h5>
                    </div>
                  </div>
                         </a>
                </div>
                    
                    
              </div>
            </div>        
                    
<!-- Modal NUEVO EQUIPO -->
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
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="empresa" name ="empresa">
                                                                                             
                                     <option value="N/A">N/A</option>
                                         <option value="Latinconsulting">Latinconsulting</option>      
                                         <option value="DK-WORK">DK-WORK</option> 
                                         <option value="Arthurs Audit Global">Arthurs Audit Global</option>  
                                         <option value="Hispaudit">Hispaudit</option>  
                                </select>
                  </div>
                  <label>Ubicacion/ Oficina:</label>
<!--                  <div class="input-group mb-3">
                      <input type="number" class="form-control" placeholder="1,50" aria-label="Password" aria-describedby="password-addon"  name="transporte"  id="" value="1.50">
                  </div>-->
                   <select class="chosen-select form-control" id="ubicacionoficina" name ="ubicacionoficina">                                                     
                                     <option value="Norte">Norte</option>
                                            <option value="Kennedy 401">Kennedy 401</option>    
                                            <option value="Kennedy 403">Kennedy 403</option>          
                                            <option value="Romeria">Romeria</option>
                                            <option value="Magisterio">Magisterio</option>
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
                                                            <%
                                                try{
                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                String sql = "select * from INV_DISPOSITIVO where estado = 'A' order by 2";
                                                PreparedStatement st = cn.prepareStatement(sql);
                                                ResultSet rs = st.executeQuery();       
                                                while (rs.next()) {%>        
                                                            <option value="<%=rs.getString(2)%>"><%=rs.getString(2)%> </option>
                                                            <%}     
                                                         rs.close();
                                                         st.close();
                                                         cn.close();
                                                      }catch(Exception e){
                                                          e.printStackTrace();
                                                      }%>     
                                                        </select>
                                                    </div>

                  
                  

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
                     <label>Currier</label>
                  <div class="input-group mb-3">
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="id_currier" name ="id_currier">
                                             <%
                                 try{
                                 DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                 Connection   cn = DriverManager.getConnection(url, user, pass);
                                 String sql = "select * from INV_CURRIER where estado = 'A' order by 1";
                                 PreparedStatement st = cn.prepareStatement(sql);
                                 ResultSet rs = st.executeQuery();       
                                 while (rs.next()) {%>        
                                  <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
                                        <%}     
                                     rs.close();
                                     st.close();
                                     cn.close();
                                  }catch(Exception e){
                                      e.printStackTrace();
                                  }%>     
                                </select>
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
<!--              <div class="card-footer text-center pt-0 px-sm-4 px-1">
                <p class="mb-4 mx-auto">
                  Already have an account?
                  <a href="javascrpt:;" class="text-primary text-gradient font-weight-bold">Sign in</a>
                </p>
              </div>-->
            </div>
          </div>
        </div>
      </div>
    </div>

          </div>
        </div>
        
    </div>
      </div>
    <div class="container-fluid py-4 pb-0">
        <div class="row">
        <div class="col-12">
          <div class="card mb-4">
            <div class="card-header pb-0">
              <h6>Lista de Equipos</h6>
            </div>
              <div>

              </div>
   <div class="card-body px-0 pt-0 pb-2">
       <div class="row px-4 mt-3">
    <div class="col-md-4">
        <div class="form-group">
            <label class="form-control-label text-xs font-weight-bold text-uppercase">Filtrar por Estado:</label>
            <select id="filtroEstado" class="form-control form-control-sm">
                <option value="">Todos los estados</option>
                <option value="Asignado">Asignado</option>
                <option value="Disponible">Disponible</option>
                <option value="Fuera de servicio">Fuera de servicio</option>
                <option value="Mantenimiento">Mantenimiento</option>
                <option value="Vendida">Vendida</option>
                <option value="Para Venta">Para Venta</option>
                <option value="Robada">Robada</option>
                <option value="Infraestructura">Infraestructura</option>
            </select>
        </div>
    </div>
</div>
    <div class="table-responsive p-3"> 
        <table id="example" class="table align-items-center mb-0 table-hover w-100" style="width:100%">
            <thead>
                    <tr>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">ID</th>
                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Compra/Currier</th>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Asignación</th>
                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Equipo</th>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Estado</th>
                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7" style="max-width: 120px;">Obs.</th>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Img</th>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Depto</th>
                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Acciones</th>
<!--                        <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"></th> -->
                    </tr>
                </thead>
            <tbody>
                       <% 
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "SELECT a.idinvequipo, TO_CHAR(a.fechacompra, 'DD/MM/YYYY') AS fech_compra, a.ubicacionoficina, a.departamento, a.marca, a.modelo,  a.serial, a.procesador,a.procesador,  a.hdd,a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre || ' ' || c.apellidos AS usuario_nombre_completo, a.empresa, a.dispositivo, a.fichero, d.nombres || ' ' || d.apellidos AS currier_nombre_completo, TO_CHAR(b.fechaasignacion, 'YYYY/MM/DD') AS fech_asigna FROM inv_equipos a LEFT JOIN inv_asignacion b ON b.idinvequipo = a.idinvequipo AND b.estado = 'A' LEFT JOIN usuario c ON b.idusuario = c.idusuario LEFT JOIN inv_currier d ON a.id_currier = d.id_currier WHERE (a.estado IN ('A', 'D', 'F', 'V', 'R', 'M', 'I', 'PV')) AND a.estado_ai = 'A' ORDER BY a.estado DESC, c.nombre, c.apellidos";
//                            String sql = "select a.idinvequipo, TO_CHAR(a.fechacompra, 'DD/MM/YYYY') AS fech_compra, a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
//                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where (a.estado = 'A' or a.estado='D' or a.estado='F' or a.estado='V' or a.estado='R' or a.estado='M' or a.estado='I' or a.estado='PV' )and a.estado_ai ='A' ORDER BY a.estado desc, c.nombre, c.apellidos";
//                            String sql = "select a.IDUSUARIO, a.NOMBRE, a.APELLIDOS, a.EMAIL, b.COMPANIA  , c.departamento from USUARIO a, compania b, adm_departamento c where a.IDCOMPANIA = b.IDCOMPANIA AND a.ESTADO = 'a' AND a.id_adm_departamento =c.id_departamento order by 1";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {%>
                        
                        <tr>
                    <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=rs.getString(1)%></p></td>
                    <td>
                        <p class="text-xs font-weight-bold mb-0"><%=rs.getString(2)%></p>
                        <p class="text-xxs text-muted mb-0">Currier: <%=rs.getString(20)%></p>
                    </td>
                    <td class="text-center"><p class="text-xs font-weight-bold mb-0"><%=rs.getString(21)%></p></td>
                    <td>
                        <div class="d-flex px-2 py-1">
                            <div class="d-flex flex-column justify-content-center">
                                <h6 class="mb-0 text-xs"><%=rs.getString(16)%></h6>
                                <p class="text-xxs text-secondary mb-0"><%=rs.getString(18)%></p>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-xs">Modelo: <%=rs.getString(6)%></h6>
                            <h6 class="mb-0 text-xs">Marca: <%=rs.getString(5)%></h6>
                            <p class="text-xxs text-secondary mb-0">S/N: <%=rs.getString(7)%></p>
                            <div class="text-xxs">
                            <b>CPU:</b> <%=rs.getString(8)%><br>
                            <b>RAM:</b> <%=rs.getString(11)%>
                        </div>
                        </div>
                    </td>
<!--                    <td>
                        
                    </td>-->
                    <td class="text-center">
                      
                           <%if(rs.getString(14).equals("A")){%>
                          
          <span class="badge badge-sm bg-gradient-warning">Asignado</span>
            
        <%}%>
        <%if(rs.getString(14).equals("D")){%>
        <!--<p class="text-xs font-weight-bold mb-0" title="Disponible." style="background-color: #99ff66">Disponible</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
          <span class="badge badge-sm bg-gradient-success">Disponible</span>
        <%}%>
        <%if(rs.getString(14).equals("F")){%>
         <!--<p class="text-xs font-weight-bold mb-0" title="Fuera de Servicio." style="background-color: #ff9999">Fuera de Servicio</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
          <span class="badge badge-sm bg-gradient-danger">Fuera de servicio</span>
            
        <%}%>
        <%if(rs.getString(14).equals("V")){%>
           
            <!--<p class="text-xs font-weight-bold mb-0" title="Vendido." style="background-color: #ff9999">Vendido</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
            <span class="badge badge-sm bg-gradient-dark">Vendida</span>
        <%}%>
        <%if(rs.getString(14).equals("PV")){%>
            <span class="badge badge-sm bg-gradient-dark">Para Venta</span>
        <%}%>
        
        <%if(rs.getString(14).equals("R")){%>
           
             <!--<p class="text-xs font-weight-bold mb-0" title="Robado." style="background-color: #ff9999">Robado</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
            <span class="badge badge-sm bg-gradient-faded-danger">Robada</span>
        <%}%>
        <%if(rs.getString(14).equals("M")){%>
           
             <!--<p class="text-xs font-weight-bold mb-0" title="Mantenimiento." style="background-color: #00ffff">Mantenimiento</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
            <span class="badge badge-sm bg-gradient-primary">Mantenimiento</span>
        <%}%>
        <%if(rs.getString(14).equals("I")){%>
           
             <!--<p class="text-xs font-weight-bold mb-0" title="Infraestructura." style="background-color: #008CBA">Infraestructura</p>-->
          <!--<p class="text-xs text-secondary mb-0 text-truncate" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>-->
            <span class="badge badge-sm bg-gradient-faded-danger-vertical">Infraestructura</span>
        <%}%>
        <br>
        
        <!--<b><p class="text-xs mb-0"><%=rs.getString(3)%></p></b>--> 
                      </td>

<td style="max-width: 150px;">
                        <p class="text-xs mb-0 text-wrap" style="line-height: 1.2;">
                            <%= (rs.getString(13) != null) ? rs.getString(13) : "" %>
                        </p>
                    </td>
        <!-- Imagen miniatura con trigger al modal -->
        <td class="text-center">
                        <img src="../INV_MostrarImagenEquipo?nombre=equipo_<%=rs.getString(1)%>" 
                             class="rounded border shadow-xs" 
                             style="height: 40px; width: 60px; object-fit: cover; cursor: pointer;"
                             data-bs-toggle="modal" data-bs-target="#modalImagenEquipo_<%=rs.getString(1)%>">
                    </td>

        <!-- Modal individual por equipo -->
        <div class="modal fade" id="modalImagenEquipo_<%=rs.getString(1)%>" tabindex="-1" aria-labelledby="modalImagenLabel_<%=rs.getString(1)%>" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content bg-transparent border-0">
                    <div class="modal-body text-center p-0">
                        <img src="../INV_MostrarImagenEquipo?nombre=equipo_<%=rs.getString(1)%>"
                             alt="Imagen ampliada del equipo"
                             class="img-fluid rounded shadow-lg" />
                    </div>
                </div>
            </div>
        </div>

   



                       <td class="text-center">
                         <span class="badge border text-dark text-xxs"><%=rs.getString(4)%></span>
                         <p class="text-xs mb-0"><%=rs.getString(3)%></p>
                    </td>

                      
                      <td class="text-center">
                        <div class="d-flex flex-column gap-1">
                            <a class="btn btn-xs btn-primary mb-1 py-1" href="../Inventario/INV_Equipos_Editar.jsp?idInvEquipo=<%=rs.getString(1)%>">
                                <i class="fas fa-edit">Asignar / Editar</i>
                            </a>
                            <button type="button" class="btn btn-xs btn-outline-info py-1" onclick="previsualizarActa('<%=rs.getString(16)%>', '<%=rs.getString(15)%>', '<%=rs.getString(5)%>', '<%=rs.getString(6)%>', '<%=rs.getString(7)%>', '<%=rs.getString(4)%>')">
                                <i class="fa fa-file-pdf">Imprimir Acta</i>
                            </button>
                        </div>
                    </td>

                     
                    </tr>
                        <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                    
                    
                    
                  </tbody>
                </table>
              </div>
            </div>
                            
                            <script>
                function passIdToModal(idinvequipo) {
                    document.getElementById('modalId').innerText = 'ID del equipo: ' + idinvequipo;
                    // Aquí puedes realizar otras acciones, como cargar el historial mediante AJAX
                }
            </script>
                            <!--modal para asignar usuario A EQUIPO-->
  <div class="modal fade" id="asignarEquipoUsuario" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">

           
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body p-0">
                <div class="card card-plain">
                    <div class="card-header pb-0 text-left">
                        <h3 class="font-weight-bolder text-primary text-gradient">Historial equipo</h3>
                        <p class="mb-0">Lista de asignaciones correspondientes a este equipo: </p>
                        <div id="modalId">ID del equipo: </div>
                        
                    </div>
                    <div class="card-body pb-3">
                        <div class="table-responsive">
                            <table id="detalles" class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <!--<th class="text-center">Id</th>-->
                                        <th class="text-center">Fecha Asignación</th>
                                        <th class="text-center">Nombre Usuario</th>
                                        <th class="text-center">Fecha Devolución</th>
                                       
                                    </tr>
                                </thead>
                                <tbody align="center">
                                    <% try {
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection cn3 = DriverManager.getConnection(url, user, pass);
                                        String historiaEquipo = "select a.idinvequipo, a.fechaasignacion, b.apellidos, b.nombre, a.fechadevolucion from inv_asignacion a , usuario b where a.idinvequipo =  "+idcab+"  and a.idusuario = b.idusuario";
                                        PreparedStatement st3 = cn3.prepareStatement(historiaEquipo);
                                        ResultSet rs3 = st3.executeQuery();
                                        while (rs3.next()) { %>
                                            <tr>
                                                <!--<td><%= rs3.getString(1) %></td>-->
                                                <td><%= rs3.getString(2) %></td>
                                                <td><%= rs3.getString(3) %> - <%= rs3.getString(4) %></td>
                                                <td><%= rs3.getString(5) %></td>
                                                
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
                        </div>
                    </div>
                    <div class="card-footer text-center pt-0 px-sm-4 px-1">
                        <p class="mb-4 mx-auto">
                            <a href="javascript:;" class="text-primary text-gradient font-weight-bold"></a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>



                                <!--fin modal asignar usuario-->
          </div>
        </div>
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
          </a>
        </div>-->
      </div>
    </div>
  </div>
  <!--   Core JS Files   -->
  <script src="../assets/js/core/popper.min.js"></script>
  <script src="../assets/js/core/bootstrap.min.js"></script>
  <script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
  <script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
  
  <script>
function previsualizarActa(usuario, cedula, marca, modelo, serial, depto) {
    const opcionesFecha = { year: 'numeric', month: 'long', day: 'numeric' };
    const fechaActual = new Date().toLocaleDateString('es-ES', opcionesFecha);
    
    const ancho = 850; 
    const alto = 900;
    const x = (screen.width / 2) - (ancho / 2);
    const y = (screen.height / 2) - (alto / 2);
    
    const ventimp = window.open('', 'PREVISUALIZACION', `width=${ancho},height=${alto},left=${x},top=${y},toolbar=0,scrollbars=1,status=0`);
    
    ventimp.document.write('<html><head><title>Acta de Responsabilidad - ' + usuario + '</title>');
    ventimp.document.write('<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />');
    ventimp.document.write('<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />');
    
    ventimp.document.write('<style>');
    ventimp.document.write('body { background: #f8f9fe; padding: 50px; font-family: "Open Sans", sans-serif; color: #333; }');
    ventimp.document.write('.hoja-acta { background: white; padding: 60px; box-shadow: 0 0 20px rgba(0,0,0,0.1); border-radius: 8px; min-height: 842px; position: relative; }');
    ventimp.document.write('.logo-buadnet { height: 75px; float: right; }');
    ventimp.document.write('.texto-verde { color: #2dce89 !important; font-weight: 600; }');
    ventimp.document.write('.firma-linea { border-top: 1px solid #adb5bd; width: 180px; margin-top: 80px; margin-bottom: 10px; }');
    ventimp.document.write('.text-justify { text-align: justify; text-justify: inter-word; line-height: 1.6; }');
    ventimp.document.write('@media print { body { background: white; padding: 0; } .hoja-acta { box-shadow: none; border: none; padding: 20px; } .btn-imprimir { display: none; } }');
    ventimp.document.write('</style></head><body>');

    ventimp.document.write('<div class="text-center mb-4 btn-imprimir">');
    ventimp.document.write('<button onclick="window.print();" class="btn btn-success px-5"><i class="fa fa-print me-2"></i> CONFIRMAR E IMPRIMIR</button>');
    ventimp.document.write('</div>');

    ventimp.document.write('<div class="hoja-acta">');
    ventimp.document.write('<img src="../assets/img/promanetlogo.png" class="logo-buadnet">');
    ventimp.document.write('<div style="clear: both;"></div>');
    
    ventimp.document.write('<p class="mt-4"><strong>Guayaquil, ' + fechaActual + '</strong></p>');
    ventimp.document.write('<h2 class="text-center mt-5 mb-5" style="color: #5e72e4; letter-spacing: 1px;">Acta de Responsabilidad y Entrega</h2>');

    // --- NUEVA REDACCIÓN ACTUALIZADA ---
    ventimp.document.write('<p class="text-justify">Yo, <strong class="text-uppercase">' + usuario + '</strong>, con identificación: <strong>' + cedula + '</strong>, declaro haber recibido de la empresa, en calidad de <strong>herramienta de trabajo</strong>, el equipo de cómputo detallado a continuación para el desempeño exclusivo de mis funciones laborales en el área de <strong>' + depto + '</strong>.</p>');

    ventimp.document.write('<p class="text-justify mt-3">Hago constar que el bien se me entrega en <strong>perfectas condiciones físicas, operativo y totalmente funcional</strong>, libre de desperfectos que impidan su uso. El equipo queda bajo mi custodia para <strong>uso exclusivo de las actividades de la empresa</strong>, asumiendo la responsabilidad total de su correcto uso, cuidado y conservación, conforme a las directrices de seguridad y políticas del Departamento de Sistemas.</p>');

    ventimp.document.write('<div class="mt-4 ps-4">');
    ventimp.document.write('<ul style="list-style: disc;">');
    ventimp.document.write('<li class="mb-1"><span class="texto-verde">Dispositivo:</span> Laptop</li>');
    ventimp.document.write('<li class="mb-1"><span class="texto-verde">Marca:</span> <strong class="text-dark">' + marca + '</strong></li>');
    ventimp.document.write('<li class="mb-1"><span class="texto-verde">Modelo:</span> ' + modelo + '</li>');
    ventimp.document.write('<li class="mb-1"><span class="texto-verde">Serial:</span> ' + serial + '</li>');
    ventimp.document.write('<li class="mb-1"><span class="texto-verde">Accesorio:</span> Cargador Original</li>');
    ventimp.document.write('</ul></div>');

    ventimp.document.write('<p class="mt-5 text-justify">Me comprometo a velar por el adecuado mantenimiento del activo asignado, garantizando su integridad física y operativa. En caso de daño por negligencia, pérdida o uso indebido fuera del ámbito laboral, acepto las políticas de reposición establecidas por la organización.</p>');

    // BLOQUE DE FIRMAS
    ventimp.document.write('<div class="d-flex justify-content-between mt-8 text-center">');
    
    ventimp.document.write('  <div style="flex: 1;">');
    ventimp.document.write('    <div class="firma-linea mx-auto"></div>');
    ventimp.document.write('    <p class="text-xs">Entregado por:<br><strong><%=nombre%> <%=apellidos%></strong></p>');
    ventimp.document.write('  </div>');
    
    ventimp.document.write('  <div style="flex: 1;">');
    ventimp.document.write('    <div class="firma-linea mx-auto"></div>');
    ventimp.document.write('    <p class="text-xs">Recibí Conforme:<br><strong class="text-uppercase">' + usuario + '</strong></p>');
    ventimp.document.write('  </div>');
    
    ventimp.document.write('  <div style="flex: 1;">');
    ventimp.document.write('    <div class="firma-linea mx-auto"></div>');
    ventimp.document.write('    <p class="text-xs">Movilización<br><strong>Responsable</strong></p>');
    ventimp.document.write('  </div>');
    
    ventimp.document.write('</div>');

    ventimp.document.write('</div>'); 
    ventimp.document.write('</body></html>');
    ventimp.document.close();
}
</script>
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
        <script src="../assets/js/custom-sidenav-toggle.js"></script>
</body>
</html>
