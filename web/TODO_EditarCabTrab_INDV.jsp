<%-- 
    Document   : Edita la Cabecera de Trabajo
    Created on : 1-Agosto-2018, 15:34:01
    Author     : Jquinde
--%>

<%@page import="java.sql.*" import=" java.util.Date"
        %>
<%  String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String roltodo = (String) session.getAttribute("roltodo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String cabTrab = request.getParameter("idCabTrab");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String idCabTodoCabIndv = request.getParameter("idCabTodoCabIndv");
    String estadoTrabajo = "";
    
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;}
    if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
    }else{
        response.sendRedirect("sesionInvalida.jsp");}
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Editar TODO</title> 
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css" > 
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>        
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>              
    </head>
</html>
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
                                <li class="active"><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
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
        <form class="form-horizontal"  action="TODO_CabTrabEditarINDV.jsp?idCabTodoCabIndv=<%=idCabTodoCabIndv%>" method="POST" >  
            <h2 class="text-center">Modificar Trabajo a Realizar</h2>
                <div class="form-group">
                    <table class="table table-striped ">
                        <thead >
                            <tr>
                                <th class="text-center" style="font-size: 14px">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                        <tr>
                            
                            <td class="text-center">
                              <%if(roltodo.equals("JEFE")){%>
                                 <button type="sumit" class="btn btn-default " data-toggle="modal" data-target="#myModal">
                                    <i class="material-icons"  style="font-size:30px;">save</i>
                                 </button> 
                              <%}else if(roltodo.equals("ASISTENTE")){%>
                                 <button type="sumit" class="btn btn-primary" >
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}%>
                                 <a href="TODO_Cab_Trabajo.jsp" class="btn btn-success">
                                    <i class="material-icons"  style="font-size:30px;">subdirectory_arrow_left</i>
                                 </a>
                            </td>
                        </tr> 
                        </tbody>
                    </table>
                </div>
            <div class="container-fluid"  >
                <div class="container-fluid panel panel-default" style="padding-top:2em;">
                  <%try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);
                    String sql = "SELECT  a.idtodocabindv,to_char(a.fechainicio, 'yyyy-MM-dd'), to_char(a.fechafin, 'yyyy-MM-dd'), to_char(a.fechalegal, 'yyyy-MM-dd'),to_char(a.fechacontrato, 'yyyy-MM-dd'), to_char(a.fechahoraasig, 'yyyy-MM-dd') ,a.trabajo, a.comentario, b.cliente, c.descripcion, a.esttrab, a.descripcion, a.idcliente, a.IDJEFEASIG, d.apellidos, d.nombre, a.idtodoarea from todocabtrabindv a, cliente b, todoarea c, usuario d where a.idusuario = "+codigo+" and a.idtodocabindv = "+idCabTodoCabIndv+" and a.idcliente = b.idcliente and a.idtodoarea = c.idtodoarea and a.idjefeasig = d.idusuario";
                    PreparedStatement st = cn.prepareStatement(sql);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()){ %>
                  
                              <div class="form-group"> 
                                  <label  for="FechaInicio" class="col-lg-1  control-label">Fecha Inicio</label>
                                  <div class="col-lg-2">
                                      <input type="date" name="FechaInicio" value="<%=rs.getString(2)%>"  class="form-control" required  disabled >
                                  </div> 
                                  <label  for="FechaFin" class="col-lg-1 control-label">Fecha Fin</label>
                                  <div class="col-lg-2">
                                      <input type="date" name="FechaFin" value="<%=rs.getString(3)%>"  disabled class="form-control"  >
                                  </div>      

                                    <label  for="FechaLegal" class="col-lg-1 control-label">Fecha Legal</label>
                                  <div class="col-lg-2">
                                      <input type="date" name="FechaLegal" value="<%=rs.getString(4)%>"  class="form-control" disabled >
                                  </div>   
                                    <label  for="FechaContrato" class="col-lg-1 control-label">Fecha Contrato</label>
                                  <div class="col-lg-2">
                                      <input type="date" name="FechaContrato" value="<%=rs.getString(5)%>"  class="form-control" disabled >
                                  </div>      
                            </div>                 
                            <div class="form-group"> 
                                
                                <label class="col-lg-1 control-label">Jefe Asignado</label>
                                        <div class="col-lg-2">
                                                    <select class="form-control" name="idjefeasig">
                                                                                                                 
                                                           <option value="<%= rs.getString(14)%>" name="idjefeasig"><%= rs.getString(15)%> <%= rs.getString(16)%></option>  
                                                            <%try{
                                                             DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                             Connection   cn4 = DriverManager.getConnection(url, user, pass);
                                                             String sql4 = "select * from usuario where idroltodo = 1 and estado = 'a' order by 1 DESC";
                                                             PreparedStatement st4 = cn4.prepareStatement(sql4);
                                                             ResultSet rs4 = st4.executeQuery();       
                                                             while (rs4.next()) {%>                                                                
                                                               <option value="<%=rs4.getString(1)%>"><%=rs4.getString(2)%> <%=rs4.getString(3)%></option>
                                                             <%}     
                                                                 rs4.close();
                                                                 st4.close();
                                                                 cn4.close();
                                                             }catch(Exception e){
                                                                  e.printStackTrace();
                                                             }%>                   
                                                    </select> 
                                        </div>
                                        
                                        <!--  <label  for="Comentario" class="col-lg-1  control-label">Comentario</label>
                                        <div class="col-lg-2">
                                            <input value="<%= rs.getString(8)%>" type="text"  name="Comentario" class="form-control" required />
                                        </div>  -->
                                <label class="col-lg-1 control-label">Estado Trabajo</label>
                                            <div class="col-lg-2">
                                                    <select class="form-control" name="Esttrab">
                                                        <option value="<%=rs.getString(11)%>" required ><%=rs.getString(11)%></option>                                                   
                                                           <option value="TERMINADO">TERMINADO</option>
                                                           <option value="PENDIENTE">PENDIENTE</option>                             
                                                           

                                                    </select> 
                                            </div>

                                 <label class="col-lg-1 control-label">Area</label>
                                        <div class="col-lg-2">
                                                    <select class="form-control" name="idTodoArea">                                               
                                                           <option value="<%= rs.getString(16)%>" name="Area"><%= rs.getString(10)%> </option>
                                                            <%try{
                                                             DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                             Connection   cn5 = DriverManager.getConnection(url, user, pass);
                                                             String sql5 = "select * from todoarea where  estado = 'A' order by 1 DESC";
                                                             PreparedStatement st5 = cn5.prepareStatement(sql5);
                                                             ResultSet rs5 = st5.executeQuery();       
                                                             while (rs5.next()) {%>                                                           
                                                               <option value="<%=rs5.getString(1)%>"><%=rs5.getString(2)%> </option>
                                                             <%}     
                                                                 rs5.close();
                                                                 st5.close();
                                                                 cn5.close();
                                                             }catch(Exception e){
                                                                  e.printStackTrace();
                                                             }%>                   
                                                    </select> 
                                        </div>

                                 <label  for="Comentario" class="col-lg-1  control-label">Comentario</label>
                                <div class="col-lg-2">
                                    <input value="<%= rs.getString(8)%>" type="text"  name="Comentario" class="form-control"  />
                                </div>  
                            </div>
                        

                            <div class="form-group">  
                            <label class="col-lg-1 control-label">Cliente</label>
                                        <div class="col-lg-2">
                                                    <select class="form-control" name="idCliente">           
                                                           <option value="<%= rs.getString(13)%>" required><%= rs.getString(9)%></option>  
                                                            <%try{
                                                             DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                             Connection   cn4 = DriverManager.getConnection(url, user, pass);
                                                             String sql4 = "select * from cliente where estado = 'a' order by 1 DESC";
                                                             PreparedStatement st4 = cn4.prepareStatement(sql4);
                                                             ResultSet rs4 = st4.executeQuery();       
                                                             while (rs4.next()) {%>                                                         
                                                               <option value="<%=rs4.getString(1)%>"><%=rs4.getString(2)%></option>
                                                             <%}     
                                                                 rs4.close();
                                                                 st4.close();
                                                                 cn4.close();
                                                             }catch(Exception e){
                                                                  e.printStackTrace();
                                                             }%>                   
                                                    </select> 
                                        </div>     
                            </div> 


                            <div class="form-group">
                                <label  for="Trabajo" class="col-lg-1 control-label">Trabajo</label>
                                <div class="col-lg-5">
                                    <!-- <input value="<%= rs.getString(7)%>" type="text"  name="Trabajo" class="form-control" required /> -->
                                    <textarea class="form-control" name="Trabajo" ><%= rs.getString(7)%></textarea>
                                </div> 

                                <label  for="Descripcion" class="col-lg-1 control-label">Descripcion</label>
                                        <div class="col-lg-5">
                                                <textarea class="form-control" name="Descripcion" ><%= rs.getString(12)%></textarea>
                                        </div>

                            </div>         
                            
                    <%}     
                    rs.close();
                    st.close();
                    cn.close();
                    }catch(Exception e){
                              e.printStackTrace();
                        }%>
            </div>      
        </div>  
        </form>                  
            
   </div>
   </div>
  <script src="js/jquery.js"></script>
  <script src="js/bootstrap.min.js"></script>
</body>
