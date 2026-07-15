<%-- 
    Document   : Home
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page contentType="text/html" 
        import=" java.util.Date"
%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>
<!DOCTYPE html>
<%  String compania = (String) session.getAttribute("compania");
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
    
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
             if (!COMUN.PermisoHelper.tiene(session, "ACCESO_GENERAL")) {
                    response.sendRedirect("sesionInvalida.jsp");
                    return;
             }
   %>
<html>
    <head>
        
        <title>ProMaNet | Bienvenido</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href='http://fonts.googleapis.com/css?family=Varela+Round' rel='stylesheet' type='text/css'>        
        <link href="http://netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
        
        <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<!------ Include the above in your HEAD tag ---------->
    </head>

    <body>
        
    <header>
<!--    <div class="container-fluid">
    <div class='row'>
        <div class="logo ">
            <img src="image/banner2020.png" class="img-responsive" > 
        </div>
        <nav class="navbar navbar-default " id="nav2">
        <div class="container-fluid">   
             <div class="nav-links">
                 <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
                     <span class="sr-only" >Menu</span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                 </button>
                 <a href="Home.jsp" class="navbar-brand active" >HOME</a>    
             </div>
             <div  class="collapse navbar-collapse " id="navbar-1" >
                 <ul class="nav navbar-nav " >
                     <li><a href="Contactos.jsp" >CONTACTOS</a></li>
                     <%if(usuario.equals("uparrales")){%>
                        <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                     <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                        <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                     <%}%>
                     <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                     <li><a href="Mantenimiento.jsp">AVANCE</a></li>
                     <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
                            PANEL DE CONTROL<span class="caret"></span></a>
                        <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                            <li class="dropdown-submenu">
                            <a tabindex="-1" href="#" >Crear</a>
                            <ul class="dropdown-menu">
                                <li><a  href="Crear_Clientes.jsp">Crear Cliente</a></li>
                                <li class="divider"></li>
                                <li><a href="PCN_ListadoUsuario.jsp">Crear Usuario</a></li>
                                <li class="divider"></li>
                                <li><a href="#">Crear Rol</a></li>
                                <li class="divider"></li>
                                <li><a href="Grupo_Trabajo.jsp">Crear Grupo de Trabajo</a></li>
                                <li class="divider"></li>
                                <li><a href="INV_ListadoEquipo.jsp">Inventario</a></li>
                            </ul>
                            </li>
                           <li class="divider"></li>
                          <li class="dropdown-submenu">
                            <a tabindex="-1" href="#">Asignacion</a>
                            <ul class="dropdown-menu">
                                <li><a href="RGA_Listado.jsp">Asignacion Reporte de Gastos</a></li>
                            </ul>
                          </li>
                        </ul>
                      </li>
                     <li><a href="cerrar.jsp">CERRAR SESION</a></li>
                 </ul>
             </div>
         </div>   
        </nav>
                     <table class="table active">
                <thead>
                    <tr class="success text-center" colspan="3">
                        <th>
                            <%=compania%>
                        </th>
                        <th>
                            <%=nombre%> <%=apellidos%>
                        </th>
                        <th>
                            <%Date  fecha = new Date();%> 
                            <%=fecha%>
                        </th>
                    </tr>
                </thead>
                <tbody>
                   
                </tbody>
            </table>
                     
        <div class="form-group" class="success">
            <table class="table table-bordered ">
                <tr>       
                     <td class="text-center titulo1" colspan="3" >
                         <b><%=compania%></b>
                     </td>
                     <td class="text-center titulo1" colspan="3">
                         <b> <%=nombre%> <%=apellidos%></b>
                     </td>
                     <td class="text-center titulo1" colspan="3">
                         <b>
                           
                         </b> 
                     </td>
                 </tr>
            </table>
        </div> 
    </div>
    </div>-->
    </header>   
<% String sql =""; 
String imagen =""; String marca =""; String modelo =""; String serial =""; 
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);               
                   sql = "select a.fichero,a.marca,a.modelo,a.serial from inv_equipos a left join inv_asignacion b on a.idinvequipo = b.idinvequipo where b.idusuario = "+codigo+" and b.estado = 'A'";
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                imagen=rs.getString(1);
                marca=rs.getString(2);
                modelo=rs.getString(3);
                serial=rs.getString(4);
              } rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%> 
<!--    <div class="container ">
        <div class="row">
        <div class="col-lg-4" align ="center">
            <img class="img-circle" src="image/dibujoHombre.jpg" alt="JAVIER VARAS H." width="140" height="140">            
            <h2 style="font-family: arial"> <%=nombre%> <%=apellidos%> </h2>
            <p style="font-family: arial"> Rol : <%=cargo%> </p>
            <p style="font-family: arial"> <%=compania%></p>
            <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i></a>
            </button> 
        </div> /.col-lg-4 
        <div class="col-lg-4" align ="center">
            <img id="myImg" src="image/promanet/inventario/<%=imagen%>" alt="pc" width="140" height="140">
            <h2 style="font-family: arial"><%=marca%> </h2>
            <p style="font-family: arial"> Modelo : <%=modelo%> </p>
            <p style="font-family: arial"> Serial: <%=serial%></p>
             <a href="https://www.youtube.com/watch?v=1bAjqT_-p_E" class="btn btn-danger" target="_blank" >
                <i class="fa fa-youtube" aria-hidden="true"></i>  Ver Tutorial</a> 
        </div>
        <div class=" col-lg-4">
        <h2>CAMBIAR CONTRASE�A</h2>
        <form action="ActualizarContrasena.jsp" method="post"> 
            <div class="form-group">
                <label for="passv1">Contrase�a Actual</label>
                <input type="password" name="pass1" id="passv1" class="form-control" placeholder="Contrase�a Actual" required> 
            </div> 
            <div class="form-group">
                <label for="passv2">Nueva Contrase�a</label>
                <input type="password" name="pass2" id="passv2" class="form-control" placeholder="Contrase�a Nueva" required><br>   
            </div>
            <div class="form-group">
                <button type="submit"  class="btn btn-primary">
                <i class="fa fa-save" aria-hidden="true"></i>  GUARDAR CONTRASE�A</button>
            </div>  
        </form>
        </div>
        <br>
        <iframe width="560" height="315" 
            src="https://www.youtube.com/embed/0jHXEbomu_o?disablekb=1"  
            allowfullscreen>
                
        </iframe>
        </div>
    </div>-->
             
             
 <!--===============================================
                      NAVBAR
      ===============================================-->
<div class="topnav">  
 <span class="brand-logo"><a href="#"> <img src="image/promanet.png">  </a></span>
  <div class="topnav-right">
    <span class="social">
    <a href="#twitter"><i class="fa fa-twitter"></i></a>
    <a href="#fb"><i class="fa fa-facebook-f"></i></a>
    <a href="#insta"><i class="fa fa-linkedin"></i></a>
    </span>
  </div>
</div>

<!--    SIDE NAVBAR START-->
    
    <nav>
	<div class="menu-btn">
		<div class="line line--1"></div>
		<div class="line line--2"></div>
		<div class="line line--3"></div>
	</div>

	<div class="nav-links">
            <a href="../ProMaNet/Proyectos/PRO_Dashboard.jsp" class="link"> Gesti�n de Proyectos</a>
                <a href="Perfil.jsp" class="link" >CAMBIAR CONTRASE�A</a>
                 <a href="Agenda.jsp" class="link" >AGENDA</a>
                <a href="ReporteGastosIndividual.jsp" class="link">Reportes de Gastos</a>
                <a href="Contactos.jsp" class="link" >CONTACTOS</a>
                <%if(usuario.equals("uparrales")){%>
                        <a href="TODO_CabTrabXP.jsp" class="link" >TO-DO</a>
                     <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                        <a href="TODO_Cab_Trabajo.jsp" class="link" >TO-DO</a>
                     <%}%>
		
		
		
                <a href="INV_ListadoEquipo.jsp" class="link">Panel de control</a>
<!--                <li class="link"><a href="#">
                            PANEL DE CONTROL</a>
                        <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                            <li class="dropdown-submenu">
                            <a tabindex="-1" href="#" >Crear</a>
                            <ul class="dropdown-menu">
                                <li><a  href="Crear_Clientes.jsp">Crear Cliente</a></li>
                                <li class="divider"></li>
                                <li><a href="PCN_ListadoUsuario.jsp">Crear Usuario</a></li>
                                <li class="divider"></li>
                                <li><a href="#">Crear Rol</a></li>
                                <li class="divider"></li>
                                <li><a href="Grupo_Trabajo.jsp">Crear Grupo de Trabajo</a></li>
                                <li class="divider"></li>
                                <li><a href="INV_ListadoEquipo.jsp">Inventario</a></li>
                            </ul>
                            </li>
                           <li class="divider"></li>
                          <li class="dropdown-submenu">
                            <a tabindex="-1" href="#">Asignacion</a>
                            <ul class="dropdown-menu">
                                <li><a href="RGA_Listado.jsp">Asignacion Reporte de Gastos</a></li>
                            </ul>
                          </li>
                        </ul>
                      </li>-->
                <a href="cerrar.jsp" class="link">Cerrar sesion</a>
	</div>
</nav>

<!-- ==========================================
             HEADER SECTION START
==========================================-->
   
<!--
<section class="content-container">  
  <div class="landing-content">
     <div class="landing-content-holder">

      </div>
  </div>
   <video loop muted autoplay src="https://storage.googleapis.com/coverr-main/mp4/Going-Places.mp4" id="video-container"></video>
</section>
-->
 
    
    
<!--====================== Home Banner======================-->
   
   <section class="main-wrap">
    
    <section class="site-banner">		
			<div class="site-banner__vid">
				<video muted="" autoplay="" loop="" preload="" playsinline="" data-video="0">
                    <source src="http://www.saxonglobal.com/wp-content/themes/saxonglobal/video/saxonglobal.mp4">
					<source src="https://ic-creative.co.uk/wp-content/themes/ic-creative/assets/vid/banner.ogg" type="video/ogg">
					<source src="https://ic-creative.co.uk/wp-content/themes/ic-creative/assets/vid/banner.webm" type="video/webm">
				</video>
			</div>	
     <div class="headertitle">
         <h4>
      Administre su talento
    </h4>
    <h1>
      ProMaNet <br>
         Gestor de talento humano.
    </h1>
    
  </div>   
        
<!--        <div class="search_form">
        <div class="form-group form-inline">
           <form class="request-form">
             <input name="Email" type="email" id="Email" class="form-control user-email" placeholder="Search For Jobs">
			 <input type="submit" value="Search" name="send" placeholder="" class="request-btn">
          </form>
            </div>
        </div>-->
        
    </section>
    
       <section class="for-for">
       <div class="container-fluid">
         <div class="row">
           <div class="col-md-6">
             <div id="f2">
          <div class="inside" >
            <span></span>
            <h3> Reporte de <span class="blue-text"><a href="ReporteGastosIndividual.jsp"> Gastos</a></span></h3>
            <h4>
              <a href="ReporteGastosIndividual.jsp"> Registre su reporte de gastos aqu�! </a>
            </h4>
          </div>
        </div>
             </div>
           <div class="col-md-6">
             <div id="f3">
          <div class="inside">
            <span></span>
            <h3>Buscar <span class="blue-text"> <a href="Contactos.jsp"> contactos </a></span></h3>
            <h4>
              <a href="Contactos.jsp"> Consulte informaci�n de sus compa�eros aqu�! </a>
            </h4>
          </div>
        </div>
             </div>
           </div>
       </div>
       </section>
       
<!--=================FOOTER SECTION=====================-->
    
    
    
    <footer>
      <div class="container">
         <div class="row">
           <div class="col-md-3">
             <div class="text-warp">
               <h4>About Us</h4>
                 <li><a href="Home.jsp">Home</a></li>
                 <li><a href="Perfil.jsp">Perfil</a></li>
                 <li><a href="https://www.youtube.com/watch?v=1bAjqT_-p_E">Video Tutorial</a></li>
               </div>
             </div>
             
             <div class="col-md-3">
             <div class="text-warp">
               <h4>Other</h4>
                 <li><a href="#">Terms of Service</a></li>
                 <li><a href="#">Privacy policy</a></li>
                 <li><a href="#">FAQ</a></li>
               </div>
             </div>
             
             <div class="col-md-3">
             <div class="text-warp">
               <h4>Contacto</h4>
                 <li><a href="#">jvaras@overclocking.com.ec</a></li>
                 <li><a href="#">0994610380</a></li>
                 <li><a href="#">FAQ</a></li>
               </div>
             </div>
             
             <div class="col-md-3">
             <div class="text-warp">
               <h4>Adders</h4>
                 <li><a href="#">Edificio Kennedy Point ,<br>Piso #4 ,<br>Oficina 401</a></li>                 
               </div>
             </div>
          </div>
        </div>
    </footer>
    

    <section class="copy-right">
     <div class="text-center"><p>Copyright � 2020- 2021, Buadnet S.A.  All rights reserved.</p></div>
    </section>

    </section> 
    
    
    </body>
    <style>
      @font-face {
    font-family: 'TitilliumWeb';
    src: url(../font-style/TitilliumWeb-Light.ttf) format('truetype');
}
@font-face {
    font-family: 'Comfortaa';
    src: url(../font-style/Comfortaa-Regular.ttf) format('truetype');
}
@font-face {
    font-family: 'googleapis';
    src: url(https://fonts.googleapis.com/css?family=Montserrat%3A300%2C400%2C600%2C700%2C900) format('truetype');
}


.main_warp {
    padding-top: 50px;
    padding-bottom: 50px;
}
body {
  margin: 0;
   font-family: 'TitilliumWeb';
}


::-moz-selection {
    color: #fff;
    background: #b50201;
}
::selection {
    color: #fff;
    background: #b50201;
}
::-webkit-scrollbar-track {
    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
    border-radius: 10px;
    background-color: #F5F5F5;
    
}
::-webkit-scrollbar {
    width: 6px;
    background-color: #F5F5F5;
    
}
::-webkit-scrollbar-thumb {
    border-radius: 10px;
    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, .3);
    background-color: #b50201;
    
}
.mr-top-250{
    margin-top:250px;
}
.mr-top-150{
    margin-top:150px;
}
.mr-top-100{
    margin-top:100px;
}
/********************************
**********SUPPORT CLASS**********
********************************/

a:hover {
    text-decoration: none!important;
}
.position-rel {
    position: relative;
}
.m_top_20 {
    margin-top: 20px;
}
.m_bot_20 {
    margin-bottom: 40px;
}
.m_top_30 {
    margin-top: 30px;
}
.m_top_40 {
    margin-top: 40px;
}
.m_top_60 {
    margin-top: 60px;
}
.m_top_80 {
    margin-top: 80px;
}
.mar-auto {
    margin-left: auto;
    margin-right: auto;
}

/*TOP NAVBAR START==========================================*/


.main-wrap{
    padding-left:70px;
}

.request-form {
    position: relative;
    margin-top: 25px;
    margin-bottom: 20px;
    margin-left: auto;
    width: 75%;
    margin-right: auto;
}
.search_form {
    position: absolute;
    z-index: 11;
    bottom: 0%;
    width: 100%;
}
.request-form .form-control {
    width: 100%;
    height: 75px;
    background-color: white;
    border: 0px solid white;
    border-radius: 0px;
    box-shadow: 0 8px 20px rgba(0,0,0,.2);
    outline: 0;
    display: inline-block;
    padding: 0 30px;
    font-size: 30px;
    font-weight: 400;
    text-shadow: none;
    letter-spacing: 1px;
    font-family: 'Comfortaa';
    color: #476787;
}
.request-btn {
    padding: 4px 35px;
    position: absolute;
    z-index: 8;
    font-size: 30px;
    font-weight: 400;
    height: 75px;
    top: 0px;
    border-radius: 0px;
    right: 0px;
    transition: 0.5s;
    color: #ffffff;
    border: solid 0px;
    cursor: pointer;
    background-color: #f6911f;
}



.brand-logo {
    float: left;
    margin-left: 4px;
    width: 230px;
    margin-top: 7px;
    padding: 9px;
}
.brand-logo img{
    max-width: 100%;
}

.topnav {
    overflow: hidden;
    z-index: 90;
    position: fixed;
    width: 100%;
    background-color: #1b73bc;
    min-height: 65px;
}
.topnav .topnav-right  a {
  float: left;
  color: #1b73bc;
  text-align: center;
  padding: 14px 16px;
  text-decoration: none;
  font-size: 17px;
  min-width: 20px;
  transition: box-shadow 1s ease;
}


.topnav .topnav-right a:hover{
  box-shadow: inset 0 0 0 50px rgba(255, 255, 255, .2);
/*  border-bottom: 1px solid rgba(255, 255, 255, .2);*/
}

.topnav a.active {
  border-bottom: 1px solid gold;
}

.social {
  display: flex;
  width: 200px;
/*  background-color: #70665c;*/
    margin-top:8px;
}

.social a {
  flex: 1;
}

.topnav-right {
  float: right;
}


/*SIDE NAVBAR=================================*/

nav {
    overflow: hidden;
    position: fixed;
    transform: translateX(-200px);
    height: 100%;
    width: 270px;
    transition: all 800ms cubic-bezier(.8, 0, .33, 1);
    /* border-radius: 0% 0% 100% 50%; */
    top: 0px;
    background-color: #1b73bc;
    z-index: 12;
}

nav.nav-open {
    transform: translateX(0px);
    border-radius: 0% 0% 0% 0%;
/*	 background: rgba(255, 255, 255, 0.6);*/
    background-color:#4d8836;
}

nav .menu-btn {
    position: absolute;
    top: 50%;
    right: 10%;
    padding: 0;
    width: 30px;
    cursor: pointer;
    z-index: 2;
}

nav .menu-btn .line {
    padding: 0;
    width: 30px;
    background: #fff;
    height: 2px;
    margin: 5px 0;
    transition: all 700ms cubic-bezier(.9, 0, .33, 1);
}

nav .menu-btn .line.line--1 {
    width: 30px;
    transform: rotate(0) translateY(0);
}

nav .menu-btn .line.line--1.line-cross {
    width: 30px;
    transform: rotate(45deg) translateY(10px);
	 background: rgba(0,0,0,0.6);
}

nav .menu-btn .line.line--2 {
    width: 28px;
    transform: translateX(0);
}

nav .menu-btn .line.line--2.line-fade-out {
    width: 28px;
    transform: translate(30px);
    opacity: 0;
}

nav .menu-btn .line.line--3 {
    width: 20px;
    transform: rotate(0) translateY(0);
}

nav .menu-btn .line.line--3.line-cross {
    width: 30px;
    transform: rotate(-45deg) translateY(-10px);
	 background: rgba(0,0,0,0.6);
}

nav .nav-links {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    transform: translateX(-100px);
    opacity: 0;
    transition: all 900ms cubic-bezier(.9, 0, .33, 1);
}

nav .nav-links.fade-in {
    opacity: 1;
    transform: translateX(0px);
}

nav .nav-links .link {
    margin: 20px 0;
    text-decoration: none;
    font-family: 'TitilliumWeb';
    color: #fff;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 1.2rem;
    transition: all 300ms cubic-bezier(.9, 0, .33, 1);
}

nav .nav-links .link:hover {
    color: rgba(0, 0, 0, .5);
}

/*VIDEO SECTION START==================================*/


.content-container .landing-content {
	position: absolute;
	top: 50%;
	left: 50%;
	ms-transform: translateX(-50%) translateY(-50%);
	-moz-transform: translateX(-50%) translateY(-50%);
	-webkit-transform: translateX(-50%) translateY(-50%);
	transform: translateX(-50%) translateY(-50%);
}

.content-container #video-container {
	position: fixed;
	top: 50%;
	left: 50%;
	min-width: 100%;
	min-height: 100%;
	width: auto;
	height: auto;
	z-index: -100;
	-ms-transform: translateX(-50%) translateY(-50%);
	-moz-transform: translateX(-50%) translateY(-50%);
	-webkit-transform: translateX(-50%) translateY(-50%);
	transform: translateX(-50%) translateY(-50%);
	background: url(polina.jpg) no-repeat;
	background-size: cover;
    
}





.site-banner{
    position: relative;
}

.site-banner.site-banner--vid {
	overflow: hidden
}

.site-banner .site-banner__vid {
	width: 100%;
	height: 100%
}
.site-banner .site-banner__vid video {
	width: 100%;
	height: 100%;
	display: block;
	object-fit: cover;
/*	position: absolute;*/
	left: 0;
	top: 0
}

.site-banner:before {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    left: 0;
    content: '';
    background: rgba(0, 0, 0, 0.66);
}

.site-banner.site-banner--vid:before {
	background: rgba(29, 37, 45, 0.7)
}
.site-banner:before {
    z-index: 1;
}



.boxes {
    position: absolute;
    bottom: 0px;
    margin: 0 auto;
    left: 0px;
    right: 0px;
    width: 45%;
        z-index: 5;
}

.first-line {
  flex: 1;
  display: flex;
  flex-direction: row;
  width: 50%;
}

#f1 {
  background: #83726b;
  flex: 1;
  cursor: pointer;
  transition: box-shadow 1s ease;
}

#f1:hover {
  box-shadow: inset 0 0 0 10px rgba(255, 255, 255, .4);
}

.second-line {
  flex: 1;
  display: flex;
  flex-direction: row;
}

#f2 {
  flex: 1;
  background: #e4e4e4;
  cursor: pointer;
  transition: box-shadow 1s ease;   
    
}


#f2:hover {
    box-shadow: inset 0 0 0 10px #f6911f;
      background-image: url(https://www.peopleplace.eu/wp-content/themes/peopleplace/images/bg-employer.jpg);
  background-size: cover;
  background-position:top center;
    transition-duration: 0.5s;
    -webkit-transition-duration: 0.5s;
    transition: 2s;
}
#f3 {
  flex: 1;
  background: #e4e4e4;
  cursor: pointer;
  transition: box-shadow 1s ease;
    
}

#f3:hover {
  box-shadow: inset 0 0 0 10px #1b74bc;
  background-image: url(https://www.peopleplace.eu/wp-content/themes/peopleplace/images/bg-candidate.jpg);
  background-size: cover;
  background-position:top center;
        transition-duration: 0.5s;
    -webkit-transition-duration: 0.5s;
    transition: 2s;
}

.inside {
    width: 100%;
    height: Calc(100% - 41px);
    margin: 20px 0;
    text-align: center;
    vertical-align: middle;
    color: #000;
    padding: 15px 0px;
}
.blue-text{
    color:#1b72bc;
}
.inside:hover{    
    color: #fff;  
}
.inside > span {
    height: 1px;
    width: 30%;
    background: #f6911f;
    display: block;
    margin: 0 auto;
    margin-bottom: 76px;
    margin-top: 50px;
}

.inside h3 {
    position: relative;
    top: 30%;
    transform: translateY(-50%);
    font-size: 50px;
    padding: 15px 0px;
    font-weight: bolder;
}

.inside h4 {
    color: #f6911f;
    position: relative;
    transform: translateY(-50%);
    margin-bottom: 50px;
    font-size: 18px;
}
.slidep {
  background: silver;
  flex: 5;
  overflow: hidden;
}

.headertitle {
    position: absolute;
    z-index: 9;
    color: white;
    padding-left: 15px;
    border-left: 6px solid #f6901f;
    letter-spacing: 1px;
    top: 335px;
    left: 160px;
}

.headertitle h1 {
    font-size: 75px;
    font-weight: bold;
    color: #fff;
    font-family: 'googleapis';
    text-transform: uppercase;
}


/*=====================Footer=====================*/
footer{
    padding: 50px 0px;
    background-color:#242424;
}
footer h4{
    color:#fff;
    margin-bottom:15px;
}
footer li{
    list-style-type: none;    
}
footer li a {
    text-decoration: none;
    color: #fff;
    display: block;
    padding: 5px 0px;
    font-size: 14px;
}

.copy-right{
    padding:10px 0px;
    background-color:#333333;
}
.copy-right p{
    color:#fff;
    padding:0px;
    margin:0px;
    font-size:14px;
}


    </style>
    <script>
       $(document).ready(function(){
     
         var menuBtn = document.querySelector('.menu-btn');
var nav = document.querySelector('nav');
var lineOne = document.querySelector('nav .menu-btn .line--1');
var lineTwo = document.querySelector('nav .menu-btn .line--2');
var lineThree = document.querySelector('nav .menu-btn .line--3');
var link = document.querySelector('nav .nav-links');
menuBtn.addEventListener('click', () => {
    nav.classList.toggle('nav-open');
    lineOne.classList.toggle('line-cross');
    lineTwo.classList.toggle('line-fade-out');
    lineThree.classList.toggle('line-cross');
    link.classList.toggle('fade-in');
})
  
 });
    </script>
</html>
