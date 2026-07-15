<%-- 
    Document   : Editar Cliente
    Created on : 16-feb-2017, 16:57:01
    Author     : JVaras
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>


<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String idCliente = request.getParameter("idCliente");
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
        if (!COMUN.PermisoHelper.tiene(session, "CLIENTES_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Editar Cliente</title> 
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css" > 
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
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
        <div class="navbar-header">
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
    <div class="container-fluid"  >
    <div class="container-fluid panel panel-default" style="padding-top:2em;">
      <form class="form-horizontal" method = "post" role="form" action="ADM_Editar_Cliente.jsp?idCliente=<%= idCliente%>">
        <div class="form-group text-center">                              
           <button type="submit"  class="btn btn-success" ><span class="glyphicon glyphicon-save-file"  ></span> <b>Guardar</b></button>
           <a href="Crear_Clientes.jsp" class="btn btn-info"><i class="glyphicon glyphicon-backward" aria-hidden="true"></i> Ver Lista de Clientes</a>                               
        </div>
         <% try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);
               String sql = "select IDCLIENTE,CLIENTE,CONTACTO,DIRECCION,ESTADO,RUC,TELEFONO,EMAIL from cliente where IDCLIENTE = "+idCliente+" ";
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {%>
               <div class="form-group">
                  <label  for="Cliente" class="col-lg-1  control-label">Cliente</label>
                  <div class="col-lg-2">
                    <input value="<%= rs.getString(2)%>" type="text"  name="Cliente" class="form-control"  />
                  </div> 
                  <label  for="Ruc" class="col-lg-1 control-label">RUC/CI</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(6)%>" type="text"  name="Ruc" class="form-control"  />
                  </div>      
                  <label  for="Direccion" class="col-lg-1 control-label">Direcci�n</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(4)%>" type="text"  name="Direccion" class="form-control"   />
                  </div>   
                    <label  for="IdCliente" class="col-lg-1 control-label">Cliente # </label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(1)%>" type="text"  name="idCliente" class="form-control" disabled="true"  />
                  </div>  
               </div>
               <div class="form-group">
                  <label  for="Contacto" class="col-lg-1 control-label">Cont�cto</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(3)%>" type="text"  name="Contacto" class="form-control"  />
                  </div>
                  <label  for="EMAIL" class="col-lg-1 control-label">E-MAIL</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(8)%>" type="text"  name="Email" class="form-control" />
                  </div>
                  <label  for="TELEFONO" class="col-lg-1 control-label">Tel�fono</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(7)%>" type="text"  name="Telefono" class="form-control" />
                  </div>
                  <label  for="Estado" class="col-lg-1 control-label">Estado</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(5)%>" type="text"  name="Estado" class="form-control" disabled="true"/>
                  </div>
               </div>
         <%} rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>  
      </form>
   </div>
   </div>      
   </div>
   </div>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
    </body>
</html>
