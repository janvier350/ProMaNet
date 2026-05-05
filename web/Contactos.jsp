<%-- 
    Document   : Contactos 
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page import=" java.util.Date" 
        import="java.sql.*" %>

<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String(""+ip);
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
<meta http-equiv="Content-type" content="text/html, charset=utf-8">
<meta name="viewport content="width=device-width, initial-scale=1">
<link rel="shorcut icon" href="image/logo.png">
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
<link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=170d96f69db52446b9aa21d2653da1f4">
<link rel="stylesheet" type="text/css" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css">
<link rel="stylesheet" href="css/portalv2.css" >
<style type="text/css" class="init"></style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" async="" src="https://ssl.google-analytics.com/ga.js"></script>
<script type="text/javascript" src="/media/js/site.js?_=864bfcf009a679ab8affaaf56e444759"></script>
<script type="text/javascript" src="/media/js/dynamic.php?comments-page=examples%2Fstyling%2Fbootstrap.html" async=""></script>
<script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js"></script>
<script type="text/javascript" language="javascript" src="../resources/demo.js"></script>
   <script type="text/javascript" class="init">
   $(document).ready(function() {
           $('#example').DataTable();
   } );
   </script>
   <title>ProMaNet | Contactos</title> 
   </head>
<body>
    <header>
        <div class="container-fluid">
        <div class='row'>
            <div class="logo "><img  src="image/banner2020.png" class="img-responsive" ></div>
        <nav class="navbar navbar-default " id="nav2">
            <div class="container-fluid">   
                <div class="navbar-header"  >
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
                        <span class="sr-only" >Menu</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a href="Home.jsp" class="navbar-brand" >HOME</a>    
                </div>
                <div  class="collapse navbar-collapse " id="navbar-1" >
                    <ul class="nav navbar-nav " >
                        <li class="active"><a href="Contactos.jsp">CONTACTOS</a></li>
                         <li><a href="Agenda.jsp" >AGENDA</a></li>
                        <%if(usuario.equals("uparrales")){%>
                           <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                        <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                           <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                        <%}%>
                        <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                        <!--  <li><a href="TODO_Lista_GRUPO.jsp">AVANCE</a></li> -->

                        <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">AVANCE<span class="caret"></span></a>
                        <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                            <li class="dropdown-submenu">
                                <a tabindex="-1" href="#" >Revision</a>
                                <ul class="dropdown-menu">
                                    <li><a  href="TODO_Lista_GRUPO.jsp">Jefes x Grupo</a></li>
                                <li class="divider"></li>
                                <li><a href="TODO_Lista_Trabajos.jsp">Trabajos Individuales</a></li>
                                <li class="divider"></li>
                                <li><a href="#">Estadistico</a></li>
                                <li class="divider"></li>
                                
                                </ul>
                            </li>
                            <li class="divider"></li>
                            <li class="dropdown-submenu">
                                <a tabindex="-1" href="#">Asignacion</a>
                                <ul class="dropdown-menu">
                                   <!--  <li><a href="#">Asignacion Reporte de Gastos</a></li> -->
                                </ul>
                            </li>
                        </ul>
                        </li>
                        <li class="dropdown">
                            <a id="dLabel" role="button" data-toggle="dropdown" href="#">PANEL DE CONTROL<span class="caret"></span></a>
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
                                    </ul>
                                </li>
                                <li class="divider"></li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">Asignacion</a>
                                    <ul class="dropdown-menu">
                                      <li><a href="RGA_Listado.jsp">Asignación Reporte de Gastos</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li class="dropdown">
                            <a id="dLabel" role="button" data-toggle="dropdown" href="#">RECURSOS<span class="caret"></span></a>
                            <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#" >ARTHURS AUDIT GLOBAL</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="https://www.arthursaudit.ec/wp-content/uploads/2023/01/PORTAFOLIO-DE-SERVICIOS-ARTHURS-23.pdf">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.arthursaudit.ec/wp-content/uploads/2023/08/HOJA-MEMBRETADA-ARTHURS.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Otros</a></li>
                                    </ul>
                                </li>
                                <li class="divider"></li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">BUADNET S.A.</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="https://www.buadnet.com.ec/wp-content/uploads/2022/09/PORTAFOLIODESERVICIOS_2022_2.pdf">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.buadnet.com.ec/wp-content/uploads/2023/08/PRESENTACION-BUADNET.pptx">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.buadnet.com.ec/wp-content/uploads/2023/08/HOJA_MEMBRETADA_APROBADA_BUADNET.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Otros</a></li>
                                    </ul>
                                </li>
                                 <li class="divider"></li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">LATINCONSULTING  S.A.</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="#">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://latinconsulting.com.ec/wp-content/uploads/2023/08/Hoja-membretada-Latin.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Otros</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li><a href="cerrar.jsp">CERRAR SESION</a></li>
                    </ul>
                </div>
            </div>   
        </nav>
        <div class="form-group">
            <table class="table table-bordered ">
            <tr>       
                <td class="text-center titulo1" colspan="3">
                    <b><%=compania%></b>
                </td>
                <td class="text-center titulo1" colspan="3">
                    <b> <%=nombre%> <%=apellidos%></b>
                </td>
                <td class="text-center titulo1" colspan="3">
                    <b>
                       <%Date  fecha = new Date();%> 
                       <%=fecha%>
                    </b> 
                </td>
            </tr>
            </table>
        </div> 
        </div>
        </div>
    </header> 
        
    <div class="container-fluid">
        <div class="form-group">
            <div class="table-responsive">
                <table id="example" class="table table-striped table-hover " >
                    <thead>
                      <tr class="success">
                          <th class="text-center titulo ">Departamento</th> 
                        <th class="text-center titulo ">Nombre</th>
                        <th class="text-center titulo ">Apellido</th>
                        <th class="text-center titulo " >E-mail</th>
                        <th class="text-center titulo ">Ubicacion</th>  
                        
                    </tr>  
                    </thead>
                    <tbody align="center">
                        <% 
                        try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "select a.IDUSUARIO, a.NOMBRE, a.APELLIDOS, a.EMAIL, b.COMPANIA  , c.departamento from USUARIO a, compania b, adm_departamento c where a.IDCOMPANIA = b.IDCOMPANIA AND a.ESTADO = 'a' AND a.id_adm_departamento =c.id_departamento order by 1";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {%>
                        <tr>
                            <td> <%=rs.getString(6)%></td>
                            <td> <%=rs.getString(2)%></td>  
                            <td> <%=rs.getString(3)%></td>
                            <td> <%=rs.getString(4)%></td>
                            <td> <%=rs.getString(5)%></td>
                            
                        </tr>
                        <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                    </tbody>
                </table> 
            </div>
        </div>
    </div>
                   
</body>
    
  <footer class="text-center text-white" style="background-color: #0a4275;">
    <!-- Grid container -->
    <div class="container p-4 pb-0">
      <!-- Section: CTA -->
      
      <!-- Section: CTA -->
    </div>
    <!-- Grid container -->

    <!-- Copyright -->
    <div class="text-center text-warning p-3" style="background-color: #0a4275;">
      © 2023 Copyright:
      <a class="text-white" href="https://overclocking.com.ec/">overclocking.com.ec</a>
    </div>
    <!-- Copyright -->
  </footer>
</html>
