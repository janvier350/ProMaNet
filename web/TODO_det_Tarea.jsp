<%-- 
    Document   : Detalle de tareas
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html"
        import=" java.util.Date"
        %>
<%  
    String usuario = (String) session.getAttribute("usuario");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String roltodo = (String) session.getAttribute("roltodo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String CabTrab = request.getParameter("idCabTrab");
    String DetTrab = request.getParameter("idDetTrab");
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
        <title>ProMaNet|Tareas</title> 
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
                        <thead>
                            <tr>
                                <th class="text-center" style="font-size: 12px">Crear</th>
                            </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td align="center" >
                               <%if(roltodo.equals("JEFE")){%>
                                 <button type="button" class="btn btn-default disabled " data-toggle="modal" data-target="#myModal">
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}else if(roltodo.equals("ASISTENTE")){%>
                                 <button type="button" class="btn btn-default" data-toggle="modal" data-target="#myModal">
                                    <i class="material-icons"  style="font-size:30px;">note_add</i>
                                 </button> 
                              <%}%>
                                <a href="TODO_det_Trabajo.jsp?idCabTrab=<%=CabTrab%>" class="btn btn-success"> 
                                    <i class="material-icons"  style="font-size:30px;">subdirectory_arrow_left</i>
                                </a>
                            </td>
                        </tr> 
                        </tbody>
                    </table>
                </div>
            <div class="container-fluid">
                <div class="container-fluid panel panel-default" style="padding-top:2em;">
                    <form class="form-horizontal" role="form">
                             
                  <%try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cn = DriverManager.getConnection(url, user, pass);
                    String sql = "SELECT A.IDTODODET, to_char(A.FECHAHORAINICIO, 'DD-MM-YY'),to_char(A.FECHAHORAFIN, 'DD-MM-YY'),A.DETALLE, A.EST_DET_TRAB "
                            + " from TODODETTRAB A"
                            + " where A.IDTODODET = "+DetTrab+"  and A.ESTADO = 'A'";
                    PreparedStatement st = cn.prepareStatement(sql);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()) {%>
                <div class="form-group"> 
                  <label  for="FechaInicio" class="col-lg-4  control-label">Fecha Inicio</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(2)%>" type="text"  id="FechaInicio" class="form-control" required disabled/>
                  </div> 
                  <label  for="FechaFin" class="col-lg-1 control-label">Fecha Fin</label>
                  <div class="col-lg-2">
                      <input value="<%= rs.getString(3)%>" type="text"  id="FechaFin" class="form-control" required disabled/>
                  </div>            
                </div>                 
                <div class="form-group"> 
                <label  for="Trabajo" class="col-lg-4 control-label">Trabajo</label>
                <div class="col-lg-2">
                    <input value="<%= rs.getString(4)%>" type="text"  id="Trabajo" class="form-control" required disabled/>
                </div>  

                <label  for="Estado" class="col-lg-1 control-label">Estado</label>
                <div class="col-lg-2">
                    <%if(rs.getString(5).equals("P")){%>
                    <input value="PENDIENTE"style="background-color: yellow" 
                    <%}%>
                    <%if(rs.getString(5).equals("T")){%>
                    <input value="TERMINADO"style="background-color: #99ff66" 
                    <%}%>
                    <%if(rs.getString(5).equals("A")){%>
                    <input value="ATRASADO"style="background-color: #ff9999" 
                    <%}%>
                    type="text"  id="Estado" class="form-control" required disabled/>
                </div>
                </div>
                
                <%}rs.close();
                    st.close();
                    cn.close();
                }catch(Exception e){
                e.printStackTrace();
                }%>  
            </form>
            </div></div>       
                          
            <div class="form-group">
              <div class="table-responsive">
                  <table id="detalles" class="table table-striped table-hover  " >
                        <thead>
                          <tr>
                            <th class="text-center  ">ID</th>
                            <th class="text-center ">Detalle</th>
                            <th class="text-center  ">Fecha inicio</th>
                            <th class="text-center  ">Fecha Fin</th> 
                            <th class="text-center  ">Eliminar</th>
                          </tr> 
                        </thead>
            <%String usr2="RRHH";
            String pass2="RRHH";
            String url2 = new String("jdbc:oracle:thin:@192.168.0.70:1521:xe");
            try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url2, usr2, pass2);
        String sql2 = "select A.IDTODODETTAREA,A.DETALLE, to_char(A.FECHAHORAINICIO, 'DD-MM-YY'),to_char(A.FECHAHORAFIN, 'DD-MM-YY'),A.ESTADO, B.IDTODODET "
                + " from TODODETTAREA A, TODODETTRAB B "
                + "where B.IDTODODET = "+DetTrab+" AND A.IDTODODETTRAB =B.IDTODODET order by 1  ";
                PreparedStatement st = cn.prepareStatement(sql2);
                ResultSet rs = st.executeQuery();       
            while (rs.next()) {%>                                
            <tbody align="center">
        <tr>
            <td> <%= rs.getString(1)%></td>         
            <td> <%= rs.getString(2)%></td>
            <td> <%= rs.getString(3)%></td>
            <td type="text" ><%= rs.getString(4)%> </td>
            <td ><a class="btn btn-danger" href="TODO_EliminarDetTarea.jsp?idDetTrab=<%= rs.getString(1)%>&idDet=<%=DetTrab%>&idCab=<%=CabTrab%>"><i class="material-icons " style="color:white">delete_forever</i></a></td>
        </tr>
            </tbody>
            <%}rs.close();
                st.close();
                cn.close();
            }catch(Exception e){
                 e.printStackTrace();
            }%>  
          </table> 
          </div>
      </div>

        <div class="modal fade" id="myModal" role="dialog">
            <div class="modal-dialog modal-lg">
            <!-- Modal content-->
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal">&times;</button>
                  <h4 class="modal-title">Nuevo detalle de Trabajo</h4>
                </div>
                <form  action="TODO_InsertTarea.jsp?idDetTrab=<%=DetTrab%>&idCabTrab=<%=CabTrab%>"  method="POST" >
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="row">
                        <div class="col-lg-4 form-group">
                            <label class=" control-label" for="fechaini" >
                                Fecha Inicio
                            </label>
                            <input type="date" name="fechaini" id="fechaini" class="form-control" required />
                            <script>
                            document.getElementById('fechaini').value = new Date().toISOString().substring(0, 10);
                            </script>
                        </div>
                        <div class="col-lg-4 form-group">
                            <label class=" control-label" for="fechafin" >
                                Fecha Fin
                            </label>
                            <input type="date" name="fechafin" id="fechafin" class="form-control" required />
                            <script>
                                document.getElementById('fechafin').value = new Date().toISOString().substring(0, 10);
                            </script>
                        </div>
                    </div>
                        <div class="row">
                        <div class="col-lg-12">
                        <div class="form-group">
                            <label for="Trabajo" class="form-control-label">Descripcion</label>
                            <textarea class="form-control" id="Trabajo" name="Trabajo"></textarea>
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
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </body>
