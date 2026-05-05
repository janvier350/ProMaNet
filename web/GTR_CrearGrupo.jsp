<%-- 
    Document   : Crear Grupo de Trabajo
    Created on : 31-May-2018, 9:57:01
    Author     : JQuinde
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date" %>
<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
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
        if(nombre.equals("Jonathan")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Grupos Trabajo</title> 
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css" > 
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
    </head>
   <body>
      <header>
        <div class="container-fluid">
            <div class="row">

               <div class="logo ">
              <img   src="image/banner2020.png" class="img-responsive" > 
         </div>
        </div>
        </div>
      </header>
   <div class="container-fluid">
   <div class="row">
      <nav class="navbar navbar-default" id="nav2">
      <div class="navbar-header"  >
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
              <span class="sr-only" >Menu</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
          </button>
          <a href="Home.jsp" class="navbar-brand " >HOME</a>    
      </div>
      <div  class="collapse navbar-collapse " id="navbar-1" >
          <ul class="nav navbar-nav " >
                <li><a href="Contactos.jsp">CONTACTOS</a></li>
                <%if(usuario.equals("uparrales")){%>
                   <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                   <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                <%}%>
                <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                <li><a href="Mantenimiento.jsp">AVANCE</a></li>
                <li class="dropdown active"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
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
      </nav>  
      <div class="form-group" >
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
      <div class="container">
      <form class="form-horizontal" role="form" action="GTR_InsertaCabGrupo.jsp"  method="POST">
         <div class="form-group">
         <table class="table table-striped ">
            <thead >
               <tr>
                  <th class="text-center" style="font-size: 16px">Guardar</th>
                  <th class="text-center" style="font-size: 16px">Regresar</th>
               </tr>
            </thead>
            <tbody>
               <tr>
                <td align="center" >
                   <button type="sumit" class="btn btn-default">
                        <i class="material-icons"  style="font-size:30px;">note_add</i>
                    </button> 
                </td>
                <td align="center">
                     <a type="button" class="btn btn-default " href="#">
                        <i class="material-icons" style="color:green;font-size:30px">lens</i>     
                    </a>
                </td>
               </tr> 
            </tbody>
         </table>
         </div>
      
            <div class="form-group">
               <label for="Nombre" class="col-lg-offset-2 col-lg-2 control-label">Nombre:</label>
               <div class="col-lg-4">
                 <input type="text" class="form-control" name="Nombre">
               </div>
            </div>
            <div class="form-group">
                <label for="Nombre" class="col-lg-offset-2 col-lg-2 control-label">Descripcion:</label>
                <div class="col-lg-4">
                  <input type="text" class="form-control" id="Descripcion">
                </div>
            </div>
         </form>
      </div> 
   </div>                   
   </div>
   <script src="js/jquery.js"></script>
   <script src="js/bootstrap.min.js"></script>
   </body>
</html>