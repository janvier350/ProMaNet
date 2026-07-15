<%-- 
    Document   : PRO_Lista
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
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String depart = "";
    
    
    String totalAtrasos = "";
    
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if(COMUN.PermisoHelper.tiene(session, "SOPORTES_ACCESO")){
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
          ProMaNet | Lista Tickets
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
    </head>
   <body class="g-sidenav-show   bg-gray-100">
  <div class="min-height-300 bg-primary position-absolute w-100"></div>
  <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
    <div class="sidenav-header">
      <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
      <a class="navbar-brand m-0" href=" #" target="_blank">
        <img src="../assets/img/logo-ct-dark.png" class="navbar-brand-img h-100" alt="main_logo">
        <span class="ms-1 font-weight-bold">Listado de Proyectos </span>
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
          <a class="nav-link " href="../Proyectos/PRO_Lista.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Lista de proyectos</span>
          </a>
        </li>
<!--        <li class="nav-item">
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
              ni ni-single-copy-04
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
        </li>-->
        <li class="nav-item">
          <a class="nav-link " href="../Proyectos/Recursos.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-archive-2 text-dark text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Recursos</span>
          </a>
        </li>
<!--        <li class="nav-item">
          <a class="nav-link " href="../ReporteGastosIndividual.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-books text-danger text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Reporte de Gastos</span>
          </a>
        </li>-->
        
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
            
             
                  <%}%>
            
<!--            <a class="nav-link " href="../cerrar.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-button-power text-dark text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Cerrar sesión</span>
          </a>-->
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
            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Proyectos</a></li>
            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Contactos</li>
          </ol>
          <h6 class="font-weight-bolder text-white mb-0"></h6>
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
                <span class="d-sm-inline d-none"> 
                   <b> <%=nombre%> <%=apellidos%> </b>  </span>
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
    <div class="container-fluid py-4">
        <div class="row">
        <div class="col-12">
          <div class="card mb-4">
              <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn4 = DriverManager.getConnection(url, user, pass);
     
         String todos = "select count(*) from rep_biom_atraso where id_usuario = "+codigo+" and estado = 'A' ";

        PreparedStatement st4 = cn4.prepareStatement(todos);
        ResultSet rs4 = st4.executeQuery();       
    while (rs4.next()) {
    totalAtrasos = rs4.getString(1);
        }
            rs4.close();
            st4.close();
            cn4.close();
        }catch(Exception e){
             e.printStackTrace();}   

    %>
 
            <div class="card-header pb-0">
              <h6>Pendientes  </h6>
              <!--<p class="text-danger"> <b>Tienes <%= totalAtrasos%> atrasos en el mes.</b></p>-->
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                  
                <table class="table align-items-center justify-content-center mb-0"> 
                  <thead>
                    <tr>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Solicitud</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Ejecutivo</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Equipo Asigando</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Soporte</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Prioridad</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Estado</th>
                      
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2">Funcion</th>
<!--                       <th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2"></th>-->
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                        <% String sqlAtrasos =""; 
                                
                            try{
                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                              Connection cna = DriverManager.getConnection(url, user, pass);               
                                  sqlAtrasos = "select  a.fecha_solicitud, b.marca, b.modelo,b.fechacompra, a.soporte, a.prioridad, a.estado, a.idsoporte, c.apellidos, c.nombre from sop_soporte_cab a , inv_equipos b, usuario c where a.idequipo = b.idinvequipo and a.estado = 'PENDIENTE' and a.idusuario = c.idusuario order by 1 desc";


                              PreparedStatement sta = cna.prepareStatement(sqlAtrasos);
                              ResultSet rsa = sta.executeQuery();       
                           while (rsa.next()) {
//                           totalAtrasos = totalAtrasos + 1;
                               %>
                    <tr>
                  
                        <td>
                        <div class="d-flex px-2">
                          <div>
                              <img src="../assets/img/small-logos/Atraso3.svg" class="avatar avatar-sm rounded-circle me-2" alt="spotify">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm"><%=rsa.getString(1)%> </h6>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(9)%> </p>
                         <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(10)%> </p>
                          <!--<p class="text-sm font-weight-bold mb-0"><%=rsa.getString(4)%> </p>-->
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(2)%> </p>
                         <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(3)%> </p>
                          <!--<p class="text-sm font-weight-bold mb-0"><%=rsa.getString(4)%> </p>-->
                      </td>
                       <td style="max-width: 300px;">
    <div class="d-flex flex-column justify-content-center" style="width: 100%;">
        <p class="text-xs font-weight-bold mb-0" style="max-width: 100%; word-break: break-word; white-space: normal;">
            <%=rsa.getString(5)%>
        </p>
        <p class="text-xs text-secondary mb-0" style="max-width: 100%; word-break: break-word; white-space: normal;"></p>
    </div>
</td>
<!--                      <td>
                        <span class="text-xs font-weight-bold"><%=rsa.getString(5)%></span>
                      </td>-->
                      <td>
                        <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(6)%> </p>
                      </td>
                       <td>
                        <p class="text-sm font-weight-bold mb-0"><%=rsa.getString(7)%> </p>
                       
                      </td>
                      
<!--                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold"> </span>
                          <div>
                            <div >
                              <div ><%=totalAtrasos%></div>
                            </div>
                          </div>
                        </div>
                         </td>-->
                  <% if(COMUN.PermisoHelper.tiene(session, "SOPORTES_ACCESO")){%>
                      <td class="align-middle">
                        <a href ="../Soportes/SOP_EditarSolicitudes.jsp?idSolicitud=<%= rsa.getString(8)%>&fecha=<%= rsa.getString(1)%>&soporte=<%= rsa.getString(5)%>&prioridad=<%= rsa.getString(6)%>&estado=<%= rsa.getString(7)%>" class="btn btn-sm btn-warning mb-0 d-none d-lg-block "> Atender</a>
                      </td>
                      <%}%>
<!--                      <td class="align-middle">
                        <a href ="../SOP_EliminarSolicitud?idSolicitud=<%= rsa.getString(8)%>" class="btn btn-sm btn-danger mb-0 d-none d-lg-block "> Eliminar</a>
                      </td>-->
                    </tr>
                <%
              } rsa.close();
            sta.close();
            cna.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>
                  
                  </tbody>
                </table>
              </div>
            </div>
          <hr class="horizontal dark">
         <div class="card-header pb-0">
              <h6>Atendidos  </h6>
              <!--<p class="text-danger"> <b>Tienes <%= totalAtrasos%> atrasos en el mes.</b></p>-->
            </div>
         
         <style>
  .text-wrap {
    /*max-width: 100px;  Ajusta este valor según sea necesario */
    word-wrap: break-word;
    word-break: break-word;
    white-space: normal;
  }
</style>

<div class="card-body px-0 pt-0 pb-2">
  <div class="table-responsive p-0">
    <table class="table align-items-center justify-content-center mb-0">
      <thead>
        <tr>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Solicitud</th>
          <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Ejecutivo</th>-->
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Equipo Asigando</th>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Soporte</th>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Prioridad</th>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Estado</th>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Reporte</th>
          <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Fecha Atendido</th>
          <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Técnico</th>-->
          <th></th>
        </tr>
      </thead>
      <tbody>
        <% 
          try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cna5 = DriverManager.getConnection(url, user, pass);               
            String sqlAtrasos1 = "select a.fecha_solicitud, b.marca, b.modelo, b.fechacompra, a.soporte, a.prioridad, a.estado, a.idsoporte, a.reporte, a.fecha_reporte, c.apellidos, c.nombre, a.tecnico from sop_soporte_cab a, inv_equipos b, usuario c where a.idequipo = b.idinvequipo and a.estado = 'ATENDIDO' and a.idusuario = c.idusuario order by 1 desc";
            PreparedStatement sta5 = cna5.prepareStatement(sqlAtrasos1);
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
                <h6 class="mb-0 text-sm"><%=rsa5.getString(1)%> </h6>
                <p class="text-sm font-weight-bold mb-0 text-warning "><%=rsa5.getString(11)%> </p>
            <p class="text-sm font-weight-bold mb-0 text-warning "><%=rsa5.getString(12)%> </p>
              </div>
            </div>
          </td>
<!--          <td>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(11)%> </p>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(12)%> </p>
          </td>-->
          <td>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(2)%> </p>
            <p class="text-sm font-weight mb-0"><%=rsa5.getString(3)%> </p>
          </td>
          <td class="text-wrap">
            <p class="text-xs font-weight-bold mb-0"><%=rsa5.getString(5)%></p>
          </td>
          <td>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(6)%> </p>
          </td>
          <td>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(7)%> </p>
          </td>
          <td class="text-wrap">
            <p class="text-xs font-weight-bold mb-0"><%=rsa5.getString(9)%></p>
          </td>
          <td>
            <p class="text-sm font-weight-bold mb-0"><%=rsa5.getString(10)%> </p>
              <p class="text-sm font-weight-bold mb-0 text-danger "  ><%=rsa5.getString(13)%> </p>
          </td>
          <td>
            <p class="text-sm font-weight-bold mb-0"> </p>
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
      </tbody>
    </table>
  </div>
</div>

          </div>
        </div>
      </div>

      <footer>
          <h1 class="text-danger"><%=totalAtrasos%></h1>
          <p>Total de solicitudes</p>
      </footer>
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
</body>
</html>
