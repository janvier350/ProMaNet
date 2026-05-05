<%-- 
    Document   : Lista de Grupo de Trabajo
    Created on : 31-May-2018, 9:57:01
    Author     : Jquinde
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager" import=" java.util.Date" %>
<%  
    String usuario = (String) session.getAttribute("usuario");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String idcab = request.getParameter("id");
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
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Grupo Trabajo</title> 
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
        <script>
            var id =<%=idcab%>;
                     if(id>0){
                        $(window).load(function(){
                        $('#myModal').modal('show');}
                   );
            }  
        </script> 
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
                    <div class="container-fluid">
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
                             <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
                                    PANEL DE CONTROL<span class="caret"></span>
                                </a>
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
                        <div class="form-group">
                    <table class="table table-striped ">
                        <thead >
                            <tr>
                                <th  >Buscar </th>
                                <th class="text-center" style="font-size: 16px">Crear</th>
                                <th class="text-center" style="font-size: 16px" colspan="4">Filtro</th>
                            </tr>
                        </thead>
                        <tbody>
                           <tr>
                            <td align="center" >
                                <input type="text" class="form-control" placeholder="Buscar.." style="width:60%"  id="myInput" required>
                            </td>   
                            <td align="center" >
                                <a type="button" class="btn btn-default " data-toggle="modal" data-target="#myModalINSERT">
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                </a> 
                            </td>
                            <td align="center">
                                 <a type="button" class="btn btn-default " href="#">
                                    <i class="material-icons" style="color:green;font-size:30px">lens</i>     
                                </a>
                                <a type="button" class="btn btn-default"  href="#">
                                   <i class="material-icons" style="color:red;font-size:30px">lens</i>    
                                </a>
                            </td>
                        </tr> 
                        </tbody>
                    </table>
                </div>  
      <div class="form-group">
        <div class="table-responsive">
            <h3 class="text-center">Listado de Grupo de Trabajo para TODO</h3>
           <table id="detalles" class="table table-striped table-hover table-bordered  " >
              <thead>
                <tr class="success">
                  <th class="text-center">Nombre de Grupo</th>
                  <th class="text-center">Cantidad de Usuarios </th>
                  <th class="text-center">Estado</th>
                  <th class="text-center">Ver</th>  
                  <th class="text-center">Modificar</th>
                </tr> 
              </thead>
       <%
          try{
              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
              Connection cn = DriverManager.getConnection(url, user, pass);
              String sql = "select A.IDTODOCABGRUPO, A.NOMBREGRUPO, A.ESTADO from TODOCABGRUPO A where  A.IDTODOCABGRUPO>1 AND ESTADO = 'A' ORDER BY 2";
              PreparedStatement st = cn.prepareStatement(sql);
              ResultSet rs = st.executeQuery();       
          while (rs.next()) {
             int cabgrupo = rs.getInt(1);
         %>
         <tbody align="center" id="myTable">
          <tr>
              <td type="text" hidden="true" ><%= rs.getString(1)%></td> 
              <td type="text" ><%= rs.getString(2)%></td> 
          <%try{
              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
              Connection cn2 = DriverManager.getConnection(url, user, pass);
              String sql2 = "SELECT COUNT(IDUSUARIO)FROM TODODETGRUPO WHERE IDTODOCABGRUPO = "+ cabgrupo +" AND ESTADO ='A'";
              PreparedStatement st2 = cn2.prepareStatement(sql2);
              ResultSet rs2 = st2.executeQuery();       
          while (rs2.next()) {%>
               <td type="text" ><%= rs2.getString(1)%></td>     
          <%} rs2.close();
              st2.close();
              cn2.close();
          }catch(Exception e){
               e.printStackTrace();
          }%>     
         <%if(rs.getString(3).equals("A")){%>
              <td type="text" style="background-color: yellow"> Activo</td>
         <%}%>
         <%if(rs.getString(3).equals("I")){%>
            <td type="text" style="background-color: #99ff66">  Inactivo</td>
         <%}%>
            <td><a class="btn btn-primary" href="Grupo_Trabajo.jsp?id=<%= rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 15px" >visibility</i></a></td> 
          <td ><a class="btn btn-info" href="GTR_VerAsignados.jsp?id=<%= rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 15px">mode_edit</i></a></td>
          </tr>
      </tbody>
      <%}   rs.close();
            st.close();
            cn.close();
          }catch(Exception e){
            e.printStackTrace();
       }%> 
   </table> 
                          
   <script>
      $('#detalles tr').on('click', function(){
      var dato = $(this).find('td:first').html();
      $('#Comentario').val(dato);
      });                    
   </script>
   </div>
   </div>
   <!--//MODAL PARA VER LISTADO DE USUARIOS DENTRO DEL GRUPO SELECCIONADO--> 
      <div class="modal fade" id="myModal" role="dialog">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Lista de Usuarios</h4>
              </div>
                <form  action="#.jsp"  method="POST" >
              <div class="modal-body">
                  <table id="detalles" class="table table-striped table-hover   " >
      <thead>
        <tr>
          <th class="text-center">Nombre</th>
          <th class="text-center">Apellido</th>
          <th class="text-center">Compania</th>
          <th class="text-center">Cargo</th>  
          <th class="text-center">Tareas Asignadas</th>
        </tr> 
      </thead>
    <% try{
      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
      Connection cn2 = DriverManager.getConnection(url, user, pass);
      String sql2 = "SELECT  A.IDUSUARIO, B.NOMBRE, B.APELLIDOS,B.IDCOMPANIA,C.COMPANIA, B.IDROL, D.CARGO "
              + "FROM TODODETGRUPO A, USUARIO B, COMPANIA C, ROL D "
              + "WHERE IDTODOCABGRUPO = "+ idcab 
              + " AND A.IDUSUARIO= B.IDUSUARIO and b.ESTADO='a' AND B.IDCOMPANIA = C.IDCOMPANIA AND C.IDCOMPANIA = D.IDROL";
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center" >
      <tr>
        <td type="text" ><%= rs2.getString(2)%></td> 
        <td type="text" ><%= rs2.getString(3)%></td>
        <td type="text" ><%= rs2.getString(5)%></td>
        <td type="text" ><%= rs2.getString(7)%></td>
        <td type="text" ><%= rs2.getString(1)%></td>     
      </tr>
      </tbody>
 <%}   rs2.close();
    st2.close();
    cn2.close();
  }catch(Exception e){
    e.printStackTrace();
 }%> 
 </table> 
   </div>      
   <div class="modal-footer">
      <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
      <!--<button type="submit"  class="btn btn-primary">Guardar</button>-->
   </div>
   </form>
   </div>
   </div>
   </div>
 
 <!--//MODAL PARA INSERTAR NUEVO GRUPO DE TRABAJO-->   
    <div class="modal fade" id="myModalINSERT" role="dialog">
            <div class="modal-dialog modal-lg">
            <!-- Modal content-->
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal">&times;</button><br>
                  <h3 class="modal-title text-center">Creacion de Nuevo Grupo de Trabajo </h3>
                </div>
                <form  action="GTR_InsertaCabGrupo.jsp"  method="POST" >
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="row">
                        <div class="form-group">
                            <div class="col-lg-4">
                                <label for="Nombre" class="control-label">Nombre:</label>
                                <input type="text" class="form-control" required name="Nombre">
                            </div>
                            <div class="col-lg-4">
                               <label for="Nombre" class="control-label">Descripcion:</label>
                               <input type="text" class="form-control" required name="Descripcion">
                            </div>
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
   </div>
   </div>
   <script>
        $(document).ready(function(){
          $("#myInput").on("keyup", function() {
            var value = $(this).val().toLowerCase();
            $("#myTable tr").filter(function() {
              $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
            });
          });
        });
    </script>
    <script src="js/chosen.jquery.js" type="text/javascript"></script>     
    <script src="js/init.js" type="text/javascript" ></script>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
   </body>
</html>