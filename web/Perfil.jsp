<%-- 
    Document   : Home
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page contentType="text/html" %>
<%@page import="java.util.Date" %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date" %>
<!DOCTYPE html>
<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String email = (String) session.getAttribute("email");
     String telefono = (String) session.getAttribute("telefono");
    
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
   %>
<html>
    <head>
        
        <title>ProMaNet | Bienvenido</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href='http://fonts.googleapis.com/css?family=Varela+Round' rel='stylesheet' type='text/css'>        
        <link href="http://netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </head>
    <body>
        <% if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
             if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
                }else{
                    response.sendRedirect("sesionInvalida.jsp");
             }%>
    <header>
    <div class="container-fluid">
    <div class='row'>
        <div class="logo ">
            <img src="image/banner2020.png" class="img-responsive" > 
        </div>
        <nav class="navbar navbar-default " id="nav2">
        <div class="container-fluid">   
             <div class="navbar-header">
                 <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
                     <span class="sr-only" >Menu</span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                 </button>
                 <a href="Home.jsp" class="navbar-brand active" >HOME</a>    
             </div>
             <div  class="collapse navbar-collapse " id="navbar-1" >
                 <ul class="nav navbar-nav " >
                     <li><a href="Contactos.jsp" >CONTACTOS</a></li>
                       <li><a href="Agenda.jsp">AGENDA</a></li>
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
                                <li class="divider"></li>
                                <li><a href="INV_ListadoEquipo.jsp">Inventario</a></li>
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
                      <li class="dropdown">
                            <a id="dLabel" role="button" data-toggle="dropdown" href="#">RECURSOS<span class="caret"></span></a>
                            <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#" >ARTHURS AUDIT GLOBAL</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="https://www.arthursaudit.ec/wp-content/uploads/2023/01/PORTAFOLIO-DE-SERVICIOS-ARTHURS-23.pdf">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.arthursaudit.ec/wp-content/uploads/2023/08/HOJA-MEMBRETADA-ARTHURS.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Otros</a></li>
                                    </ul>
                                </li>
                                <li class="divider"></li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">BUADNET S.A.</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="https://www.buadnet.com.ec/wp-content/uploads/2022/09/PORTAFOLIODESERVICIOS_2022_2.pdf">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.buadnet.com.ec/wp-content/uploads/2023/08/PRESENTACION-BUADNET.pptx">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.buadnet.com.ec/wp-content/uploads/2023/08/HOJA_MEMBRETADA_APROBADA_BUADNET.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://www.buadnet.com.ec/wp-content/uploads/2023/08/PORTADA-Y-CONTRAPORTADA.docx">Portada y Contraportada</a></li>
                                    </ul>
                                </li>
                                 <li class="divider"></li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">LATINCONSULTING  S.A.</a>
                                    <ul class="dropdown-menu">
                                        <li><a  href="#">Brochure</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Power Point </a></li>
                                        <li class="divider"></li>
                                        <li><a href="https://latinconsulting.com.ec/wp-content/uploads/2023/08/Hoja-membretada-Latin.docx">Hoja Membretada</a></li>
                                        <li class="divider"></li>
                                        <li><a href="#">Otros</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                     <li><a href="cerrar.jsp">CERRAR SESION</a></li>
                 </ul>
             </div>
         </div>   
        </nav>
                     <table class="table active">
                <thead>
                    <tr class="success text-center" colspan="3">
                        <th>
                            <%=compania%>
                        </th>
                        <th>
                            <%=nombre%> <%=apellidos%>
                        </th>
                        <th>
                            <%Date  fecha = new Date();%> 
                            <%=fecha%>
                        </th>
                    </tr>
                </thead>
                <tbody>
                   
                </tbody>
            </table>

    </div>
    </div>
    </header>     
<br>   
<% String sql =""; 
String imagen =""; String marca =""; String modelo =""; String serial =""; 
String fechacompra =""; String  observaciones=""; String procesador =""; String  ram =""; String ubicacionoficina =""; String fechaasignacion = "";
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);               
                   sql = "select a.fichero,a.marca,a.modelo,a.serial,  a.fechacompra, a.observaciones, a.procesador,a.ram, a.ubicacionoficina, b.fechaasignacion from inv_equipos a left join inv_asignacion b on a.idinvequipo = b.idinvequipo where b.idusuario = "+codigo+" and b.estado = 'A'";
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                imagen=rs.getString(1);
                marca=rs.getString(2);
                modelo=rs.getString(3);
                serial=rs.getString(4);
                fechacompra=rs.getString(5);
                observaciones=rs.getString(6);
                procesador=rs.getString(7);
                ram=rs.getString(8);
                ubicacionoficina=rs.getString(9);
                fechaasignacion= rs.getString(10);
              } rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%> 
    <div class="container ">
        <div class="row">
        <div class="col-lg-4" align ="">
            <img class="img-circle" src="image/dibujoHombre.jpg" alt="JAVIER VARAS H." width="140" height="140">            
            <h2 style="font-family: arial"> <%=nombre%> <%=apellidos%> </h2>
            <p style="font-family: arial"> <strong>Rol : </strong> <%=cargo%> </p>
            <p style="font-family: arial"> <%=compania%></p>
            <p style="font-family: arial"> <strong> Email : </strong> <%=email%></p>
             <p style="font-family: arial"> <strong> Teléfono : </strong> <%=telefono%></p>
<!--            <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i></a>
            </button> -->
        </div><!-- /.col-lg-4 -->
        <div class="col-lg-4" align ="">
                <br><!--  -->
            <img id="myImg" src="image/promanet/inventario/<%=imagen%>" alt="pc" width="140" height="140">
            <br> 
            <h2 style="font-family: arial"><%=marca%> </h2>
            <p style="font-family: arial">  <strong> Modelo : </strong><%=modelo%> </p>
            <p style="font-family: arial"> <strong> RAM :</strong> <%=ram%></p>
            <p style="font-family: arial"> <strong> PROCESADOR :</strong> <%=procesador%></p>
            <p style="font-family: arial"> <strong> Serial :</strong> <%=serial%></p>
            <p style="font-family: arial"> <strong> FECHA COMPRA : </strong> <%=fechacompra%></p>
            <p style="font-family: arial"> <strong> FECHA ASIGNACIÓN : </strong> <%=fechaasignacion%></p>
            <p style="font-family: arial"> <strong> Ubicación :</strong> <%=ubicacionoficina%></p>
            <p style="font-family: arial"> <strong> Observaciones :</strong> <%=observaciones%></p>
            
            <br><!-- comment -->
            <a href="https://www.youtube.com/watch?v=1bAjqT_-p_E" class="btn btn-danger" target="_blank" >
                <i class="fa fa-youtube" aria-hidden="true"></i>  Ver Tutorial</a> 
        </div>
        <div class=" col-lg-4">
        <h2>CAMBIAR CONTRASEÑA</h2>
        <form action="ActualizarContrasena.jsp" method="post"> 
            <div class="form-group">
                <label for="passv1">Contraseña Actual</label>
                <input type="password" name="pass1" id="passv1" class="form-control" placeholder="Contraseña Actual" required> 
            </div> 
            <div class="form-group">
                <label for="passv2">Nueva Contraseña</label>
                <input type="password" name="pass2" id="passv2" class="form-control" placeholder="Contraseña Nueva" required><br>   
            </div>
            <div class="form-group">
                <button type="submit"  class="btn btn-success">
                <i class="fa fa-save" aria-hidden="true"></i>  GUARDAR CONTRASEÑA</button>
            </div>  
        </form>
        </div>
        <br>
<!--        <iframe width="560" height="315" 
            src="https://www.youtube.com/embed/0jHXEbomu_o?disablekb=1"  
            allowfullscreen>
                
        </iframe>-->
        </div>
    </div>
            <br>
    </body>
<footer class="bg-body-tertiary text-center text-lg-start">
  <!-- Copyright -->
  <div class="text-center p-3" style="background-color: rgba(0, 0, 0, 0.05);">
    © 2023 Copyright:
    <a class="text-body" href="https://overclocking.com.ec/">overclocking.com.ec</a>
  </div>
  <!-- Copyright -->
</footer>
</html>
