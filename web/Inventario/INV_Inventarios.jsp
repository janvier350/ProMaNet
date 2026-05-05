<%-- 
 Document   : PRO_Dashboard
 Created on : 1 oct 2023, 23:56:58
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
    
    String departamento = (String) session.getAttribute("departamento");
    
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
        String FlagFiltro = request.getParameter("filtro");

        String roltodo = (String) session.getAttribute("roltodo");

    
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("../sesionExpirada.jsp");
             return;
             }
             
             //validar departamento
             
             if(departamento.equals("MARKETING")||departamento.equals("TECNOLOGÍA")||departamento.equals("ADMINISTRACIÓN")){
                }else{
                    response.sendRedirect("../sesionInvalida.jsp");
             }
             
//             validar rol
             if(cargo.equals("ADMINISTRADOR")||cargo.equals("ADMINISTRACION")||cargo.equals("JEFE")||cargo.equals("CONTRALOR")){
                }else{
                    response.sendRedirect("../sesionInvalida.jsp");
             }
             
 String EstTrab ="";
    if(FlagFiltro==null||FlagFiltro.equals(null)){
       EstTrab= "IS NOT NULL";
    }else if (FlagFiltro.equals("1")){
       EstTrab= "='T'";
    }else if (FlagFiltro.equals("2")){
       EstTrab= "='P'";
    }else if (FlagFiltro.equals("3")){
       EstTrab= "='A'";
    }else{
       EstTrab= "IS NOT NULL";
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>
            Proyectos
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


        <!--link para el modal-->
        <!--<meta name="viewport" content="width=device-width, initial-scale=1">-->
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
        <!--fin links modal-->

    </head>
    <body>

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
                        <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||apellidos.equals("Varas Herrera")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){%>
                        <a class="nav-link " href="../Control/ADM_Atrasos_ALL.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-archive-2 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Reportes de atrasos</span>
                        </a>
                        <a class="nav-link " href="../Inventario/INV_Equipos.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-laptop text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Inventario</span>
                        </a>
                        <a class="nav-link " href="../Soportes/SOP_ListaSolicitudes_ALL.jsp">
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
                <a href="../cerrar.jsp" target="_blank" class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesión</a>

            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <!-- Navbar -->
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Menu</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Inventarios</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Panel de control inventarios</h6>
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
            <div class="w3-container">


                <!--<button onclick="document.getElementById('id01').style.display='block'" class="card-body p-3">Registrar</button>-->


                <div id="id02"class="w3-modal w3-animate-opacity">
                    <div class="w3-modal-content w3-card-4">
                        <header class="w3-container w3"> 
                            <span onclick="document.getElementById('id02').style.display = 'none'" 
                                  class="w3-button w3-large w3-display-topright">&times;</span>
                            <h2 class ="text-dark">Registrar producto</h2>
                        </header>
                        <div class="w3-container">
                            <form  action="../ADM_Insertar_Atraso.jsp"  method="POST" >
                                <div class="modal-body">
                                    <div class="container-fluid">


                                        <div class="row">
                                            <div class="col-lg-12 ">
                                                <div class="form-group">
                                                    <label class=" control-label" for="Cliente" >CategorÍa</label>
                                                    <!--<input type="text" name="Cliente" id="Cliente" class="form-control" required />-->
                                                    <div class="form-group">
                                                        <select class=" form-control" id="motivo" name ="motivo">

                                                            <%
                                                                try{
                                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                                String sql = "select * from INV_CATEGORIA  where estado = 'A' order by 2";
                                                                PreparedStatement st = cn.prepareStatement(sql);
                                                                ResultSet rs = st.executeQuery();       
                                                                while (rs.next()) {
                                                            %>                                                                    
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                                                            <%
                                                                }     
                                                                rs.close();
                                                                st.close();
                                                                cn.close();
                                                            }catch(Exception e){
                                                                 e.printStackTrace();
                                                            }

                                                            %>       
                                                        </select>
                                                    </div>

                                                </div>


                                            </div>
                                        </div>                                             
                                        <!--            <div class="row">
                                                    <div class="col-lg-12">
                                                        <div class="form-group">
                                                            <label for="Observacion" class="form-control-label">Observación</label>
                                                            <textarea class="form-control" id="observacion" name="observacion" ></textarea>
                                                        </div>  
                                                    </div>
                                                    </div>-->
                                    </div>

                                </div> 
                                <footer class="">
                                    <div class="modal-footer">
                                        <!--                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>-->
                                        <button type="submit" name="guardar" id="guardar" class="btn btn-warning bg-gradient-warning "  onclick="verificarTiempo()" >Guardar</button>
                                    </div>
                                </footer>
                            </form>

                        </div>

                    </div>
                </div>
            </div>
            <div class="w3-container">


                <!--<button onclick="document.getElementById('id01').style.display='block'" class="card-body p-3">Registrar</button>-->


                <div id="id01"class="w3-modal w3-animate-opacity">
                    <div class="w3-modal-content w3-card-4">
                        <header class="w3-container w3"> 
                            <span onclick="document.getElementById('id01').style.display = 'none'" 
                                  class="w3-button w3-large w3-display-topright">&times;</span>
                            <h2 class ="text-dark">Notificar Atraso</h2>
                        </header>
                        <div class="w3-container">
                            <form  action="../ADM_Insertar_Atraso.jsp"  method="POST" >
                                <div class="modal-body">
                                    <div class="container-fluid">


                                        <div class="row">
                                            <div class="col-lg-12 ">
                                                <div class="form-group">
                                                    <label class=" control-label" for="Cliente" >Motivo</label>
                                                    <!--<input type="text" name="Cliente" id="Cliente" class="form-control" required />-->
                                                    <div class="form-group">
                                                        <select class=" form-control" id="motivo" name ="motivo">

                                                            <%
                                                                try{
                                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                                String sql = "select * from reg_biom_motivo where estado = 'A' order by 1";
                                                                PreparedStatement st = cn.prepareStatement(sql);
                                                                ResultSet rs = st.executeQuery();       
                                                                while (rs.next()) {
                                                            %>                                                                    
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                                                            <%
                                                                }     
                                                                rs.close();
                                                                st.close();
                                                                cn.close();
                                                            }catch(Exception e){
                                                                 e.printStackTrace();
                                                            }

                                                            %>       
                                                        </select>
                                                    </div>

                                                </div>


                                            </div>
                                        </div>                                             
                                        <!--            <div class="row">
                                                    <div class="col-lg-12">
                                                        <div class="form-group">
                                                            <label for="Observacion" class="form-control-label">Observación</label>
                                                            <textarea class="form-control" id="observacion" name="observacion" ></textarea>
                                                        </div>  
                                                    </div>
                                                    </div>-->
                                    </div>

                                </div> 
                                <footer class="">
                                    <div class="modal-footer">
                                        <!--                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>-->
                                        <button type="submit" name="guardar" id="guardar" class="btn btn-warning bg-gradient-warning "  onclick="verificarTiempo()" >Guardar</button>
                                    </div>
                                </footer>
                            </form>

                        </div>

                    </div>
                </div>
            </div>

            <div class="container-fluid py-4">
                <div class="row">

                    <!--          <div class="col-xl-2 col-sm-6 mb-xl-0 mb-4">
                              <div class="card">
                                  <a id="guardar2" onclick="document.getElementById('id01').style.display='block'" >
                                  <div class="card-body p-3">
                                  <div class="row">
                                    <div class="col-8">
                                      <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">Justificar </p>
                                        
                                        <h5 class="font-weight-bolder"> ATRASO  </h5>
                                        <p class="mb-0">
                                          <span class="text-danger text-sm font-weight-bolder">15 minutos antes </span>
                                           <b class="text-danger ">de su horario de entrada.</b>
                                        </p>
                                      </div>
                                    </div>
                                    <div class="col-4 text-end">
                                      <div class="icon icon-shape bg-gradient-warning shadow-primary text-center rounded-circle">
                                        <i class="ni ni-time-alarm text-lg opacity-10" aria-hidden="true"></i>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                                      </a>
                              </div>
                            </div>-->

                    <div class="col-xl-2 col-sm-6 mb-xl-0 mb-4">
                        <div class="card">
                            <a href="../Inventario/INV_Equipos.jsp">
                                <div class="card-body p-3">
                                    <div class="row">
                                        <div class="col-8">
                                            <div class="numbers">
                                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Computadoras </p>

                                                <h5 class="font-weight-bolder">Inventario de computadoras </h5>
                                                <p class="mb-0">
                                                    <span class="text-primary text-sm font-weight-bolder">Registre activos  </span>
                                                    <b class="text-primary ">de computo.</b>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-4 text-end">
                                            <div class="icon icon-shape bg-gradient-primary shadow-primary text-center rounded-circle">
                                                <i class="ni ni-laptop text-lg opacity-10" aria-hidden="true"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>

                    <div class="col-xl-2 col-sm-6 mb-xl-0 mb-4">
                        <div class="card">
                            <a href="../Inventario/INV_Ingreso_Suministro2.jsp">
                                <div class="card-body p-3">
                                    <div class="row">
                                        <div class="col-8">
                                            <div class="numbers">
                                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Suministros</p>
                                                <h5 class="font-weight-bolder">Inventario de suministros</h5>
                                                <p class="mb-0">
                                                    <span class="text-success text-sm font-weight-bolder"><b>Registre suministros   </b></span>
                                                    <b class="text-success ">para uso de oficina.</b>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-4 text-end">
                                            <div class="icon icon-shape bg-gradient-success shadow-danger text-center rounded-circle">
                                                <i class="ni ni-ruler-pencil text-lg opacity-10" aria-hidden="true"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>

                    <!--MODAL CATEGORIA-->
                    <div class="modal fade" id="exampleModalSignUp2" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-body p-0">
                                    <div class="card card-plain">
                                        <div class="card-header pb-0 text-left">
                                            <h3 class="font-weight-bolder text-primary text-gradient">Registrar categoría</h3>
                                            <!--<p class="mb-0">Ingresar datos</p>-->
                                        </div>
                                        <div class="card-body pb-3">
                                            <form role="form text-left" action="../INV_InsertCategoria">

                                                <div> 
                                                    <!--<input type="text" value=""  name="idRepGasCab"> </div>-->
                                                    <!--                  <label>Fecha Compra</label>
                                                                      <div class="input-group mb-3">
                                                                        <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                                                                         <script>
                                                                                document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
                                                                </script>
                                                                      </div>-->

                                                    <label>Categoría</label>

                                                    <div class="input-group mb-3">
                                                        <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="categoria" name ="categoria" required="true">
                                                    </div>

                                                    <label>Categorías Registradas</label>
                                                    <div class="input-group mb-3">
                                                        <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                        <select class="chosen-select form-control" id="id_categoria" name ="id_categoria">
                                                            <%
                                                try{
                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                String sql = "select * from INV_CATEGORIA where estado = 'A' order by 2";
                                                PreparedStatement st = cn.prepareStatement(sql);
                                                ResultSet rs = st.executeQuery();       
                                                while (rs.next()) {%>        
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> </option>
                                                            <%}     
                                                         rs.close();
                                                         st.close();
                                                         cn.close();
                                                      }catch(Exception e){
                                                          e.printStackTrace();
                                                      }%>     
                                                        </select>
                                                    </div>







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
                    <!--FIN MODAL CATEGORIA-->
                    <!--MODAL UNIDADES DE MEDIDA-->
                    <div class="modal fade" id="exampleModalSignUpUnidades" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-body p-0">
                                    <div class="card card-plain">
                                        <div class="card-header pb-0 text-left">
                                            <h3 class="font-weight-bolder text-primary text-gradient">Registrar Unidades de medidas</h3>
                                            <!--<p class="mb-0">Ingresar datos</p>-->
                                        </div>
                                        <div class="card-body pb-3">
                                            <form role="form text-left" action="../INV_InsertUnidadesMedida">

                                                <div> 
                                                    <!--<input type="text" value=""  name="idRepGasCab"> </div>-->
                                                    <!--                  <label>Fecha Compra</label>
                                                                      <div class="input-group mb-3">
                                                                        <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                                                                         <script>
                                                                                document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
                                                                </script>
                                                                      </div>-->

                                                    <label>Unidad</label>

                                                    <div class="input-group mb-3">
                                                        <input type="text" class="form-control" placeholder="Paquete, frasco, cartón, ..." aria-label="Password" aria-describedby="password-addon" id="unidad" name ="unidad" required="true">
                                                    </div>
                                                    

                                                    <label>Descripción: </label>

                                                    <div class="input-group mb-3">
                                                        <input type="text" class="form-control" placeholder="12 unidades, 450 gr, 12 paquetes,..." aria-label="Password" aria-describedby="password-addon" id="descripcion" name ="descripcion" required="true">
                                                    </div
                                                    
                                                    <label><p>Unidades Registradas</p></label>
                                                    <div class="input-group mb-3">
                                                        <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                        <select class="chosen-select form-control" id="id_categoria" name ="id_categoria">
                                                            <%
                                                try{
                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                String sql = "select * from INV_UNIDAD_MEDIDA where estado = 'A' order by 2";
                                                PreparedStatement st = cn.prepareStatement(sql);
                                                ResultSet rs = st.executeQuery();       
                                                while (rs.next()) {%>        
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%>  -  <%=rs.getString(3)%>  </option>
                                                            <%}     
                                                         rs.close();
                                                         st.close();
                                                         cn.close();
                                                      }catch(Exception e){
                                                          e.printStackTrace();
                                                      }%>     
                                                        </select>
                                                    </div>







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
                    <!--FIN UNIDADES DE MEDIADA-->
                    <!--MODAL NUEVO PRODUCTO-->
                    <div class="modal fade" id="exampleModalSignUp" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-body p-0">
                                    <div class="card card-plain">
                                        <div class="card-header pb-0 text-left">
                                            <h3 class="font-weight-bolder text-primary text-gradient">Registrar producto</h3>
                                            <p class="mb-0">Ingresar datos</p>
                                        </div>
                                        <div class="card-body pb-3">
                                            <form role="form text-left" action="../INV_InsertProducto">

                                                <div> 
                                                    <!--<input type="text" value=""  name="idRepGasCab"> </div>-->
                                                    <!--                  <label>Fecha Compra</label>
                                                                      <div class="input-group mb-3">
                                                                        <input type="date" class="form-control"  aria-label="Name" aria-describedby="name-addon" name="fecha"  id="fecha">
                                                                         <script>
                                                                                document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
                                                                </script>
                                                                      </div>-->

                                                    <label>Producto xxxx</label>

                                                    <div class="input-group mb-3">
                                                        <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="descripcion" name ="descripcion" required="true">
                                                    </div>

                                                    <label>Unidad de medida:</label>
                                                    <div class="input-group mb-3">
                                                        <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                        <select class="chosen-select form-control" id="unidad" name ="id_unidad">
                                                            <%
                                                try{
                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                String sql = "select * from INV_UNIDAD_MEDIDA where estado = 'A' order by 2";
                                                PreparedStatement st = cn.prepareStatement(sql);
                                                ResultSet rs = st.executeQuery();       
                                                while (rs.next()) {%>        
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> -  <%=rs.getString(3)%> </option> 
                                                            <%}     
                                                         rs.close();
                                                         st.close();
                                                         cn.close();
                                                      }catch(Exception e){
                                                          e.printStackTrace();
                                                      }%>     
                                                        </select>
                                                    </div>


                                                    <label>Categoría:</label>
                                                    <div class="input-group mb-3">
                                                        <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                        <select class="chosen-select form-control" id="idCategoria" name ="idCategoria">
                                                            <%
                                                try{
                                                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                Connection   cn = DriverManager.getConnection(url, user, pass);
                                                String sql = "select * from INV_CATEGORIA where estado = 'A' order by 2";
                                                PreparedStatement st = cn.prepareStatement(sql);
                                                ResultSet rs = st.executeQuery();       
                                                while (rs.next()) {%>        
                                                <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> </option> 
                                                            <%}     
                                                         rs.close();
                                                         st.close();
                                                         cn.close();
                                                      }catch(Exception e){
                                                          e.printStackTrace();
                                                      }%>     
                                                        </select>
                                                    </div>







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
                                                <label>Productos Registrados</label>
                                                <div class="input-group mb-3">
                                                    <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                    <select class="chosen-select form-control" id="id_categoria" name ="id_categoria">
                                                        <%
                                            try{
                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                            Connection   cn = DriverManager.getConnection(url, user, pass);
                                            String sql = "select inv_producto.id_producto, inv_producto.descripcion as producto,inv_unidad_medida.unidad as unidad, inv_unidad_medida.descripcion as descripcion from inv_producto inner join inv_unidad_medida on inv_producto.id_unidad =   inv_unidad_medida.id_unidad_medida order by 2";
                                            PreparedStatement st = cn.prepareStatement(sql);
                                            ResultSet rs = st.executeQuery();       
                                            while (rs.next()) {%>        
                                                        <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> - <%=rs.getString(3)%>  <%=rs.getString(4)%> </option>
                                                        <%}     
                                                     rs.close();
                                                     st.close();
                                                     cn.close();
                                                  }catch(Exception e){
                                                      e.printStackTrace();
                                                  }%>     
                                                    </select>
                                                </div>
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
                    <!--FIN MODAL NUEVO PRODUCTO-->

                    <div class="col-xl-2 col-sm-6 mb-xl-0 mb-4">
                        <div class="card">
                            <a href="../Inventario/INV_Ingreso_SuministroMarketing.jsp">
                                <div class="card-body p-3">
                                    <div class="row">
                                        <div class="col-8">
                                            <div class="numbers">
                                                <p class="text-sm mb-0 text-uppercase font-weight-bold">Marketing</p>
                                                <h5 class="font-weight-bolder">Inventario Marketing </h5>
                                                <p class="mb-0">
                                                    <span class="text-dark text-sm font-weight-bolder">Registre suministros </span>
                                                    <b class="text-dark">para networking.</b>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-4 text-end">
                                            <div class="icon icon-shape bg-gradient-faded-dark shadow-success text-center rounded-circle">
                                                <i class="ni ni-ruler-pencil text-lg opacity-10" aria-hidden="true"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>

                    <!--        <div class="col-xl-2 col-sm-6 mb-xl-0 mb-4">
                              <div class="card">
                                  <a href="../TODO_Cab_Trabajo.jsp">
                                      <div class="card-body p-3">
                                  <div class="row">
                                    <div class="col-8">
                                      <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">TAREAS</p>
                                        <h5 class="font-weight-bolder">
                                          TO-DO
                                        </h5>
                                        <p class="mb-0">
                                          <span class="text-danger text-sm font-weight-bolder">Mejore su productividad</span>
                                          <b class="text-danger"> registrando tareas.</b>
                                        </p>
                                      </div>
                                    </div>
                                    <div class="col-4 text-end">
                                      <div class="icon icon-shape bg-gradient-danger shadow-success text-center rounded-circle">
                                        <i class="ni ni-check-bold text-lg opacity-10" aria-hidden="true"></i>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                                  </a>
                              </div>
                            </div>-->
                    <!--        <div class="col-xl-2 col-sm-6">
                              <div class="card">
                                  
                                  <a href="../Agenda.jsp">
                                      <div class="card-body p-3">
                                  <div class="row">
                                    <div class="col-8">
                                      <div class="numbers">
                                        <p class="text-sm mb-0 text-uppercase font-weight-bold">REUNIONES</p>
                                        <h5 class="font-weight-bolder">
                                          AGENDA
                                        </h5>
                                        <p class="mb-0">
                                          <span class="text-danger text-sm font-weight-bolder">Consulte sus reuniones</span> 
                                           <b class="text-danger ">pendientes del día</b>
                                        </p>
                                      </div>
                                    </div>
                                    <div class="col-4 text-end">
                                      <div class="icon icon-shape bg-gradient-warning shadow-warning text-center rounded-circle">
                                        <i class="ni ni-calendar-grid-58 text-lg opacity-10" aria-hidden="true"></i>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                                  </a>
                              </div>
                            </div>-->
                </div>

                <%
                if(roltodo.equals("ASISTENTE")){
           
                %>
                <div class="row mt-4">
                    <div class="col-lg-7 mb-lg-0 mb-4">
                        <div class="card z-index-2 h-100">
                            <div class="card-header pb-0 pt-3 bg-transparent">
                                <h6 class="text-capitalize">Tareas </h6> <p><%=roltodo%></p>
                                <p class="text-sm mb-0">
                                    <i class="fa fa-arrow-up text-success"></i>
                                    <span class="font-weight-bold"> Pendies y proximamente caducar</span>  2024
                                </p>
                            </div>

                            <!--inicio tabla asistente-->

                            <table class="table align-items-center ">

                                <thead>
                                    <tr class="success">
                                        <!--<th class="text-center">Ver</th>-->
                                        <th class="text-center">Cliente</th>
                                        <!--<th class="text-center">Trabajo</th>-->
                                        <!--<th class="text-center">Jefe Asignado</th>-->
                                        <th class="text-center">Fecha Inicio</th>
                                        <th class="text-center">Avance</th>  
                                        <th class="text-center">Fecha Fin</th>


                                    </tr> 
                                </thead>
                                <tbody>

                                    <%  
                 try{
                     DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                     Connection cn4 = DriverManager.getConnection(url, user, pass);
                     String sql4 ="";
                     sql4  = "SELECT to_char(B.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,a.CLIENTE, b.TRABAJO, b.ESTTRAB,b.IDTODOCAB , B.descripcion "
                          + " from cliente a,(SELECT DISTINCT B.IDTODOCABTRAB, A.IDTODOCAB, A.IDUSUARIO, A.DESCRIPCION, A.TRABAJO, "
                          + " A.FECHAINCIO, A.FECHAFIN, A.FECHAHORAASIG, A.FECHALEGAL, A.FECHACONTRATO, A.IDCLIENTE, A.ESTADO, A.COMENTARIO, A.IDTODOAREA, A.ESTTRAB, A.IDTODOCABGRUPO "
                          + " FROM TODOCABTRAB A,TODODETTRAB B, TODOASIGTAREA C WHERE A.IDTODOCAB = B.IDTODOCABTRAB AND B.IDTODODET = C.IDTODODETTRAB "
                          + " AND C.IDUSUARIO = "+codigo+" ) b where a.IDCLIENTE = b.IDCLIENTE and b.ESTADO = 'A' and b.ESTTRAB = 'P'   order by 7 DESC";
       
                     PreparedStatement st4 = cn4.prepareStatement(sql4);
                     ResultSet rs4 = st4.executeQuery();       
                 while (rs4.next()) {%>


                                    <tr>
                                        <td class="w-10">
                                            <div class="d-flex px-2 py-1 align-items-center">
                                                <div>

                                                    <a class="btn btn-xs btn-primary " href="../TODO_det_Trabajo_1.jsp?idCabTrab=<%=rs4.getString(7)%>">
                                                        <i class="fas fa-eye"></i>
                                                    </a>

                                                </div>
                                                <div class="ms-4">
                                                    <p class="text-xs font-weight-bold mb-0">
                                                    </p>
                                                    <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(4))%></h6>
                                                     <!--<p class="text-xs font-weight-bold mb-0">Trabajo: <%= String.valueOf(rs4.getString(5))%></p>-->
                                                    <p class="text-xs font-weight-bold mb-0" style="max-width: 100%; word-break: break-word; white-space: normal;">
                                                        <%=rs4.getString(5)%> <%=rs4.getString(8)%>
                                                    </p>
                                                </div>
                                            </div>
                                        </td>
                                        <!--                    <td>
                                                              <div class="text-center">
                                                                <p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>
                                                                <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(4))%></h6>
                                                              </div>
                                                            </td>-->
                                        <!--                    <td class="w-30" style="max-width: 300px;">
                                                              <div class="d-flex px-2 py-1 align-items-center">
                                                                <div>
                                                                    <a  href="../TODO_det_Trabajo_1.jsp?idCabTrab=<%=rs4.getString(7)%>">
                                                                        <img src="../image/folder.png" alt="Country flag" style="width: 20px; height: 20px;" >
                                                                    
                                                                    <img src="../assets/img/icons/Tareas/Tareas1.png" alt="Country flag">
                                                                    </a>
                                                                </div>
                                                                <div class="ms-4">
                                                                    <p class="text-xs font-weight-bold mb-0">
                                        <%--<%= String.valueOf(rs4.getString(5))%>--%>
                                    </p>
                                  <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(6))%></h6>
                                     <p class="text-xs font-weight-bold mb-0" style="max-width: 100%; word-break: break-word; white-space: normal;">
                                        <%=rs4.getString(7)%>
                                    </p>
                                                    </div>
                                                  </div>
                                                </td>-->
                                        <td>
                                            <div class="text-center">
                                                <!--<p class="text-xs font-weight-bold mb-0">Jefe Asignado:</p>-->
                                                <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(1))%></h6>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="text-center">
                                                <!--<p class="text-xs font-weight-bold mb-0">Jefe Asignado:</p>-->
                                                <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(6))%></h6>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="text-center">
                                                <!--<p class="text-xs font-weight-bold mb-0">Jefe Asignado:</p>-->
                                                <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(2))%></h6>
                                            </div>
                                        </td>


                                    </tr>

                                    <%}%>

                                </tbody>
                            </table>
                            <% rs4.close();
                        st4.close();
                        cn4.close();
                        }catch(Exception e){
                          e.printStackTrace();
                        }
                  }%>  
                            <!--tabla asistente-->
                        </div>
                    </div>
                    <div class="col-lg-5">
                        <div class="card card-carousel overflow-hidden h-100 p-0">
                            <div id="carouselExampleCaptions" class="carousel slide h-100" data-bs-ride="carousel">
                                <div class="carousel-inner border-radius-lg h-100">
                                    <div class="carousel-item h-100 active" style="background-image: url('../assets/img/carousel-1.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-camera-compact text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Panel de control</h5>
                                            <p>Ahora puedes ver el avance de tus tareas junto con tus colegas, con la nueva vista de gráficos.</p>
                                        </div>
                                    </div>
                                    <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-2.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-bulb-61 text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Indicadores de avance</h5>
                                            <p>Gestionar tus tareas y medir tu rendimiento con los indicadores.</p>
                                        </div>
                                    </div>
                                    <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-3.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-trophy text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Si lo que necesitas es terminar tus tareas más rápido!</h5>
                                            <p>No dudes en visitar nuestro tutorial.</p>
                                        </div>
                                    </div>
                                </div>
                                <button class="carousel-control-prev w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="prev">
                                    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Previous</span>
                                </button>
                                <button class="carousel-control-next w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="next">
                                    <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Next</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!--para posible uso de otra tabla--> 
                <!--        <div class="row mt-4">
                        <div class="col-lg-7 mb-lg-0 mb-4">
                          <div class="card z-index-2 h-100">
                            <div class="card-header pb-0 pt-3 bg-transparent">
                              <h6 class="text-capitalize">TODO </h6> <p><%=roltodo%></p>
                              <p class="text-sm mb-0">
                                <i class="fa fa-arrow-up text-success"></i>
                                <span class="font-weight-bold">4% more</span> in 2023
                              </p>
                            </div>
                              
                              inicio tabla asistente
                          
                            
                            tabla asistente
                          </div>
                        </div>
                        <div class="col-lg-5">
                          <div class="card card-carousel overflow-hidden h-100 p-0">
                            <div id="carouselExampleCaptions" class="carousel slide h-100" data-bs-ride="carousel">
                              <div class="carousel-inner border-radius-lg h-100">
                                <div class="carousel-item h-100 active" style="background-image: url('../assets/img/carousel-1.jpg');
                      background-size: cover;">
                                  <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                    <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                      <i class="ni ni-camera-compact text-dark opacity-10"></i>
                                    </div>
                                    <h5 class="text-white mb-1">Panel de control</h5>
                                    <p>Ahora puedes ver el avance de tus tareas junto con tus colegas, con la nueva vista de gráficos.</p>
                                  </div>
                                </div>
                                <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-2.jpg');
                      background-size: cover;">
                                  <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                    <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                      <i class="ni ni-bulb-61 text-dark opacity-10"></i>
                                    </div>
                                    <h5 class="text-white mb-1">Indicadores de avance</h5>
                                    <p>Gestionar tus tareas y medir tu rendimiento con los indicadores.</p>
                                  </div>
                                </div>
                                <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-3.jpg');
                      background-size: cover;">
                                  <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                    <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                      <i class="ni ni-trophy text-dark opacity-10"></i>
                                    </div>
                                    <h5 class="text-white mb-1">Si lo que necesitas es terminar tus tareas más rápido!</h5>
                                    <p>No dudes en visitar nuestro tutorial.</p>
                                  </div>
                                </div>
                              </div>
                              <button class="carousel-control-prev w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="prev">
                                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                <span class="visually-hidden">Previous</span>
                              </button>
                              <button class="carousel-control-next w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="next">
                                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                <span class="visually-hidden">Next</span>
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>-->

                <div class="row mt-4">
                    <div class="col-lg-7 mb-lg-0 mb-4">
                        <div class="card z-index-2 h-100">
                            <div class="card-header pb-0 pt-3 bg-transparent">
                                <!--<h6 class="text-capitalize">Lista de tareas asignadas </h6>-->
                                <p><%=roltodo%></p>
                                <p><%=departamento%></p>
                                <p class="text-sm mb-0">
                                    <i class="fa fa-arrow-up text-success"></i>
                                    <span class="font-weight-bold">Lista de suministros </span>
                                </p>
                            </div>
                            <div class="card-body p-3">
                                <!--              <div class="chart">
                                                <canvas id="chart-line" class="chart-canvas" height="300"></canvas>
                                              </div>-->
                                <div class="table-responsive overflow-auto" style="max-height: 400px;">
                                    <% if(apellidos.equals("Varas Herrera")||apellidos.equals("Bravo")){%>
                                    <div class="row">
<!--                                        <div>
                                            <button type="#" class="btn btn-danger"  href="">
                                                <a class="nav-link " href="../Inventario/INV_Inventario_Lista_Productos.jsp"> <i class="fa fa-eye" aria-hidden="true">  </i>Ingreos de productos </a>
                                            </button>
                                        </div>
                                        <div>
                                            <button type="#" class="btn btn-success"  href="">
                                                <a class="nav-link " href="../Inventario/INV_Productos.jsp"> <i class="fa fa-eye" aria-hidden="true">  </i>Lista de productos </a>
                                            </button>
                                        </div>-->
<!--                                        <div>
                                            <button type="#" class="btn btn-warning"  href="">
                                                <a class="nav-link " href="../Inventario/INV_Ingreso_Suministro2.jsp"> <i class="fa fa-pencil-alt" aria-hidden="true">  </i>Ingreso de suministos </a>
                                            </button>
                                        </div>-->
<!--                                        <div>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUp">   Nuevo Producto</button>
                                        </div>
                                        <div>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUp2">   Nuevo Categoría</button>
                                        </div>
                                        <div>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUpUnidades">   Nuevo Unidad de medida</button>
                                        </div>-->
                                    </div>


                                    <table class="table align-items-center ">

                                        <thead>
                                            <tr class="success">

                                                <!--<th class="text-center">Id Producto</th>-->
                                                <th class="text-center">Descripcion</th>

                                                <!--<th class="text-center">Jefe Asignado</th>-->
                                                
                                                <th class="text-center">Existencia</th> 
                                                <th class="text-center">Unidad</th>
                                                <th class="text-center">Categoria</th>
                                                <!--<th class="text-center">Atender</th>-->

                                            </tr> 
                                        </thead>
                                        <tbody>


                                            <%  
                              try{
                                  DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                  Connection cn4 = DriverManager.getConnection(url, user, pass);
    
//                                  String sql4 = "SELECT a.id_producto, b.descripcion, b.unidad,  a.existencia,  b.inv_id_categoria, c.descripcion AS categoria FROM  inv_suministro_existencia a JOIN  inv_producto b ON a.id_producto = b.id_producto JOIN  inv_categoria c ON b.inv_id_categoria = c.inv_id_categoria";
String exitencia = "SELECT " +
               "    A.id_producto, " +
               "    B.descripcion, " +
               "    SUM(A.cantidad) AS total_cantidad, " +
               "    B.unidad, " +
               "    B.inv_id_categoria, " +
               "    C.descripcion AS categoria " +
               "FROM " +
               "    inv_suministro_ingreso_det A " +
               "INNER JOIN " +
               "    inv_producto B " +
               "    ON A.id_producto = B.id_producto " +
               "INNER JOIN " +
               "    inv_categoria C " +
               "    ON B.inv_id_categoria = C.inv_id_categoria " +
               "GROUP BY " +
               "    A.id_producto, " +
               "    B.descripcion, " +
               "    B.unidad, " +
               "    B.inv_id_categoria, " +
               "    C.descripcion " +
               "ORDER BY " +
               "    B.descripcion";

                          
                                  PreparedStatement st4 = cn4.prepareStatement(exitencia);
                                  ResultSet rs4 = st4.executeQuery();       
                              while (rs4.next()) {%>


                                            <tr>

<!--                                                <td>
                                                    <div class="text-center">
                                                        <p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>
                                                        <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(1))%></h6>
                                                    </div>
                                                </td>-->
                                                <td class="w-30" style="max-width: 300px;">
                                                    <div class="d-flex px-2 py-1 align-items-center">
                                                        <div>
                                                            <!--<a  href="../TODO_det_Trabajo_1.jsp?idCabTrab=<%=rs4.getString(6)%>">-->
                                                            <!--<img src="../image/folder.png" alt="Country flag" style="width: 20px; height: 20px;" >-->

                                                            <!--<img src="../assets/img/icons/Tareas/Tareas1.png" alt="Country flag">-->
                                                            </a>
                                                        </div>
                                                        <div class="ms-4">
                                                            <p class="text-xs font-weight-bold mb-0">
                                                                <%--<%= String.valueOf(rs4.getString(5))%>--%>
                                                            </p>
                                                          <!--<h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(2))%></h6>-->
                                                            <p class="text-xs font-weight-bold mb-0" style="max-width: 100%; word-break: break-word; white-space: normal;">
                                                                <%=rs4.getString(2)%>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-center">
                                                        <!--<p class="text-xs font-weight-bold mb-0">Jefe Asignado:</p>-->
                                                        <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(3))%></h6>

                                                    </div>
                                                </td>


                                                <td>
                                                    <div class="text-center">
                                                        <!--<p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>-->
                                                        <h5 class="text-sm mb-0"><%= String.valueOf(rs4.getString(4))%></h5>
                                                    </div>
                                                </td>
                                                <td class="align-middle text-sm">
                                                    <div class="col text-center">
                                                        <!--<p class="text-xs font-weight-bold mb-0">Fecha Fin:</p>-->
                                                        <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(6))%></h6>
                                                        <!--<h5 class="text-sm mb-0"><%= String.valueOf(rs4.getString(2))%></h5>-->
                                                    </div>
                                                </td>
                                                <td class="align-middle">
                                                    <a href ="../Soportes/SOP_EditarSolicitudes.jsp?idSolicitud=<%= rs4.getString(1)%>&fecha=<%= rs4.getString(1)%>&soporte=<%= rs4.getString(5)%>&prioridad=<%= rs4.getString(6)%>&estado=<%= rs4.getString(6)%>" class="btn btn-sm btn-warning mb-0 d-none d-lg-block "><i class="ni ni-app"></i> </a>
                                                </td>
                                            </tr>

                                            <%}%>

                                            <!--inicio de registro-->
                                            <!--                  <tr>
                                                                <td class="w-30">
                                                                  <div class="d-flex px-2 py-1 align-items-center">
                                                                    <div>
                                                                        <img src="../assets/img/icons/flags/BR.png" alt="Country flag">
                                                                    </div>
                                                                    <div class="ms-4">
                                                                      <p class="text-xs font-weight-bold mb-0">Devolucion IVA exportador</p>
                                                                      <h6 class="text-sm mb-0">Balseca</h6>
                                                                    </div>
                                                                  </div>
                                                                </td>
                                                                <td>
                                                                  <div class="text-center">
                                                                    <p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>
                                                                    <h6 class="text-sm mb-0">12 Agosto 2023</h6>
                                                                  </div>
                                                                </td>
                                                                <td>
                                                                  <div class="text-center">
                                                                    <p class="text-xs font-weight-bold mb-0">Avance:</p>
                                                                    <h6 class="text-sm mb-0">5%</h6>
                                                                  </div>
                                                                </td>
                                                                <td class="align-middle text-sm">
                                                                  <div class="col text-center">
                                                                    <p class="text-xs font-weight-bold mb-0">Fecha Fin:</p>
                                                                    <h6 class="text-sm mb-0">31 Octubre 2023</h6>
                                                                  </div>
                                                                </td>
                                                              </tr>-->
                                            <!--fin de registro-->
                                        </tbody>
                                    </table>
                                    <% rs4.close();
                                  st4.close();
                                  cn4.close();
                                  }catch(Exception e){
                                    e.printStackTrace();
                            } 
                            }%>

                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-5">
                        <div class="card card-carousel overflow-hidden h-100 p-0">
                            <div id="carouselExampleCaptions" class="carousel slide h-100" data-bs-ride="carousel">
                                <div class="carousel-inner border-radius-lg h-100">
                                    <div class="carousel-item h-100 active" style="background-image: url('../assets/img/carousel-1.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-camera-compact text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Panel de control</h5>
                                            <p>Ahora puedes ver el avance de tus tareas junto con tus colegas, con la nueva vista de gráficos.</p>
                                        </div>
                                    </div>
                                    <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-2.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-bulb-61 text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Indicadores de avance</h5>
                                            <p>Gestionar tus tareas y medir tu rendimiento con los indicadores.</p>
                                        </div>
                                    </div>
                                    <div class="carousel-item h-100" style="background-image: url('../assets/img/carousel-3.jpg');
                                         background-size: cover;">
                                        <div class="carousel-caption d-none d-md-block bottom-0 text-start start-0 ms-5">
                                            <div class="icon icon-shape icon-sm bg-white text-center border-radius-md mb-3">
                                                <i class="ni ni-trophy text-dark opacity-10"></i>
                                            </div>
                                            <h5 class="text-white mb-1">Si lo que necesitas es terminar tus tareas más rápido!</h5>
                                            <p>No dudes en visitar nuestro tutorial.</p>
                                        </div>
                                    </div>
                                </div>
                                <button class="carousel-control-prev w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="prev">
                                    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Previous</span>
                                </button>
                                <button class="carousel-control-next w-5 me-3" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="next">
                                    <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Next</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mt-4">
                    <div class="col-lg-7 mb-lg-0 mb-4">
                        <div class="card ">
                            <div class="card-header pb-0 p-3">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-2">Lista de proyectos en General DEFINIR</h6>
                                    <p><%=roltodo%></p>
                                </div>
                            </div>
                            <div class="table-responsive overflow-auto" style="max-height: 400px;">
                                <table class="table align-items-center ">

                                    <thead>
                                        <tr class="success">
                                            <th class="text-center">Cliente</th>

                                            <th class="text-center">Jefe Asignado</th>
                                            <th class="text-center">Fecha</th>
                                            <!--                <th class="text-center">Fecha Inicio</th>-->
                                            <th class="text-center">Avance</th>  
                                            <!--<th class="text-center">Fecha Fin</th>-->


                                        </tr> 
                                    </thead>
                                    <tbody>


                                        <%  
                          try{
                              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                              Connection cn4 = DriverManager.getConnection(url, user, pass);
                              String sql4 ="";
                               if(roltodo.equals("JEFE")||roltodo.equals("CONTRALOR")){
                                 sql4 = "SELECT to_char(B.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,a.CLIENTE, "
                                         + "b.TRABAJO, b.ESTTRAB,b.IDTODOCAB ,b.IDJEFEASIG, C.NOMBRE||' '||C.APELLIDOS, b.idtodocabgrupo, d.tarea, d.id_todo_cab_tareas  from cliente a,TODOCABTRAB b , USUARIO C , todo_cab_tareas d "
                                         + "where a.IDCLIENTE = b.IDCLIENTE and b.ESTADO = 'A' and (b.IDUSUARIO= "+codigo+" or b.IDJEFEASIG= "+codigo+") and b.ESTTRAB "+EstTrab+" and b.IDJEFEASIG=C.IDUSUARIO and b.idcabtarea = d.id_todo_cab_tareas order by 7 DESC";
                              }else if(roltodo.equals("ASISTENTE")||roltodo.equals("JEFE")){
                                 sql4 = "SELECT to_char(B.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,a.CLIENTE, b.TRABAJO, b.ESTTRAB,b.IDTODOCAB "
                                   + " from cliente a,(SELECT DISTINCT B.IDTODOCABTRAB, A.IDTODOCAB, A.IDUSUARIO, A.DESCRIPCION, A.TRABAJO, "
                                   + " A.FECHAINCIO, A.FECHAFIN, A.FECHAHORAASIG, A.FECHALEGAL, A.FECHACONTRATO, A.IDCLIENTE, A.ESTADO, A.COMENTARIO, A.IDTODOAREA, A.ESTTRAB, A.IDTODOCABGRUPO "
                                   + " FROM TODOCABTRAB A,TODODETTRAB B, TODOASIGTAREA C WHERE A.IDTODOCAB = B.IDTODOCABTRAB AND B.IDTODODET = C.IDTODODETTRAB "
                                   + " AND C.IDUSUARIO = "+codigo+" ) b where a.IDCLIENTE = b.IDCLIENTE and b.ESTADO = 'A' and b.ESTTRAB "+EstTrab+" order by 7 DESC";
                              }
                              PreparedStatement st4 = cn4.prepareStatement(sql4);
                              ResultSet rs4 = st4.executeQuery();       
                          while (rs4.next()) {%>


                                        <tr>

                                            <td class="w-30">
                                                <div class="d-flex px-2 py-1 align-items-center">
                                                    <div >
                                                        <a class="btn btn-xs btn-primary " href="../Proyectos/PRO_Detalle_Trabajo.jsp?idCabTrab=<%=rs4.getString(7)%>&jefeAsignado=<%= String.valueOf(rs4.getString(9))%>&idCabTarea=<%=rs4.getString(12)%>">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                            <!--                              <a class="btn btn-xs btn-primary " href="../TODO_det_Trabajo_1.jsp?idCabTrab=<%=rs4.getString(7)%>">
                                                            <i class="fas fa-eye"></i>
                                                        </a>-->
                                                        <!--<img src="../assets/img/icons/Tareas/Tareas1.png" alt="Country flag" >-->
                                                    </div>
                                                    <div class="ms-4">
                                                        <p class="text-xs font-weight-bold mb-0">
                                                            <%--<%= String.valueOf(rs4.getString(5))%>--%>
                                                        </p>
                                                        <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(11))%> </h6>
                            <!--                          <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(4))%> TODOCABTRAB <%= String.valueOf(rs4.getString(7))%></h6>-->
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="text-center">
                                                    <!--<p class="text-xs font-weight-bold mb-0">Jefe Asignado:</p>-->
                                                    <h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(9))%></h6>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="text-center">
                                                    <!--<p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>-->
                                                    <h6 class="text-sm mb-0">Inicio: <%= String.valueOf(rs4.getString(1))%></h6>
                                                    <h6 class="text-sm mb-0">Fin: <%= String.valueOf(rs4.getString(2))%></h6>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="text-center">
                                                    <!--<p class="text-xs font-weight-bold mb-0">Avance:</p>-->

                                                    <%if(rs4.getString(6).equals("P")){%>
                                                    <h6 class="text-sm mb-0"  title="El proyecto se encuentra en proceso." style="background-color: yellow">PENDIENTE</h6>
                                                    <!--<td type="text"title="El proyecto se encuentra en proceso." style="background-color: yellow"> PENDIENTE</td>-->
                                                    <%}%>
                                                    <%if(rs4.getString(6).equals("T")){%>
                                                    <h6 class="text-sm mb-0" title="Proyecto Terminado." style="background-color: #99ff66">TERMINADO</h6>
                                                    <!--<td type="text"title="Proyecto Terminado." style="background-color: #99ff66">  TERMINADO</td>-->
                                                    <%}%>
                                                    <%if(rs4.getString(6).equals("A")){%>
                                                    <h6 class="text-sm mb-0" title="Proyecto Atrasado." style="background-color: #ff9999">ATRASADO</h6>
                                                    <!--<td type="text"title="Proyecto Atrasado." style="background-color: #ff9999">  ATRASADO</td>-->
                                                    <%}%>
                                                    <%if(rs4.getString(6).equals("R")){%>
                                                    <h6 class="text-sm mb-0"  title="Proyecto Reversado." style="background-color: #ff5722">REVERSADO</h6>
                                                    <!--<td type="text"title="Proyecto Reversado." style="background-color: #ff5722">  REVERSADO</td>-->
                                                    <%}%>
                                                    <%if(rs4.getString(6).equals("I")){%>
                                                    <h6 class="text-sm mb-0"  title="Proyecto Reversado." style="background-color: #ff5722">INACTIVO</h6>
                                                    <!--<td type="text"title="Proyecto Reversado." style="background-color: #ff5722">  REVERSADO</td>-->
                                                    <%}%>
                                                </div>
                                            </td>
                                            <td class="align-middle text-sm">
                                                <div class="col text-center">
                                                    <!--<p class="text-xs font-weight-bold mb-0">Fecha Fin:</p>-->
                                                    <!--<h6 class="text-sm mb-0"><%= String.valueOf(rs4.getString(2))%></h6>-->
                                                </div>
                                            </td>
                                        </tr>

                                        <%}%>

                                        <!--inicio de registro-->
                                        <!--                  <tr>
                                                            <td class="w-30">
                                                              <div class="d-flex px-2 py-1 align-items-center">
                                                                <div>
                                                                    <img src="../assets/img/icons/flags/BR.png" alt="Country flag">
                                                                </div>
                                                                <div class="ms-4">
                                                                  <p class="text-xs font-weight-bold mb-0">Devolucion IVA exportador</p>
                                                                  <h6 class="text-sm mb-0">Balseca</h6>
                                                                </div>
                                                              </div>
                                                            </td>
                                                            <td>
                                                              <div class="text-center">
                                                                <p class="text-xs font-weight-bold mb-0">Fecha Inicio:</p>
                                                                <h6 class="text-sm mb-0">12 Agosto 2023</h6>
                                                              </div>
                                                            </td>
                                                            <td>
                                                              <div class="text-center">
                                                                <p class="text-xs font-weight-bold mb-0">Avance:</p>
                                                                <h6 class="text-sm mb-0">5%</h6>
                                                              </div>
                                                            </td>
                                                            <td class="align-middle text-sm">
                                                              <div class="col text-center">
                                                                <p class="text-xs font-weight-bold mb-0">Fecha Fin:</p>
                                                                <h6 class="text-sm mb-0">31 Octubre 2023</h6>
                                                              </div>
                                                            </td>
                                                          </tr>-->
                                        <!--fin de registro-->
                                    </tbody>
                                </table>
                                <% rs4.close();
                              st4.close();
                              cn4.close();
                              }catch(Exception e){
                                e.printStackTrace();
                              }%>  
                            </div>
                        </div>
                        <div >

                            <!--para borrar-->   

                        </div>
                    </div>
                    <%if(apellidos.equals("Varas Herrera")){%>
                    <div class="col-lg-5">
                        <div class="card">
                            <div class="card-header pb-0 p-3">
                                <h6 class="mb-0">Atender notificaciones</h6>

                            </div>


                            <div class="card-body p-3">
                                <ul class="list-group">
                                    <!--                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                                                      <div class="d-flex align-items-center">
                                                        <div class="icon icon-shape icon-sm me-3 bg-gradient-dark shadow text-center">
                                                          <i class="ni ni-mobile-button text-white opacity-10"></i>
                                                        </div>
                                                        <div class="d-flex flex-column">
                                                          <h6 class="mb-1 text-dark text-sm">Arturs Audit Global</h6>
                                                          <span class="text-xs">250 in stock, <span class="font-weight-bold">346+ sold</span></span>
                                                        </div>
                                                      </div>
                                                      <div class="d-flex">
                                                        <button class="btn btn-link btn-icon-only btn-rounded btn-sm text-dark icon-move-right my-auto"><i class="ni ni-bold-right" aria-hidden="true"></i></button>
                                                      </div>
                                                    </li>-->
                                    <div class="table-responsive p-0">
                                        <table class="table align-items-center justify-content-center mb-0"  id= "example"> 
                                            <thead>
                                                <tr>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Ejecutivo</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Fecha Ingreso</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Fecha Notificación</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Solicitante</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Jefe Inmediato</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Estado</th>
                                                    <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Atender</th>-->
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
                         solicitudes = "select  a.apellidos, a.nombres, TO_CHAR(a.fecha_ingreso, 'DD/MM/YYYY') ,b.nombre, b.apellidos,TO_CHAR(a.fecha_notificacion, 'DD/MM/YYYY HH24:MI') , a.compania,a.rol, a.actividades,  a.estado, a.idnotificaciones, a.jefe_inmediato, a.observaciones FROM adm_notificaciones a INNER JOIN usuario b ON a.id_usuario_solicitante = b.idusuario WHERE   a.estado = 'PENDIENTE' ";
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
                                                                <p class="text-xs text-secondary mb-0">  <b><%=rsa1.getString(13)%></b></p>
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
                                                        <%if(usuario.equals("uparrales")){%>
                                                        <%}else if(rsa1.getString(10).equals("PENDIENTE")){%>
                                                        <button class="btn btn-link text-primary mb-0">
                                                            <a href="../Proyectos/PRO_AtenderNotificacion.jsp?idNotificacion=<%= rsa1.getString(11)%>">Atender <i  class="fa fa-chevron-down text-xs"></i> </a>
                                                        </button>
                                                        <%}%>
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
                                    <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                                        <div class="d-flex align-items-center">
                                            <div class="icon icon-shape icon-sm me-3 bg-gradient-danger shadow text-center">
                                                <i class="ni ni-bell-55 text-white opacity-10"></i>
                                                <!--<i class="ni ni-tag text-white opacity-10"></i>-->
                                            </div>
                                            <div class="d-flex flex-column">
                                                <button class="btn btn-link text-secondary mb-0">
                                                    <a href="../Proyectos/PRO_Notificaciones.jsp">
                                                        <h6 class="mb-1 text-dark text-sm"></h6>
                                                        <span class="text-xs">Ver todas las notificaciones, <span class="font-weight-bold">aprobadas y pendientes</span></span>

                                                        <!--<i  class="fa fa-bell text-xs"></i> </a>-->
                                                </button>

                                            </div>
                                        </div>
                                        <div class="d-flex">
                                            <button class="btn btn-link btn-icon-only btn-rounded btn-sm text-dark icon-move-right my-auto"><i class="ni ni-bold-right" aria-hidden="true"></i></button>
                                        </div>
                                    </li>
                                    <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                                        <div class="d-flex align-items-center">
                                            <div class="icon icon-shape icon-sm me-3 bg-gradient-dark shadow text-center">
                                                <i class="ni ni-tag text-white opacity-10"></i>
                                            </div>
                                            <div class="d-flex flex-column">
                                                <h6 class="mb-1 text-dark text-sm">Buadnet S.A.</h6>
                                                <span class="text-xs">123 closed, <span class="font-weight-bold">15 open</span></span>
                                            </div>
                                        </div>
                                        <div class="d-flex">
                                            <button class="btn btn-link btn-icon-only btn-rounded btn-sm text-dark icon-move-right my-auto"><i class="ni ni-bold-right" aria-hidden="true"></i></button>
                                        </div>
                                    </li>


                                    <!--                <li class="list-group-item border-0 d-flex justify-content-between ps-0 mb-2 border-radius-lg">
                                                      <div class="d-flex align-items-center">
                                                        <div class="icon icon-shape icon-sm me-3 bg-gradient-dark shadow text-center">
                                                          <i class="ni ni-box-2 text-white opacity-10"></i>
                                                        </div>
                                                        <div class="d-flex flex-column">
                                                          <h6 class="mb-1 text-dark text-sm">Latinconsulting S.A.</h6>
                                                          <span class="text-xs">1 is active, <span class="font-weight-bold">40 closed</span></span>
                                                        </div>
                                                      </div>
                                                      <div class="d-flex">
                                                        <button class="btn btn-link btn-icon-only btn-rounded btn-sm text-dark icon-move-right my-auto"><i class="ni ni-bold-right" aria-hidden="true"></i></button>
                                                      </div>
                                                    </li>-->
                                    <!--                <li class="list-group-item border-0 d-flex justify-content-between ps-0 border-radius-lg">
                                                      <div class="d-flex align-items-center">
                                                        <div class="icon icon-shape icon-sm me-3 bg-gradient-dark shadow text-center">
                                                          <i class="ni ni-satisfied text-white opacity-10"></i>
                                                        </div>
                                                        <div class="d-flex flex-column">
                                                          <h6 class="mb-1 text-dark text-sm">Happy users</h6>
                                                          <span class="text-xs font-weight-bold">+ 430</span>
                                                        </div>
                                                      </div>
                                                      <div class="d-flex">
                                                        <button class="btn btn-link btn-icon-only btn-rounded btn-sm text-dark icon-move-right my-auto"><i class="ni ni-bold-right" aria-hidden="true"></i></button>
                                                      </div>
                                                    </li>-->
                                </ul>
                            </div>
                        </div>
                    </div>
                    <%}%>

                </div>
                <!--FIN DEL TODO-->

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
    <script src="../assets/js/plugins/chartjs.min.js"></script>
    <script>
                  var ctx1 = document.getElementById("chart-line").getContext("2d");

                  var gradientStroke1 = ctx1.createLinearGradient(0, 230, 0, 50);

                  gradientStroke1.addColorStop(1, 'rgba(94, 114, 228, 0.2)');
                  gradientStroke1.addColorStop(0.2, 'rgba(94, 114, 228, 0.0)');
                  gradientStroke1.addColorStop(0, 'rgba(94, 114, 228, 0)');
                  new Chart(ctx1, {
                      type: "line",
                      data: {
                          labels: ["Ene", "Feb", "Marz", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
                          datasets: [{
                                  label: "Mobile apps",
                                  tension: 0.4,
                                  borderWidth: 0,
                                  pointRadius: 0,
                                  borderColor: "#5e72e4",
                                  backgroundColor: gradientStroke1,
                                  borderWidth: 3,
                                  fill: true,
                                  data: [50, 40, 300, 220, 500, 250, 400, 230, 500, 300, 400, 500],
                                  maxBarThickness: 6

                              }],
                      },
                      options: {
                          responsive: true,
                          maintainAspectRatio: false,
                          plugins: {
                              legend: {
                                  display: false,
                              }
                          },
                          interaction: {
                              intersect: false,
                              mode: 'index',
                          },
                          scales: {
                              y: {
                                  grid: {
                                      drawBorder: false,
                                      display: true,
                                      drawOnChartArea: true,
                                      drawTicks: false,
                                      borderDash: [5, 5]
                                  },
                                  ticks: {
                                      display: true,
                                      padding: 10,
                                      color: '#fbfbfb',
                                      font: {
                                          size: 11,
                                          family: "Open Sans",
                                          style: 'normal',
                                          lineHeight: 2
                                      },
                                  }
                              },
                              x: {
                                  grid: {
                                      drawBorder: false,
                                      display: false,
                                      drawOnChartArea: false,
                                      drawTicks: false,
                                      borderDash: [5, 5]
                                  },
                                  ticks: {
                                      display: true,
                                      color: '#ccc',
                                      padding: 20,
                                      font: {
                                          size: 11,
                                          family: "Open Sans",
                                          style: 'normal',
                                          lineHeight: 2
                                      },
                                  }
                              },
                          },
                      },
                  });
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
    <script>
       function verificarTiempo() {
           //optener la hora actual
           var now = new Date();
           var hour = now.getHours();
           var minute = now.getMinutes();

           //verificar la hora de intervalo activo
           //
 //          en minuto final quitar uno 
           if (hour === 08 && minute >= 00 && hour <= 08 && minute <= 50) {
               document.getElementById("guardar").disabled = false;
           } else {
               document.getElementById("guardar").disabled = true;
           }



       }

       verificarTiempo();

       setInterval(verificarTiempo, 60000);

    </script>
</body>

</body>
</html>
