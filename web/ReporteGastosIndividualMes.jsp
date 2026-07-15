<%-- 
    Document   : ReporteGastosIndivi
    Created on : Mar 1, 2024, 10:00:48 AM
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
    
    String idRepGasCab ="";
    
 double validar =0;
        String roltodo = (String) session.getAttribute("roltodo");

    String  idrep_gastDet  ="";
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             if (!COMUN.PermisoHelper.tiene(session, "REPORTE_GASTOS_ACCESO")) {
                    response.sendRedirect("sesionInvalida.jsp");
                    return;
             }



        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sqlvalidar = "SELECT idrepgascab, idusuario, fecha, total, aprobado FROM rep_gascab WHERE idusuario = "+codigo+" AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE) " ;
            PreparedStatement st = cn.prepareStatement(sqlvalidar);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 validar = rs.getDouble(4);        
                 idRepGasCab = rs.getString(1);
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
                        System.out.println (validar);
                        
 String alimentacionPDF ="";
 String  transportePDF = "";

             %>
<html>
    <head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
  <link rel="icon" type="image/png" href="../assets/img/favicon.png">
  <title>
    Reporte de Gastos
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
  <!--<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">-->
  
<!--contar letras--> 
         <style>
        .mensaje-error {
            color: red;
        }
    </style>
    <script>
        function contarLetras() {
            var inputTexto = document.getElementById('Obva').value;
            var longitudTexto = inputTexto.length;
            var maxCaracteres = 1000;

            var mensaje = document.getElementById('mensaje');
            mensaje.innerHTML = ''; // Limpiar el mensaje anterior

            if (longitudTexto > maxCaracteres) {
                mensaje.innerHTML = '<span class="mensaje-error">Has excedido el límite de 1000 caracteres por ' + (longitudTexto - maxCaracteres) + ' caracteres.</span>';
            } else {
                mensaje.innerHTML = 'Te faltan ' + (maxCaracteres - longitudTexto) + ' caracteres para alcanzar el límite de 1000.';
            }
        }
    </script>
    <!--fin contar letras-->

<!--<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
   Nucleo Icons 
  <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
  <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
   Font Awesome Icons 
  <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
  <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
   CSS Files 
  <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />-->

<!--para el popUp notificacion--> 
<script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>
<script type="text/javascript">   
            function popup_content(hideOrshow) {
            if (hideOrshow == 'hide') document.getElementById('popup_content_wrap').style.display = "none";
            else document.getElementById('popup_content_wrap').removeAttribute('style');
        }
        window.onload = function () {
            setTimeout(function () {
                popup_content('show');
                 var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
       
//        año  y mes actual
        var fecha = new Date();
        var mes = meses[fecha.getMonth()];
        var año = fecha.getFullYear();
        document.getElementById("mesActual").innerHTML = mes;
        document.getElementById("añoActual").innerHTML = año;
            }, 100);
}


</script>





                  
                  

<body class="g-sidenav-show   bg-gray-100">
    
    <div id="popup_content_wrap" style='display:none'   id="exampleModalSignUp">
    <div id="popup_content">
        <center>
             <h1>Recuerda revisar los registros del mes anterior en la opción:</h1> 

            <hr><hr>             
            <!--<h1>en la opción :</h1>-->

                    <ul class="list-group">
                      <!-- <li class="list-group-item active" aria-current="true">An active item</li> -->
                      <li class="list-group-item text-danger"><b> "Filtrar reportes" </b></li>
                      <!--<li class="list-group-item"></li>-->
                      <li class="list-group-item">Para evitar duplicados.</li>
                    </ul>
            <br>
            <input type="submit" name="submit" value="Continue" class="btn btn-primary" onClick="popup_content('hide')" />
        </center>
    </div>
 
</head>
</div>
    
  <div class="min-height-300 bg-primary position-absolute w-100"></div>
  <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
    <div class="sidenav-header">
      <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
      <a class="navbar-brand m-0" href="../Proyectos/PRO_Dashboard.jsp " target="_blank">
          <img src="../assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
        <span class="ms-1 font-weight-bold">ProMaNet</span>
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
                  <%}%>
            
            <a class="nav-link " href="../cerrar.jsp">
            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
              <i class="ni ni-button-power text-dark text-sm opacity-10"></i>
            </div>
            <span class="nav-link-text ms-1">Cerrar sesión</span>
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
            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Reportes</a></li>
            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Gastos</li>
          </ol>
          <h6 class="font-weight-bolder text-white mb-0">Individual</h6>
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
                        <!--<img class="w-60 mt-2" src="../assets/img/logos/mastercard.png" alt="logo">-->
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-xl-6">
              <div class="row">
                <div class="col-md-4">
                  <div class="card">
                    <div class="card-header mx-4 p-3 text-center">
                      <div class="icon icon-shape icon-lg bg-gradient-primary shadow text-center border-radius-lg">
                          <!--<a href="../generarReporteGastosMes" ><i class="fas fa-calendar-alt opacity-10"></i></a>-->
                          <%
                              if(validar > 0){
                          %>  
                          <a href="#" ><i class="fa fa-ban opacity-10"></i></a>
                          <!--<p class="text-white mb-0 " >No disponible</p>-->
                          <%
                              }else{%>
                                  <a href="../AutoGenMes" ><i class="fas fa-calendar-alt opacity-10"></i></a>
                         <%   }
                          %>
                        
                      </div>
                    </div>
                    <div class="card-body pt-0 p-3 text-center">
                      <h6 class="text-center mb-0">Generar</h6>
                      <span class="text-xs">Reporte Gastos Mes</span>
                      <hr class="horizontal dark my-3">
                      <h5 class="text-warning mb-0">$ <%=validar%></h5>
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
                    
<!-- Modal -->
    <div class="modal fade" id="exampleModalSignUp" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-md" role="document">
        <div class="modal-content">
          <div class="modal-body p-0">
            <div class="card card-plain">
              <div class="card-header pb-0 text-left">
                  <h3 class="font-weight-bolder text-primary text-gradient">Reporte Diario</h3>
                  <p class="mb-0">Ingresar datos de reporte</p>
              </div>
              <div class="card-body pb-3">
                  <form role="form text-left" action="../InsertReporteDiario">
                    
                    <div> 
                        <input type="hidden" value="<%=idRepGasCab%>"  name="idRepGasCab"> </div>
                  <label>Fecha</label>
                  <div class="input-group mb-3">
                    <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                     <script>
                            document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
            </script>
                  </div>
                  <label>Alimentación</label>
                  <div class="input-group mb-3">
                      <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                  <select class="chosen-select form-control" id="alimentacion" name ="alimentacion">
                                                                                             
                                     <option value="0">0</option>
                                         <option value="3.50">3,50</option>      
                                         <option value="5.00">5,00</option>  
                                </select>
                  </div>
                  <label>Transporte</label>
<!--                  <div class="input-group mb-3">
                      <input type="number" class="form-control" placeholder="1,50" aria-label="Password" aria-describedby="password-addon"  name="transporte"  id="" value="1.50">
                  </div>-->
<select class="chosen-select form-control" id="transporte" name ="transporte">                                                     
                                     <option value="0">0</option>
                                     <option value="0.75">0,75</option>    
                                         <option value="1.50">1,50</option>          
                                         <option value="5.00">5,00</option>       
                                         <option value="10.00">10,00</option>    
                                </select>
                  
<!--                  <label>Cliente</label>
                  <div class="input-group mb-3">
                    <input type="number" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon">
                  </div>-->
                  
                  <div class="form-group">
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
                        </div>
                  
                  <label>Observación</label>
                  <div class="input-group mb-3">
                      <textarea class="form-control" id= "Obva"  name="observacion" oninput ="contarLetras()" >Reporte de gastos</textarea>
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

<!--Modal editar reporte diario-->
<div class="modal fade" id="editarReporteDiario" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-md" role="document">
        <div class="modal-content">
          <div class="modal-body p-0">
            <div class="card card-plain">
              <div class="card-header pb-0 text-left">
                  <h3 class="font-weight-bolder text-primary text-gradient">Reporte Diario</h3>
                  <p class="mb-0">Editar datos de reporte</p>
              </div>
              <div class="card-body pb-3">
                  <form role="form text-left" action="../InsertReporteDiario">
                    
                    <div> 
                        <input type="hidden" value="<%=idRepGasCab%>"  name="idRepGasCab"> </div>
                  <label>Fecha</label>
                  <div class="input-group mb-3">
                    <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                     <script>
                            document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
            </script>
                  </div>
                  <label>Alimentación</label>
                  <div class="input-group mb-3">
                      <input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">
                  </div>
                  <label>Transporte</label>
                  <div class="input-group mb-3">
                      <input type="number" class="form-control" placeholder="1,50" aria-label="Password" aria-describedby="password-addon"  name="transporte"  id="transporte" value="1.50">
                  </div>
<!--                  <label>Cliente</label>
                  <div class="input-group mb-3">
                    <input type="number" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon">
                  </div>-->
                  
                  <div class="form-group">
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
                        </div>
                  
                  <label>Observación</label>
                  <div class="input-group mb-3">
                      <textarea class="form-control" id= "Obva"  name="observacion" oninput ="contarLetras()" >Reporte de gastos</textarea>
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
                                <!--fin modal editar reporte diario-->
            <div class="col-md-12 mb-lg-0 mb-4">
              <div class="card mt-4">
                <div class="card-header pb-0 p-3">
                  <div class="row">
                    <div class="col-6 d-flex align-items-center">
                         
                         <% 
                        
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "SELECT idrepgascab, idusuario, fecha, total, aprobado FROM rep_gascab WHERE idusuario = "+codigo+" AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE)";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {
                          idrep_gastDet = rs.getString(1);
                          String sum = rs.getString(4);
                          
                         %>
                         <h6 class="mb-0 text-danger text-gradient " >Total mes en curso $   <%=rs.getString(4)%> </h6>
                         
                           
                        <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                   
                    </div>
                          
                    <div class="col-6 text-end">
                        <%
                        if(validar >0){%>
                        <button type="button" class="btn bg-gradient-warning mb-0" data-bs-toggle="modal" data-bs-target="#exampleModalSignUp">
                            <i class="fas fa-plus"></i>&nbsp;&nbsp;Añadir día
                        </button>
                        <%
                            }else{%>
                            <h6 class="mb-0 text-danger text-gradient " >Debe generar el mes en curso !!!</h6>
                         
                       
                          <%  }
                        %>
                       
                        
<!--                      <a class="btn bg-gradient-warning mb-0" onclick="document.getElementById('id01').style.display='block'" >
                          <i class="fas fa-plus"></i>&nbsp;&nbsp;Añadir día
                      </a>-->
                    </div>
                  </div>
                </div>
                <div class="card-body p-3">
                  <div class="row">
                    <div class="col-md-6 mb-md-0 mb-4">
                      <div class="card card-body border card-plain border-radius-lg  d-flex align-items-center flex-row">
                          <h6 class="mb-0">Total&nbsp;&nbsp;&nbsp;Alimentación&nbsp;&nbsp;&nbsp;****&nbsp;&nbsp;&nbsp;$
                          <% 
//                        idrep_gastDet = "3";
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "SELECT SUM(totalim) AS suma_totalim,sum(totmovi) as suma_totamovi  from rep_gasdet where idrepgascab = "+idrep_gastDet+" AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE)";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {
                         alimentacionPDF = rs.getString(1);
                          transportePDF =rs.getString(2);
                          %>
                            
                         <%=rs.getString(1) %></h6>
                       
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="card card-body border card-plain border-radius-lg d-flex align-items-center flex-row">
                        <!--<img class="w-10 me-3 mb-0" src="../assets/img/logos/visa.png" alt="logo">-->
                        <h6 class="mb-0">Total&nbsp;&nbsp;&nbsp;Transporte&nbsp;&nbsp;&nbsp;****&nbsp;&nbsp;&nbsp;$ <%= rs.getString(2) %></h6>
                        <!--<i class="fas fa-pencil-alt ms-auto text-dark cursor-pointer" data-bs-toggle="tooltip" data-bs-placement="top" title="Edit Card"></i>-->
                      </div>
                         <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-lg-4">
          <div class="card h-100">
            <div class="card-header pb-0 p-3">
              <div class="row">
                <div class="col-6 d-flex align-items-center">
                  <h6 class="mb-0">Reporte  de gastos por mes</h6>
                </div>
                <div class="col-6 text-end">
                  <button class="btn btn-outline-primary btn-sm mb-0">Ver Todos</button>
                </div>
              </div>
            </div>
            <div class="card-body p-3 pb-0">
              <ul class="list-group">
                  <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="mb-1 text-dark font-weight-bold text-sm">Abril, 01, 2024</h6>
                    <span class="text-xs">#MS-415646</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                   $ <%=validar%>
                    <a href="../reporteGastosMesPDF?alimPDF=<%=alimentacionPDF%>&transpor=<%=transportePDF%>&mes=<%=4%>" >
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1" target="_blank"></i> PDF</button>
                    </a>
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="mb-1 text-dark font-weight-bold text-sm">Marzo, 01, 2024</h6>
                    <span class="text-xs">#MS-415646</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                   $ <%=validar%>
                    <a href="../reporteGastosMesPDF?alimPDF=<%=alimentacionPDF%>&transpor=<%=transportePDF%>&mes=<%=3%>" >
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1" target="_blank"></i> PDF</button>
                    </a>
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="mb-1 text-dark font-weight-bold text-sm">Febrero, 01, 2024</h6>
                    <span class="text-xs">#MS-415646</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                   $ <%=validar%>
                    <a href="../reporteGastosMesPDF?alimPDF=<%=alimentacionPDF%>&transpor=<%=transportePDF%>&mes=<%=2%>" >
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1" target="_blank"></i> PDF</button>
                    </a>
                  </div>
                </li>
                
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="text-dark mb-1 font-weight-bold text-sm">Enero, 05, 2024</h6>
                    <span class="text-xs">#FB-212562</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                    $0
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1"></i> PDF</button>
                  </div>
                </li>
<!--                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="text-dark mb-1 font-weight-bold text-sm">June, 25, 2019</h6>
                    <span class="text-xs">#QW-103578</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                    $120
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1"></i> PDF</button>
                  </div>
                </li>-->
<!--                <li class="list-group-item border-0 d-flex justify-content-between ps-0 border-radius-lg">
                  <div class="d-flex flex-column">
                    <h6 class="text-dark mb-1 font-weight-bold text-sm">March, 01, 2019</h6>
                    <span class="text-xs">#AR-803481</span>
                  </div>
                  <div class="d-flex align-items-center text-sm">
                    $300
                    <button class="btn btn-link text-dark text-sm mb-0 px-0 ms-4"><i class="fas fa-file-pdf text-lg me-1"></i> PDF</button>
                  </div>
                </li>-->
              </ul>
            </div>
          </div>
        </div>
    </div>
      </div>
      <div class="row">
        <div class="col-md-7 mt-4">
          <div class="card">
            <div class="card-header pb-0 px-3">
              <h6 class="mb-0">Reporte diario <span id="mesActual"></span>  <span id="añoActual"></span></h6>
            </div>
            <div class="card-body pt-4 p-3 ">
              <ul class="list-group">
                  <% 
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "SELECT a.idrepgasdet, a.idcliente,to_char(A.fecha, 'DD/MON/YYYY'), a.VALOR,a.trabrealizado,a.totalim, a.totmovi, a.idrepgascab , TO_CHAR(a.fecha, 'Day', 'NLS_DATE_LANGUAGE=SPANISH') AS dia_semana , c.cliente FROM rep_gasdet a, rep_gascab b, cliente c WHERE a.idrepgascab = "+idrep_gastDet+" and b.idrepgascab = a.idrepgascab and a.idcliente = c.idcliente AND EXTRACT(MONTH FROM a.fecha) = EXTRACT(MONTH FROM SYSDATE) order by 3";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {
                  %>
                <li class="list-group-item border-0 d-flex p-4 mb-2 bg-gray-100 border-radius-lg">
                    
                  <div class="d-flex flex-column">
                      
                    <h6 class="mb-3 text-sm"> <%=rs.getString(3)%>  (<%=rs.getString(9)%>)</h6>
                    <span class="mb-2 text-xs">Cliente: <span class="text-dark font-weight-bold ms-sm-2">   <%=rs.getString(10)%> </span></span>
                    <span class="mb-2 text-xs">Alimentación:<span class="text-dark ms-sm-2 font-weight-bold">$ <%=rs.getString(6)%> </span></span>
                    <span class="mb-2 text-xs">Transporte    : <span class="text-dark ms-sm-2 font-weight-bold">$ <%=rs.getString(7)%> </span></span>
                   
                     <span class="text-xs">Observación: <span class="text-dark ms-sm-2 font-weight-bold"><%=rs.getString(5)%>.</span></span>
                  </div>
                  <div class="ms-auto text-end">
                      <a class="btn btn-link text-danger text-gradient px-3 mb-0"  href="../eliminarReporteDiario?idCab=<%=rs.getString(8)%>&idDet=<%=rs.getString(1)%>"  data-bs-toggle="tooltip" title="Eliminar este día!"><i class="far fa-trash-alt me-2"></i>Eliminar</a> 
                    <a class="btn btn-link text-dark px-3 mb-0" href="../ReporteGastos/editarReporteDiario.jsp?idCab=<%=rs.getString(8)%>&idDet=<%=rs.getString(1)%>"><i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Editar</a>
<!--                     <button type="button" class="btn bg-gradient-warning mb-0" data-bs-toggle="modal" data-bs-target="#editarReporteDiario">
                            <i class="fas fa-plus"></i>&nbsp;&nbsp;editar Dia
                        </button>-->
                  </div>
                    
                </li>
                <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
              </ul>
                  
              <ul class="list-group">
                  
                <li class="list-group-item border-0 d-flex p-4 mb-2 bg-gray-100 border-radius-lg">
                    
<!--                  <div class="d-flex flex-column">
                      
                    <h6 class="mb-3 text-sm"> </h6>
                    <span class="mb-2 text-xs">Cliente: <span class="text-dark font-weight-bold ms-sm-2">   </span></span>
                    <span class="mb-2 text-xs">Alimentación: <span class="text-dark ms-sm-2 font-weight-bold"> </span></span>
                    <span class="mb-2 text-xs">Transporte: <span class="text-dark ms-sm-2 font-weight-bold"> </span></span>
                   
                     <span class="text-xs">Observación: <span class="text-dark ms-sm-2 font-weight-bold"></span></span>
                  </div>
                  <div class="ms-auto text-end">
                    <a class="btn btn-link text-danger text-gradient px-3 mb-0" href="javascript:;"><i class="far fa-trash-alt me-2"></i>Eliminar</a>
                    <a class="btn btn-link text-dark px-3 mb-0" href="javascript:;"><i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Editar</a>
                  </div>-->
                    
                </li>
                
              </ul>
            </div>
                  
          </div>
                  
        </div>
                  
        <div class="col-md-5 mt-4">
          <div class="card h-100 mb-4">
            <div class="card-header pb-0 px-3">
              <div class="row">
                <div class="col-md-6">
                  <h6 class="mb-0">Atrasos en el mes</h6>
                </div>
                <div class="col-md-6 d-flex justify-content-end align-items-center">
                  <i class="far fa-calendar-alt me-2"></i>
                  <small>23 - 30 March 2020</small>
                </div>
              </div>
            </div>
            <div class="card-body pt-4 p-3">
              <h6 class="text-uppercase text-body text-xs font-weight-bolder mb-3"></h6>
<!--              <ul class="list-group">
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-danger mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-arrow-down"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">Netflix</h6>
                      <span class="text-xs">27 March 2020, at 12:30 PM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-danger text-gradient text-sm font-weight-bold">
                    - $ 2,500
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-success mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-arrow-up"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">Apple</h6>
                      <span class="text-xs">27 March 2020, at 04:30 AM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-success text-gradient text-sm font-weight-bold">
                    + $ 2,000
                  </div>
                </li>
              </ul>-->
              <h6 class="text-uppercase text-body text-xs font-weight-bolder my-3"></h6>
<!--              <ul class="list-group">
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-success mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-arrow-up"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">Stripe</h6>
                      <span class="text-xs">26 March 2020, at 13:45 PM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-success text-gradient text-sm font-weight-bold">
                    + $ 750
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-success mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-arrow-up"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">HubSpot</h6>
                      <span class="text-xs">26 March 2020, at 12:30 PM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-success text-gradient text-sm font-weight-bold">
                    + $ 1,000
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-success mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-arrow-up"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">Creative Tim</h6>
                      <span class="text-xs">26 March 2020, at 08:30 AM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-success text-gradient text-sm font-weight-bold">
                    + $ 2,500
                  </div>
                </li>
                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                  <div class="d-flex align-items-center">
                    <button class="btn btn-icon-only btn-rounded btn-outline-dark mb-0 me-3 btn-sm d-flex align-items-center justify-content-center"><i class="fas fa-exclamation"></i></button>
                    <div class="d-flex flex-column">
                      <h6 class="mb-1 text-dark text-sm">Webflow</h6>
                      <span class="text-xs">26 March 2020, at 05:00 AM</span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center text-dark text-sm font-weight-bold">
                    Pending
                  </div>
                </li>
              </ul>-->
            </div>
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
                made with <i class="fa fa-heart"></i> by
                <a href="https://www.creative-tim.com" class="font-weight-bold" target="_blank">Creative Tim</a>
                for a better web.
              </div>
            </div>
            <div class="col-lg-6">
              <ul class="nav nav-footer justify-content-center justify-content-lg-end">
                <li class="nav-item">
                  <a href="https://www.creative-tim.com" class="nav-link text-muted" target="_blank">Creative Tim</a>
                </li>
                <li class="nav-item">
                  <a href="https://www.creative-tim.com/presentation" class="nav-link text-muted" target="_blank">About Us</a>
                </li>
                <li class="nav-item">
                  <a href="https://www.creative-tim.com/blog" class="nav-link text-muted" target="_blank">Blog</a>
                </li>
                <li class="nav-item">
                  <a href="https://www.creative-tim.com/license" class="nav-link pe-0 text-muted" target="_blank">License</a>
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
        <a class="btn bg-gradient-dark w-100" href="https://www.creative-tim.com/product/argon-dashboard">Free Download</a>
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
  
  <style type="text/css">
            h1{
                color:#D6DBDF;
                }
                p{
                color:#fff;}
                /*img{
                width:100%;}*/
                #popup_content_wrap {
                width: 100%;
                    height: 100%;   
                    top: 0;
                    left: 0;   
                 position: fixed;   
                    background: rgba(0, 0, 0, 0.74);
                    z-index: 9999999;
                }
                #popup_content {
                    width: 50%;
                    height: 500px;
                    padding:20px;
                     position: relative;
                    top: 15%;
                    left: 25%;
                    background: #1b100ed9;
                    border: 10px solid #7080F0;  
   
    
                }
        </style>
</body>
  
</html>

