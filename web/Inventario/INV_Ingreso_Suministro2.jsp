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
    String roltodo = (String) session.getAttribute("roltodo");
    String cabTrab = request.getParameter("idCabTrab");
    String DetTrab = request.getParameter("DetTrab");
    String DetTrabAC = "";
    String NombreAsig= request.getParameter("asis");
   
        String departamento = (String) session.getAttribute("departamento");

     String jefeAsignado= request.getParameter("jefeAsignado");
     String idCabTarea =  request.getParameter("idCabTarea");
     
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String NombreTarea="";
    
    String id_suministro_ingreso_cab ="";
    int p =0;
    int t =0;
    int r=0;
    int avance = 0;
     int retomar =0;
    
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
             if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")){
                }else{
                    response.sendRedirect("../sesionInvalida.jsp");
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
            ProMaNet | Ingreso Suministros
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

        <script>
            var id =<%=DetTrabAC%>;
            if (id > 0) {
                $(window).load(function () {
                    $('#myModalACTIVIDADES').modal('show');
                }
                );
            }
        </script> 
        <script>
            var id =<%=DetTrab%>;
            if (id > 0) {
                $(window).load(function () {
                    $('#myModalASISTENTE').modal('show');
                }
                );
            }
        </script> 

    </head>
    <body class="g-sidenav-show   bg-gray-100">
        <div class="min-height-300 bg-primary position-absolute w-100"></div>
        <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
            <div class="sidenav-header">
                <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
                <a class="navbar-brand m-0" href=" #" target="_blank">
                    <img src="../assets/img/logo-ct-dark.png" class="navbar-brand-img h-100" alt="main_logo">
                    <span class="ms-1 font-weight-bold">INVENTARIOS</span>
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
                        <a class="nav-link active" href="../Proyectos/PRO_Lista.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Lista de Proyectos</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../Inventario/INV_Lista_Productos.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-calendar-grid-58 text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Lista de Productos</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <!--          <a class="nav-link " href="../pages/billing.html">
                                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                      <i class="ni ni-credit-card text-success text-sm opacity-10"></i>
                                    </div>
                                    <span class="nav-link-text ms-1">Billing</span>
                                  </a>-->
                    </li>
                    <li class="nav-item">
                        <!--          <a class="nav-link " href="../pages/virtual-reality.html">
                                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                      <i class="ni ni-app text-info text-sm opacity-10"></i>
                                    </div>
                                    <span class="nav-link-text ms-1">Virtual Reality</span>
                                  </a>-->
                    </li>
                    <li class="nav-item">
                        <!--          <a class="nav-link " href="../pages/rtl.html">
                                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                      <i class="ni ni-world-2 text-danger text-sm opacity-10"></i>
                                    </div>
                                    <span class="nav-link-text ms-1">RTL</span>
                                  </a>-->
                    </li>
                    <li class="nav-item mt-3">
                        <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">PANEL DE CONTROL</h6>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Perfil.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Perfil</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <!--          <a class="nav-link " href="../pages/sign-in.html">
                                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                      <i class="ni ni-single-copy-04 text-warning text-sm opacity-10"></i>
                                    </div>
                                    <span class="nav-link-text ms-1">Sign In</span>
                                  </a>-->
                    </li>
                    <li class="nav-item">
                        <!--          <a class="nav-link " href="../pages/sign-up.html">
                                    <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                      <i class="ni ni-collection text-info text-sm opacity-10"></i>
                                    </div>
                                    <span class="nav-link-text ms-1">Sign Up</span>
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
                            <p class="text-xs font-weight-bold mb-0">Revisa nuestro tutorial</p>
                        </div>
                    </div>
                </div>
                <a href="#" target="_blank" class="btn btn-dark btn-sm w-100 mb-3">Video Tutorial</a>
                <!--<a class="btn btn-primary btn-sm mb-0 w-100" href="https://www.creative-tim.com/product/argon-dashboard-pro?ref=sidebarfree" type="button">Upgrade to pro</a>-->
            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <!-- Navbar -->
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="javascript:;">Menu</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Inventario</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Ingreso de suministros</h6>
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

            <!--modales--> 
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

                                            <label>Producto</label>

                                            <div class="input-group mb-3">
                                                <input type="text" class="form-control" placeholder="" aria-label="Password" aria-describedby="password-addon" id="descripcion" name ="descripcion" required="true">
                                            </div>

                                            <label>Unidad de medida:</label>
                                            <div class="input-group mb-3">
                                                <!--<input type="number" class="form-control"  aria-label="Email" aria-describedby="email-addon" name="alimentacion" id="alimentacion" value="3.50">-->
                                                <select class="chosen-select form-control" id="unidad" name ="id_unidad" required="true">
                                                    <%
                                        try{
                                        String unidad2 = "saludos";
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
                                        String sql = "select * from INV_UNIDAD_MEDIDA where estado = 'A' order by 2";
                                        PreparedStatement st = cn.prepareStatement(sql);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()) {%>        
                                                    <option value="<%= rs.getString(1) + "," + rs.getString(3) %>"><%=rs.getString(2)%> -      <%=rs.getString(3) %> </option> 
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
                                                <select class="chosen-select form-control" id="idCategoria" name ="idCategoria" required="true">
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
            <!--FIN UNIDADES DE MEDIDA-->

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
            <!--fin modal categoria-->

            <div class="container-fluid py-4">
                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4">
                            <div class="card-header pb-0">
                                <div class="row">
                                    <label for="example-text-input" class="form-control-label"> Funciones para productos</label>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="example-text-input" class="form-control-label"> </label>
                                            <label for="example-text-input" class="form-control-label"> </label>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignProveedor">   Nuevo proveedor</button>
                                            <!--<a class="btn btn-xs btn-warning "  <i class="fas fa-plus"></i> </a>-->
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="example-text-input" class="form-control-label"> </label>
                                            <label for="example-text-input" class="form-control-label"> </label>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUpUnidades">   Nuevo Unidad de medida</button>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="example-text-input" class="form-control-label"></label>
                                            <label for="example-text-input" class="form-control-label">  </label>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUp2">   Nuevo Categoría</button>
                                            <!--<input class="form-control" type="date" name ="fechaRecibido">-->
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label for="example-text-input" class="form-control-label"></label>
                                            <label for="example-text-input" class="form-control-label">  </label>
                                            <button type="#" class="btn btn-primary"  href=""  data-bs-toggle="modal" data-bs-target="#exampleModalSignUp">   Nuevo Producto</button>
                                            <!--<input class="form-control" type="date" name ="fechaRecibido">-->
                                        </div>
                                    </div>
                                </div>
                                <hr class="horizontal dark">
                                <h6>Información - Factura </h6>
                            </div>
                            <div class="card-body px-0 pt-0 pb-2">
                                <div class="table-responsive p-0">



                                    <div class="card-body">
                                        <form role="form text-left" action="../INV_Insert_Ingreso_Suministro_Cab">
                                            <div class="row">

                                                <div class="col-md-3">

                                                    <div class="form-group">
                                                        <label for="example-text-input" class="form-control-label">Fecha Compra </label>
                                                        <label for="example-text-input" class="form-control-label"> </label>

                                                        <input class="form-control" type="date" name="fechaCompra" required="true" >
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label for="example-text-input" class="form-control-label">Fecha Pedido </label>
                                                        <label for="example-text-input" class="form-control-label"> </label>
                                                        <input class="form-control" type="date" name="fechaPedido" required="true">
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label for="example-text-input" class="form-control-label">Fecha Recibido</label>
                                                        <label for="example-text-input" class="form-control-label">  </label>
                                                        <input class="form-control" type="date" name ="fechaRecibido " required="true">
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label for="example-text-input" class="form-control-label">Factura #</label>
                                                        <label for="example-text-input" class="form-control-label">  </label>
                                                        <input class="form-control" type="text" placeholder="001-001-00000123" name="numero_factura" required="true">
                                                    </div>
                                                </div>

                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="example-text-input" class="form-control-label">Proveedor </label>

                                                        <select class="form-control" name="idProveedor" required="true">
                                                            <%try{
                                                             DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                             Connection   cn2 = DriverManager.getConnection(url, user, pass);
                                                             String proveedor = "select * from inv_proveedor where estado = 'A' order by 3";
                                                             PreparedStatement st2 = cn2.prepareStatement(proveedor);
                                                             ResultSet rs2 = st2.executeQuery();       
                                                             while (rs2.next()) {%>         
                                                            <option value="<%=rs2.getString(1)%>"><%=rs2.getString(2)+" - "+rs2.getString(3)%></option>

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
                                                <div class="col-md-6">

                                                </div>

                                                <div class="modal-footer">
                                                    <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Close</button>
                                                    <label>   </label> 
                                                    <button type="submit" class="btn bg-gradient-success">Generar documento</button>
                                                </div>


                                        </form>

                                        <hr class="horizontal dark">

                                        <!--modal nuevo proveedor-->
                                        <div class="modal fade" id="exampleModalSignProveedor" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered modal-md" role="document">
                                                <div class="modal-content">
                                                    <div class="modal-body p-0">
                                                        <div class="card card-plain">
                                                            <div class="card-header pb-0 text-left">
                                                                <h3 class="font-weight-bolder text-primary text-gradient">Nuevo Proveedor</h3>
                                                                <!--<p class="mb-0">Ingresar datos</p>-->
                                                            </div>
                                                            <div class="card-body pb-3">
                                                                <form role="form text-left" action="../INV_InsertProveedor" >
                                                                    <!--<form role="form text-left" action="../INV_InsertCategoria">-->
                                                                    <div> 
                                                                        <input type="hidden" value="<%=cabTrab%>" name="idCab">
                                                                        <input type="hidden" value="<%=idCabTarea%>" name="idCabTarea1">
                                                                        <label>Identificación:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="text" class="form-control" placeholder="0923000000" aria-label="Password" aria-describedby="password-addon"  name="identificacion" required="true" >
                                                                        </div>
                                                                        <label>Razón Social:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="text" class="form-control" placeholder="Nombre comercial" aria-label="Password" aria-describedby="password-addon"  name="razonSocial" required="true">
                                                                        </div>
                                                                        <label>Dirección:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="text" class="form-control" placeholder="Av. Calle" aria-label="Password" aria-describedby="password-addon"  name="direccion" >
                                                                        </div>
                                                                        <label>Telefonos:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="text" class="form-control" placeholder="0994154441 - 6003701" aria-label="Password" aria-describedby="password-addon"  name="telefonos" >
                                                                        </div>
                                                                        <label>Correo:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="mail" class="form-control" placeholder="nombre@negocio.com" aria-label="Password" aria-describedby="password-addon"  name="correo" >
                                                                        </div>
                                                                        <label>Contacto:  </label>
                                                                        <div class="input-group mb-3">
                                                                            <input type="text" class="form-control" placeholder="Nombre del contacto compras" aria-label="Password" aria-describedby="password-addon"  name="contacto" >
                                                                        </div>

                                                                        <div class="modal-footer">
                                                                            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Close</button>
                                                                            <button type="submit" class="btn bg-gradient-primary">Guardar</button>
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
                                        <!--FIN  Modal asignar tarea ajecutivo  -->

                                        <!--modal lista de tareas del ejecutivo-->

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
                                    <!--modal tareas realizadas por el ejecutivo-->




                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                
                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4">
                            <div class="card-header pb-0">
                                <h6>Facturas de suministros.</h6>
                                <!--<a class="btn btn-xs btn-warning " href="PRO_NUEVA_TAREA.jsp?idCabTarea=<%=idCabTarea%>"> <i class="fas fa-plus"></i>    Agregar nueva tarea</a>-->

                                <div class="card-body px-0 pt-0 pb-2">
                                    <div class="table-responsive p-0">
                                        <table class="table align-items-center justify-content-center mb-0">
                                            <thead>
                                                <tr>
                                                    <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Tarea</th>-->
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Compra</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Pedido</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Recibido</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Factura</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Razón Social</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Identificación</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Usuario</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Ver</th>
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Registrar Productos</th>
                                                    <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Editar</th>-->
                                                    <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Eliminar</th>
                                                    <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2">Avance</th>-->
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <%try{
                                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                       Connection cn = DriverManager.getConnection(url, user, pass);
                                       String sql ="";
                                       String query = "";
                                        
                                             query = "SELECT " +
               "    a.id_suministro_ingreso_cab AS id_ingreso, " +
               "    to_char(A.fecha_compra, 'DD/MON/YYYY'), " +
               "    to_char(A.fecha_pedido, 'DD/MON/YYYY'),  " +
               "    to_char(A.fecha_recibido, 'DD/MON/YYYY'), " +
               "    a.numero_factura, " +
               "    b.razon_social AS proveedor, " +
               "    b.identificacion AS ruc_proveedor, " +
               "    c.usuario AS nombre_usuario, a.estado " +
               "FROM " +
               "    inv_suministro_ingreso_cab a " +
               "INNER JOIN " +
               "    inv_proveedor b " +
               "    ON a.id_inv_proveedor = b.id_proveedor " +
               "INNER JOIN " +
               "    usuario c " +
               "    ON a.id_usuario = c.idusuario " +
               "WHERE " +
               "    a.estado IN ('A', 'C')  " +
               "ORDER BY " +
               "    a.fecha_compra DESC";

                                          
                                       PreparedStatement st = cn.prepareStatement(query);
                                       ResultSet rs = st.executeQuery();       
                                   while (rs.next()) {%>   
                                            <tbody>
                                                <tr>

                                                    <td>
                                                        <p class="text-sm font-weight-bold mb-0"><%= rs.getString(2)%>   </p>
                                                        <p class="text-sm font-weight-bold mb-0"><%= id_suministro_ingreso_cab =rs.getString(1)%> </p>
                                                    </td>
                                                    <td>
                                                        <p class="text-sm font-weight-bold mb-0"><%= rs.getString(3)%></p>
                                                    </td>
                                                    <td>
                                                        <span class="text-xs font-weight-bold"><%= rs.getString(4)%>   </span>

                                                    </td>
                                                    <td>
                                                        <span class="text-xs font-weight-bold"><%= rs.getString(5)%></span>

                                                    </td>
                                                    <td>
                                                        <span class="text-xs font-weight-bold"><%= rs.getString(6)%></span>

                                                    </td>
                                                    <td>
                                                        <span class="text-xs font-weight-bold"><%= rs.getString(7)%></span>

                                                    </td>
                                                    <td>
                                                        <span class="text-xs font-weight-bold"><%= rs.getString(8)%></span>

                                                    </td>


                                                    <td>

                                                        <a class="btn btn-xs btn-primary "  data-id="<%=rs.getString(1)%>"  data-bs-toggle="modal" data-bs-target="#modalListaTareas" > 
                                                            <i class="ni ni-bag-17"></i>
                                                        </a>
                                                    <td >
                                                        <% if(rs.getString(9).equals("C")) {%>
                                                        <!--<a class="btn btn-xs btn-danger" data-bs-toggle="tooltip" title="Elimina esta tarea, eliminación en cascada (las tareas aplicadas en este proceso se eliminaran)!" href="../TODO_EliminarTrabajo.jsp?idCab=<%=cabTrab%>&idDetTrab=<%=rs.getString(1)%>"> <i class="fas fa-trash-alt"></i></a></td>-->
                                                        <span class="text-m font-weight-bold text-danger">Procesado</span>
                                                        <%}else{%>

                                                        <a class="btn btn-sm btn-primary "data-bs-toggle="tooltip" title="Agrega productos al registro" href="INV_Ingreso_Suministro_Detalle.jsp?ID_SUMINISTRO_INGRESO_CAB=<%=rs.getString(1)%>"> <i class="ni ni-cart"></i></a>
                                                    </td>
                                                    <td >
                                                        <a class="btn btn-sm btn-danger" 
                                                           data-bs-toggle="tooltip" 
                                                           title="Eliminar este registro!" 
                                                           href="../INV_Delete_Suministro_Cab?ID_SUMINISTRO_INGRESO_CAB=<%=rs.getString(1)%>" 

                                                           onclick="return confirm('¿Estás seguro de que deseas eliminar este registro?');">
                                                            <i class="ni ni-basket"></i>
                                                        </a>
                                                       
                                               <!--<a class="btn btn-s btn-danger" data-bs-toggle="tooltip" title="Eliminar este registro!" href="TODO_det_Trabajo.jsp?ID_SUMINISTRO_INGRESO_CAB=<%=rs.getString(1)%>"><i class="ni ni-basket"></i></a>-->
                                                    </td>
                                                    <%}%>

                                                </tr>


                                            </tbody>

                                            <%}rs.close();
                                         st.close();
                                         cn.close();
                                     }catch(Exception e){
                                          e.printStackTrace();
                                     }%>  
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div> 
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const modal = document.getElementById('modalListaTareas');
                        modal.addEventListener('show.bs.modal', function (event) {
                            const button = event.relatedTarget;
                            const idCabecera = button.getAttribute('data-id');
                            document.getElementById('id_cabecera_modal').value = idCabecera;
 const iframe = document.getElementById('iframeProductos');
                            iframe.src = '../Inventario/productos_modal.jsp?id=' + idCabecera;
                            // Aquí podrías hacer una llamada AJAX para cargar productos en la tabla si deseas
                            // o redireccionar a una página con ?id=...
                        });
                    });
                </script>
<!--                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const modal = document.getElementById('modalListaTareas');
                        modal.addEventListener('show.bs.modal', function (event) {
                            const button = event.relatedTarget;
                            const idCabecera = button.getAttribute('data-id');
                            const iframe = document.getElementById('iframeProductos');
                            iframe.src = 'productos_modal.jsp?id=' + idCabecera;
                        });
                    });
                </script>-->

                <!--detalle productos por factura-->
                <div class="modal fade" id="modalListaTareas" tabindex="-1" role="dialog" aria-labelledby="exampleModalSignTitle" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-body p-0">
                                <div class="card card-plain">
                                    <div class="card-header pb-0 text-left">
                                        <h3 class="font-weight-bolder text-primary text-gradient">Detalle de productos</h3>
                                        <input type="hidden" id="id_cabecera_modal" name="id_cabecera_modal" value="">

                                            
                                        <input type="hidden" value="<%=id_suministro_ingreso_cab%>"> 
                                    </div>
                                    <div class="card-body pb-3">
                                        <table id="detalles" class="table table-striped table-hover">
                                            <thead class="">
                                                
                                            </thead>
                                            <tbody align="center">
                                            <iframe id="iframeProductos"
                                                    src=""
                                                    width="100%" height="400px" frameborder="0"></iframe>
                                              
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <div class="card mb-4">
                            <div class="card-header pb-0">
                                <h6>Tabla de Proyectos en curso</h6>
                            </div>
                            <div class="card-body px-0 pt-0 pb-2">
                                <div class="table-responsive p-0">
                                    <table class="table align-items-center justify-content-center mb-0">
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

                                        </tbody>
                                    </table>
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
