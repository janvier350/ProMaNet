<%-- 
    Document   : INV_EQUIPOS
    Created on : 13 jUNIO 2024, 20:32:28
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
    String url = new String(""+ip);
    String depart = "";
   String idInvEquipo = request.getParameter("idInvEquipo");  
  
   String estdoEquipo = "";
            
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if(COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")){
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
        <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
        
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
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="empresa" name ="empresa">
                                                                                             
                                     <option value="N/A">N/A</option>
                                         <option value="Latinconsulting">Latinconsulting</option>      
                                         <option value="DK-WORK">DK-WORK</option> 
                                         <option value="Arthurs Audit Global">Arthurs Audit Global</option>  
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
<!-- Modal -->
    <div class="container-fluid py-4">
      <div class="row">
        <div class="col-lg-8">
          <div class="row">
<!--            <div class="col-xl-6 mb-xl-0 mb-4">
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
            </div>-->
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
                    


            <div class="col-md-12 mb-lg-0 mb-4">
              <div class="card mt-4">
<!--                <div class="card-header pb-0 p-3">
                  <div class="row">
                    <div class="col-6 d-flex align-items-center">
                         
                        
                         <h6 class="mb-0 text-danger text-gradient " >Total mes en curso $    </h6>
                         
                  
                   
                    </div>
                          
                    <div class="col-6 text-end">
                      
                       
                             
                        
               
             
                            
                    </div>
                  </div>
                </div>-->
<!--                <div class="card-body p-3">
                  <div class="row">
                    <div class="col-md-6 mb-md-0 mb-4">
                      <div class="card card-body border card-plain border-radius-lg  d-flex align-items-center flex-row">
                          <h6 class="mb-0">Total&nbsp;&nbsp;&nbsp;Alimentación&nbsp;&nbsp;&nbsp;****&nbsp;&nbsp;&nbsp;$</h6>
                         

                       
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="card card-body border card-plain border-radius-lg d-flex align-items-center flex-row">
                        <img class="w-10 me-3 mb-0" src="../assets/img/logos/visa.png" alt="logo">
                        <h6 class="mb-0">Total&nbsp;&nbsp;&nbsp;Transporte&nbsp;&nbsp;&nbsp;****&nbsp;&nbsp;&nbsp;$</h6>
                        <i class="fas fa-pencil-alt ms-auto text-dark cursor-pointer" data-bs-toggle="tooltip" data-bs-placement="top" title="Edit Card"></i>
                      </div>
                      
                    </div>
                  </div>
                </div>-->
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
              <h6>Editar equipo</h6>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="row">
                  

                
                  <form action="../INV_UpdateEquipo" method="post">
                      <% String sql ="";            
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);            
               sql = "SELECT a.idinvequipo, " +
      "       TO_CHAR(a.fechacompra, 'yyyy-MM-dd'), " +
      "       a.ubicacionoficina, " +
      "       a.departamento, " +
      "       a.marca, " +
      "       a.modelo, " +
      "       a.serial, " +
      "       a.procesador, " +
      "       a.hdd, " +
      "       a.ram, " +
      "       a.pantalla, " +
      "       a.observaciones, " +
      "       a.estado, " +
      "       b.idusuario, " +
      "       c.nombre || ' ' || c.apellidos AS usuario_nombre_completo, " +
      "       a.empresa, " +
      "       a.dispositivo, " +
      "       a.fichero, " +
      "       d.nombres || ' ' || d.apellidos AS currier_nombre_completo, " +
       "      d.id_currier " +
      "FROM inv_equipos a " +
      "LEFT JOIN inv_asignacion b ON b.idinvequipo = a.idinvequipo AND b.estado = 'A' " +
      "LEFT JOIN usuario c ON b.idusuario = c.idusuario " +
      "LEFT JOIN inv_currier d ON a.id_currier = d.id_currier " +
      "WHERE a.idinvequipo = " + idInvEquipo + " AND a.estado_ai = 'A'";

//                   sql = "select a.idinvequipo, to_char(a.fechacompra, 'yyyy-MM-dd'), a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
//                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where a.idinvequipo=  "+idInvEquipo+ " and a.estado_ai ='A' "; ;            
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                %>
                    <div class="row">
                      <div class="col-md-6 ">
                        <div class="form-group">
                          <label for="fechaIngreso" class="form-control-label ">Fecha Compra</label>
                          <input class="form-control" type="date" name="fecha" required="true" value="<%=rs.getString(2)%>">
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="form-group">
                          <label for="compania" class="form-control-label">Empresa</label>

                          <div class="form-group">

                                                      <div class="form-group">
                                                                      <select class="chosen-select form-control" id="empresa" name ="empresa" >
                                                                          <option value="<%=rs.getString(16)%>"><%=rs.getString(16)%></option>  
                                                                          
                                                                          <%
                                                                              try{
                                                                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                              Connection   cn4 = DriverManager.getConnection(url, user, pass);
                                                                              String empresa = "select * from compania where estado = 'a'  order by 2";
                                                                              PreparedStatement st4 = cn4.prepareStatement(empresa);
                                                                              ResultSet rs4 = st4.executeQuery();       
                                                                              while (rs4.next()) {
                                                                              
                                                                              %>                    
                                                                              
                                                                              <option value="<%=rs4.getString(3)%>"> <%=rs4.getString(3)%></option>
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
  <div class="row">
    <div class="col-md-6">
          <label>Ubicacion/ Oficina:</label>
<!--                  <div class="input-group mb-3">
                      <input type="number" class="form-control" placeholder="1,50" aria-label="Password" aria-describedby="password-addon"  name="transporte"  id="" value="1.50">
                  </div>-->
                   <select class="chosen-select form-control" id="ubicacion" name ="ubicacion">       
                       <option value="<%=rs.getString(3)%>"><%=rs.getString(3)%></option>  
                                     <option value="Norte">Norte</option>
                                     <option value="Kennedy 401">Kennedy 401</option>    
                                     <option value="Kennedy 403">Kennedy 403</option>          
                                     <option value="Outsourcing">Outsourcing</option>       
                                          
                    </select>
<!--      <div class="form-group">
        <label for="nombres" class="form-control-label">Ubicación - Oficina</label>
        <input class="form-control" type="text" placeholder="Nombres completos y bien escritos (datos de la cédula)" name="nombres" required="true">
      </div>-->
    </div>
    <div class="col-md-6">
      <div class="form-group">
          <label>Departamento: </label>
                  <div class="input-group mb-3">
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="departamento" name ="departamento">
                                    <option value="<%=rs.getString(4)%>"><%=rs.getString(4)%></option>  
                                      <option value="Administración">Administración</option>      
                                      <option value="ADMINISTRACIÓN NORTE">Administración Norte</option> 
                                     <option value="Auditoría">Auditoría</option> 
                                         <option value="Contabilidad">Contabilidad</option> 
                                         <option value="Commark">Commark</option> 
                                         <option value="Gerencia">Gerencia</option> 
                                         <option value="Impuestos">Impuestos</option>
                                         <option value="IMPUESTOS NORTE">Impuestos Norte</option>
                                          <option value="Legal">Legal</option>  
                                          <option value="Tecnología">Tecnología</option>
                                          
                                </select>
                  </div>
<!--        <label for="apellidos" class="form-control-label">Apellidos</label>
        <input class="form-control" type="text" placeholder="Apellidos completos y bien escritos (datos de la cédula)" name="apellidos" required="true">-->
      </div>
    </div>
  </div>
  
                                        
    <div class="row">
    <div class="col-md-6">
      <div class="form-group">
<!--        <label for="actividades" class="form-control-label">Marca: </label>
        <input class="form-control" type="text" placeholder="Marca " name="actividades" required="true" >-->
 <label>Tipo de Dispositivo:</label>
                  <div class="input-group mb-3">
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="dispositivo" name ="dispositivo">
                                           <option value="<%=rs.getString(17)%>"><%=rs.getString(17)%></option>                                                    
                                     <option value="Laptop">Laptop</option>
                                         <option value="Impresora">Impresora</option>      
                                         <option value="Proyector">Proyector</option> 
                                         <option value="Networking">Networking</option>  
                                         <option value="CCTV">CCTV</option>  
                                         <option value="Periférico">Periférico</option>  
                                         <option value="Servidor">Servidor</option>  
                                </select>
                  </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
<!--        <label for="ubicacion" class="form-control-label">Modelo: </label>
        <input class="form-control" type="text" name="ubicacion" placeholder="sdf"required="true">-->
 <label class="col-lg-1 control-label">Estado:</label>
                    <div class="col-lg-2">
                        <select class="form-control" id="estado" name ="estado" style="width:100%"> 
                            <%if(rs.getString(13).equals("A")){
                             estdoEquipo = "A";%>
                                <option value="A" style="background-color: yellow">Asignado</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("D")){%>
                                <option value="D" style="background-color: #99ff66">Disponible</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("M")){%>
                                <option value="F" style="background-color: #ff9999">Mantenimiento</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("PV")){%>
                                <option value="I" style="background-color: #ff9999">Para Venta</option> 
                            <%}%>
                            <%if(rs.getString(13).equals("F")){%>
                                <option value="F" style="background-color: #ff9999">Fuera de Servicio</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("V")){%>
                                <option value="V" style="background-color: #ff9999">Vendido</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("R")){%>
                                <option value="R" style="background-color: #ff9999">Robado</option>                                 
                            <%}%>  
                            <%if(rs.getString(13).equals("I")){%>
                                <option value="I" style="background-color: #ff9999">Infraestructura</option> 
                            <%}%>
                            <option value="D">Disponible</option>                      
                            <option value="M">Mantenimiento</option> 
                            <option value="F">Fuera de Servicio</option>       
                             <option value="PV">Para Venta</option>  
                            <option value="V">Vendido</option>  
                            <option value="R">Robado</option>                               
                            <option value="A">Asignado</option>                             
                            <option value="I">Infraestructura</option> 
                        </select>
                    </div>
      </div>
    </div>
  </div>                                    
                                       
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="actividades" class="form-control-label">Marca: </label>
        <input class="form-control" type="text" placeholder="Marca " name="marca" value= "<%=rs.getString(5)%>" required="true" >
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="ubicacion" class="form-control-label">Modelo: </label>
        <input class="form-control" type="text" name="modelo" value= "<%=rs.getString(6)%>" required="true">
      </div>
    </div>
  </div>
  
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="actividades" class="form-control-label">Serial: </label>
        <input class="form-control" type="text" value= "<%=rs.getString(7)%>" name="serial" required="true" >
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="ubicacion" class="form-control-label">Procesador</label>
        <input class="form-control" type="text" name="procesador" value= "<%=rs.getString(8)%>"required="true">
      </div>
    </div>
  </div>
 <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="actividades" class="form-control-label">Disco: </label>
        <input class="form-control" type="text"  name="hdd" value= "<%=rs.getString(9)%>" required="true" >
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="ubicacion" class="form-control-label">Memoria:</label>
        <input class="form-control" type="text" name="ram" value= "<%=rs.getString(10)%>" required="true">
      </div>
    </div>
  </div>
   <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="actividades" class="form-control-label">Pantalla: </label>
        <input class="form-control" type="text"  name="pantalla" value= "<%=rs.getString(11)%>"required="true" >
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="ubicacion" class="form-control-label">IdEquipo</label>
        <input class="form-control" type="text" name="idInvEquipo" value="<%=idInvEquipo%>" required="true" readonly="true">

                    
      </div>
    </div>
  </div>
       
        <div class="row">
    <div class="col-md-6">
      <div class="form-group">
<!--        <label for="actividades" class="form-control-label">Pantalla: </label>
        <input class="form-control" type="text"  name="pantalla" value= "<%=rs.getString(11)%>"required="true" >-->
<label class="col-lg-1 control-label">Asignado:</label>
<input value="<%= rs.getString(15)%>" type="text"  name="asignado" class="form-control" readonly="true" />
      </div>
    </div>
       <div class="col-md-6">
      <div class="form-group">
<!--        <label for="actividades" class="form-control-label">Pantalla: </label>
        <input class="form-control" type="text"  name="pantalla" value= "<%=rs.getString(11)%>"required="true" >-->
<label class="col-lg-1 control-label">Currier: </label>
<!--<input value="<%= rs.getString(15)%>" type="text"  name="asignado" class="form-control" readonly="true" />-->
<select class="chosen-select form-control" id="id_currier" name ="id_currier">
  
     <option value="<%=rs.getString(20)%>"><%=rs.getString(19)%> </option>
                                             <%
                                 try{
                                 DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                 Connection   cn2 = DriverManager.getConnection(url, user, pass);
                                 String sql2 = "select * from INV_CURRIER where estado = 'A' order by 1";
                                 PreparedStatement st2 = cn2.prepareStatement(sql2);
                                 ResultSet rs2 = st2.executeQuery();       
                                 while (rs2.next()) {%>        
                                 <option value="<%=rs2.getString(1)%>"><%=rs2.getString(2)%> <%=rs2.getString(3)%>    " Contacto: <%=rs2.getString(5)%>" </option>
                                        <%}     
                                     rs2.close();
                                     st2.close();
                                     cn2.close();
                                  }catch(Exception e){
                                      e.printStackTrace();
                                  }%>     
                                </select>
      </div>
    </div>
      
      
<!--    <div class="col-md-6">
      <div class="form-group">
       <label class="form-control-label">Observaciones:</label>
        <textarea  type="text"  name="observaciones" class="form-control"><%= rs.getString(12)%></textarea>            
      </div>
    </div>-->
<!--<div class="col-md-6">
                        <div class="form-group">
                          <label for="compania" class="form-control-label">Empresa</label>
<label class="col-lg-1 control-label">Asignar a:</label>
                          <div class="form-group">
 
                                                      <div class="form-group">
                                                                      <select class="chosen-select form-control" id="empresa" name ="empresa" >
                                                                          <option value="<%=rs.getString(16)%>"><%=rs.getString(16)%></option>  
                                                                          
                                                                          <%
                                                                              try{
                                                                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                              Connection   cn4 = DriverManager.getConnection(url, user, pass);
//                                                                              String empresa = "select * from compania where estado = 'a'  order by 2";
                                                                                String usuarios = "Select IDUSUARIO, NOMBRE||' '||APELLIDOS as nombre,IDROL,ESTADO From usuario where ESTADO='a' and  "
              + " Not IDUSUARIO In (select a.IDUSUARIO from INV_ASIGNACION a where a.ESTADO = 'A')  order by 2";
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
                      </div>-->
  </div>
        
  
            <div class="row">
   
    <div class="col-md-12">
      <div class="form-group">
        <label class="col-lg-1 control-label">Observaciones:</label>
                    <div class="col-lg-12">
                        <!--<input value="<%= rs.getString(12)%>" type="text"  name="observaciones" class="form-control" />-->
                        <textarea  type="text"  name="observaciones" class="form-control"><%= rs.getString(12)%></textarea>
                    </div>
      </div>
    </div>
  </div>
                        
  <hr class="horizontal dark">
  <p class="text-uppercase text-sm"> </p>
<!--  <div class="form-group">
    <button type="submit" class="btn btn-success" >
      <i class="fa fa-envelope-o" aria-hidden="true"></i>    ENVIAR 
    </button>
  </div>-->
    <div class="modal-footer">
            <button type="submit" class="btn btn-success" >
                <i class="fa fa-save" aria-hidden="true">  </i>    Guardar 
              </button>
          </div>
   
   <%} rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>  
</form>
  
              </div>
              <hr class="horizontal dark">
         
            </div>
          </div>
        </div>
      </div>

      
              
        <div class="row">
        <div class="col-12">
          <div class="card mb-4 card-header pb-0">
            <div class="card-header pb-0">
              <h6>Asignar Equipo</h6>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                  <div class="row">
                      <form action="../INV_InsertarAsignacion.jsp" method="post">
                          <div class="col-md-6">
                          <div class="form-group">
                    <!--        <label for="actividades" class="form-control-label">Pantalla: </label>
                            <input class="form-control" type="text"  name="pantalla" value= ""required="true" >-->
                    <label class="col-lg-1 control-label">Asignado:</label>
                    <!--<input value="" type="text"  name="asignado" class="form-control"  value="" readonly="true" />-->
                    <input class="form-control" type="text" name="idEquipo" value="<%=idInvEquipo%>" required="true" readonly="true">
                          </div>
                        </div>
                    <!--    <div class="col-md-6">
                          <div class="form-group">
                           <label class="form-control-label">Observaciones:</label>
                            <textarea  type="text"  name="observaciones" class="form-control"></textarea>            
                          </div>
                        </div>-->
                    <div class="col-md-6">
                                            <div class="form-group">
                                              <!--<label for="compania" class="form-control-label">Empresa</label>-->
                    <label class="col-lg-1 control-label">Asignar a:</label>
                    <% if(estdoEquipo.equals("A")){
                                                }else{%>
                                              <div class="form-group">

                                                                          <div class="form-group">
                                                                                          <select class="chosen-select form-control" id="idUsuario" name ="idUsuario" >
                                                                                              <option value="">Elija a un ejecutivo</option>  

                                                                                              <%
                                                                                                  try{
                                                                                                  DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                                                  Connection   cn4 = DriverManager.getConnection(url, user, pass);
                    //                                                                              String empresa = "select * from compania where estado = 'a'  order by 2";
                                                                                                    String usuarios = "Select IDUSUARIO, NOMBRE||' '||APELLIDOS as nombre,IDROL,ESTADO From usuario where ESTADO='a' and  "
                                  + " Not IDUSUARIO In (select a.IDUSUARIO from INV_ASIGNACION a where a.ESTADO = 'A')  order by 2";
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
                                        <div class="modal-footer">
                                            
                                            <button type="submit" class="btn btn-danger" >
                                                <i class="fa fa-check" aria-hidden="true">  </i>    Asignar Equipo 
                                              </button>
                                            <%    }%>
                                            
                                          </div>
                      </form>
                      </div>
<!--                <table class="table align-items-center justify-content-center mb-0">
                  <thead>
                    <tr>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Proyecto</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Cliente</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Estado</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2">Avance</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-spotify.svg" class="avatar avatar-sm rounded-circle me-2" alt="spotify">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Devolución de IVA</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">CONSEGUA</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">En proceso</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">55%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-info" role="progressbar" aria-valuenow="55" aria-valuemin="0" aria-valuemax="100" style="width: 55%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-invision.svg" class="avatar avatar-sm rounded-circle me-2" alt="invision">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Determinación de Activos patrimoniales</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">AGROBAN</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">AVANCE MEDIO</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">33%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-warning" role="progressbar" aria-valuenow="33" aria-valuemin="0" aria-valuemax="100" style="width: 33%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0" aria-haspopup="true" aria-expanded="false">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-jira.svg" class="avatar avatar-sm rounded-circle me-2" alt="jira">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Representación</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">COMANDATO</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">DEFICIENTE</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">2%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-danger" role="progressbar" aria-valuenow="2" aria-valuemin="0" aria-valuemax="30" style="width: 2%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0" aria-haspopup="true" aria-expanded="false">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-slack.svg" class="avatar avatar-sm rounded-circle me-2" alt="slack">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Devolución de IVA exportador</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">BALCECA</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">DEFICIENTE</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">5%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-danger" role="progressbar" aria-valuenow="5" aria-valuemin="0" aria-valuemax="0" style="width: 5%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0" aria-haspopup="true" aria-expanded="false">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-webdev.svg" class="avatar avatar-sm rounded-circle me-2" alt="webdev">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Webdev</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">$14,000</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">working</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">80%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-info" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="80" style="width: 80%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0" aria-haspopup="true" aria-expanded="false">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2">
                          <div>
                            <img src="../assets/img/small-logos/logo-xd.svg" class="avatar avatar-sm rounded-circle me-2" alt="xd">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm">Adobe XD</h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0">$2,300</p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold">done</span>
                      </td>
                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold">100%</span>
                          <div>
                            <div class="progress">
                              <div class="progress-bar bg-gradient-success" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%;"></div>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="align-middle">
                        <button class="btn btn-link text-secondary mb-0" aria-haspopup="true" aria-expanded="false">
                          <i class="fa fa-ellipsis-v text-xs"></i>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>-->
              </div>
            </div>
          </div>
        </div>
      </div>
                                                                              <!--inicio tabla de asignados historia-->
   <div class="row">
        <div class="col-12">
          <div class="card mb-4">
            <div class="card-header pb-0">
              <h6>Historia de asiganción</h6>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                <table class="table align-items-center mb-0">
                  <thead>
                    <tr>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Usuario</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Fecha Asignación</th>
                      <!--<th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Usuario</th>-->
                      <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha entrega</th>
                      <th class="text-secondary opacity-7"></th>
                    </tr>
                  </thead>
                  <tbody>
                      <% try {
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection cn3 = DriverManager.getConnection(url, user, pass);
                                        String historiaEquipo = "select a.idinvequipo, a.fechaasignacion, b.apellidos, b.nombre, a.fechadevolucion, b.email,b.telefono  from inv_asignacion a , usuario b where a.idinvequipo =  "+idInvEquipo+"  and a.idusuario = b.idusuario";
                                        PreparedStatement st3 = cn3.prepareStatement(historiaEquipo);
                                        ResultSet rs3 = st3.executeQuery();
                                        while (rs3.next()) { %>
                                        <tr>
                                                <td>
                                                  <div class="d-flex px-2 py-1">
                                                    <div>
                                                      <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user1">
                                                    </div>
                                                    <div class="d-flex flex-column justify-content-center">
                                                      <h6 class="mb-0 text-sm"><%= rs3.getString(3) %> - <%= rs3.getString(4) %></h6>
                                                      <p class="text-xs text-secondary mb-0"> <%= rs3.getString(6) %></p>
                                                    </div>
                                                  </div>
                                                </td>
                                                <td>
                                                  <p class="text-xs font-weight-bold mb-0"><%= rs3.getString(2) %></p>
                                                  <p class="text-xs text-secondary mb-0"></p>
                                                </td>
<!--                                                <td class="align-middle text-center text-sm">
                                                  <span class="badge badge-sm bg-gradient-success">Online</span>
                                                </td>-->
                                                <td class="align-middle text-center">
                                                  <span class="text-secondary text-xs font-weight-bold"><%= rs3.getString(5) %></span>
                                                </td>
                                                <td class="align-middle">
                                                  <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                                                    Edit
                                                  </a>
                                                </td>
                                              </tr>
                                            <tr>
                                                <!--<td><%= rs3.getString(1) %></td>-->
                                              
                                            </tr>
                                        <% }
                                        rs3.close();
                                        st3.close();
                                        cn3.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } %>
                    
<!--                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-3.jpg" class="avatar avatar-sm me-3" alt="user2">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Alexa Liras</h6>
                            <p class="text-xs text-secondary mb-0">alexa@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programator</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">11/01/19</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-4.jpg" class="avatar avatar-sm me-3" alt="user3">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Laurent Perrier</h6>
                            <p class="text-xs text-secondary mb-0">laurent@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Executive</p>
                        <p class="text-xs text-secondary mb-0">Projects</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-success">Online</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">19/09/17</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-3.jpg" class="avatar avatar-sm me-3" alt="user4">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Michael Levi</h6>
                            <p class="text-xs text-secondary mb-0">michael@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programator</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-success">Online</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">24/12/08</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user5">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Richard Gran</h6>
                            <p class="text-xs text-secondary mb-0">richard@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Manager</p>
                        <p class="text-xs text-secondary mb-0">Executive</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">04/10/21</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-4.jpg" class="avatar avatar-sm me-3" alt="user6">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Miriam Eric</h6>
                            <p class="text-xs text-secondary mb-0">miriam@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programtor</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">14/09/20</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>-->
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
        <!--INICIO TABLA CONTACTOS-->
<!--      <div class="row">
        <div class="col-12">
          <div class="card mb-4">
            <div class="card-header pb-0">
              <h6>Authors table</h6>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                <table class="table align-items-center mb-0">
                  <thead>
                    <tr>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Author</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Function</th>
                      <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Status</th>
                      <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Employed</th>
                      <th class="text-secondary opacity-7"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user1">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">John Michael</h6>
                            <p class="text-xs text-secondary mb-0">john@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Manager</p>
                        <p class="text-xs text-secondary mb-0">Organization</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-success">Online</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">23/04/18</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-3.jpg" class="avatar avatar-sm me-3" alt="user2">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Alexa Liras</h6>
                            <p class="text-xs text-secondary mb-0">alexa@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programator</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">11/01/19</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-4.jpg" class="avatar avatar-sm me-3" alt="user3">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Laurent Perrier</h6>
                            <p class="text-xs text-secondary mb-0">laurent@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Executive</p>
                        <p class="text-xs text-secondary mb-0">Projects</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-success">Online</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">19/09/17</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-3.jpg" class="avatar avatar-sm me-3" alt="user4">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Michael Levi</h6>
                            <p class="text-xs text-secondary mb-0">michael@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programator</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-success">Online</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">24/12/08</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user5">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Richard Gran</h6>
                            <p class="text-xs text-secondary mb-0">richard@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Manager</p>
                        <p class="text-xs text-secondary mb-0">Executive</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">04/10/21</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <div class="d-flex px-2 py-1">
                          <div>
                            <img src="../assets/img/team-4.jpg" class="avatar avatar-sm me-3" alt="user6">
                          </div>
                          <div class="d-flex flex-column justify-content-center">
                            <h6 class="mb-0 text-sm">Miriam Eric</h6>
                            <p class="text-xs text-secondary mb-0">miriam@creative-tim.com</p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-xs font-weight-bold mb-0">Programtor</p>
                        <p class="text-xs text-secondary mb-0">Developer</p>
                      </td>
                      <td class="align-middle text-center text-sm">
                        <span class="badge badge-sm bg-gradient-secondary">Offline</span>
                      </td>
                      <td class="align-middle text-center">
                        <span class="text-secondary text-xs font-weight-bold">14/09/20</span>
                      </td>
                      <td class="align-middle">
                        <a href="javascript:;" class="text-secondary font-weight-bold text-xs" data-toggle="tooltip" data-original-title="Edit user">
                          Edit
                        </a>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>-->
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
