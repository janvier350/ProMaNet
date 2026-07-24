<%-- 
    Document   : Perfil
    Created on : 19 ene 2024, 10:17:16
    Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"
        import=" java.util.Date"
        %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String email = (String) session.getAttribute("email");
     String telefono = (String) session.getAttribute("telefono");
     
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    
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
             
         String soporte = request.getParameter("soporte");
         String fecha = request.getParameter("fecha");
         String prioridad = request.getParameter("prioridad");
         String estado = request.getParameter("estado");
         String idSolicitud = request.getParameter("idSolicitud");
         String apellidosUsuario = request.getParameter("apellidosUsuario");
         String nombresUsuario = request.getParameter("nombresUsuario");
         

        
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>ProMaNet - Perfil </title>
        
        <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>

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
  
     
    </head>
    
    <% String sql =""; 
String imagen =""; String marca =""; String modelo =""; String serial =""; 
String fechacompra =""; String  observaciones=""; String procesador =""; String  ram =""; String ubicacionoficina =""; String fechaasignacion = ""; String hdd = ""; String idinvequipo = "";
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);               
                   sql = "select a.fichero,a.marca,a.modelo,a.serial,  a.fechacompra, a.observaciones, a.procesador,a.ram, a.ubicacionoficina, b.fechaasignacion, a.hdd, a.idinvequipo from inv_equipos a left join inv_asignacion b on a.idinvequipo = b.idinvequipo where b.idusuario = "+codigo+" and b.estado = 'A'";
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                imagen=rs.getString(1);
                marca=rs.getString(2);
                modelo=rs.getString(3);
                serial=rs.getString(4);
                fechacompra=rs.getString(5);
                observaciones=rs.getString(6);
                procesador=rs.getString(7);
                ram=rs.getString(8);
                ubicacionoficina=rs.getString(9);
                fechaasignacion= rs.getString(10);
                hdd= rs.getString(11);
                idinvequipo = rs.getString(12);
              } rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>
    <body class="g-sidenav-show bg-gray-100">
  <div class="position-absolute w-100 min-height-300 top-0" style="background-image: url('https://raw.githubusercontent.com/creativetimofficial/public-assets/master/argon-dashboard-pro/assets/img/profile-layout-header.jpg'); background-position-y: 50%;">
    <span class="mask bg-primary opacity-6"></span>
  </div>
  <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
    <div class="sidenav-header">
      <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
      <a class="navbar-brand m-0" href="../Proyectos/PRO_Dashboard.jsp " target="_blank">
          <img src="../assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
        <span class="ms-1 font-weight-bold">ProMaNet</span>
      </a>
    </div>
    <hr class="horizontal dark mt-0">
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
             <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
            
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
    <div class="sidenav-footer mx-3 ">
      <div class="card card-plain shadow-none" id="sidenavCard">
        <img class="w-50 mx-auto" src="../assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
        <div class="card-body text-center p-3 w-100 pt-0">
          <div class="docs-info">
            <h6 class="mb-0">Need help?</h6>
            <p class="text-xs font-weight-bold mb-0">Please check our docs</p>
          </div>
        </div>
      </div>
      <a href="https://www.creative-tim.com/learning-lab/bootstrap/license/argon-dashboard" target="_blank" class="btn btn-dark btn-sm w-100 mb-3">Documentation</a>
      <a class="btn btn-primary btn-sm mb-0 w-100" href="https://www.creative-tim.com/product/argon-dashboard-pro?ref=sidebarfree" type="button">Upgrade to pro</a>
    </div>
  </aside>
  <div class="main-content position-relative max-height-vh-100 h-100">
    <!-- Navbar -->
    <nav class="navbar navbar-main navbar-expand-lg bg-transparent shadow-none position-absolute px-4 w-100 z-index-2 mt-n11">
      <div class="container-fluid py-1">
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 ps-2 me-sm-6 me-5">
            <li class="breadcrumb-item text-sm"><a class="text-white opacity-5" href="javascript:;">Pages</a></li>
            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Profile</li>
          </ol>
          <h6 class="text-white font-weight-bolder ms-2">Profile</h6>
        </nav>
        <div class="collapse navbar-collapse me-md-0 me-sm-4 mt-sm-0 mt-2" id="navbar">
          <div class="ms-md-auto pe-md-3 d-flex align-items-center">
            <div class="input-group">
              <span class="input-group-text text-body"><i class="fas fa-search" aria-hidden="true"></i></span>
              <input type="text" class="form-control" placeholder="Type here...">
            </div>
          </div>
          <ul class="navbar-nav justify-content-end">
            <li class="nav-item d-flex align-items-center">
              <a href="javascript:;" class="nav-link text-white font-weight-bold px-0">
                <i class="fa fa-user me-sm-1"></i>
                <span class="d-sm-inline d-none">Sign In</span>
              </a>
            </li>
            <li class="nav-item ps-3 pe-0 d-flex align-items-center">
              <a href="javascript:;" class="nav-link text-white p-0">
                <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                  <div class="sidenav-toggler-inner">
                    <i class="sidenav-toggler-line bg-white"></i>
                    <i class="sidenav-toggler-line bg-white"></i>
                    <i class="sidenav-toggler-line bg-white"></i>
                  </div>
                </a>
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
              <ul class="dropdown-menu dropdown-menu-end px-2 py-3 ms-n4" aria-labelledby="dropdownMenuButton">
                <li class="mb-2">
                  <a class="dropdown-item border-radius-md" href="javascript:;">
                    <div class="d-flex py-1">
                      <div class="my-auto">
                        <img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3">
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
                        <img src="../assets/img/small-logos/logo-spotify.svg" class="avatar avatar-sm bg-gradient-dark me-3">
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
                      <div class="avatar avatar-sm bg-gradient-secondary me-3 my-auto">
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
    <div class="card shadow-lg mx-4 card-profile-bottom">
      <div class="card-body p-3">
        <div class="row gx-4">
          <div class="col-auto">
            <div class="avatar avatar-xl position-relative">
                <img src="../assets/img/Ejecutivo.jpg" alt="profile_image" class="w-100 border-radius-lg shadow-sm">
            </div>
          </div>
          <div class="col-auto my-auto">
            <div class="h-100">
              <h5 class="mb-1">
                <%=nombre%> <%=apellidos%>
              </h5>
              <p class="mb-0 font-weight-bold text-sm">
                  <%=ubicacionoficina%>
              </p>
            </div>
          </div>
          <div class="col-lg-4 col-md-6 my-sm-auto ms-sm-auto me-sm-0 mx-auto mt-3">
            <div class="nav-wrapper position-relative end-0">
              <ul class="nav nav-pills nav-fill p-1" role="tablist">
                <li class="nav-item">
                    <a href="../Control/ADM_Atrasos.jsp" class="nav-link mb-0 px-0 py-1 active d-flex align-items-center justify-content-center " aria-selected="true">
                    <i class="ni ni-time-alarm"></i>
                    <span class="ms-2">Atrasos</span>
                  </a>
                </li>
                <li class="nav-item">
                  <a class="nav-link mb-0 px-0 py-1 d-flex align-items-center justify-content-center " data-bs-toggle="tab" href="javascript:;" role="tab" aria-selected="false">
                    <i class="ni ni-email-83"></i>
                    <span class="ms-2">Messages</span>
                  </a>
                </li>
                <li class="nav-item">
                  <a class="nav-link mb-0 px-0 py-1 d-flex align-items-center justify-content-center " data-bs-toggle="tab" href="javascript:;" role="tab" aria-selected="false">
                    <i class="ni ni-settings-gear-65"></i>
                    <span class="ms-2">Settings</span>
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="container-fluid py-4">
      <div class="row">
        <div class="col-md-8">
          <div class="card">
            <div class="card-header pb-0">
              <div class="d-flex align-items-center">
                <p class="mb-0">Editar Solicitud de soporte</p>
                <!--<button class="btn btn-primary btn-sm ms-auto">Settings</button>-->
              </div>
            </div>
            <div class="card-body">
              <p class="text-uppercase text-sm">Información solicitud</p>
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Fecha solicitud</label>
                    <input class="form-control" type="text" value="<%=fecha%>" disabled="true">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label"> Estado</label>
                    <input class="form-control" type="email" value="<%=estado%>" disabled="true">
                  </div>
                </div>
                  <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Apellidos</label>
                    <input class="form-control" type="text" value="<%=apellidosUsuario%>" disabled="true">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label"> Nombres</label>
                    <input class="form-control" type="text" value="<%=nombresUsuario%>" disabled="true">
                  </div>
                </div>
                  
                  <form action="../SOP_EditarSolicitud" method="POST">
                  <div class="row">
                         <div class="col-md-12">
                             <div class="form-group">
                                <i class="ni education_hat mr-2"></i><b>Solicitar soporte: </b> 
                                <div class="input-group mb-3">
                                     
                       <% if(COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL")){%>
                       <textarea  type="form-control"  name="soporteEditar" class="form-control" disabled="true" placeholder="Detalle su solicitud de soporte tecnico."><%=soporte %> </textarea>
                      <%  }else{
                  %>
                    <textarea  type="form-control"  name="soporteEditar" class="form-control" placeholder="Detalle su solicitud de soporte tecnico."><%=soporte %> </textarea>
                            <%}%>          
                                </div>
                      </div>
                      </div>
                 </div>
                  <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                 <label>Prioridad: </label>
                                <div class="input-group mb-3">
                                    <select class="chosen-select form-control" id="prioridadEditar" name ="prioridadEditar">
                                        <option value="<%=prioridad%>"><%=prioridad %></option>  
                                      <option value="Alta">Alta</option>                                                 
                                     <option value="Media">Media</option> 
                                         <option value="Baja">Baja</option> 
                                          
                                </select>
                  </div>
          <p><em><strong>Alta:</strong> Equipo constantemente inestable imposible continuar mis actividades laborales.</em></p>
          <p><em><strong>Media: </strong>Equipo funciona pero ciertas ocaciones presenta el problema. Programar una fecha de atención.</em></p>
          <p><em><strong>Baja: </strong>Equipo funciona pero si puedo continuar con mis actividades laborales.</em></p>
         <input type="hidden" name="idSolicitud" value="<%=idSolicitud%>">
<!--        <label for="apellidos" class="form-control-label">Apellidos</label>
        <input class="form-control" type="text" placeholder="Apellidos completos y bien escritos (datos de la cédula)" name="apellidos" required="true">-->
                </div>
              </div>
                    </div>
                            
                          <% if(COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL")){%>


                          <%}else{%>
                                        <div class="modal-footer">
                                            <button type="#" class="btn btn-info"  href="">
                                                 <a class="nav-link " href="../Soportes/SOP_ListaSolicitudes.jsp">
                                                     <i class="fa fa-eye" aria-hidden="true">  </i>    ver todas las solicitudes </a>
                                             </button>
                                           <button type="submit" class="btn btn-success" >
                                               <i class="fa fa-save" aria-hidden="true">  </i>  Guardar Cambios 
                                             </button>
                                        </div>
                                   <% }%>
                                      
                                       
                                      </form>
<!--                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Nombres</label>
                    <input class="form-control" type="text" value="<%=nombre%>" disabled="true">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Apellidos</label>
                    <input class="form-control" type="text" value="<%=apellidos%>" disabled="true">
                  </div>
                </div>-->
                 
                  <hr class="horizontal dark">
                  <% if(COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL")){%>
                  <form action="../InsertReporteTecnico" method="POST">
                      <div class="row">
                         <div class="col-md-12">
                             <div class="form-group">
                                <i class="ni education_hat mr-2"></i><b>Reporte Técnico: </b> 
                                <input type="hidden" name="idSolicitudTicket" value="<%=idSolicitud %>">
                                <div class="input-group mb-3">
                                        <textarea  type="form-control"  name="reporte" class="form-control" placeholder="Detalle su reporte."> </textarea>
                                </div>
                      </div>
                      </div>
                                <div class="modal-footer">
                        
                        <button type="submit" class="btn btn-warning" >
                            <i class="fa fa-save" aria-hidden="true">  </i>  Registrar reporte 
                          </button>
                      </div>
                 </div>
                      
                  </form>
                
                         
                  
                    <%  }
                  %>
                  
                  
              </div>
              <hr class="horizontal dark">
              <!--<p class="text-uppercase text-sm">Contact Information</p>-->
<!--              <div class="row">
                <div class="col-md-12">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Address</label>
                    <input class="form-control" type="text" value="Bld Mihail Kogalniceanu, nr. 8 Bl 1, Sc 1, Ap 09">
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">City</label>
                    <input class="form-control" type="text" value="New York">
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Country</label>
                    <input class="form-control" type="text" value="United States">
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Postal code</label>
                    <input class="form-control" type="text" value="437300">
                  </div>
                </div>
              </div>-->
              <!--<hr class="horizontal dark">-->
              <!--<p class="text-uppercase text-sm">About me</p>-->
<!--              <div class="row">
                <div class="col-md-12">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">About me</label>
                    <input class="form-control" type="text" value="A beautiful Dashboard for Bootstrap 5. It is Free and Open Source.">
                  </div>
                </div>
              </div>-->
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card card-profile">
              <img src="../assets/img/bg1.jpg" alt="Image placeholder" class="card-img-top">
            <div class="row justify-content-center">
              <div class="col-4 col-lg-4 order-lg-2">
                <div class="mt-n4 mt-lg-n6 mb-4 mb-lg-0">
                  <a href="javascript:;">
                      <img src="../assets/img/08.jpg" class="rounded-circle img-fluid border border-2 border-white">
                  </a>
                </div>
              </div>
            </div>
            <div class="card-header text-center border-0 pt-0 pt-lg-2 pb-4 pb-lg-3">
              <div class="d-flex justify-content-between">
                <a href="javascript:;" class="btn btn-sm btn-info mb-0 d-none d-lg-block">Solicitar</a>
                <a href="javascript:;" class="btn btn-sm btn-info mb-0 d-block d-lg-none"><i class="ni ni-collection"></i></a>
                <a href="javascript:;" class="btn btn-sm btn-dark float-right mb-0 d-none d-lg-block">Reportar</a>
                <a href="javascript:;" class="btn btn-sm btn-dark float-right mb-0 d-block d-lg-none"><i class="ni ni-email-83"></i></a>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row">
                <div class="col">
                  <div class="d-flex justify-content-center">
                    <div class="d-grid text-center">
                      <span class="text-lg font-weight-bolder"><%=ram%></span>
                      <span class="text-sm opacity-8">RAM</span>
                    </div>
                    <div class="d-grid text-center mx-4">
                      <span class="text-lg font-weight-bolder"> <%=procesador%></span>
                      <span class="text-sm opacity-8">PROCESADOR</span>
                    </div>
                    <div class="d-grid text-center">
                      <span class="text-lg font-weight-bolder"><%=hdd%></span>
                      <span class="text-sm opacity-8">DISCO DURO</span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="text-center mt-4">
                  <h5>
                  Marca :<span class="font-weight-light"><%=marca%></span>
                </h5>
                <h5>
                  Modelo :<span class="font-weight-light"><%=modelo%></span>
                </h5>
                <div class="h6 font-weight-300">
                  <i class="ni location_pin mr-2"></i>Serial: <%=serial%>
                </div>
                <div class="h6 mt-4">
                  <i class="ni business_briefcase-24 mr-2"></i>Fecha Compra - <%=fechacompra%>
                </div>
                <div class="h6 mt-4">
                  <i class="ni business_briefcase-24 mr-2"></i>Fecha Asignación - <%=fechaasignacion%>
                </div>
                
                <div>
                    <i class="ni education_hat mr-2"></i><b>Observaciones: </b>  - <%=observaciones%>
                </div>
                <br>
                 <hr class="horizontal dark">
                <form action="../insertSoporte" method="POST">
                    <div>
                        <i class="ni education_hat mr-2"></i><b>Solicitar soporte: </b> 
                        <p><em>Tu equipo asigando presenta muchos problemas!! , entoces solicita un soporte al departamento de IT.</em></p>
                    
                </div>
                    
                        
                
                    <div class="row">
   
    <div class="col-md-12">
      <div class="form-group">
       
                    <div class="col-lg-12">
                        
                        <textarea  type="text"  name="soporte" class="form-control" placeholder="Detalle su solicitud de soporte tecnico."></textarea>
                    </div>
      </div>
    </div>
  </div>
                     <hr class="horizontal dark">
                    <div class="row">
                        <div class="col-md-12">
      <div class="form-group">
           <label>Prioridad: </label>
                  <div class="input-group mb-3">
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="prioridad" name ="prioridad">
                                   
                                      <option value="Alta">Alta</option>                                                 
                                     <option value="Media">Media</option> 
                                         <option value="Baja">Baja</option> 
                                          
                                </select>
                  </div>
          <p><em><strong>Alta:</strong> Equipo constantemente inestable imposible continuar mis actividades laborales.</em></p>
          <p><em><strong>Media: </strong>Equipo funciona pero ciertas ocaciones presenta el problema. Programar una fecha de atención.</em></p>
          <p><em><strong>Baja: </strong>Equipo funciona pero si puedo continuar con mis actividades laborales.</em></p>
         
<!--        <label for="apellidos" class="form-control-label">Apellidos</label>
        <input class="form-control" type="text" placeholder="Apellidos completos y bien escritos (datos de la cédula)" name="apellidos" required="true">-->
                </div>
              </div>
                    </div>
                     <div>
                       
                     </div>
                    <div class="modal-footer">
                        
                         <button type="#" class="btn btn-info"  href="">
                              <a class="nav-link " href="../Soportes/SOP_ListaSolicitudes.jsp">
                                  
                                  <i class="fa fa-eye" aria-hidden="true">  </i>    ver todas las solicitudes </a>
                          </button>
                        <button type="submit" class="btn btn-success" >
                            <i class="fa fa-save" aria-hidden="true">  </i>    Enviar Solicitud 
                          </button>
                      </div>
                </form>
                
              </div>
            </div>
          </div>
        </div>
      </div>
      <footer class="footer pt-3  ">
        <div class="container-fluid">
          <div class="row align-items-center justify-content-lg-between">
            <div class="col-lg-6 mb-lg-0 mb-4">
              <div class="copyright text-center text-sm text-muted text-lg-start">
                 Overclocking
                ©,
                Creado por  <i class="fa fa-clock"></i> by
                <a href="https://www.overclocking.com.ec" class="font-weight-bold" target="_blank">Javier </a>
               Varas
              </div>
            </div>
            <div class="col-lg-6">
              <ul class="nav nav-footer justify-content-center justify-content-lg-end">
                <li class="nav-item">
                  <a href="../Home.jsp" class="nav-link text-muted" target="_blank">ProMaNet 2023  -  versión 2.0 </a>
                </li>
                <li class="nav-item">
                  <a href="#" class="nav-link text-muted" target="_blank">Reporte de Gastos</a>
                </li>
                <li class="nav-item">
                  <a href="#" class="nav-link text-muted" target="_blank">Blog</a>
                </li>
                <li class="nav-item">
                  <a href="#" class="nav-link pe-0 text-muted" target="_blank">License</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </footer>
    </div>
  </div>
  <div class="fixed-plugin">
    <a class="fixed-plugin-button text-dark position-fixed px-3 py-2">
      <i class="fa fa-cog py-2"> </i>
    </a>
    <div class="card shadow-lg">
      <div class="card-header pb-0 pt-3 ">
        <div class="float-start">
          <h5 class="mt-3 mb-0">Argon Configurator</h5>
          <p>See our dashboard options.</p>
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
