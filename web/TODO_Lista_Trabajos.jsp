<%-- 
    Document   : LISTADO DE TRABAJOS
    Created on : 17-agost-2021, 12:21:01
    Author     : Jvaras
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
        if(cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ADMINISTRACION")){

        }else{
         response.sendRedirect("sesionInvalida.jsp");
         return;
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet|Lista de Trabajos por usuarios</title>
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
                <%}else if(COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){%>
                   <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                <%}%>
                <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                <li><a href="Mantenimiento.jsp">AVANCE</a></li>
                <li class="dropdown "><a id="dLabel" role="button" data-toggle="dropdown" href="#">
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
        <a href="TODO_Cab_Trabajo.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    <div class="container">
    <div class="form-group" >
         <div class="form-group">
            <table class="table table-striped ">
                <thead >
                    <tr>
                        <th class="text-center" style="font-size: 16px">Buscar tareas de asistentes</th>
                        <!-- <th class="text-center" style="font-size: 16px">Crear</th> -->
                        <!-- <th class="text-center" style="font-size: 16px" colspan="4">Exportar</th> -->
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td align="center" >
                        <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
                    </td>
                    <td align="center" >
                        <!-- <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i>
                        </button>  -->
                    </td>
                    <!-- <td align="center">
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
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
      <tr class="success">
        <th class="text-center">Id</th>                  
        <th class="text-center">Nombres</th>  
        <th class="text-center">Email</th>
        <th class="text-center">Compa�ia</th>
        <th class="text-center">Rol</th>
        <th class="text-center">Revisar</th>
        <!-- <th class="text-center">Eliminar</th> -->
        <!-- <th class="text-center">Ver Padre</th> -->
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select A.IDUSUARIO, A.NOMBRE||' '||A.APELLIDOS AS NOMBRES, A.EMAIL, A.IDCOMPANIA, B.COMPANIA, A.IDROL, C.CARGO , A.IDROLTODO"
                + " from USUARIO A, COMPANIA B, ROL C "
                + " WHERE A.IDCOMPANIA = B.IDCOMPANIA AND A.IDROL = C.IDROL AND A.ESTADO='a' ORDER BY 2";
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(7)%></td>
        <td>
            <a href="TODO_TRABAJO_INDIVIDUAL.jsp?idUser=<%=rs.getString(1)%>&idRolTodo=<%=rs.getString(8)%>" class="btn btn-success ">
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
    <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Agregar Nuevo Usuario</h4>
    </div>
        
    </div>
  </div>
</div>
                <!--MODAL PARA VER EL FEJE ASIGNADO-->

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