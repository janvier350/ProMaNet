<%-- 
    Document   : TODO CAB TRABAJO
    Created on : 16-feb-2017, 16:57:01
    Author     : Jvaras
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date"%>
<%  String codigo = (String) session.getAttribute("cod");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String roltodo = (String) session.getAttribute("roltodo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String FlagFiltro = request.getParameter("filtro");
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
             return;}
    if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
    }else{
        response.sendRedirect("sesionInvalida.jsp");}
    String EstTrab ="";
    if(FlagFiltro==null||FlagFiltro.equals(null)){
       EstTrab= "IS NOT NULL";
    }else if (FlagFiltro.equals("1")){
       EstTrab= "='T'";
    }else if (FlagFiltro.equals("2")){
       EstTrab= "='P'";
    }else if (FlagFiltro.equals("3")){
       EstTrab= "='A'";
    }else{
       EstTrab= "IS NOT NULL";
    }
    String NombreGTR="";
    int TareasAsig =0;
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|TODO</title> 
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css" > 
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <link href="dist/clockpicker.css" rel="stylesheet" />
        <script src="dist/clockpicker.js"></script>
        <link href="dist/bootstrap-clockpicker.css" rel="stylesheet" />
        <script src="js/jquery.js"></script>        
        <script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>
        <script type="text/javascript">
            $('.clockpicker').clockpicker();
        </script>
        <script src="dist/bootstrap-clockpicker.min.js" type="text/javascript"></script>
        <script>
            var id =<%=idcab%>;
                     if(id>0){
                        $(window).load(function(){
                        $('#myModalGTR').modal('show');}
                   );
            }  
        </script> 
    </head>
    <a href="#"><img src="image/toTop.png" title="Ir arriba" style="width: 50px; height: 50px;position: fixed; bottom: 10px; right: 0" /></a>
    <header>
        <div class="container-fluid">
        <div class="row">
        <div class="logo ">
            <img src="image/banner2020.png" class="img-responsive"> 
        </div>
        </div>
        </div>
    </header>
    <div class="container-fluid">
    <div class="row">
    <nav class="navbar navbar-default"  id="nav2">
    <div class="navbar-header"  >
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
            <span class="sr-only">Menu</span>
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
        <li class="active"><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
     <%}%>
    <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
    <li><a href="Mantenimiento.jsp">AVANCE</a></li>
    <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">PANEL DE CONTROL<span class="caret"></span></a>
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
<main>
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
    <div class="form-group">
        <h2 class="text-center">Listado de Trabajos a Realizar</h2>
        <table class="table table-striped ">
            <thead>
                <tr>
                    <th style="font-size: 14px" >Buscar </th>
                    <th style="font-size: 14px" colspan="3">Crear</th>
                    <th style="font-size: 14px" >Filtro</th>
                    
                </tr>
            </thead>
            <tbody>
               <tr>
                <td align="center" >
                    <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
                </td>
                <td align="center" >
                   <%if(roltodo.equals("JEFE")){%>
                     <button type="button" class="btn btn-default " data-toggle="modal" data-target="#myModal">
                        <i class="material-icons"  style="font-size:30px;">note_add</i>
                     </button> 
                      <a type="button" class="btn btn-default btn-warning " href="TODO_Lista_Trabajos.jsp">
                        <i class="material-icons" style="color:#0A6BD2;font-size:30px">assignment_ind</i>     
                    </a>
                   <%}else if(roltodo.equals("ASISTENTE")){%>
                     <button type="button" class="btn btn-defaul disabled" data-toggle="modal" data-target="#myModal2">
                        <i class="material-icons"  style="font-size:30px;">note_add</i>
                     </button>
                   <%}%>
                    <%if(roltodo.equals("JEFE")){%>
                 
                   <%}else if(roltodo.equals("ASISTENTE")){%>
                     <button type="button" class="btn btn-defaul " data-toggle="modal" data-target="#myModal2">
                        <i class="material-icons"  style="font-size:30px;">note_add</i>
                     </button>
                   <%}%>
                </td>
              



                <td align="center">
                     <a type="button" class="btn btn-default " href="TODO_Cab_Trabajo.jsp">
                        <i class="material-icons" style="color:#0A6BD2;font-size:30px">assignment_ind</i>     
                    </a>
                    <a type="button" class="btn btn-default"  href="TODO_Cab_Trabajo.jsp?filtro=1">
                       <i class="material-icons" style="color:green;font-size:30px">check_circle</i>    
                    </a>
                    <a type="button" class="btn btn-default "  href="TODO_Cab_Trabajo.jsp?filtro=2">
                        <i class="material-icons " style="color:#D2C80A;font-size:30px">report_problem</i>
                    </a>
                    <a type="button" class="btn btn-default " href="TODO_Cab_Trabajo.jsp?filtro=3">
                     <i class="material-icons"  style="color:red;font-size:30px" >remove_circle</i>     
                    </a>
                </td>
                </tr> 
            </tbody>
        </table>
    </div>
                   
    <!-- INICIA TABLA DE CABECERA DE LOS TRABAJOS DE LOS USUARIOS -->

    <div class="container" align="center">
        <a href="TODO_Lista_Trabajos.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    <div class="container">
    <div class="form-group" >
         <div class="form-group">
            <table class="table table-striped ">
                <thead >
                    <tr>
                        <!-- <th class="text-center" style="font-size: 16px">Buscar Tareas</th> -->
                        <!-- <th class="text-center" style="font-size: 16px">Crear</th>
                        <th class="text-center" style="font-size: 16px" colspan="4">Exportar</th> -->
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <!-- <td align="center" >
                        <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
                    </td> -->
                  <!--   <td align="center" >
                        <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i>
                        </button> 
                    </td>
                    <td align="center">
                        <a type="button" class="btn btn-default " href="#">
                            <i class="material-icons" style="color:#000;font-size:30px">description</i>     
                        </a>
                        <a type="button" class="btn btn-default"  href="#">
                           <i class="material-icons" style="color:#000;font-size:30px">picture_as_pdf</i>    
                        </a>
                    </td> -->
                </tr> 
                </tbody>
            </table>
        </div>

        <!-- prueba paneles con contenido -->

        

        

        <!-- fin panels con contenido -->
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
      <tr class="success">
        <th class="text-center">Cliente</th>                  
        <th class="text-center">Trabajo</th>  
        <th class="text-center">Descripcion</th>
        <th class="text-center">Fecha Inicio</th>
        <th class="text-center">Fecha Fin</th>
        <th class="text-center">Estado</th>
         <th class="text-center">Quien dice?</th>
        <!--<th class="text-center">Eliminar</th> -->
        <th class="text-center">Ver Tareas</th>
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
       // String sql2 = "select A.IDUSUARIO, A.NOMBRE||' '||A.APELLIDOS AS NOMBRES, A.EMAIL, A.IDCOMPANIA, B.COMPANIA, A.IDROL, C.CARGO , A.IDROLTODO"
       //         + " from USUARIO A, COMPANIA B, ROL C "
       //         + " WHERE A.IDCOMPANIA = B.IDCOMPANIA AND A.IDROL = C.IDROL AND A.ESTADO='a' ORDER BY 2";
         String sql2 = "select c.cliente, trabajo, descripcion, fechainicio, fechafin, esttrab,a.idtodocabindv, a.comentario  from todocabtrabindv a , cliente c where a.idusuario = "+idUser+" and c.idcliente = a.idcliente"; 

        PreparedStatement st = cn.prepareStatement(sql2);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(4)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(7)%></td>
        <td><%=rs.getString(8)%></td>
        
        <td>
            <a href="TODO_TRABAJO_INDIVIDUAL_DETALLE.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(1)%>&idCabTodoDetIndv=<%=rs.getString(7)%>" class="btn btn-info ">
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


    <!-- FIN DE CABECERA DE TRBAJOS -->
    <br><br><br>
        <div class="modal fade" id="myModal" role="dialog">
        <div class="modal-dialog modal-lg">
        <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Nuevo Trabajo</h4>
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
               <label for="Coment" class="control-label">Comentario</label>
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
               
<!--              modal para asistente-->
<div class="modal fade" id="myModal2" role="dialog">
        <div class="modal-dialog modal-lg">
        <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Nuevo Trabajo asistente</h4>
        </div>
    <form  action="TODO_InsertCabIndv.jsp"  method="POST" >
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
<!--               fi modal asistente-->

    <div class="modal fade" id="myModalGTR" role="dialog">
        <% try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn2 = DriverManager.getConnection(url, user, pass);
                String sql2 = "SELECT  A.IDTODOCABGRUPO, A.NOMBREGRUPO FROM TODOCABGRUPO A WHERE A.IDTODOCABGRUPO = "+ idcab ;
                PreparedStatement st2 = cn2.prepareStatement(sql2);
                ResultSet rs2 = st2.executeQuery();       
            while (rs2.next()) {
                  NombreGTR = rs2.getString(2);
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
                <h3 class="modal-title text-center">GRUPO DE TRABAJO - <%= NombreGTR%></h3><br>
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
              + " AND A.IDUSUARIO= B.IDUSUARIO and b.ESTADO='a' AND B.IDCOMPANIA = C.IDCOMPANIA AND B.IDROL = D.IDROL";
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center">
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
   </div>
   </form>
   </div>
   </div>
   </div>
    </div>
    </main>
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

