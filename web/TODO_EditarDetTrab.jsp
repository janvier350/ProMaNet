<%-- 
    Document   : Edita el detalle de Trabajo
    Created on : 21-Agosto-2018, 12:10:01
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
    String cabTrab = request.getParameter("idCab");
    String DetTrab = request.getParameter("DetTrab");
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
        <script src="js/jquery.min.js" type="text/javascript"></script>                
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
        <form class="form-horizontal"  action="TODO_DetTrabEditar.jsp?idDet=<%=DetTrab%>&idCabTrab=<%=cabTrab%>" method="POST" >  
            <h2 class="text-center">Editar Detalle del Trabajo a Realizar</h2>
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
                                 <button type="button" class="btn btn-default disabled" >
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}%>
                                 <a href="TODO_det_Trabajo.jsp?idCabTrab=<%=cabTrab%>" class="btn btn-success">
                                    <i class="material-icons"  style="font-size:30px;">subdirectory_arrow_left</i>
                                 </a>
                            </td>
                        </tr> 
                        </tbody>
                    </table>
                </div>
            <div class="container-fluid">
                <div class="container-fluid panel panel-default" style="padding-top:2em;">                                                 
                  <%try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);
                    String sql = "select A.IDTODODET,to_char(A.FECHAHORAINICIO, 'yyyy-MM-dd'),to_char(A.FECHAHORAFIN, 'yyyy-MM-dd'),a.detalle, "
                            + "(CASE a.est_det_trab WHEN 'P' THEN 'PENDIENTE' WHEN 'A' THEN 'ATRASADO' ELSE 'TERMINADO'  END) AS ESTADO from tododettrab a where a.idtododet = "+DetTrab ;                            
                    PreparedStatement st = cn.prepareStatement(sql);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()) {%>                                                        
                <div class="form-group"> 
                  <label  for="FechaInicio" class="col-lg-1  control-label">Fecha Inicio</label>
                  <div class="col-lg-2">
                      <input type="date" name="FechaInicio" value="<%=rs.getString(2)%>"  class="form-control" required >
                  </div> 
                  <label  for="FechaFin" class="col-lg-1 control-label">Fecha Fin</label>
                  <div class="col-lg-2">
                      <input type="date" name="FechaFin" value="<%=rs.getString(3)%>"  class="form-control" required >
                  </div>
                  <label  for="Area" class="col-lg-1 control-label">Estado</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(5)%>" type="text"  name="Estado" class="form-control" required disabled/>
                    </div>
                </div>                 
                <div class="form-group"> 
                    <label  for="Trabajo" class="col-lg-1 control-label">Detalle Trabajo</label>
                    <div class="col-lg-5">
                        <input value="<%= rs.getString(4)%>" type="text"  name="Detalle" class="form-control" required />
                    </div>                                         
                </div>
                <%}rs.close();
                    st.close();
                    cn.close();
                }catch(Exception e){
                e.printStackTrace();
                }%> 
                </div>
            </div>
        </div>       
        </form>                  
            

   
   </div>
   </div>
  <script src="js/jquery.js"></script>
  
</body>
