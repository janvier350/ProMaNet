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
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||apellidos.equals("Varas Herrera")){
           
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
      <form class="form-horizontal" method = "post" role="form" action="PCN_EditarUsuario.jsp?idUser=<%= idUser%>">
        <div class="form-group text-center">                              
           <button type="submit"  class="btn btn-success" ><span class="glyphicon glyphicon-save-file"  ></span> <b>Guardar</b></button>
           <a href="PCN_ListadoUsuario.jsp" class="btn btn-info"><i class="glyphicon glyphicon-backward" aria-hidden="true"></i> Ver Lista de Usuario</a>                               
        </div>
         <% String sql ="";
            String RolTodo ="";
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);
               if(idRolTodo.equals("null")){
                   sql = "select A.IDUSUARIO,A.NOMBRE,A.APELLIDOS,A.TELEFONO,A.EMAIL,A.USUARIO,A.CONTRASENA,A.IDCOMPANIA,A.IDROL,A.ESTADO,A.IDROLTODO,b.compania, c.cargo, D.cargotodo,  e.departamento, e.id_departamento "
                       + " from USUARIO A,  COMPANIA b , rol c , adm_departamento e "
                       + " where A.IDUSUARIO = "+idUser+ " and A.IDCOMPANIA = b.IDCOMPANIA and A.IDROL = c.IDROL  AND A.IDROLTODO=D.IDROLTODO and a.id_adm_departamento = e.id_departamento";
               }else{
                   sql = "select A.IDUSUARIO,A.NOMBRE,A.APELLIDOS,A.TELEFONO,A.EMAIL,A.USUARIO,A.CONTRASENA,A.IDCOMPANIA,A.IDROL,A.ESTADO,A.IDROLTODO,b.compania, c.cargo, D.cargotodo,  e.departamento,e.id_departamento "
                       + " from USUARIO A,  COMPANIA b , rol c , TODOROL D, adm_departamento e "
                       + " where A.IDUSUARIO = "+idUser+ " and A.IDCOMPANIA = b.IDCOMPANIA and A.IDROL = c.IDROL AND A.IDROLTODO=D.IDROLTODO and a.id_adm_departamento = e.id_departamento ";
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
                    <input value="<%= rs.getString(2)%>" type="text"  name="nombre" class="form-control"  />
                  </div> 
                  <label  for="apellido" class="col-lg-1 control-label">Apellido</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(3)%>" type="text"  name="apellido" class="form-control"  />
                  </div>      
                  <label  for="telefono" class="col-lg-1 control-label">Telefono</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(4)%>" type="text"  name="telefono" class="form-control"   />
                  </div>   
                    <label  for="id" class="col-lg-1 control-label">Usuario # </label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(1)%>" type="text"  name="idusuario" class="form-control" disabled="true"  />
                  </div>  
               </div>
               <div class="form-group">
                  <label  for="email" class="col-lg-1 control-label">Email</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(5)%>" type="text"  name="email" class="form-control"  />
                  </div>
                  <label  for="user" class="col-lg-1 control-label">Usuario</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(6)%>" type="text"  name="usuario" class="form-control" />
                  </div>
                  <label  for="pass" class="col-lg-1 control-label">Contrasena</label>
                  <div class="col-sm-2">
                      <input value="<%= rs.getString(7)%>" type="password"  name="contrasena" id ="password" class="form-control" />
                      <input id="show_password" type="checkbox" />
                  </div>
                
                  <label  for="Estado" class="col-lg-1 control-label">Estado</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(10)%>" type="text"  name="Estado" class="form-control" disabled="true"/>
                  </div>
                  </div>
                  <div class="form-group">
                  <label for="" class="col-lg-1 control-label">Compania:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="idCia" name ="idCia" style="width:100%">
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
                  <label for="" class="col-lg-1 control-label">Rol REPORTE DE GASTO:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="idRol" name ="idRol" style="width:100%">
                        <option value="<%=rs.getString(9)%>"><%=rs.getString(13)%></option>
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn1 = DriverManager.getConnection(url, user, pass);
                        String sql1 = "select * from ROL where estado = 'a' order by 2";
                        PreparedStatement st1 = cn1.prepareStatement(sql1);
                        ResultSet rs1 = st1.executeQuery();       
                        while (rs1.next()) {%>                                                                    
                        <option value="<%=rs1.getString(1)%>"><%=rs1.getString(2)%></option>
                        <% }     
                            rs1.close();
                            st1.close();
                            cn1.close();
                        }catch(Exception e){
                             e.printStackTrace();
                    }%>       
                    </select>
                    </div>
                    
                    <label for="" class="col-lg-1 control-label">DEPARTAMENTO:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="idDepartamento" name ="idDepartamento" style="width:100%">
                        <option value="<%=rs.getString(16)%>"><%=rs.getString(15)%></option>
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn1 = DriverManager.getConnection(url, user, pass);
                        String sql1 = "select * from ADM_DEPARTAMENTO where estado = 'A' order by 2";
                        PreparedStatement st1 = cn1.prepareStatement(sql1);
                        ResultSet rs1 = st1.executeQuery();       
                        while (rs1.next()) {%>                                                                    
                        <option value="<%=rs1.getString(1)%>"><%=rs1.getString(2)%></option>
                        <% }     
                            rs1.close();
                            st1.close();
                            cn1.close();
                        }catch(Exception e){
                             e.printStackTrace();
                    }%>       
                    </select>
                    </div><!-- DEPARTAMENTO -->
                    <label for="" class="col-lg-1 control-label">Rol DE TO-DO:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="idRolTodo" name ="idRolTodo" style="width:100%">
                        <option value="<%=rs.getString(11)%>"><%=RolTodo%></option>
                    <% try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection   cn1 = DriverManager.getConnection(url, user, pass);
                        String sql1 = "select * from TODOROL where estado = 'A' order by 2";
                        PreparedStatement st1 = cn1.prepareStatement(sql1);
                        ResultSet rs1 = st1.executeQuery();       
                        while (rs1.next()) {%>                                                                    
                        <option value="<%=rs1.getString(1)%>"><%=rs1.getString(2)%></option>
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
