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
             if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
                }else{
                    response.sendRedirect("../sesionInvalida.jsp");
                    return;
             }
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
  
                <link rel="stylesheet" href="css/chosen.css">
          
    </head>
    
    <% String sql =""; 
String imagen =""; String marca =""; String modelo =""; String serial =""; 
String fechacompra =""; String  observaciones=""; String procesador =""; String  ram =""; String ubicacionoficina =""; String fechaasignacion = ""; String hdd = "";
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);               
                   sql = "select a.fichero,a.marca,a.modelo,a.serial,  a.fechacompra, a.observaciones, a.procesador,a.ram, a.ubicacionoficina, b.fechaasignacion, a.hdd from inv_equipos a left join inv_asignacion b on a.idinvequipo = b.idinvequipo where b.idusuario = "+codigo+" and b.estado = 'A'";
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
            <li class="nav-item d-xl-none ps-3 pe-0 d-flex align-items-center">
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
                <%--<%=nombre%> <%=apellidos%>--%>
                Solicitud de nuevo Ejecutivo
              </h5>
              <p class="mb-0 font-weight-bold text-sm">
                  <%--<%=ubicacionoficina%>--%>
                  
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
                <p class="mb-0">.</p>
               
                
              </div>
                
                <div class="row">
    <div class="col-md-6">
      <div class="form-group">
          <p class="mb-0"></p>
          <p class="mb-0">Datos personales</p>
<!--        <label for="nombres" class="form-control-label">Nombres</label>
        <input class="form-control" type="text" placeholder="Nombres completos y bien escritos (datos de la cédula)" name="nombres" required="true">-->
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="apellidos" class="form-control-label"></label>
        <!--<input class="form-control" type="text" placeholder="Apellidos completos y bien escritos (datos de la cédula)" name="apellidos" required="true">-->
          <a href="https://www.youtube.com/watch?v=7ARvES8eon4" target="blank " >  <button type="button" class="btn bg-gradient-danger mb-0"  >    Tutorial: Nuevo Ejecutivo </button></i> </a>
      </div>
        
        
    </div>
  </div>
                
            </div>
            <div class="card-body">
              <p class="text-uppercase text-sm">Información del Ejecutivo</p>
              <div class="row">
                  
<!--                   <form action="../NuevoEjecutivo.jsp" method="post">     
                 
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Día de ingreso</label>
                    <input class="form-control" type="date" id="fechaIngreso">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Compañía </label>
                    <input class="form-control" type="text" placeholder="Compañía en la que registramos en reporte de gastos" id="compania">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Nombres</label>
                    <input class="form-control" type="text" placeholder="Nombres y apellidos completos y bien escritos (datos de la cédula)"id="nombres">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Apellidos</label>
                    <input class="form-control" type="text" placeholder="Nombres y apellidos completos y bien escritos (datos de la cédula)" id="apellidos">
                  </div>
                </div>
                  <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Rol</label>
                    <input class="form-control" type="text" id="rol" >
                  </div>
                </div>
                   <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Jefe Inmediato</label>
                    <input class="form-control" type="text" id="jefeInmediato" >
                  </div>
                </div>
                   <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Acitivades a realizar</label>
                    <input class="form-control" type="text" placeholder="Actividad (para registrar en la firma de correo):" id="actividades" >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="example-text-input" class="form-control-label">Detallar si el ejecutivo va estar en cliente o en alguna de las oficinas</label>
                    <input class="form-control" type="text" id="ubicacion" >
                  </div>
                </div>

                  <hr class="horizontal dark">
                  <p class="text-uppercase text-sm">Cambiar Contraseña</p>
                  
                      

                   <div class="form-group">
                <button type="submit"  class="btn btn-success">
                <i class="fa fa-save" aria-hidden="true"></i>  GUARDAR CONTRASEÑA</button>
            </div>

                 
        
        </form>-->
                  <form action="../NuevoEjecutivo.jsp" method="post">
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="fechaIngreso" class="form-control-label">Día de ingreso</label>
        <input class="form-control" type="date" name="fechaIngreso" required="true">
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="compania" class="form-control-label">Compañía - Correo</label>
       
        <div class="form-group">
    <select class="chosen-select form-control" id="compania" name="compania" required>
        <option value="" disabled selected>Seleccione</option>
        <%
            try {
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn4 = DriverManager.getConnection(url, user, pass);
                String empresa = "SELECT * FROM compania WHERE estado = 'a' ORDER BY 2";
                PreparedStatement st4 = cn4.prepareStatement(empresa);
                ResultSet rs4 = st4.executeQuery();       
                while (rs4.next()) {
        %>                                                                    
        <option value="<%=rs4.getString(3)%>"><%=rs4.getString(3)%></option>
        <%
                }     
                rs4.close();
                st4.close();
                cn4.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>       
    </select>
</div>

<script>
    document.querySelector("form").addEventListener("submit", function(event) {
        let compania = document.getElementById("compania");
        if (compania.value === "") {
            alert("Por favor, seleccione una compañía válida.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
</script>

      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="nombres" class="form-control-label">Nombres</label>
        <input class="form-control" type="text" placeholder="Nombres completos y bien escritos (datos de la cédula)" name="nombres" required="true">
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="apellidos" class="form-control-label">Apellidos</label>
        <input class="form-control" type="text" placeholder="Apellidos completos y bien escritos (datos de la cédula)" name="apellidos" required="true">
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="rol" class="form-control-label">Rol</label>
        <div class="form-group">
                                  
                                    <div class="form-group">
                                        <select class="chosen-select form-control" id="rol" name ="rol" required="true" >
                                                       
                                                         <option value="" disabled selected>Seleccione</option>
                                                        <%
                                                            try{
                                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                            Connection   cn2 = DriverManager.getConnection(url, user, pass);
                                                            String rol = "select * from rol where estado = 'a'  order by 2";
                                                            PreparedStatement st2 = cn2.prepareStatement(rol);
                                                            ResultSet rs2 = st2.executeQuery();       
                                                            while (rs2.next()) {
                                                            %>                                                                    
                                                            <option value="<%=rs2.getString(2)%>"><%=rs2.getString(2)%> </option>
                                                            <%
                                                                }     
                                                                rs2.close();
                                                                st2.close();
                                                                cn2.close();
                                                            }catch(Exception e){
                                                                 e.printStackTrace();
                                                            }

                                                        %>       
                                        </select>
                                    </div>
                                        <script>
                                          
     document.querySelector("form").addEventListener("submit", function(event) {
        let rol = document.getElementById("rol");
        if (rol.value === "") {
            alert("Por favor, seleccione un rol válido.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
    
                                        </script>
                                </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="jefeInmediato" class="form-control-label">Jefe Inmediato</label>
       
        <div class="form-group">
                                   
                                    <div class="form-group">
                                                    <select class="chosen-select form-control" id="jefeInmediato" name ="jefeInmediato"  required="true">
                                                         <option value="" disabled selected>Seleccione</option>
                                                        <%
                                                            try{
                                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                            Connection   cn3 = DriverManager.getConnection(url, user, pass);
                                                            String ejecutivo = "select * from usuario where estado = 'a' and idrol in (4,5)  order by 3";
                                                            PreparedStatement st3 = cn3.prepareStatement(ejecutivo);
                                                            ResultSet rs3 = st3.executeQuery();       
                                                            while (rs3.next()) {
                                                            %>                                                                    
                                                            <option value="<%=rs3.getString(2)%> <%=rs3.getString(3)%>"><%=rs3.getString(3)%> <%=rs3.getString(2)%></option>
                                                            <%
                                                                }     
                                                                rs3.close();
                                                                st3.close();
                                                                cn3.close();
                                                            }catch(Exception e){
                                                                 e.printStackTrace();
                                                            }

                                                        %>       
                                        </select>
                                    </div>
                                        <script> 
                                         document.querySelector("form").addEventListener("submit", function(event) {
        let jefeInmediato = document.getElementById("jefeInmediato");
        if (jefeInmediato.value === "") {
            alert("Por favor, seleccione un jefe inmediato.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
    
    
                                        </script>
                                </div>
      </div>
    </div>
  </div>
                                        <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="rol" class="form-control-label">Requiere nuevo correo?</label>
        <div class="form-group">
                                  
                                    <div class="form-group">
                                        <select class="chosen-select form-control" id="nuevoCorreo" name ="nuevoCorreo" required="true" >
                                                         <option value="" disabled selected>Seleccione</option>
                                                        <option value="Correo Nuevo -  " >Si</option>
                                                        <option value="Reactivar Correo -  " >Reactivar correo</option>
                                                        <option value="Conservar Correo -  " >Conservar correo</option>
                                                        <option value="No necesita correo - " >No necesita correo</option>
                                        </select>
                                    </div>
            
            <script> 
             document.querySelector("form").addEventListener("submit", function(event) {
        let nuevoCorreo = document.getElementById("nuevoCorreo");
        if (nuevoCorreo.value === "") {
            alert("Por favor, seleccione un correo.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
    
     
            </script>
                                </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="jefeInmediato" class="form-control-label">Ubicación:</label>
       
        <div class="form-group">
                                   
                                    <div class="form-group">
                                        <select class="chosen-select form-control" id="lugar" name ="lugar" required="true" >
                                                        <option value="" disabled selected>Seleccione</option>
                                                          <option value="Kennedy 401">Kennedy 401</option>
                                                            <option value="Kennedy 403" >Kennedy 403</option>
                                                            <option value="Romería" >Romería</option>
                                                            <option value="Cliente">Cliente</option>
                                        </select>
                                    </div>
            <script>
            document.querySelector("form").addEventListener("submit", function(event) {
        let lugar = document.getElementById("lugar");
        if (lugar.value === "") {
            alert("Por favor, seleccione una opción válida.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
    
   
            </script>
                                </div>
      </div>
    </div>
  </div>
                                        
                                       
  <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="actividades" class="form-control-label">Firma de correo:</label>
        <input class="form-control" type="text" placeholder="Actividad " name="actividades" required="true" >
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
        <label for="ubicacion" class="form-control-label">Detallar si el ejecutivo va a estar en cliente o en alguna de las oficinas</label>
        <input class="form-control" type="text" name="ubicacion" placeholder="(401 - 403 - Romeria)" required="true">
      </div>
    </div>
  </div>
                                        <div class="row">
    <div class="col-md-6">
      <div class="form-group">
        <label for="rol" class="form-control-label">Requiere Kit básico de bienvenida? (Agenda, pluma, lápiz y block de notas)</label>
        <div class="form-group">
                                  
                                    <div class="form-group">
                                        <select class="chosen-select form-control" id="kit" name ="kit"  required="true">
                                                         <option value="" disabled selected>Seleccione</option>
                                                        <option value="SI" >Si</option>
                                                        <option value="NO" >No</option>
                                        </select>
                                    </div>
            <script> 
              document.querySelector("form").addEventListener("submit", function(event) {
        let kit = document.getElementById("kit");
        if (kit.value === "") {
            alert("Por favor, seleccione una opción válida.");
            event.preventDefault(); // Evita que el formulario se envíe
        }
    });
            </script>
                                </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="form-group">
<!--        <label for="jefeInmediato" class="form-control-label">Ubicación:</label>
       
        <div class="form-group">
                                   
                                    <div class="form-group">
                                                    <select class="chosen-select form-control" id="lugar" name ="lugar" >
                                                        <option >Seleccione</option>
                                                          <option value="Kennedy 401">Kennedy 401</option>
                                                            <option value="Kennedy 403" >Kennedy 403</option>
                                                            <option value="Romería" >Romería</option>
                                                            <option value="Cliente">Cliente</option>
                                        </select>
                                    </div>
                                </div>-->
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
                <i class="fa fa-envelope-o" aria-hidden="true"></i>    ENVIAR 
              </button>
          </div>
</form>

              </div>
              <hr class="horizontal dark">
              <div class="row">
        <div class="col-12">
          <div class="card mb-4">
              
 
            <div class="card-header pb-0">
              <h6>Lista ejecutivos notificados  </h6>
              
            </div>
            <div class="card-body px-0 pt-0 pb-2">
              <div class="table-responsive p-0">
                  
                <table class="table align-items-center justify-content-center mb-0"> 
                  <thead>
                    <tr>
                        <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Ingreso</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Fecha Notificación</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Solicitante</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Jefe Inmediato</th>
                      <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Estado</th>
                      <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Cancelar</th>-->
                      <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2"># Atrasos</th>-->
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                        <% String solicitudes =""; 
                                
                            try{
                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                              Connection cna1 = DriverManager.getConnection(url, user, pass);               
//                                  sqlAtrasosALL = "select a.id_usuario,c.nombre, c.apellidos ,to_char(A.fecha_notificacion, 'DD/MON/YYYY'), b.descripcion, to_char(fecha_notificacion, 'HH24:MI') from rep_biom_atraso a, reg_biom_motivo b, usuario c  where a.id_rep_biom_motivo = b.id_biom_motivo and a.id_usuario = c.idusuario and a.estado = 'A' order by 4 desc";
//                                    sqlAtrasosALL ="WITH RankedAtrasos AS ( SELECT c.apellidos,  a.id_usuario, c.nombre,TO_CHAR(a.fecha_notificacion, 'MM/YYYY') AS mes_y_anio_notificacion, b.descripcion,TO_CHAR(a.fecha_notificacion, 'HH24:MI') AS hora_notificacion, ROW_NUMBER() OVER (PARTITION BY a.id_usuario ORDER BY a.fecha_notificacion DESC) AS rn, COUNT(*) OVER (PARTITION BY a.id_usuario) AS total_atrasos FROM rep_biom_atraso a INNER JOIN reg_biom_motivo b ON a.id_rep_biom_motivo = b.id_biom_motivo INNER JOIN  usuario c ON a.id_usuario = c.idusuario WHERE a.estado = 'A' AND a.fecha_notificacion < CURRENT_TIMESTAMP) SELECT apellidos,  id_usuario, nombre,  mes_y_anio_notificacion, descripcion, hora_notificacion,total_atrasos FROM  RankedAtrasos WHERE   rn = 1 ORDER BY  mes_y_anio_notificacion DESC";
 solicitudes = "select  a.apellidos, a.nombres, TO_CHAR(a.fecha_ingreso, 'DD/MM/YYYY') ,b.nombre, b.apellidos,TO_CHAR(a.fecha_notificacion, 'DD/MM/YYYY HH24:MI') , a.compania,a.rol, a.actividades,  a.estado, a.idnotificaciones, a.jefe_inmediato, a.observaciones, a.kit_mk FROM adm_notificaciones a INNER JOIN usuario b ON a.id_usuario_solicitante = b.idusuario WHERE  a.id_usuario_solicitante = "+codigo+"  AND (a.estado = 'ATENDIDO' OR a.estado = 'PENDIENTE')";
                              PreparedStatement sta1 = cna1.prepareStatement(solicitudes);
                              ResultSet rsa1 = sta1.executeQuery();       
                           while (rsa1.next()) {
                               %>
                    <tr>
                  
                        <td>
                        <div class="d-flex px-2">
                          <div>
                              <img src="../assets/img/Ejecutivo.jpg" class="avatar avatar-sm rounded-circle me-2" alt="spotify">
                          </div>
                          <div class="my-auto">
                            <h6 class="mb-0 text-sm"><%=rsa1.getString(1)%> <%=rsa1.getString(2)%> </h6>
                            <p class="text-xs text-secondary mb-0"> <%=rsa1.getString(9)%></p>
                            <p class="text-xs text-secondary mb-0"> <%=rsa1.getString(7)%></p>
                              <p class="text-xs text-secondary mb-0"> Rol: <%=rsa1.getString(8)%></p>
                            <p class="text-xs text-secondary mb-0"> <b> <%=rsa1.getString(13)%></b></p>
                            <p class="text-xs text-danger mb-0"> <b> Kit merchandising <%=rsa1.getString(14)%></b></p>
                          </div>
                        </div>
                      </td>
                      <td>
                        <p class="text-sm font-weight-bold mb-0"><%=rsa1.getString(3)%> </p>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold"><%=rsa1.getString(6)%></span>
                      </td>
                       <td>
                        <span class="text-xs font-weight-bold"><%=rsa1.getString(5)%></span>
                      </td>
                       <td>
                        <span class="text-xs font-weight-bold"><%=rsa1.getString(12)%></span>
                      </td>
                      <td>
                        <span class="text-xs font-weight-bold"><%=rsa1.getString(10)%></span>
                      </td>
<!--                      <td class="align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center">
                          <span class="me-2 text-xs font-weight-bold"> </span>
                          <span class="text-xs font-weight-bold"><%=rsa1.getString(6)%></span>
                        </div>
                         </td>-->
                      <td class="align-middle">
                          
                          
                          <%if(rsa1.getString(10).equals("PENDIENTE")){%>
                          <button class="btn btn-link text-primary mb-0">
                            <a href="../Proyectos/PRO_EliminarNotificacion.jsp?idNotificacion=<%= rsa1.getString(11)%>">Cancelar <i  class="fa fa-trash-alt text-xs"></i></a>
                        </button>
             
                        <%}else{
                            
                            }%>
                      </td>
                    </tr>
                <%
              } rsa1.close();
            sta1.close();
            cna1.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>
                  
                  
    
                      
                      <td>
                        
                          <br>
                           <br>
                      </td>
                  
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
  
  
</body>
</html>
