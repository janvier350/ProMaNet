<%-- 
    Document   : Editar Usuario
    Created on : 15-Agosto-2018, 12:12:01
    Author     : Jquinde
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
    String idUser = request.getParameter("idUser");
    String idRolTodo = request.getParameter("idRolTodo");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String idAsistente = "";
    int contadorTrabajo = 0;
    String contadorTareas ="";
    String contadorTerminados = "";

    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||nombre.equals("Jonathan")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Editar Usuario</title> 
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
    <div class="container-fluid" >
    <div class="container-fluid panel panel-default" style="padding-top:2em;">
      <form class="form-horizontal" method = "post" role="form" action="PCN_EditarUsuario.jsp?idUser=<%= idUser%>">
        <!-- <div class="form-group text-center">                              
           <button type="submit"  class="btn btn-success" ><span class="glyphicon glyphicon-save-file"  ></span> <b>Guardar</b></button>
           <a href="PCN_ListadoUsuario.jsp" class="btn btn-info"><i class="glyphicon glyphicon-backward" aria-hidden="true"></i> Ver Lista de Usuario</a>                               
        </div> -->
         <% String sql ="";
            String RolTodo ="";
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);
               if(idRolTodo.equals("null")){
                   sql = "select A.IDUSUARIO,A.NOMBRE,A.APELLIDOS,A.TELEFONO,A.EMAIL,A.USUARIO,A.CONTRASENA,A.IDCOMPANIA,A.IDROL,A.ESTADO,A.IDROLTODO,b.compania, c.cargo "
                       + " from USUARIO A,  COMPANIA b , rol c "
                       + " where A.IDUSUARIO = "+idUser+ " and A.IDCOMPANIA = b.IDCOMPANIA and A.IDROL = c.IDROL ";
               }else{
                   sql = "select A.IDUSUARIO,A.NOMBRE,A.APELLIDOS,A.TELEFONO,A.EMAIL,A.USUARIO,A.CONTRASENA,A.IDCOMPANIA,A.IDROL,A.ESTADO,A.IDROLTODO,b.compania, c.cargo, D.cargotodo "
                       + " from USUARIO A,  COMPANIA b , rol c , TODOROL D "
                       + " where A.IDUSUARIO = "+idUser+ " and A.IDCOMPANIA = b.IDCOMPANIA and A.IDROL = c.IDROL AND A.IDROLTODO=D.IDROLTODO ";
               }
               
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                if(idRolTodo.equals("null")){
                    RolTodo = "Ninguno";
               }else{
                    RolTodo = rs.getString(14);
               }%>
               <div class="form-group">
                  <label  for="nombre" class="col-lg-1  control-label">Nombre</label>
                  <div class="col-lg-2">
                    <input value="<%= rs.getString(2)%>" type="text"  name="nombre" class="form-control" disabled="true" />
                  </div> 
                  <label  for="apellido" class="col-lg-1 control-label">Apellido</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(3)%>" type="text"  name="apellido" class="form-control"  disabled="true"/>
                  </div>      
                  <label  for="telefono" class="col-lg-1 control-label">Telefono</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(4)%>" type="text"  name="telefono" class="form-control" disabled="true"  />
                  </div>   
                    <label  for="id" class="col-lg-1 control-label">Usuario # </label>
                  <div class="col-lg-2"> 
                    
                      <input value="<%= rs.getString(1)%>" type="text"  name="idusuario" class="form-control" disabled="true"  />
                  </div>  
               </div>
               <div class="form-group">
                  <label  for="email" class="col-lg-1 control-label">Email</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(5)%>" type="text"  name="email" class="form-control" disabled="true"  />
                  </div>
                  <label  for="user" class="col-lg-1 control-label">Usuario</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(6)%>" type="text"  name="usuario" class="form-control" disabled="true" />
                  </div>
                 <!--  <label  for="pass" class="col-lg-1 control-label">Contrasena</label> -->
                  <!-- <div class="col-sm-2">
                      <input value="<%= rs.getString(7)%>" type="password"  name="contrasena" id ="password" class="form-control" disabled="true" />
                      <input id="show_password" type="checkbox" />
                  </div> -->
                
                  <label  for="Estado" class="col-lg-1 control-label">Estado</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(10)%>" type="text"  name="Estado" class="form-control" disabled="true"/>
                  </div>
                  </div>
                  <div class="form-group">
                  <label for="" class="col-lg-1 control-label">Compania:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="idCia" name ="idCia" style="width:100%" disabled="true">
                        <option value="<%=rs.getString(8)%>"><%=rs.getString(12)%></option>
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn1 = DriverManager.getConnection(url, user, pass);
                        String sql1 = "select * from COMPANIA where estado = 'a' order by 2";
                        PreparedStatement st1 = cn1.prepareStatement(sql1);
                        ResultSet rs1 = st1.executeQuery();       
                        while (rs1.next()) {%>                                                                    
                        <option value="<%=rs1.getString(1)%>"><%=rs1.getString(3)%></option>
                        <% }     
                            rs1.close();
                            st1.close();
                            cn1.close();
                        }catch(Exception e){
                             e.printStackTrace();
                    }%>       
                    </select>
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

   <!-- TABLA PARA DETALLE DE TRABAJOS DEL USUARIO -->
 <div class="container" align="center">
        <a href="TODO_Lista_Trabajos.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    <div class="container">
    <div class="form-group">

      <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn3 = DriverManager.getConnection(url, user, pass);
     
         String terminados = "select count(*) from todocabtrabindv A where idusuario = "+idUser+" and estado = 'A' AND esttrab = 'PENDIENTE' order by idtodocabindv desc";

        PreparedStatement st3 = cn3.prepareStatement(terminados);
        ResultSet rs3 = st3.executeQuery();       
    while (rs3.next()) {
    contadorTareas = rs3.getString(1);
        }
            rs3.close();
            st3.close();
            cn3.close();
        }catch(Exception e){
             e.printStackTrace();}   

    %>
 <div class="alert alert-danger" style = "height:35px;padding-top:8px;width:25%;Float:left;margin-left:10%">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                    ×</button>
                <span class="glyphicon glyphicon-exclamation-sign"></span>
                    Tienes <%= contadorTareas%> pendientes.
    </div>

      <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
     
         String tareas = "select count(*) from todocabtrabindv A where idusuario = "+idUser+" and estado = 'A' AND esttrab = 'TERMINADO' order by idtodocabindv desc";

        PreparedStatement st = cn.prepareStatement(tareas);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {
    contadorTareas = rs.getString(1);
        }
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}   

    %>

    <div class="alert alert-success" style = "height:35px;padding-top:8px;width:25%;Float:left;margin-left:10%;">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                    ×</button>
               <span class="glyphicon glyphicon-ok"></span> 
                   Tienes  <%= contadorTareas%> terminados.
    </div>


     <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn4 = DriverManager.getConnection(url, user, pass);
     
         String todos = "select count(*) from todocabtrabindv A where idusuario = "+idUser+" and estado = 'A' order by idtodocabindv desc";

        PreparedStatement st4 = cn4.prepareStatement(todos);
        ResultSet rs4 = st4.executeQuery();       
    while (rs4.next()) {
    contadorTareas = rs4.getString(1);
        }
            rs4.close();
            st4.close();
            cn4.close();
        }catch(Exception e){
             e.printStackTrace();}   

    %>
 <div class="alert btn-primary" style = "height:35px;padding-top:8px;width:25%;Float:left;margin-left:10%">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                    ×</button>
                <span class="glyphicon glyphicon-exclamation-sign"></span>
                    Tienes <%= contadorTareas%> tareas asignadas.
    </div>

   

            

    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
      <tr class="warning">
        <th class="text-center">Trabajos</th>
        <th class="text-center">Area</th>
        <th class="text-center">Cliente</th>                  
        <th class="text-center">Trabajo</th>  
        <th class="text-center">Descripcion</th>
        <th class="text-center">Fecha Inicio</th>
        <th class="text-center">Fecha Fin</th>
        <th class="text-center">Estado</th>
         <th class="text-center">Solicitante</th>
        <th class="text-center">Comentario</th> 
        <th class="text-center">Ver Tareas</th>
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
     
         String sql2 = "select c.cliente, trabajo, a.descripcion, fechainicio, fechafin, esttrab, a.idtodocabindv, a.comentario, d.apellidos, a.idusuario, d.nombre, e.descripcion  from todocabtrabindv a , cliente c, usuario d, todoarea e where a.idusuario = "+idUser+" and c.idcliente = a.idcliente AND d.IDUSUARIO = a.IDJEFEASIG and a.estado = 'A' and e.idtodoarea = a.idtodoarea order by a.idtodocabindv desc"; 

        PreparedStatement st = cn.prepareStatement(sql2);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {
    contadorTrabajo++;
    %>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=contadorTrabajo%></td>
        <td><%=rs.getString(12)%></td>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(4)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(6)%></td>
        <td><%=rs.getString(9)%> <%=rs.getString(11)%></td> <!--  //aqui debemos validar las 'P' de los detalles para automatizar el estado de la cabecera trabajo -->
        <td><%=rs.getString(8)%></td>
        <td>
            <!-- <td ><a class="btn btn-danger " href="PCN_EliminarUsuario.jsp?idUser=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size:21px">delete_forever</i></a></td>
        <td><a class="btn btn-success" href="PCN_ListadoUsuario.jsp?id=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 21px" >visibility</i></a></td>  -->
            <a href="TODO_TRABAJO_INDIVIDUAL_DETALLE.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(1)%>&idCabTodoDetIndv=<%=rs.getString(7)%>&idUsua=<%=rs.getString(10)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:25px">visibility</i>
            </a>    
        </td>
        <!-- <td ><a class="btn btn-danger " href="PCN_EliminarUsuario.jsp?idUser=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size:21px">delete_forever</i></a></td>
        <td><a class="btn btn-success" href="PCN_ListadoUsuario.jsp?id=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 21px" >visibility</i></a></td>  -->
    </tr>
    </tbody>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}%>
    </table>
    </div>
    </div>   
    </div>

<!-- Modal para detalle de tareas -->


<!-- Fin Modal tareas -->

    <!-- FIN TABLA PARA DETALLE DE TRABAJOS DEL USUARIO -->

      <script>
            $('#show_password').on('change',function(event){
            // Si el checkbox esta "checkeado"
            if($('#show_password').is(':checked')){
               // Convertimos el input de contraseña a texto.
               $('#password').get(0).type='text';
            // En caso contrario..
            } else {
               // Lo convertimos a contraseña.
               $('#password').get(0).type='password';
            }
         });
        </script>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
    </body>
</html>
