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
        <title>ProMaNet | TODO</title> 
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
      <li><a href="Agenda.jsp">AGENDA</a></li>
    <%if(usuario.equals("uparrales")){%>
        <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
     <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
        <li class="active"><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
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
                     <button type="button" class="btn btn-default " data-toggle="modal" data-bs-toggle="tooltip" title="Tareas Predeterminadas" data-target="#myModalProyectos">
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

                    <a type="button" class="btn btn-default " href="TODO_TRABAJO_INDIVIDUAL_JV.jsp">
                        <i class="material-icons" style="color:#0A6BD2;font-size:30px">assignment_ind</i>
                    </a>                     
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
                   
    <div class="form-group">
    <div class="table-responsive">
        <table  class="table table-striped table-hover table-bordered  " >
        <thead>
          <tr class="success">
                <th class="text-center">Fecha de Asignacion</th>
                <th class="text-center">Fecha de Entrega</th>
                <th class="text-center">Jefe Asignado</th>
                <th class="text-center">Cliente</th>
                <th class="text-center">Trabajo</th>  
                <th class="text-center">Estado</th>
                <th class="text-center">Pasar a Revision</th> 
                <th class="text-center">Ver</th>
                  <%if(roltodo.equals("JEFE")){%>
                <!--<th class="text-center">Asignar</th>-->
                    <th class="text-center">Editar</th>
                <th class="text-center">Eliminar</th>
                <th class="text-center">Imprimir</th> 
                  <%}else if(roltodo.equals("ASISTENTE")){%>
                   
                  <%}%>
                
            </tr> 
        </thead>
<%  
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql ="";
        if(roltodo.equals("JEFE")){
           sql = "SELECT to_char(B.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,a.CLIENTE, "
                   + "b.TRABAJO, b.ESTTRAB,b.IDTODOCAB ,b.IDJEFEASIG, C.NOMBRE||' '||C.APELLIDOS, b.idtodocabgrupo, d.tarea from cliente a,TODOCABTRAB b , USUARIO C , todo_cab_tareas d "
                   + "where a.IDCLIENTE = b.IDCLIENTE and b.ESTADO = 'A' and (b.IDUSUARIO= "+codigo+" or b.IDJEFEASIG= "+codigo+") and b.ESTTRAB "+EstTrab+" and b.IDJEFEASIG=C.IDUSUARIO and b.idcabtarea = d.id_todo_cab_tareas  order by 7 DESC";
        }else if(roltodo.equals("ASISTENTE")){
           sql = "SELECT to_char(B.FECHAHORAASIG, 'DD-MM-YY'),to_char(b.FECHAFIN, 'DD-MM-YY'),to_char(b.FECHALEGAL, 'DD-MM-YY') ,a.CLIENTE, b.TRABAJO, b.ESTTRAB,b.IDTODOCAB "
             + " from cliente a,(SELECT DISTINCT B.IDTODOCABTRAB, A.IDTODOCAB, A.IDUSUARIO, A.DESCRIPCION, A.TRABAJO, "
             + " A.FECHAINCIO, A.FECHAFIN, A.FECHAHORAASIG, A.FECHALEGAL, A.FECHACONTRATO, A.IDCLIENTE, A.ESTADO, A.COMENTARIO, A.IDTODOAREA, A.ESTTRAB, A.IDTODOCABGRUPO "
             + " FROM TODOCABTRAB A,TODODETTRAB B, TODOASIGTAREA C WHERE A.IDTODOCAB = B.IDTODOCABTRAB AND B.IDTODODET = C.IDTODODETTRAB "
             + " AND C.IDUSUARIO = "+codigo+" ) b where a.IDCLIENTE = b.IDCLIENTE and b.ESTADO = 'A' and b.ESTTRAB "+EstTrab+" order by 7 DESC";
        }
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
              
    <tbody align="center" id="myTable">
        <tr>
            <td><%= String.valueOf(rs.getString(1))%></td>
            <td><%= String.valueOf(rs.getString(2))%></td>
             <%if(roltodo.equals("JEFE")){%>
                <td><a href="TODO_Cab_Trabajo.jsp?id=<%= rs.getString(10)%>"><%= String.valueOf(rs.getString(9))%></a></td>
              <%}else if(roltodo.equals("ASISTENTE")){%>
                <td><%= nombre+" "+apellidos%></td>
              <%}%>
            
            <td><%= String.valueOf(rs.getString(4))%></td>
            <td type="text"><%= String.valueOf(rs.getString(11))%></td>
        <%if(rs.getString(6).equals("P")){%>
            <td type="text"title="El proyecto se encuentra en proceso." style="background-color: yellow"> PENDIENTE</td>
        <%}%>
        <%if(rs.getString(6).equals("T")){%>
            <td type="text"title="Proyecto Terminado." style="background-color: #99ff66">  TERMINADO</td>
        <%}%>
        <%if(rs.getString(6).equals("A")){%>
            <td type="text"title="Proyecto Atrasado." style="background-color: #ff9999">  ATRASADO</td>
        <%}%>
        <%if(rs.getString(6).equals("R")){%>
            <td type="text"title="Proyecto Reversado." style="background-color: #ff5722">  REVERSADO</td>
        <%}%>
        <%if(roltodo.equals("JEFE")){%>
            <td><a class="btn btn-default" href="TODO_TerminarCabTrab.jsp?idCab=<%=rs.getString(7)%>"><i class="material-icons " style="color:green;font-size:21px">check_circle</i></a></td>              
<!--            <td><a class="btn btn-primary" href="TODO_det_Trabajo.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">	visibility</i></a></td> -->
             <td><a class="btn btn-primary" href="../ProMaNet/Proyectos/PRO_Lista.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">	visibility</i></a></td> 
             
             <td><a class="btn btn-dark" href="../ProMaNet/TODO_det_Trabajo_1.jsp?idCabTrab=<%=rs.getString(7)%>&idTrabajo=<%=rs.getString(5)%>"><i class="material-icons " style="color:white;font-size:21px">	visibility</i></a></td> 
             
            <!--<td><a class="btn btn-success" href="TODO_det_Trabajo.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">supervisor_account</i></a></td>-->  
            <td><a class="btn btn-info" href="TODO_EditarCabTrab.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">mode_edit</i></a></td> 
            <td ><a class="btn btn-danger" href="TODO_EliminarCabTrab.jsp?idCab=<%=rs.getString(7)%>&idTrabajo=<%=rs.getString(5)%>"><i class="material-icons " style="color:white;font-size:21px">delete_forever</i></a></td>
            <td ><a class="btn btn-warning " target="_blank"  href="TODO_GenerarPDF.jsp?id=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">print</i></a></td>
         <%}else if(roltodo.equals("ASISTENTE")){%>
             <td><a class="btn btn-default" href="TODO_TerminarCabTrab.jsp?idCab=<%=rs.getString(7)%>"><i class="material-icons " style="color:green;font-size:21px">check_circle</i></a></td>  
            <!--<td><a class="btn btn-default disabled "><i class="material-icons " style="color:green;font-size:27px">check_circle</i></a></td>-->              
                         <td><a class="btn btn-primary" href="../ProMaNet/Proyectos/PRO_Lista.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">	visibility</i></a></td> 
           
 <td><a class="btn btn-primary "href="TODO_det_Trabajo.jsp?idCabTrab=<%=rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:21px">	visibility</i></a></td>      
         <%}%>
        </tr>
       <%}%>
    </tbody>
    </table> 
   <% rs.close();
      st.close();
      cn.close();
      }catch(Exception e){
        e.printStackTrace();
      }%>  
    </div>
    
    </div>
    <br><br><br>
    <!--modal crear proyectos-->
    <div class="modal fade" id="myModalProyectos" role="dialog">
        <div class="modal-dialog modal-lg">
        <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Nuevo Compromiso</h4>
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
            <label class=" control-label" for="fechaleg">Fecha Legal</label>
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
<!--           <div class="col-lg-6" class="form-group">
               <label for="Trabajo" class="form-control-label">Proyecto</label>
               <input type="text" name="Trabajo" id="Trabajo" class="form-control" required />
           </div>  -->
<div class="col-lg-6 form-group">
    <label class="control-label" for="Trabajo">Compromiso</label>
    <select class="form-control" name="Trabajo" id="Trabajo" onchange="setCompromisoValue(this)">
        <%  
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql3 = "select * from TODO_CAB_TAREAS where estado = 'A' order by 1";
            PreparedStatement st = cn.prepareStatement(sql3);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
        %>      
        <option value="<%=rs.getString(1)%>" data-compromiso="<%=rs.getString(3)%>"><%=rs.getString(3)%></option>
        <%  
            }     
            rs.close();
            st.close();
            cn.close();
        } catch(Exception e) {
            e.printStackTrace();
        } 
        %>  
    </select> 
</div>

<!-- Aquí el nuevo input donde quieres poner el valor de rs.getString(3) -->
<div class="col-lg-6 form-group">
    <label class="control-label" for="CompromisoValor">Valor de Compromiso</label>
    <input type="text" class="form-control" name="CompromisoValor" id="CompromisoValor" readonly>
</div>

<script>
    // JavaScript para establecer el valor de compromiso
    function setCompromisoValue(selectElement) {
        var selectedOption = selectElement.options[selectElement.selectedIndex];
        var compromisoValue = selectedOption.getAttribute("data-compromiso");
        document.getElementById("CompromisoValor").value = compromisoValue;
    }
</script>

<!--           <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="Trabajo">Compromiso</label>
               <select class="form-control" name="Trabajo" id="Trabajo">
                   <%  try{
                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                       Connection   cn = DriverManager.getConnection(url, user, pass);
                       String sql3 = "select * from TODO_CAB_TAREAS where estado = 'A' order by 1";
                       PreparedStatement st = cn.prepareStatement(sql3);
                       ResultSet rs = st.executeQuery();       
                       while (rs.next()) {
                       %>      
                       <option value="<%=rs.getString(1)%> "><%=rs.getString(3)%></option>
                           <option value="<%=rs.getString(1)%> + <%=rs.getString(3)%> "><%=rs.getString(3)%></option>
                           
                   <%  }     
                       rs.close();
                       st.close();
                       cn.close();
                   }catch(Exception e){
                        e.printStackTrace();
                   }%>  
                   
               </select> 
              
            </div>-->
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
         <!--responsable y encargado-->
         
         <div class="row">
<!--           <div class="col-lg-6" class="form-group">
               <label for="Trabajo" class="form-control-label">Proyecto</label>
               <input type="text" name="Trabajo" id="Trabajo" class="form-control" required />
           </div>  -->
           <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="responsable">Responsable</label>
               <select class="form-control" name="idJefeAsignado" id="idJefeAsignado">
                   <%  try{
                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                       Connection   cn = DriverManager.getConnection(url, user, pass);
                       String sql3 = "select * from usuario where estado = 'a' and idrol = 5 order by 2";
                       PreparedStatement st = cn.prepareStatement(sql3);
                       ResultSet rs = st.executeQuery();       
                       while (rs.next()) {
                       %>                                                                    
                           <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
                   <%  }     
                       rs.close();
                       st.close();
                       cn.close();
                   }catch(Exception e){
                        e.printStackTrace();
                   }%>              
               </select> 
            </div>
           <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="cliente">Encargado # 1</label>
               <select class="form-control" name="idEncargado1">
                   <%  try{
                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                       Connection   cn = DriverManager.getConnection(url, user, pass);
                       String sql3 = "select * from usuario where estado = 'a' order by 2";
                       PreparedStatement st = cn.prepareStatement(sql3);
                       ResultSet rs = st.executeQuery();       
                       while (rs.next()) {
                       %>                                                                    
                           <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
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
               <!--<label for="Trabajo" class="form-control-label">Proyecto</label>-->
               <!--<input type="text" name="Trabajo" id="Trabajo" class="form-control" required />-->
           </div>  
           
           <div class="col-lg-6" class="form-group">
               <label class= "control-label" for="cliente">Encargado # 2</label>
               <select class="form-control" name="idEncargado2">
                   <%  try{
                       DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                       Connection   cn = DriverManager.getConnection(url, user, pass);
                       String sql3 = "select * from usuario where estado = 'a' order by 2";
                       PreparedStatement st = cn.prepareStatement(sql3);
                       ResultSet rs = st.executeQuery();       
                       while (rs.next()) {
                       %>                                                                    
                           <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
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
               <textarea class="form-control" id="Descripcion" name="Descripcion" value ="N/A" required> N/A</textarea>
            </div>  
            <div class="col-lg-6" class="form-group ">
               <label for="Coment" class="control-label">Comentario</label>
               <input type="text" name="Comentario" id="Comentario" class="form-control" required />
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
                   String sql4 = "select * from TODOCABGRUPO where estado = 'A' order by 2 desc";
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
            <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
            <button type="submit"  class="btn btn-primary">Guardar</button>
        </div>
        </div>
    </form>
    </div>  
    </div>
    </div>
               
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
               <textarea class="form-control" id="Descripcion" name="Descripcion" required></textarea>
            </div>  
            <div class="col-lg-6" class="form-group ">
               <label for="Coment" class="control-label">Comentario</label>
               <input type="text" name="Comentario" id="Comentario" class="form-control" required />
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
                   String sql4 = "select * from TODOCABGRUPO where estado = 'A' order by 2 desc";
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
            <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
            <button type="submit"  class="btn btn-primary">Guardar</button>
        </div>
        </div>
    </form>
    </div>  
    </div>
    </div>
               
<!--              modal para asistente ESTE MODAL SE AGREGO PARA CREAR TAREAS PROPIAS PARA EL ASISTENTE MODAL 2-->
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
            <input type="date" name="fechafin" id="fechafin" class="form-control"  />
            <script>
            document.getElementById('fechafin').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechaleg">Fecha legal</label>
            <input type="date" name="fechaleg" id="fechaleg" class="form-control"  />
            <script>
            document.getElementById('fechaleg').value = new Date().toISOString().substring(0, 10);
            </script>
        </div>
        <div class="col-lg-3 form-group">
            <label class=" control-label" for="fechacont">Fecha Contrato</label>
            <input type="date" name="fechacont" id="fechacont" class="form-control"  />
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
               <textarea class="form-control" id="Descripcion" name="Descripcion" required></textarea>
            </div>  
            <div class="col-lg-6" class="form-group ">
               <label for="Coment" class="control-label">Comentario</label>
               <input type="text" name="Comentario" id="Comentario" class="form-control"  />
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
               <label class= "control-label" for="grupo" >Jefe Solicitante</label>
               <select class="form-control" name="idJefe" required>
                  <option >Ninguno</option>
                  <%try{
                   DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                   Connection   cn = DriverManager.getConnection(url, user, pass);
                   String sql4 = "select apellidos, nombre, idusuario from USUARIO where estado = 'a' and idroltodo = 1  order by 1 asc";
                   PreparedStatement st = cn.prepareStatement(sql4);
                   ResultSet rs = st.executeQuery();       
                   while (rs.next()) {%>                                                                    
                     <option value="<%=rs.getString(3)%>"><%=rs.getString(1)%> <%=rs.getString(2)%></option>
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
      <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
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

