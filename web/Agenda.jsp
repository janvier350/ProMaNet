<%-- 
    Document   : Contactos 
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page import=" java.util.Date" 
        import="java.sql.*" %>

<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String(""+ip);
    String idcliente ="";
    String client ="";
    int acciones = 0;
    int conta =0;
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <title>ProMaNet | Agenda</title> 
<meta http-equiv="Content-type" content="text/html, charset=utf-8">
<meta name="viewport content="width=device-width, initial-scale=1">
<link rel="shorcut icon" href="image/logo.png">
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
<!--<link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=170d96f69db52446b9aa21d2653da1f4">-->
<link rel="stylesheet" type="text/css" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css">
<link rel="stylesheet" href="css/portalv2.css" >
<style type="text/css" class="init"></style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" async="" src="https://ssl.google-analytics.com/ga.js"></script>
<!--<script type="text/javascript" src="/media/js/site.js?_=864bfcf009a679ab8affaaf56e444759"></script>-->
<!--<script type="text/javascript" src="/media/js/dynamic.php?comments-page=examples%2Fstyling%2Fbootstrap.html" async=""></script>-->
<script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js"></script>
<!--<script type="text/javascript" language="javascript" src="../resources/demo.js"></script>-->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  <!-- <link rel="stylesheet" href="css/chosen.css">
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    -->

<!--<style>
 

.checkbox.checbox-switch {
    padding-left: 0;
}

.checkbox.checbox-switch label,
.checkbox-inline.checbox-switch {
    display: inline-block;
    position: relative;
    padding-left: 0;
}
.checkbox.checbox-switch label input,
.checkbox-inline.checbox-switch input {
    display: none;
}
.checkbox.checbox-switch label span,
.checkbox-inline.checbox-switch span {
    width: 35px;
    border-radius: 20px;
    height: 18px;
    border: 1px solid #dbdbdb;
    background-color: rgb(255, 255, 255);
    border-color: rgb(223, 223, 223);
    box-shadow: rgb(223, 223, 223) 0px 0px 0px 0px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s;
    display: inline-block;
    vertical-align: middle;
    margin-right: 5px;
}
.checkbox.checbox-switch label span:before,
.checkbox-inline.checbox-switch span:before {
    display: inline-block;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: rgb(255,255,255);
    content: " ";
    top: 0;
    position: relative;
    left: 0;
    transition: all 0.3s ease;
    box-shadow: 0 1px 4px rgba(0,0,0,0.4);
}
.checkbox.checbox-switch label > input:checked + span:before,
.checkbox-inline.checbox-switch > input:checked + span:before {
    left: 17px;
}


/* Switch Default */
.checkbox.checbox-switch label > input:checked + span,
.checkbox-inline.checbox-switch > input:checked + span {
    background-color: rgb(180, 182, 183);
    border-color: rgb(180, 182, 183);
    box-shadow: rgb(180, 182, 183) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch label > input:checked:disabled + span,
.checkbox-inline.checbox-switch > input:checked:disabled + span {
    background-color: rgb(220, 220, 220);
    border-color: rgb(220, 220, 220);
    box-shadow: rgb(220, 220, 220) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch label > input:disabled + span,
.checkbox-inline.checbox-switch > input:disabled + span {
    background-color: rgb(232,235,238);
    border-color: rgb(255,255,255);
}
.checkbox.checbox-switch label > input:disabled + span:before,
.checkbox-inline.checbox-switch > input:disabled + span:before {
    background-color: rgb(248,249,250);
    border-color: rgb(243, 243, 243);
    box-shadow: 0 1px 4px rgba(0,0,0,0.1);
}



/* Switch Danger */
.checkbox.checbox-switch.switch-danger label > input:checked + span,
.checkbox-inline.checbox-switch.switch-danger > input:checked + span {
    background-color: rgb(200, 35, 51);
    border-color: rgb(200, 35, 51);
    box-shadow: rgb(200, 35, 51) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch.switch-danger label > input:checked:disabled + span,
.checkbox-inline.checbox-switch.switch-danger > input:checked:disabled + span {
    background-color: rgb(216, 119, 129);
    border-color: rgb(216, 119, 129);
    box-shadow: rgb(216, 119, 129) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}



</style>-->
<script type="text/javascript" class="init">
   $(document).ready(function() {
           $('#example').DataTable();
   } );
   </script>
   
   

        <!--<script src="js/highlight.min.js" type="text/javascript"></script>-->
        <!--<script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>-->
        <!--<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">-->
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <!--<link href="css/dropdown.css" rel="stylesheet" type="text/css"/>-->
        
        
   </head>
<body>
    <header>
        <div class="container-fluid">
        <div class='row'>
            <div class="logo "><img  src="image/banner2020.png" class="img-responsive" ></div>
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
                         <li class="active"><a href="Agenda.jsp" >AGENDA</a></li>
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
                                <a tabindex="-1" href="#">Asignación</a>
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
                                      <li><a href="RGA_Listado.jsp">Asignación Reporte de Gastos</a></li>
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
            
        </div>
        </div>
    </header> 
                    
                  <%  if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){%>
                    
        <div class="form-group">
    <table class="table table-striped ">
        <thead >
            <tr><th class="text-center" style="font-size: 16px">Opciones</th></tr>
        </thead>
        <tbody>
            <tr>
            <td align="center" >
                <a  href="Agenda_history.jsp"  data-bs-toggle="tooltip" title="Historia de todas las citas!" type="button" class="btn btn-default" onclick="tableToExcel('detalles', 'W3C Example Table')" >
                    <!--<i class="material-icons" style="font-size:30px">history</i>-->     
                     <span class="material-symbols-outlined" style="font-size:30px">history</span>
                </a>
                <button type="button" class="btn btn-default " data-bs-toggle="tooltip" title="Crear Cita!" href="#" data-toggle="modal" data-target="#myModal">
                   <span class="material-symbols-outlined" style="font-size:30px">calendar_add_on</span>
                    <!--<i class="material-icons"  data-bs-toggle="tooltip" title="Crear Cita!" style="font-size:30px;">calendar_add_on</i>-->
                </button> 
                <a  href="NewServlet" type="button" class="btn btn-default" onclick="tableToExcel('detalles', 'W3C Example Table')" >
                    <i class="material-icons" style="font-size:30px">print</i>     
                </a>
                 <a href="https://youtu.be/kwTs6jv27h0" data-bs-toggle="tooltip" title="Tutorial Agenda!" class="btn btn-danger" target="_blank" >
                <i class=" fa fa-youtube-play" aria-hidden="true" style="font-size:30px"></i> 
                 </a> 
<!--                <a  href="https://youtu.be/kwTs6jv27h0"  data-bs-toggle="tooltip" title="Ver tutorial!" type="button" class="btn btn-danger" onclick="tableToExcel('detalles', 'W3C Example Table')" >
                     ver turtorial <span class="material-symbols-outlined" style="font-size:20px">youtube_activity</span>
                     <span class="material-symbols-outlined" style="font-size:30px">history</span>
                </a>-->
            </td>
            </tr> 
        </tbody>
    </table>
    </div>
             <%  acciones =1;
                 }
             %>       
                    
                    
    <div class="container-fluid">
        <div class="form-group">
            <div class="table-responsive">
                <table id="example" class="table table-responsive table-striped table-hover  table-bordered " >
                    <thead>
                      <tr class="success">
                           <th class="text-center titulo "># <span class="badge bg-primary rounded-pill"> 
                           
                            <th align="center" class="text-center titulo ">ESTADO</th>  
                        
                         <th class="text-center titulo "  >MES</th>
                          <th class="text-center titulo "  >DIA</th>
                          <th class="text-center titulo "  >FECHA CITA</th>
                        <th class="text-center titulo ">INICIO</th>
                        <th class="text-center titulo " >FIN</th>
                        <th class="text-center titulo ">DEPARTAMENTO</th>
                        <th class="text-center titulo ">EJECUTIVO</th>  
                        <th class="text-center titulo ">CLIENTE</th>  
                        <th class="text-center titulo ">OBSERVACIÓN</th>  
                        
                        <%  if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("")){%>
                        <th class="text-center titulo ">ACCIONES</th>
                         <th class="text-center titulo ">ELIMINAR</th>
                         <%}%>
                         
                    </tr>  
                    </thead>
                    <tbody class="w-auto p-3" id="myTable">
                        <% 
                        try{
//                            to_char(a.fechacompra, 'yyyy-MM-dd')
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sql = "SELECT "
                            + "a.id_adm_cab_agenda,"
                            + "TO_CHAR(a.fecha_age_ini, 'yyyy-MM-dd'),"
                           + " a.hora_age_ini,"
    + "a.hora_age_fin,"
   + " c.nombre ||' '|| c.apellidos,"
   + " b.cliente,"
   + " a.observacion,"
    + "a.estado,"
    + "a.id_cliente,"
   + " a.estado_agenda,"
   + " a.area,"
   + " a.id_usuario,"
    + "TO_CHAR(a.fecha_age_ini, 'Month', 'nls_date_language=spanish') AS MES,"
   + " TO_CHAR(a.fecha_age_ini, 'DAY', 'nls_date_language=spanish') AS DIA "
+ "FROM "
 + "   adm_cab_agenda a "
+ "INNER JOIN "
 + "   cliente b ON a.id_cliente = b.idcliente "
+ "INNER JOIN "
 + "   usuario c ON a.id_usuario = c.idusuario "
+ "WHERE "
  + "  a.ESTADO = 'A' "
  + "  AND EXTRACT(MONTH FROM a.fecha_age_ini) = EXTRACT(MONTH FROM CURRENT_DATE) "
+ "ORDER BY 10";
//                            String sql ="SELECT a.id_adm_cab_agenda,to_char(a.fecha_age_ini, 'dd-MM-yyyy')  ,a.hora_age_ini, a.hora_age_fin, c.nombre ||' '|| c.apellidos,b.cliente, a.observacion, a.estado, a.id_cliente,a.estado_agenda, a.area, a.id_usuario,to_char(a.fecha_age_ini, 'Month','nls_date_language=spanish') AS MES , to_char(a.fecha_age_ini, 'DAY','nls_date_language=spanish') AS DIA from adm_cab_agenda a, cliente b, usuario c where  a.id_usuario = c.idusuario and a.id_cliente = b.idcliente AND a.ESTADO = 'A' order by 10 ";
                           // String sql = "SELECT a.id_adm_cab_agenda,a.fecha_age_ini  ,a.hora_age_ini, a.hora_age_ini, b.nombre || b.apellidos,c.cliente,a.observacion, a.estado, a.id_cliente,a.estado_agenda from adm_cab_agenda a, usuario b , cliente c where  a.id_cliente = b.idusuario and a.id_cliente = c.idcliente";
                                    // String sql = "SELECT * from adm_cab_agenda";
                                    //String sql = "select a.IDUSUARIO, a.NOMBRE, a.APELLIDOS, a.EMAIL, b.COMPANIA from USUARIO a, compania b where a.IDCOMPANIA = b.IDCOMPANIA AND a.ESTADO = 'a' order by 1";
                            PreparedStatement st = cn.prepareStatement(sql);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {
                        conta++;
                        %>
                        <tr>
                            <!--contador-->
                            <td align="center"> <%=conta %></td>  
                            <!--estado-->
                            <% 
                                if(rs.getString(10).equals("TERMINADO")){
                            %>
                            <td align="center" style="background-color:#99ff99;"> <%=rs.getString(10)%></td> 
                            <% 
                                }

                            if(rs.getString(10).equals("PENDIENTE")){
                               %>
                               <td align="center" style="background-color:#ffff99;"> <%=rs.getString(10)%></td>
                              <%     
                                  }

                            if(rs.getString(10).equals("ATRASADO")){
                            %>
                            <td align="center" style="background-color:#ffcc33;"> <%=rs.getString(10)%></td>
                              <%  
                                }

                             if(rs.getString(10).equals("CANCELADO")){
                            %>
                            <td  align="center" style="background-color:#ffcccc;"> <%=rs.getString(10)%></td>
                             <%
                                 }
                             
                             %>
                             <td class="text-center titulo "> <%=rs.getString(13)%>  </td>  
                             <td class="text-center titulo "> <%=rs.getString(14)%>  </td>  
                        <!--fecha-->
                        <td class="text-center titulo "> <%=rs.getString(2)%>  </td>  
                            <!--hora inicio-->
                            <td >  <%=rs.getString(3)%></td>
                            <!--hora fin-->
                            <td align="auto"> <%=rs.getString(4)%>
                                
                            
                            </td>
                            <td align="justify"> <b><%=rs.getString(11)%></b></td>
                            <td >
                                <b> <%=rs.getString(5)%></b>
                               
                                        <div>
                                            <ul>
                                                
                                                <%

                                                    String detalleAgenda = "select apellidos, nombres, departamento, id_usuario, id_adm_det_agenda from adm_det_agenda where id_adm_cab_agenda = '"+rs.getString(1)+"' and estado = 'A' ";

                                                            try{
                                                                 DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                Connection cn3 = DriverManager.getConnection(url, user, pass);
                                                                PreparedStatement st3 = cn3.prepareStatement(detalleAgenda);
                                                                ResultSet rs3 = st3.executeQuery(); 
                                                                while (rs3.next()){
                                                                   %> 
                                                                    
                                                                   <p> 
                                                                       <!--<a href="ADM_EliminarColega.jsp?idColega=<%= rs3.getString(1)%>" class="justify-content-center  btn-danger" data-bs-toggle="tooltip" title="Elimnar Colega!"><span class="glyphicon glyphicon-minus">--> 
                                                                     <%  if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")){%>
                                                                    <li>   <a href="ADM_EliminarColega.jsp?idColega=<%= rs3.getString(5)%>" class="btn btn-xs btn-danger" data-bs-toggle="tooltip" title="Elimnar Colega!">
                                                                            <span class="glyphicon glyphicon-minus"> </span> </a> 
                                                                        <%}%> <%=rs3.getString(2)%>  <%=rs3.getString(1)%>

                                                                   </p>
                                                                   </li>
                                                                            <%
                                                                }
                                                                rs3.close();
                                                                st3.close();
                                                                cn3.close();
                                                                }catch(Exception e){
                                                                    e.printStackTrace();
                                                                }
                                                    %>
                                                
                                                
                                            </ul>
                                                

                                            </div>

                                
                                
                           
                          
                            </td>
                            <td ><%=rs.getString(6)%>
                            
                            </td>
                            <td class="text-center titulo "> <%=rs.getString(7)%></td>
                             <%  if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("")){%>
                            
                            <td aling="justify"> 
                               <a href="Agenda_Editar_Cab.jsp?idRegistroAgenda=<%= rs.getString(1)%>&observacion=<%= rs.getString(7)%>&h_inicio=<%= rs.getString(3)%>&h_fin=<%= rs.getString(4)%>&fechaAgenda=<%= rs.getString(2)%>&idClienteAsig=<%=rs.getString(9)%>&nombreCliente=<%=rs.getString(6)%>&nombreDepartamento=<%=rs.getString(11)%>&idEjecutivo=<%=rs.getString(12)%>&nombreEjecutivo=<%=rs.getString(5)%>" class="btn btn-xs btn-warning " data-bs-toggle="tooltip" title="Editar Cita!"><span class="glyphicon glyphicon-pencil"></span> </a>
                         
                                 <a href="Agenda_Agregar_Colega.jsp?idRegistroAgenda=<%= rs.getString(1)%>" class="btn btn-xs btn-primary"data-bs-toggle="tooltip" title="Agregar Colega!">+<span class="glyphicon glyphicon-user"></span> </a>
                                
                                <a href="ADM_TerminarAgenda.jsp?idRegistroAgenda=<%= rs.getString(1)%>" class="btn btn-xs btn-success"data-bs-toggle="tooltip" title="Terminar!"><span class="glyphicon glyphicon-ok"></span> </a>
                                 
                            </td>
                                
                            <td align="center" >
                                <!--<a href="ADM_CancelarAgenda.jsp?idRegistroAgenda=<%= rs.getString(1)%>" class="btn btn-xs btn-info " data-bs-toggle="tooltip" title="Cancelar Cita!"><span class="glyphicon glyphicon-remove"></span> </a>-->
                            <a href="ADM_EliminarAgenda.jsp?idRegistroAgenda=<%= rs.getString(1)%>" class="btn btn-xs btn-danger"data-bs-toggle="tooltip" title="Elimnar!"><span class="glyphicon glyphicon-trash"></span> </a>
                            </td>
                                <%}%>
                            
                           
                        </tr>
                        <%}rs.close();st.close();cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}%>
                    </tbody>
                </table> 
            </div>
        </div>
    </div>
                    
               
               
    <div class="modal fade control-label form-group" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Nuevo Registro Agenda</h4>
    </div>
        
        <form  action="ADM_Insert_Agenda.jsp"  method="POST" >
        <div class="modal-body">
            <div class="container-fluid">
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">      
                <label class=" control-label" for="Ejecutivo">Ejecutivo</label>
                <div class="form-group ">
                                <select class=" form-control" id="idEjecutivo" name ="idEjecutivo" >
                                    <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
                                        String sql = "select * from Usuario where estado = 'a' order by 2";
                                        PreparedStatement st = cn.prepareStatement(sql);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()) {
                                        %>                                                                    
                                        <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
                                        <%
                                            }     
                                            rs.close();
                                            st.close();
                                            cn.close();
                                        }catch(Exception e){
                                             e.printStackTrace();
                                        }

                                    %>       
                    </select>
                </div>
            </div>
                
                
                
            </div>
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="Ruc" >FECHA</label>
                <input type="date" name="fechAgenda" id="fechAgenda" class="form-control" required />
                <script>
                            document.getElementById('fechaAgenda').value = new Date().toISOString().substring(0, 10);
            </script>
            </div>
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for=" Telefono" >HORA INICIO</label>
                <input type="time" name="h_inicio" id="h_inicio" class="form-control" placeholder="09:00" required />
            </div>
            </div>
            <div class="col-lg-6">
            <div class="form-group">
                <label for="Contacto" class="form-control-label">HORA FIN</label>
                <input type="time" name="h_fin" id="h_fin" class="form-control" placeholder="15:00" required   />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-12 ">
            <div class="form-group">
                <label class=" control-label" for="Cliente" >Cliente</label>
                <!--<input type="text" name="Cliente" id="Cliente" class="form-control" required />-->
                <div class="form-group">
                                <select class=" form-control" id="cliente" name ="cliente">
                                    <!--<option value="<%=idcliente%>"><%=client%></option>-->
                                    <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
                                        String sql = "select * from Cliente where estado = 'a' order by 2";
                                        PreparedStatement st = cn.prepareStatement(sql);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()) {
                                        %>                                                                    
                                        <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                                        <%
                                            }     
                                            rs.close();
                                            st.close();
                                            cn.close();
                                        }catch(Exception e){
                                             e.printStackTrace();
                                        }

                                    %>       
                    </select>
                </div>
                    
            </div>
                    
                    <div class="form-group">
                        <label class=" control-label" for="Cliente" >Departamento</label>
               <select class=" form-control" name="grupo">
                  <%try{
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection   cn = DriverManager.getConnection(url, user, pass);
                    String sql2 = "select A.IDTODOCABGRUPO, A.NOMBREGRUPO, A.ESTADO from TODOCABGRUPO A where  A.IDTODOCABGRUPO>1 AND ESTADO = 'A' ORDER BY 2";
                    PreparedStatement st = cn.prepareStatement(sql2);
                    ResultSet rs = st.executeQuery();       
                    while (rs.next()){%>   
                        <option value="<%=rs.getString(2)%>"><%=rs.getString(2)%></option>
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
            <div class="col-lg-12">
                <div class="form-group">
                    <label for="Observacion" class="form-control-label">Observación</label>
                    <textarea class="form-control" id="observacion" name="observacion" ></textarea>
                </div>  
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
               
               <!--model grupo-->
<!--               <div class="modal fade" id="myModalGrupo" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Agregar Colegas</h4>
    </div>
        <form  action="ADM_Insert_Agenda_Colega.jsp"  method="POST" >
        <div class="modal-body">
            <div class="container-fluid">
            
            <div class="container-fluid">

                <table class="fixed_headers container-fluid">
                    <thead>
                      <tr>
                          <th>Id</th>
                           <th>DEPARTAMENTO</th>
                        <th>COLEGA</th>
                         <th align="center" >AGREGAR</th>
                        <th>Elegir</th>
                       
                      </tr>
                    </thead>
                    <tbody>
   
            
                    <div class="form-check">
                        
                        <%
                                        try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
                                        String sql = "Select a.idusuario, a.apellidos, a.nombre, b.departamento from usuario a, adm_departamento b where a.id_adm_departamento = b.id_departamento and a.estado = 'a'  order by b.departamento";
//                                                "select * from Usuario where estado = 'a' order by 2";
                                        PreparedStatement st = cn.prepareStatement(sql);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()) {
                                        %>   
                                        <tr>
                                            <td><%=rs.getString(4) %></td>
                                            <td><label class="form-check-label"><%=rs.getString(2)%> - <%=rs.getString(3)%></label></td>
                                            <td align="center" >
                                                <input class="form-check-input valores" type="checkbox" id="colega" name="<%=rs.getString(2)%> <%=rs.getString(3)%> " value="<%=rs.getString(1)%> " ></td>                                          
                                        </tr>
                                        
                                        <%
                                            }     
                                            rs.close();
                                            st.close();
                                            cn.close();
                                        }catch(Exception e){
                                             e.printStackTrace();
                                        }

                                    %> 
                    </div>
                           
                   </tbody>
            </table>                                    
                      
            </div>
                    <h3>Colegas seleccionados</h3>
                    <u  class="container-fluid" id="lista" class="list-group"> </u>
                    
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
                <button type="button" id="boton" class="btn btn-success"> Confirmar selección </button>
                <button type="submit"  class="btn btn-primary">Guardar</button>
                
                
            </div>
        </div> 
        </div>
                     
        </form>
                 
                    
    </div>
  </div>
</div>   -->
<!--                    <script src="js/jquery.js"></script>   
                    <script src="js/bootstrap.min.js"></script>
                    
        <script src="js/chosen.jquery.js" type="text/javascript"></script>     
    <script src="js/init.js" type="text/javascript" ></script>-->
              
</body>
<section class="">
  <!-- Footer -->
  <footer class="text-center text-white" style="background-color: #0a4275;">
    <!-- Grid container -->
    <div class="container p-4 pb-0">
      <!-- Section: CTA -->
      
      <!-- Section: CTA -->
    </div>
    <!-- Grid container -->

    <!-- Copyright -->
    <div class="text-center text-warning p-3" style="background-color: #0a4275;">
      © 2023 Copyright:
      <a class="text-white" href="https://overclocking.com.ec/">overclocking.com.ec</a>
    </div>
    <!-- Copyright -->
  </footer>
  <!-- Footer -->
</section>
<!--<script> 
                var boton = document.getElementById('boton');
                var lista = document.getElementById('lista');
                var checks = document.querySelectorAll('.valores');
                
                boton.addEventListener('click', function (){
                    lista.innerHTML = '';
                    checks.forEach((e)=>{
                        if(e.checked == true){
                            console.log(e.value);
                            var elemento = document.createElement('li');
                            
                            elemento.className='list-group-item';
//                            elemento.innerHTML = e.name;
                            elemento.innerHTML = e.value + e.name;
                            
                            lista.appendChild(elemento);
                        }
                    });
                });
                </script>-->
<!--   <style>
                    .fixed_headers {
                        /* para ampliar ancho del modal de grupos*/
                        width: 600px; 
                        table-layout: fixed;
                        border-collapse: collapse;
                      }
                      .fixed_headers th {
                        text-decoration: underline;
                      }
                      .fixed_headers th,
                      .fixed_headers td {
                        padding: 5px;
                        text-align: center;
                      }
                      .fixed_headers td:nth-child(1),
                      .fixed_headers th:nth-child(1) {
                        min-width: 200px;
                      }
                      .fixed_headers td:nth-child(2),
                      .fixed_headers th:nth-child(2) {
                        min-width: 200px;
                      }
                      .fixed_headers td:nth-child(3),
                      .fixed_headers th:nth-child(3) {
                        width: 400px;
                      }
                      .fixed_headers thead {
                          background-color: #33cc00;
                          color: #333333;
                      }
                      .fixed_headers thead tr {
                        display: block;
                        position: relative;
                      }
                      .fixed_headers tbody {
                        display: block;
                        overflow: auto;
                        width: 100%;
                        height: 350px;
                      }
                      .fixed_headers tbody tr:nth-child(even) {
                        background-color: #DDD;
                      }
                      .old_ie_wrapper {
                        height: 300px;
                        width: 850px;
                        overflow-x: hidden;
                        overflow-y: auto;
                      }
                      .old_ie_wrapper tbody {
                        height: auto;
                      }

                </style> -->
</html>
