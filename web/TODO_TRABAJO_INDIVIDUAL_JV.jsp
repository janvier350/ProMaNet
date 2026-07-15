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
    String codigo = (String) session.getAttribute("cod");
    String contadorTareas = "";
    String contadorTerminados = "";

    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("JEFE")){

        }else{
         response.sendRedirect("sesionInvalida.jsp");
         return;
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
                <%}else if(COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){%>
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
                        <b><%=compania%> <%=idUser %></b>
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

   <!-- TABLA PARA DETALLE DE TRABAJOS DEL USUARIO -->
 <div class="container" align="center">
        <a href="TODO_Cab_Trabajo.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    <div class="container">
    <div class="form-group" >
         <div class="form-group">
            
        </div>

        <!-- prueba paneles con contenido -->
<!-- tareas = "select count(*) from todocabtrabindv A where idusuario = "+codigo+" and  esttrab = 'P' and estado = 'A' order by idtodocabindv desc"; -->
        <!-- <div class="alert alert-success" style = "height:35px;padding-top:8px;width:25%;Float:left;margin-left:10%;">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                    �</button>
               <span class="glyphicon glyphicon-ok"></span> 
                    Tienes <%= contadorTerminados%> pendientes.
    </div>

    <div class="alert alert-danger" style = "height:35px;padding-top:8px;width:25%;Float:left;margin-left:10%">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                    �</button>
                <span class="glyphicon glyphicon-exclamation-sign"></span>
                    <b> Tienes <%= contadorTareas%> pendientes.</b>
    </div> -->

        <!-- fin panels con contenido select esttrab, count(*) from todocabtrabindv where idusuario = "+codigo+" and estado = 'A' group by esttrab order by esttrab --> 


        <div class="table-responsive ">
    <table class="table table-hover table-borderless table-sm scrollTable container-fluid" >
      <tr class="danger">
        <th class="text-center">Historial</th> 
        <th class="text-center">Tareas</th>                 
       
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
      
         String sql2 = "select esttrab, count(*) from todocabtrabindv where idusuario = "+codigo+" and estado = 'A' group by esttrab order by esttrab"; 

        PreparedStatement st = cn.prepareStatement(sql2);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(2)%></td>
        
        
    </tr>
    </tbody>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}%>
    </table>
    </div>


    <!-- inicio de la tabla -->
   
    <div class="table-responsive ">
    <table class="table table-hover table-borderless table-sm scrollTable container-fluid" >
      <tr class="warning">
        <th class="text-center">Area</th> 
        <th class="text-center">Cliente</th>                 
        <th class="text-center">Trabajo</th>  
        <th class="text-center">Descripcion</th>
        <th class="text-center">Fecha Ini</th>
        <th class="text-center">Fecha Fin</th>
        <th class="text-center">Estado</th>
         <th class="text-center">Comentario</th>
         <th class="text-center">Editar</th> 
        <th class="text-center">Eliminar</th> 
        <th class="text-center">Ver </th>
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
      
         String sql2 = "select c.cliente, trabajo, a.descripcion, fechainicio, fechafin, esttrab, a.idtodocabindv, a.comentario, d.descripcion, a.idusuario  from todocabtrabindv a , cliente c, todoarea d where a.idusuario = "+codigo+" and c.idcliente = a.idcliente and a.estado = 'A' and d.idtodoarea = a.idtodoarea order by a.idtodocabindv desc"; 

        PreparedStatement st = cn.prepareStatement(sql2);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(9)%></td>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(4)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(6)%></td>
        <td><%=rs.getString(8)%></td>
        
         <td>
           <!--  <a href="TODO_EliminarCabIndvidual_JV.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(1)%>&idCabTodoCabIndv=<%=rs.getString(7)%>" class="btn btn-warning ">
               <i class="material-icons " style="color:white;font-size:25px">save_as</i>
            </a>  -->
        <!-- <button type="button" class="btn btn-warning" data-toggle="modal" data-target="#myModal">
            <i class="material-icons " style="color:white;font-size:25px">save_as</i>
          </button> -->

          <a href="TODO_EditarCabTrab_INDV.jsp?idUser=<%=rs.getString(10)%>&idCabTodoCabIndv=<%=rs.getString(7)%>" class="btn btn-warning ">
               <i class="material-icons " style="color:white;font-size:20px">save_as</i>
            </a> 
        </td>
        

        <td>
            <a href="TODO_EliminarCabIndvidual_JV.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(1)%>&idCabTodoCabIndv=<%=rs.getString(7)%>" class="btn btn-danger ">
               <i class="material-icons " style="color:white;font-size:20px">delete_forever</i>
            </a>    
        </td>

         <td>
            <a href="TODO_TRABAJO_INDIVIDUAL_DETALLE_JV.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(1)%>&idCabTodoDetIndv=<%=rs.getString(7)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:20px">visibility</i>
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
<div class="modal fade" id="myModal2" role="dialog">
        <div class="modal-dialog modal-lg">
        <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Nuevo Trabajo asistente</h4>
        </div>
    <form  action="TODO_InsertCab.jsp"  method="POST" >
        <div class="modal-body">
        <div class="container-fluid">
        <div class="row">
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechaini" >Fecha Ini</label>
            <input type="date" name="fechaini" id="fechaini" class="form-control" required />
            <script>
            document.getElementById('fechaini').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
  
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechafin" >Fecha Fin</label>
            <input type="date" name="fechafin" id="fechafin" class="form-control" required />
            <script>
            document.getElementById('fechafin').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechaleg">Fecha legal</label>
            <input type="date" name="fechaleg" id="fechaleg" class="form-control" required />
            <script>
            document.getElementById('fechaleg').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechacont">Fecha Contrato</label>
            <input type="date" name="fechacont" id="fechacont" class="form-control" required />
            <script>
            document.getElementById('fechacont').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
        </div>
        <div class="row">
           <div class="col-lg-6" class="form-group">
               <label for="Trabajo" class="form-control-label">Trabajo</label>
               <input type="text" name="Trabajo" id="Trabajo" class="form-control" required />
           </div>  
           <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="cliente">Cliente</label>
               <select class="form-control" name="cliente">
                   <%  try{
                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                       Connection   cn = DriverManager.getConnection(url, user, pass);
                       String sql3 = "select * from Cliente where estado = 'a' order by 1";
                       PreparedStatement st = cn.prepareStatement(sql3);
                       ResultSet rs = st.executeQuery();       
                       while (rs.next()) {
                       %>                                                                    
                           <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                   <%  }     
                       rs.close();
                       st.close();
                       cn.close();
                   }catch(Exception e){
                        e.printStackTrace();
                   }%>              
               </select> 
            </div>
         </div>                                               
         <div class="row">
            <div class="col-lg-6" class="form-group">
               <label for="Descripcion" class="form-control-label">Descripcion</label>
               <textarea class="form-control" id="Descripcion" name="Descripcion"></textarea>
            </div>  
            <div class="col-lg-6" class="form-group ">
               <label for="Coment" class="control-label">Jefe Solicitante</label>
               <input type="text" name="Comentario" id="Comentario" class="form-control" />
            </div>
         </div> 
         <div class="row">
            <div class="col-lg-6" class="form-group">
               <label class=" control-label" >Area</label>
               <select class="form-control" name="area">
                  <%try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection   cn = DriverManager.getConnection(url, user, pass);
                    String sql2 = "select * from TODOAREA where estado = 'A'";
                    PreparedStatement st = cn.prepareStatement(sql2);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()){%>   
                        <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                  <% }     
                    rs.close();
                    st.close();
                    cn.close();
                  }catch(Exception e){
                     e.printStackTrace();
                  }%> 
               </select> 
            </div>
            <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="grupo" >Grupo de Trabajo</label>
               <select class="form-control" name="grupo">
                  <option value="1">Ninguno</option>
                  <%try{
                   DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                   Connection   cn = DriverManager.getConnection(url, user, pass);
                   String sql4 = "select * from TODOCABGRUPO where estado = 'A' and idtodocabgrupo>1 order by 2 DESC";
                   PreparedStatement st = cn.prepareStatement(sql4);
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
         </div>      
        <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            <button type="submit"  class="btn btn-primary">Guardar</button>
        </div>
        </div>
    </form>
    </div>  
    </div>
    </div>

<!-- Fin Modal tareas -->

    <!-- FIN TABLA PARA DETALLE DE TRABAJOS DEL USUARIO -->

      <script>
            $('#show_password').on('change',function(event){
            // Si el checkbox esta "checkeado"
            if($('#show_password').is(':checked')){
               // Convertimos el input de contrase�a a texto.
               $('#password').get(0).type='text';
            // En caso contrario..
            } else {
               // Lo convertimos a contrase�a.
               $('#password').get(0).type='password';
            }
         });
        </script>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
    </body>
</html>
