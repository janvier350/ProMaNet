<%-- 
    Document   : CREAR GRUPOS
    Created on : 16-feb-2017, 16:57:01
    Author     : JVARAS
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>
<%  
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
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
        if(cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
    <meta http-equiv="Content-type" content="text/html, charset=utf-8">
    <meta name="viewport content="width=device-width, initial-scale=1">
    <link rel="shorcut icon" href="image/logo.png">
    <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
    <link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=170d96f69db52446b9aa21d2653da1f4">
    <link rel="stylesheet" type="text/css" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css">
    <link rel="stylesheet" href="css/portalv2.css" >
    <style type="text/css" class="init"></style>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
    <script type="text/javascript" async="" src="https://ssl.google-analytics.com/ga.js"></script>
    <script type="text/javascript" src="/media/js/site.js?_=864bfcf009a679ab8affaaf56e444759"></script>
    <script type="text/javascript" src="/media/js/dynamic.php?comments-page=examples%2Fstyling%2Fbootstrap.html" async=""></script>
    <script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
    <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js"></script>
    <script type="text/javascript" language="javascript" src="../resources/demo.js"></script>
    <script type="text/javascript" class="init">	
    $(document).ready(function() {
            $('#example').DataTable();
    } );
    </script>
        <style>
            #div1, #div2 {
                height: 400px;
                padding: 10px;
                border: 1px solid black;
                overflow:scroll;
            }
            .ingre{
                padding: 30px;
            }
            .d1 .buttom-user{
                background-color: white; /* Green */
    border: none;
    color: #008CBA;
    padding: 5px 13px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    -webkit-transition-duration: 0.4s; /* Safari */
    transition-duration: 0.4s;
    cursor: pointer;
    border-radius: 10px;
    border: 2px solid #008CBA;
            }
            
            .d1 .btn-user:hover{
                background-color: #008CBA;
                color: white;
            }
            .d2 .btn-user:hover{
                background-color: white;
                color: green;
            }
            .d2 .buttom-user{
                background-color: #4CAF50; /* Green */
    border: none;
    color: white;
    padding: 5px 13px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    -webkit-transition-duration: 0.4s; /* Safari */
    transition-duration: 0.4s;
    cursor: pointer;
    border-radius: 10px;
    border: 2px solid #4CAF50;
    
            }
         </style>
         <script>
            function allowDrop(ev) {
                ev.preventDefault();
            }

            function drag(ev) {
                ev.dataTransfer.setData("text", ev.target.id);
            }

            function drop(ev) {
                ev.preventDefault();
                var data = ev.dataTransfer.getData("text");
                ev.target.appendChild(document.getElementById(data));
            }
         </script>
        <title>JSP Page</title> 
   </head>
   <body>
      <header>
      <div class="container-fluid">
      <div class='row'>
         <div class="logo ">
            <img   src="image/banner2020.png" class="img-responsive" > 
         </div>
         <nav class="navbar navbar-default " id="nav2">
         <div class="container-fluid">   
            <div class="navbar-header"  >
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
                    <span class="sr-only" >Menu</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a href="Home.jsp" class="navbar-brand" >HOME</a>    
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
      </div>
      </div>
      </header> 
      <div class="form-group">
         <table class="table table-striped text-center " tyle="width:100%" >
            <thead>
               <tr><th class="text-center"  style="font-size: 16px">CREAR GRUPO</th></tr>
            </thead>
            <tbody>
               <tr>
                  <td>
                     <button type="button" class="btn btn-primary " title="Nuevo grupo" href="#" >
                        <i class="material-icons"  style="font-size:30px;">	group_add</i>
                     </button> 
                     <a type="button" class="btn btn-success" title="Guardar" href="#">
                        <i class="material-icons " style="font-size:30px">people</i>     
                     </a>
                  </td>
               </tr> 
            </tbody>
         </table>
      </div>  
      <!--  OBJETOS   DRAG AND DROP-->
      <div class="container ">
         <div class="row">
            <div class="list1 col-lg-5"><h2>Lista de personal</h2>   </div>
            <div class="ingre col-lg-offset-2 col-lg-5"><input style="font-size: 18px" type="text" placeholder="Nombre de grupo" class=" form-control"> </div>
         </div>
         <div class="fila row">
         <div class="d1 col-lg-5 panel panel-default " id="div1" ondrop="drop(event)" ondragover="allowDrop(event)">
         <div class="panel panel-body">
            <% try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sql = "select NOMBRE || ' ' || APELLIDOS ,IDUSUARIO from usuario where estado = 'a' order by idUsuario";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();       
            while (rs.next()) {%>
               <a  class="add-list add dd-gradel col-lg-12 buttom-user btn-user  " draggable="true" ondragstart="drag(event)" type="button" id="<%=rs.getString(2)%>"><span class="glyphicon glyphicon-user"></span> <%=rs.getString(1)%></a>
               <!--<input type="text" name="pass"  draggable="true" ondragstart="drag(event)" class="form-control" placeholder="Contraseña"id="drag0" style="width:80%"  required >
               <input type="text" name="pass1"  draggable="true" ondragstart="drag(event)" class="form-control" placeholder="otro"id="drag1" style="width:90%"  required >-->
               <!--<label class="add-list add dd-gradel" draggable="true" ondragstart="drag(event)" id="<%=rs.getString(2)%>" ><%=rs.getString(1)%></label>-->
            <%}%>
         </div>
         </div>
         <%   rs.close();
              st.close();
              cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%> 
         <!--                                        
         FIN DRAG AND DROP-->
         <div class="d2 col-lg-offset-2 col-lg-5 panel   " id="div2" ondrop="drop(event)" ondragover="allowDrop(event)"> </div>
         </div>
      </div>
   </body>
</html>
