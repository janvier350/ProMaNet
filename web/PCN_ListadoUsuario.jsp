<%-- 
    Document   : LISTADO DE USUARIOS
    Created on : 30-may-2018, 12:21:01
    Author     : Jquinde
--%>

<%@page contentType="text/html" 
        import ="java.sql.Connection"
        import ="java.sql.DriverManager"
        import ="java.sql.ResultSet"
        import ="java.sql.Statement"
        import ="java.sql.SQLException"
        import="java.sql.*"
        import=" java.util.Date"
        %>
<%   String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String idUser = request.getParameter("id");
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet|Lista de Usuarios</title>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link rel="stylesheet" href="css/chosen.css">
        <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="Content/bootstrap/carousel/carousel.css" rel="stylesheet" type="text/css"/> 
        <link href="Content/Style.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>
        <script src="Content/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script>
            var id =<%=idUser%>;
                     if(id>0){
                        $(window).load(function(){
                        $('#myModalJEFE').modal('show');}
                   );
            }  
        </script> 
    </head>
    <body>
    <header>
    <div class="container-fluid">
    <div class="row">
    <div class="logo ">
        <img src="image/banner2020.png" class="img-responsive" > 
    </div>
    </div>
    </div>
    </header>
    <div class="container-fluid">
    <div class="row">
    <nav class="navbar navbar-default"  id="nav2">
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
                <li><a href="Agenda.jsp">AGENDA</a></li>
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
                            <a id="dLabel" role="button" data-toggle="dropdown" href="#">PANEL DE CONTROL<span class=" caret "></span></a>
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
                                      <li><a href="RGA_Listado.jsp">Asignaci�n Reporte de Gastos</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                <li><a href="cerrar.jsp">CERRAR SESION</a></li>
            </ul>
        </div>
    </nav>  
    </div>
    </div>
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
    <div class="container" align="center">
        <a href="Home.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <!--<i class="fa fa-mail-reply" style="font-size:20px"></i>-->
        <i class="material-icons" font-size:30px">arrow_back</i>
        </a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    <div class="">
    <div class="form-group" >
         <div class="form-group">
            <table class="table table-striped ">
                <thead >
                    <tr>
                        <th class="text-center" style="font-size: 16px">Buscar</th>
                        <th class="text-center" style="font-size: 16px">Crear</th>
                        <th class="text-center" style="font-size: 16px" colspan="4">Exportar</th>
                        
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td align="center" >
                        <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
                    </td>
                    <td align="center" >
                        <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i>
                        </button> 
                    </td>
                    <td align="center">
                        <a type="button" class="btn btn-default " href="#">
                            <i class="material-icons" style="color:#000;font-size:30px">description</i>     
                        </a>
                        <a type="button" class="btn btn-default"  href="NewServlet">
                           <i class="material-icons" style="color:#000;font-size:30px">picture_as_pdf</i>    
                        </a>
                    </td>
                </tr> 
                </tbody>
            </table>
        </div>
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
      <tr class="success">
        <th class="text-center">Id</th>      
        <th class="text-center">DEPARTAMENTO</th>
        <th class="text-center">Nombres</th>  
        <th class="text-center">Email</th>
        <th class="text-center">Compa�ia</th>
        <th class="text-center">Rol-RG</th>
        <th class="text-center">Rol-TD</th>
        
        <th class="text-center">Editar</th>
        <th class="text-center">Permisos</th>
        <th class="text-center">Eliminar</th>
        <th class="text-center">Ver Padre</th>
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select A.IDUSUARIO, A.NOMBRE||' '||A.APELLIDOS AS NOMBRES, A.EMAIL, A.IDCOMPANIA, B.COMPANIA, A.IDROL, C.CARGO , A.IDROLTODO, d.cargotodo, e.departamento"
                + " from USUARIO A, COMPANIA B, ROL C, todorol D, adm_departamento E "
                + " WHERE A.IDCOMPANIA = B.IDCOMPANIA AND A.IDROL = C.IDROL AND A.ESTADO='a' AND a.idroltodo = d.idroltodo AND a.id_adm_departamento = e.id_departamento ORDER BY 2";
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
         <td><%=rs.getString(10)%></td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(7)%></td>
        <td><%=rs.getString(9)%></td>
        
        <td>
            <a href="PCN_UsuarioEditar.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(8)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
            </a>
        </td>
        <td>
            <a href="PCN_GestionPermisosUsuario.jsp?idUser=<%=rs.getString(1)%>" class="btn btn-warning" title="Permisos">
               <i class="material-icons " style="color:white;font-size:25px">lock_open</i>
            </a>
        </td>
        <td ><a class="btn btn-danger " href="PCN_EliminarUsuario.jsp?idUser=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size:21px">delete_forever</i></a></td>
        <td><a class="btn btn-success" href="PCN_ListadoUsuario.jsp?id=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 21px" >visibility</i></a></td> 
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
    <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Agregar Nuevo Usuario</h4>
    </div>
        <form  action="PCN_InsertarUsuario.jsp"  method="POST" >
        <div class="modal-body">
            <div class="container-fluid">
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Nombres:</label>
                <input type="text" name="nombre" id="nombre" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Apellidos:</label>
                <input type="text" name="apellido" id="apellido" class="form-control" required />
            </div>
            </div>
                <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Sueldo: </label>
                <input type="number" name="sueldo" id="sueldo" class="form-control" value="0" required />
            </div>
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Tel�fono:</label>
                <input type="text" name="telefono" id="telefono" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6">
            <div class="form-group">
                <label for="" class="form-control-label">Email:</label>
                <input type="text" name="email" id="email" class="form-control" value="N/A" required />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="">Usuario:</label>
                <input type="text" name="usuario" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Contrase�a:</label>
               <input type="password" name="pass" class="form-control" required />
            </div>  
            </div>
            </div>                                             
            <div class="row">
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Rol:</label>
               <select class="form-control" id="idRol" name ="idRol" style="width:100%">
                    
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn = DriverManager.getConnection(url, user, pass);
                        String sql = "select * from ROL where estado = 'a' order by 2";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();       
                        while (rs.next()) {%>                                                                    
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
            </div>
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Compa�ia:</label>
               <select class="form-control" id="idCia" name ="idCia" style="width:100%">
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn = DriverManager.getConnection(url, user, pass);
                        String sql = "select * from COMPANIA where estado = 'a' order by 2";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();       
                        while (rs.next()) {%>                                                                    
                        <option value="<%=rs.getString(1)%>"><%=rs.getString(3)%></option>
                        <% }     
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
            <div class="row">
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Rol para TO-DO:</label>
               <select class="form-control" id="idRolTodo" name ="idRolTodo" style="width:100%">
                    
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn = DriverManager.getConnection(url, user, pass);
                        String sql = "select * from TODOROL where estado = 'A' order by 2";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();       
                        while (rs.next()) {%>                                                                    
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
            </div>
                <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">DEPARTAMENTO</label>
               <select class="form-control" id="departamento" name ="departamento" style="width:100%">
                    
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn = DriverManager.getConnection(url, user, pass);
                        String sql = "select * from ADM_DEPARTAMENTO where estado = 'A' order by 2";
                        PreparedStatement st = cn.prepareStatement(sql);
                        ResultSet rs = st.executeQuery();       
                        while (rs.next()) {%>                                                                    
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
                <!--MODAL PARA VER EL FEJE ASIGNADO-->
<div class="modal fade" id="myModalJEFE" role="dialog">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">JEFE ASIGNADO</h4>
              </div>
                <form  action="#.jsp"  method="POST" >
              <div class="modal-body">
                  <table id="detalles" class="table table-striped table-hover   " >
      <thead>
        <tr>
          <th class="text-center">Id</th>
          <th class="text-center">Nombre Jefe</th>
          
        </tr> 
      </thead>
    <% try{
      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
      Connection cn2 = DriverManager.getConnection(url, user, pass);
      String sql2 = "select a.idusuario, b.nombre||' '||b.apellidos AS JEFE from REPGASASIG A, USUARIO B "
              + " WHERE a.idusuario = "+ idUser 
              + " AND a.idusuarioasig=b.idusuario";
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center" >
      <tr>
        <td type="text" ><%= rs2.getString(1)%></td> 
        <td type="text" ><%= rs2.getString(2)%></td>
             
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
      <button type="submit"  class="btn btn-primary">Guardar</button>
   </div>
   </form>
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