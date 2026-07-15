<%-- 
    Document   : Detalle de trabajo y solo veran los usuarios asignados
    Created on : 7-Junio-2018, 16:34:01
    Author     : Jquinde
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"
        import=" java.util.Date"
        %>
<%  String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String roltodo = (String) session.getAttribute("roltodo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String cabTrab = request.getParameter("idCabTrab");
    String DetTrab = request.getParameter("DetTrab");
    String DetTrabAC = request.getParameter("DetTrabAC");
    String NombreAsig= request.getParameter("asis");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    
    String idTrabajo =  request.getParameter("idTrabajo");
    
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String NombreTarea="";
    int p =0;
    int t =0;
    int r=0;
    int avance = 0;
     int retomar =0;
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;}
    if(!COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){
        response.sendRedirect("sesionInvalida.jsp");
        return;}
   %>
<!DOCTYPE html>
<html>
    <head>
         <!--barra de progreso-->
        <!--<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">-->
        <!--<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>-->
        
        <!--<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">-->
  <!--<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.4/dist/jquery.slim.min.js"></script>-->
  <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
  
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
  
  
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet | Detalle TODO</title> 
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
        <script>
            var id =<%=DetTrabAC%>;
                if(id>0){
                   $(window).load(function(){
                   $('#myModalACTIVIDADES').modal('show');}
              );
            }  
        </script> 
        <script>
            var id =<%=DetTrab%>;
                if(id>0){
                   $(window).load(function(){
                   $('#myModalASISTENTE').modal('show');}
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
                    <li class="active"><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                 <%}else if(COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){%>
                    <li class="active"><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
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
     <div class="form-group">
    <table class="table table-striped ">
        <thead >
            <tr><th class="text-center" style="font-size: 16px">Opciones</th></tr>
        </thead>
        <tbody>
            <tr>
            <td align="center" >
                
                <%if(roltodo.equals("JEFE")){%>
                                 <button type="button" class="btn btn-default " data-bs-toggle="tooltip" title="Agregar tarea!" data-toggle="modal" data-target="#myModal">
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}else if(roltodo.equals("ASISTENTE")){%>
                                 <button type="button" class="btn btn-default disabled" data-bs-toggle="tooltip" title="Agregar tarea!" data-toggle="modal" data-target="#myModal">
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}%>
                              <%if(usuario.equals("uparrales")){%>
                                <a href="TODO_CabTrabXP.jsp" class="btn btn-success">
                                   <i class="material-icons"  style="font-size:30px;">subdirectory_arrow_left</i>
                                </a> 
                             <%}else if(COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){%>
                                <a href="TODO_Cab_Trabajo.jsp" class="btn btn-success">
                                   <i class="material-icons" data-bs-toggle="tooltip" title="Volver!"   style="font-size:30px;">subdirectory_arrow_left</i>
                                </a>
                             <%}%>
                 
            </td>
            </tr> 
        </tbody>
    </table>
    </div>
                           
       <div class="container-fluid form-group">
           <h2 class="text-center">Listado de Tareas a Realizar de cada Usuario Asignado </h2>
                    
                </div>
                             <div>
                                 
                             </div>        
            <div class="container-fluid"  >
                <div class="container-fluid panel panel-default" style="padding-top:2em;">
                    <form class="form-horizontal" >
                             
                  <%
                    try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);
                    String sql = "SELECT  to_char(b.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAINCIO, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,to_char(b.FECHACONTRATO, 'DD-MM-YY'),c.DESCRIPCION,b.TRABAJO,a.CLIENTE, b.ESTTRAB, b.COMENTARIO, b.DESCRIPCION from cliente a,TODOCABTRAB b, TODOAREA c where b.IDTODOAREA= c.IDTODOAREA and b.idcliente=a.IDCLIENTE and b.IDTODOCAB = "+cabTrab+"  and b.ESTADO = 'A' ";
                    PreparedStatement st = cn.prepareStatement(sql);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()) {%>
                    
                <div>
                     
                    <div class="form-group"> 
                            <label  for="FechaInicio" class="col-lg-1  control-label">Fecha Inicio</label>
                            <div class="col-lg-2">
                                <input value="<%=rs.getString(2)%>" type="text"  id="FechaInicio" class="form-control" required disabled/>
                            </div>
                    </div>
                    <div class="form-group"> 
                            <label  for="FechaFin" class="col-lg-1  control-label">Fecha Fin</label>
                            <div class="col-lg-2">
                                <input value="<%=rs.getString(3)%>" type="text"  id="FechaFin" class="form-control" required disabled/>
                            </div>
                            
                    </div>
                        
                <div class="form-group"> 
                  <label  for="FechaInicio" class="col-lg-1  control-label">Fecha Inicio</label>
                  <div class="col-lg-2">
                      <input value="<%=rs.getString(2)%>" type="text"  id="FechaInicio" class="form-control" required disabled/>
                  </div> 
                  <label  for="FechaFin" class="col-lg-1 control-label">Fecha Fin</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(3)%>" type="text"  id="FechaFin" class="form-control" required disabled/>
                  </div>      
                    <label  for="FechaLegal" class="col-lg-1 control-label">Fecha Legal</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(4)%>" type="text"  id="FechaLegal" class="form-control" required disabled/>
                  </div>   
                    <label  for="FechaContrato" class="col-lg-1 control-label">Fecha Contrato</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(5)%>" type="text"  id="FechaContrato" class="form-control" required disabled/>
                  </div>      
                </div>                 
                <div class="form-group"> 
                    <label  for="Trabajo" class="col-lg-1 control-label">Trabajo</label>
                    <div class="col-lg-5">
                        <input value="<%= rs.getString(7)%>" type="text"  id="Trabajo" class="form-control" required disabled/>
                    </div> 
                    <label  for="Area" class="col-lg-1 control-label">Area</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(6)%>" type="text"  id="Area" class="form-control" required disabled/>
                    </div>

                    <label  for="Cliente" class="col-lg-1 control-label">Cliente</label>
                    <div class="col-lg-2">
                          <input value="<%= rs.getString(8)%>" type="text"  id="Cliente" class="form-control" required disabled/>
                    </div>
                </div>
                <div class="form-group"> 
                    <label  for="Descripcion" class="col-lg-1 control-label">Descripcion</label>
                    <div class="col-lg-5">
                        <textarea class="form-control" id="Descripcion"  disabled><%= rs.getString(11)%></textarea>
                    </div>   
                    <label  for="Estado" class="col-lg-1 control-label">Estado</label>
                    <div class="col-lg-2">
                       <%if(rs.getString(9).equals("P")){%>
                       <input value="PENDIENTE"style="background-color: yellow" 
                       <%}%>
                       <%if(rs.getString(9).equals("T")){%>
                       <input value="TERMINADO"style="background-color: #99ff66" 
                       <%}%>
                       <%if(rs.getString(9).equals("A")){%>
                       <input value="ATRASADO"style="background-color: #ff9999" 
                       <%}%>
                       type="text"  id="Estado" class="form-control" required disabled/>
                    </div>
                    <label  for="Comentario" class="col-lg-1  control-label">Comentario</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(10)%>" type="text"  id="Comentario" class="form-control" required disabled/>
                    </div> 
                </div>
                <%}rs.close();
                    st.close();
                    cn.close();
                }catch(Exception e){
                e.printStackTrace();
                }%>  
            </form>
            </div>
                </div>       
                     
      <div class="container-fluid">
          <div class="form-group">
              <div class="table-responsive">
                  
                  <div> <input type="text" class="form-control" placeholder="Buscar.." style="width:30%"  id="myInput" required>
                            </div>  
                  <br>
                  <table id="example" class="table table-responsivetable-striped table-hover  table-bordered " >
                        <thead>
                            <tr class="success">
                            <th class="text-center  ">Tarea #</th>
                            <th class="text-center ">Trabajo Asignado a:</th>
                            <th class="text-center  ">Fecha Inicio</th>
                            <th class="text-center  ">Fecha Fin</th>  
                            <th class="text-center  ">Detalle Trabajo</th>  
                            <th class="text-center  ">Estado del Trabajo</th>
                            <th class="text-center  ">Ver Actividades</th>
                            <th class="text-center  ">Terminar </th>
                            <%if(roltodo.equals("JEFE")){%>
                                <th class="text-center  ">Retomar </th>
                                <th class="text-center  ">Modificar</th>
                                <th class="text-center  ">Eliminar</th>
                             <%}else if(roltodo.equals("ASISTENTE")){%>
                                <th class="text-center">Insertar Actividades</th>    
                             <%}%>
                        
                          </tr> 
                        </thead>
            <%try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sql ="";
                  if(roltodo.equals("JEFE")){
                     sql = "select A.IDTODODET,to_char(A.FECHAHORAINICIO, 'DD-MM-YY'),to_char(A.FECHAHORAFIN, 'DD-MM-YY'), A.ESTADO, B.IDUSUARIO, C.NOMBRE||' '||C.APELLIDOS AS NOMBRE, A.DETALLE, "
                        + "(CASE a.est_det_trab WHEN 'P' THEN 'PENDIENTE' WHEN 'A' THEN 'ATRASADO' WHEN 'R' THEN 'RETOMAR' ELSE 'TERMINADO'  END) AS ESTADO "
                        + " from TODODETTRAB A, TODOASIGTAREA B, USUARIO C where A.IDTODOCABTRAB = "+cabTrab+" AND A.IDTODODET= B.IDTODODETTRAB AND B.IDUSUARIO = C.IDUSUARIO AND A.ESTADO='A' order by 1 ";
                  }else if(roltodo.equals("ASISTENTE")){
                     sql = "select A.IDTODODET,to_char(A.FECHAHORAINICIO, 'DD-MM-YY'),to_char(A.FECHAHORAFIN, 'DD-MM-YY'), A.ESTADO, B.IDUSUARIO, C.NOMBRE||' '||C.APELLIDOS AS NOMBRE, A.DETALLE ,"
                        + "(CASE a.est_det_trab WHEN 'P' THEN 'PENDIENTE' WHEN 'A' THEN 'ATRASADO' WHEN 'R' THEN 'REROMAR' ELSE 'TERMINADO'  END) AS ESTADO "
                        + " from TODODETTRAB A, TODOASIGTAREA B, USUARIO C where A.IDTODOCABTRAB = "+cabTrab+" AND B.IDUSUARIO= "+ codigo+" AND A.IDTODODET= B.IDTODODETTRAB AND B.IDUSUARIO = C.IDUSUARIO AND A.ESTADO='A'  order by 1 ";
                  }
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();       
            while (rs.next()) {%>                                
            <tbody class="w-auto p-3" align="center" id="myTable">
                <tr class="active" >
            <td><%= rs.getString(1)%></td>         
            <td><%= rs.getString(6)%></td>
            <td><%= rs.getString(2)%></td>
            <td type="text" ><%= rs.getString(3)%> </td>
            <td align="justify"><%= rs.getString(7)%></td>
            <%if(rs.getString(8).equals("PENDIENTE")){ p = p+1;%>
            <td type="text"title="La tarea se encuentra en proceso." style="background-color: yellow"> <%= rs.getString(8)%> </td>
        <%}%>
            <%if(rs.getString(8).equals("TERMINADO")){  t = t+1;%>
            <td type="text"title="Tarea Terminada con exito." style="background-color: #99ff66">  <%= rs.getString(8)%></td>
            <%}%>
            <%if(rs.getString(8).equals("RETOMAR")){  r = r+1;%>
            <td type="text"title="Tarea REVERSADO, en espera de acci�n del ejecutivo a cargo de esta tarea." style="background-color: #ff9800">  <%= rs.getString(8)%></td>
            <%}%>
            <!--<td type="text"title="El proyecto se encuentra en proceso"> <%= rs.getString(8)%></td>-->  
            
            <td><a class="btn btn-xs btn-primary " href="TODO_det_Trabajo.jsp?idCabTrab=<%=cabTrab%>&DetTrabAC=<%=rs.getString(1)%>&asis=<%=rs.getString(6)%>"><i class="material-icons " style="color:white">visibility</i></a></td>
           <td><a class="btn btn-xs btn-default" href="TODO_TerminarDetTrab.jsp?idCab=<%=cabTrab%>&DetTrab=<%=rs.getString(1)%>"><i class="material-icons " style="color:green;font-size:27px">check_circle</i></a></td>  
            <%if(roltodo.equals("JEFE")){%>                                                                                                                                                                                                              
                <td><a class="btn btn-xs btn-default"  data-bs-toggle="tooltip" title="Retomar tarea al asistente!" href="TODO_ReversarDetTrab.jsp?idCab=<%=cabTrab%>&DetTrab=<%=rs.getString(1)%>"><i class="fa fa-ban" style="color:red;font-size:27px"></i></a></td>              
                <td ><a class="btn btn-xs btn-warning "data-bs-toggle="tooltip" title="Modificar o agregar comentario a esta tarea!" href="TODO_EditarDetTrab.jsp?idCab=<%=cabTrab%>&DetTrab=<%=rs.getString(1)%>"><i class="material-icons " style="color:white">mode_edit</i></a></td>
                <td ><a class="btn btn-xs btn-danger" data-bs-toggle="tooltip" title="Elimina esta tarea, eliminaci�n en cascada (las tareas aplicadas en este proceso se eliminaran)!" href="TODO_EliminarTrabajo.jsp?idCab=<%=cabTrab%>&idDetTrab=<%=rs.getString(1)%>"><i class="material-icons " style="color:white">delete_forever</i></a></td>
             <%}else if(roltodo.equals("ASISTENTE")){%>
                 <td ><a class="btn btn-xs btn-success" data-bs-toggle="tooltip" title="Agregue comentarios en este proceso.!" href="TODO_det_Trabajo.jsp?idCabTrab=<%=cabTrab%>&DetTrab=<%=rs.getString(1)%>"><i class="material-icons " style="color:white">note_add</i></a></td>
             <%}%>
            
        </tr>
        
            </tbody>
            <%}rs.close();
                st.close();
                cn.close();
            }catch(Exception e){
                 e.printStackTrace();
            }%>  
          </table> 
            <% 
              avance = (t*100)/(t+p+r);
              retomar = (r*100)/(t+p+r);
                %>
                <div class="container-fluid">
                    <div class=" col-md-6">
	<div class="panel panel-info">
                        <div class="panel-heading">
                            <h3 class="panel-title">Progreso del proyecto</h3>
                                <span class="pull-right clickable"><i class="glyphicon glyphicon-chevron-up"></i></span>
                        </div>
            <div class="panel-body">
                <div class="panel-footer bg-info">
                    <div class=" container-fluid progress">
                    <div class="progress-bar progress-bar-success progress-bar-striped active" role="progressbar" style="width:<%=avance%>%">
                     <%=avance%>% Terminados <%=t%> 
                    </div>
                    <div class="progress-bar progress-bar-warning progress-bar-striped  active " role="progressbar" style="width:<%=retomar%>%">
                      <%=retomar%>% Retomar <%=r%>
                    </div>
                    <div class="progress-bar progress-bar-danger progress-bar-striped  active" role="progressbar" style="width:<%=100-avance-retomar%>%">
                      <%=100-avance-retomar%>% Pendientes <%=p%>
                    </div>
                  </div>
                </div> 
            </div>
             

	</div>
	</div>
                </div>
                
                
                    <script src="https://rawgit.com/kottenator/jquery-circle-progress/1.2.2/dist/circle-progress.js"></script>
                    <div class="container">
                        <h2>Progreso de proyecto</h2>
                        <div class="row text-center">


                                <div class="col-sm-4">
                                    <div class="progressbar">
                                        <div class="second circle" data-percent="<%=avance%>">
                                          <strong></strong>
                                          <span> <br> Terminados</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4">
                                    <div class="progressbar">
                                    <div class="second circle" data-percent="<%=retomar%>">
                                      <strong></strong>
                                      <span> <br> Retomar</span>
                                    </div>
                                    </div>
                                </div>

                                <div class="col-sm-4">
                                    <div class="progressbar">
                            <div class="second circle" data-percent="<%=100-avance-retomar%>">
                              <strong></strong>
                              <span> <br> Pendientes</span>
                            </div>
                            </div>
                                </div>




                        </div>
</div>
                    <style>
                        .circle {
                        width: 200px;
                        margin: 6px 6px 20px;
                        display: inline-block;
                        position: relative;
                        text-align: center;
                        line-height: 1.2;
                      }

                      .circle canvas {
                        vertical-align: top;
                        width: 200px !important;
                      }

                      .circle strong {
                        position: absolute;
                        top: 30px;
                        left: 0;
                        width: 100%;
                        text-align: center;
                        line-height: 40px;
                        font-size: 30px;
                        color: black;
                      }

                      .circle strong i {
                        font-style: normal;
                        font-size: 0.6em;
                        font-weight: normal;
                      }

                      .circle span {
                        display: block;
                        color: #aaa;
                        margin-top: 12px;
                      }
                    </style>       
                    <script >
                        
                 
                        $(document).ready(function ($) {
                            function animateElements() {
                                $('.progressbar').each(function () {
                                    var elementPos = $(this).offset().top;
                                    var topOfWindow = $(window).scrollTop();
                                    var percent = $(this).find('.circle').attr('data-percent');
                                    var animate = $(this).data('animate');
                                    if (elementPos < topOfWindow + $(window).height() - 30 && !animate) {
                                        $(this).data('animate', true);
                                        $(this).find('.circle').circleProgress({
                                            // startAngle: -Math.PI / 2,
                                            value: percent / 100,
                                            size : 400,
                                            thickness: 15,
                                            fill: {
                                                color: '#663399'
                                            }
                                        }).on('circle-animation-progress', function (event, progress, stepValue) {
                                            $(this).find('strong').text((stepValue*100).toFixed(0) + "%");
                                        }).stop();
                                    }
                                });
                            }

    animateElements();
    $(window).scroll(animateElements);
});
                    </script>
          </div>
              
          </div>
      </div>
                              
<!--MODAL PARA INSERTAR DETALLE DE TRABAJO Y ASIGNAR AL ASISTENTE  (SOLO JEFES)-->
   <div class="modal fade" id="myModal" role="dialog">
      <div class="modal-dialog modal-lg">
      <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Nuevo Tarea de Trabajo</h4>
      </div>
      <form  action="TODO_InsertTrabajo.jsp?idCab=<%=cabTrab%>"  method="POST" >
            <div class="modal-body">
                <div class="container-fluid">
                  <div class="row">
                    <div class="col-lg-12 form-group">
                        <label class=" control-label" for="fechaini" >
                            Fecha de Inicio:
                        </label>
                        <input type="date" name="fechaini" id="fechaini" class="form-control" required />
                        <script>
                        document.getElementById('fechaini').value = new Date().toISOString().substring(0, 10);
                        </script>
                    </div>
                    <div class="col-lg-12 form-group">
                        <label class=" control-label" for="fechafin" >
                            Fecha de Fin:
                        </label>
                        <input type="date" name="fechafin" id="fechafin" class="form-control" required />
                        <script>
                            document.getElementById('fechafin').value = new Date().toISOString().substring(0, 10);
                        </script>
                    </div>
                  </div>
                  <div class="row">
                     <div class="col-lg-12 form-group ">
                        <label for="Coment" class="control-label">Asignar Tarea a:</label>
                        <select class="form-control" name="usuario">
                           <%try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection   cn = DriverManager.getConnection(url, user, pass);
                            String sql3 = "select * from usuario where estado = 'a'";
//                            String sql3 = "select B.IDTODOCAB, B.IDTODOCABGRUPO , C.IDTODOCABGRUPO, D.IDUSUARIO, A.APELLIDOS, A.NOMBRE"
//                                    + " from usuario A, TODOCABTRAB B, TODOCABGRUPO C, TODODETGRUPO D"
//                                    + "  where B.IDTODOCAB= "+cabTrab+ " AND B.IDTODOCABGRUPO = C.IDTODOCABGRUPO AND C.IDTODOCABGRUPO = D.IDTODOCABGRUPO AND D.IDUSUARIO = A.IDUSUARIO AND A.estado = 'a' order by 1";
                            PreparedStatement st = cn.prepareStatement(sql3);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {%>         
                            <option value="<%=rs.getString(1)%>"><%=rs.getString(1)+"-"+rs.getString(2)+" "+rs.getString(3)%></option>
<!--                               <option><%=rs.getString(4)+"-"+rs.getString(6)+" "+rs.getString(5)%></option>-->
                            <%}     
                                rs.close();
                                st.close();
                                cn.close();
                            }catch(Exception e){
                                 e.printStackTrace();
                           }%>              
                        </select> 
                     </div>
                     <div class="col-lg-12 form-group">
<!--                        <label for="Trabajo" class="form-control-label">Descripcion de la Tarea:</label>
                        <textarea class="form-control" id="Trabajo" name="Trabajo" required></textarea>-->
                        <label for="Coment" class="control-label">Tarea:</label>
                        <select class="form-control" id="Trabajo" name="Trabajo" >
                           <%try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection   cn = DriverManager.getConnection(url, user, pass);
                            String sql3 = "SELECT * FROM TODO_DET_TAREAS WHERE ID_TODO_CAB_TAREAS = 1 AND estado = 'A' order by 1";
                            PreparedStatement st = cn.prepareStatement(sql3);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {%>                                                                    
                               <option><%=rs.getString(5)+"-"+rs.getString(3)%></option>
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
                  <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
                  <button type="submit"  class="btn btn-primary">Guardar</button>
                </div>
          </div>
      </form>
      </div>
      </div>
   </div>
    <!--//MODAL PARA INSERTAR DETALLES DE ACTIVIDADES DE ASISTENTES (SOLO EN SESION DE ASISTENTES)-->   
    <div class="modal fade" id="myModalASISTENTE" role="dialog">
       <% try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn2 = DriverManager.getConnection(url, user, pass);
                String sql2 = "SELECT  A.IDTODODET, A.DETALLE FROM TODODETTRAB A WHERE A.IDTODODET = "+ DetTrab ;
                PreparedStatement st2 = cn2.prepareStatement(sql2);
                ResultSet rs2 = st2.executeQuery();       
            while (rs2.next()) {
                  NombreTarea = rs2.getString(2);
           }   rs2.close();
              st2.close();
              cn2.close();
            }catch(Exception e){
              e.printStackTrace();
           }%> 
            <div class="modal-dialog modal-lg">
            <!-- Modal content-->
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal">&times;</button><br>
                  <h3 class="modal-title text-center">Nueva Actividad del Trabajo: <%= NombreTarea%> </h3>
                </div>
                <form  action="TODO_InsertTarea.jsp?idDetTrab=<%=DetTrab%>&idCabTrab=<%=cabTrab%>"  method="POST" >
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="row">
                        <div class="col-lg-4 form-group">
                            <label class=" control-label" for="fechaini" >
                                Fecha de Inicio:
                            </label>
                            <input type="date" name="ASISfechaini" id="ASISfechaini" class="form-control" required />
                            <script>
                            document.getElementById('ASISfechaini').value = new Date().toISOString().substring(0, 10);
                            </script>
                        </div>
                        <div class="col-lg-4 form-group">
                            <label class=" control-label" for="fechafin" >
                                Fecha de Fin:
                            </label>
                            <input type="date" name="ASISfechafin" id="ASISfechafin" class="form-control" required />
                            <script>
                                document.getElementById('ASISfechafin').value = new Date().toISOString().substring(0, 10);
                            </script>
                        </div>
                    </div>
                        <div class="row">
                        <div class="col-lg-12">
                        <div class="form-group">
                            <label for="Trabajo" class="form-control-label">Descripcion de la Actividad Realizada:</label>
                            <textarea class="form-control" id="ASISTrabajo" name="ASISTrabajo" required></textarea>
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
                <!--MODAL PARA PRESENTAR DETALLE DE LAS ACTIVIDADES REALIZADAS POR EL ASISTENTE-->
        <div class="modal fade" id="myModalACTIVIDADES" role="dialog">
        <% try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn2 = DriverManager.getConnection(url, user, pass);
                String sql2 = "SELECT  A.IDTODODET, A.DETALLE FROM TODODETTRAB A WHERE A.IDTODODET = "+ DetTrabAC ;
                PreparedStatement st2 = cn2.prepareStatement(sql2);
                ResultSet rs2 = st2.executeQuery();       
            while (rs2.next()) {
                  NombreTarea = rs2.getString(2);
           }   rs2.close();
              st2.close();
              cn2.close();
            }catch(Exception e){
              e.printStackTrace();
           }%> 
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button><br>
                <h3 class="modal-title text-center">TRABAJO:  <%= NombreTarea%></h3><br><br>
                <h4 class="modal-title">Lista de Actividades de:  <%= NombreAsig%></h4>
              </div>
                
              <div class="modal-body">
    <table id="detalles" class="table table-striped table-hover   " >
        <thead class="">
        <tr>
          <th class="text-center">Fecha de Inicio</th>
          <th class="text-center">Fecha de Fin</th>
          <th class="text-center">Detalle de Actividades</th>
          <th class="text-center">Eliminar</th>  
        </tr> 
      </thead>
    <% try{
      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
      Connection cn2 = DriverManager.getConnection(url, user, pass);
      String sql2 = "select A.IDTODODETTAREA,A.DETALLE, to_char(A.FECHAHORAINICIO, 'DD-MM-YY'),to_char(A.FECHAHORAFIN, 'DD-MM-YY'),A.ESTADO, B.IDTODODET "
                + " from TODODETTAREA A, TODODETTRAB B "
                + "where B.IDTODODET = "+DetTrabAC+" AND A.IDTODODETTRAB =B.IDTODODET AND A.ESTADO ='A' order by 1";
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center">
      <tr>
        <td type="text" ><%= rs2.getString(3)%></td> 
        <td type="text" ><%= rs2.getString(4)%></td>
        <td type="text" ><%= rs2.getString(2)%></td>
         <%if(roltodo.equals("JEFE")){%>
            <td ><a class="btn btn-danger disabled" href="#"><i class="material-icons" style="color:white">delete_forever</i></a></td>
         <%}else if(roltodo.equals("ASISTENTE")){%>
            <td ><a class="btn btn-danger" href="TODO_EliminarDetTarea.jsp?idDetTare=<%= rs2.getString(1)%>&idCab=<%=cabTrab%>"><i class="material-icons " style="color:white">delete_forever</i></a></td>
         <%}%>
        
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
   </div>
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
<footer class="bg-light text-center text-white">
  <!-- Grid container -->
  <div class="container p-4 pb-0">
    <!-- Section: Social media -->
    
    <!-- Section: Social media -->
  </div>
  <!-- Grid container -->

  <!-- Copyright -->
  <div class="text-center p-3" style="background-color: rgba(0, 0, 0, 0.2);">
    � 2023 Copyright:
    <a class="text-white" href="https://overclocking.com.ec/">Overclocking.com.ec</a>
  </div>
  <!-- Copyright -->
</footer>

</html>
