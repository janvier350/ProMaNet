<%-- 
    Document   : LISTADO DE EQUIPO
    Created on : 26-Febrero-2019, 11:21:01
    Author     : Jquinde
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
    String idEqui = request.getParameter("id");
    String idEquipoNew = "";
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("JEFE")||cargo.equals("ADMINISTRADOR")||cargo.equals("ADMINISTRACIÓN")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet|Lista de Equipo</title>
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
            var id =<%=idEqui%>;
                if(id>0){
                   $(window).load(function(){
                   $('#myModalAsig').modal('show');}
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
                <%}else if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){%>
                   <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                <%}%>
                <li><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                <li><a href="Mantenimiento.jsp">AVANCE</a></li>
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
<!--                <li class="dropdown "><a id="dLabel" role="button" data-toggle="dropdown" href="#">
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
                </li>-->
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
        <a href="Home.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
        <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
        <p style="color:green"><b>Regresar</b></p>
    </div>    
                                
    
    <div class="form-group" >
         <div class="form-group">
            <table class="table table-striped ">
                <thead >
                    <tr>
                        <th class="text-center" style="font-size: 16px">Buscar</th>
                        <th class="text-center" style="font-size: 16px">Crear</th>
                        <th class="text-center" style="font-size: 16px">Inventario Completo</th>
                        <th class="text-center" style="font-size: 16px" colspan="4">Exportar</th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td align="center" >
                        <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
                    </td>
                    <td align="center" >
                        <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">note_add</i></a>
                        </button> 
                    </td>
                    <td align="center" >
                        <a type="button" class="btn btn-default " href="INV_InventarioEquipo.jsp">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">business</i></a>                        
                    </td>
                    <td align="center">
                        <a type="button" class="btn btn-default " href="#">
                            <i class="material-icons" style="color:#000;font-size:30px">description</i>     
                        </a>
                        <a type="button" class="btn btn-default"  href="#">
                           <i class="material-icons" style="color:#000;font-size:30px">picture_as_pdf</i>    
                        </a>
                    </td>
                </tr> 
                </tbody>
            </table>
        </div>
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
    <tr>
        <th class="text-center">Id</th>                  
        <th class="text-center">Fecha Compra</th> 
        <th class="text-center">Usuario Asignado</th>
        <th class="text-center">Empresa</th>
        <th class="text-center">Oficina</th>
        <th class="text-center">Departamento</th>
        <th class="text-center">Dispositivo</th>
        <th class="text-center">Marca</th>
        <th class="text-center">Modelo</th>
        <th class="text-center">Serial</th>
        <th class="text-center">Procesador</th>
        <th class="text-center">Disco Duro</th>
        <th class="text-center">RAM</th>
        <th class="text-center">Pantalla</th>
        <th class="text-center">Observaciones</th>
        <th class="text-center">Imagen</th>        
        <th class="text-center">Estado</th>        
        <th class="text-center">Editar</th>
        <th class="text-center">Asignar a:</th>
        <th class="text-center">Eliminar</th>
        
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select a.idinvequipo, a.fechacompra, a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where (a.estado = 'A' or a.estado='D' )and a.estado_ai ='A' ORDER BY a.estado desc, c.nombre, c.apellidos";                
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td>
        <%= idEquipoNew = rs.getString(1)%>
        </td>
        <td><%=rs.getString(2)%></td>
        <td><%=rs.getString(15)%></td>
        <td><%=rs.getString(16)%></td>
        <td><%=rs.getString(3)%></td>
        <td><%=rs.getString(4)%></td>
        <td><%=rs.getString(17)%></td>
        <td><%=rs.getString(5)%></td>
        <td><%=rs.getString(6)%></td>
        <td><%=rs.getString(7)%></td>
        <td><%=rs.getString(8)%></td>
        <td><%=rs.getString(9)%></td>
        <td><%=rs.getString(10)%></td>
        <td><%=rs.getString(11)%></td>
        <td><%=rs.getString(12)%></td>
        <td><img id="myImg" class="zoom" src="image/promanet/inventario/<%=rs.getString(18)%>" alt="pc" width="50" height="50"></td>
        <%if(rs.getString(13).equals("A")){%>
            <td type="text"title="Asignado." style="background-color: yellow"> Asignado</td>
        <%}%>
        <%if(rs.getString(13).equals("D")){%>
            <td type="text"title="Disponible." style="background-color: #99ff66">  Disponible</td>
        <%}%>
        <%if(rs.getString(13).equals("F")){%>
            <td type="text"title="Fuera de Servicio." style="background-color: #ff9999">  Fuera de Servicio</td>
        <%}%>
         <%if(rs.getString(13).equals("PV")){%>
            <td type="text"title="Vendido." style="background-color: #ff9999">Vendido</td>
        <%}%>
        <%if(rs.getString(13).equals("V")){%>
            <td type="text"title="Vendido." style="background-color: #ff9999">Vendido</td>
        <%}%>
        <%if(rs.getString(13).equals("R")){%>
            <td type="text"title="Robado." style="background-color: #ff9999">Robado</td>
        <%}%>
        <%if(rs.getString(13).equals("M")){%>
            <td type="text"title="Mantenimiento." style="background-color: #00ffff">Mantenimiento</td>
        <%}%>
        <%if(rs.getString(13).equals("I")){%>
            <td type="text"title="Infraestructura." style="background-color: #008CBA">Infraestructura</td>
        <%}%>
        <td>
            <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
            </a> 
<!--            <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
            </a>    -->
        </td>        
        <%if(rs.getString(14)==null||rs.getString(14).equals(null)){%>     
        <!--data-toggle="modal" data-target="#myModal"-->
         <td><a  class="btn btn-warning " data-toggle="modal" data-target="#myModalAsig" ><i class="material-icons " style="color:white;font-size: 21px" >people</i></a></td>  
            <!--<td><a  class="btn btn-primary " href="INV_ListadoEquipo.jsp?id=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 21px" >people</i></a></td>-->             
            <td ><a class="btn btn-danger " href="INV_EliminarEquipo.jsp?idInvEquipo=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size:21px">delete_forever</i></a></td>  
            
        <%}else{%>
            <td><a  class="btn btn-primary disabled" href="#"><i class="material-icons" style="color:white;font-size: 21px" >people</i></a></td> 
            <td ><a class="btn btn-danger disabled" href="#" ><i class="material-icons"  style="color:white;font-size:21px">delete_forever</i></a></td>            
        <%}%>
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
    
    <!--inicio modal agregar equipo-->
    <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Agregar Nuevo Equipo ok</h4>
    </div>
        <form action="InsertNuevoEquipo" enctype="multipart/form-data" method="POST">        
    <div class="modal-body">
        <div class="container-fluid">
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="fecha" class="control-label">Fecha de Compra:</label>
                        <input type="date" name="fechacompra" id="fechacompra" class="form-control" required />
                          <script>
                            document.getElementById('fechacompra').value = new Date().toISOString().substring(0, 10);
            </script>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="empresa" class="control-label">Empresa</label>
                        <select class="form-control" id="empresa" name="empresa" style="width:100%">
                            <option value="Buadnet S.A">Buadnet S.A</option>                      
                            <option value="Xp Audit Solutions">Xp Audit Solutions</option>                      
                            <option value="Latin Consulting">Latin Consulting</option>                      
                            <option value="Dk Work">Dk Work</option>  
                            <option value="Arthurs Audit Global">Arthurs Audit Global</option>     
                            <option value="N/A">N/A</option> 
                        </select>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="ubicacion" class="control-label">Ubicacion/ Oficina:</label>
                        <select class="form-control" id="ubicacion" name="ubicacion" style="width:100%">
                            <option value="Norte">Norte</option>                      
                            <option value="Kennedy">Kennedy</option>                      
                            <option value="Outsourcing">Outsourcing</option>                        
                        </select>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="departamento" class="control-label">Departamento:</label>
                        <select class="form-control" id="departamento" name="departamento" style="width:100%">
                            <option value="Impuestos">Impuestos</option>                      
                            <option value="Sistemas">Sistemas</option>                      
                            <option value="Norte">Norte</option>                      
                            <option value="Contabilidad">Contabilidad</option>   
                            <option value="Gerencia">Gerencia</option>  
                            <option value="Auditoria">Auditoria</option>  
                            <option value="Legal">Legal</option>  
                            <option value="Administracion">Administracion</option>  
                        </select>
                    </div>
                </div>
            </div>    
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="dispositivo" class="control-label">Tipo de Dispositivo:</label>
                        <select class="form-control" id="dispositivo" name="dispositivo" style="width:100%">
                            <option value="Laptop">Laptop</option>                      
                            <option value="Impresora">Impresora</option>                      
                            <option value="Proyector">Proyector</option>                      
                            <option value="Networking">Networking</option>  
                            <option value="CCTV">CCTV</option>   
                            <option value="Perifericos">Perifericos</option>   
                        </select>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="marca" class="form-control-label">Marca:</label>
                        <input type="text" name="marca" id="marca" class="form-control" required value="NA" />
                    </div>  
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="modelo" class="control-label">Modelo:</label>
                        <input type="text" name="modelo" class="form-control" required value="NA" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="serial" class="form-control-label">Serial:</label>
                        <input type="text" name="serial" id="serial" class="form-control" value="NA" />
                    </div>  
                </div>
            </div>                                             
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="procesador" class="form-control-label">Procesador:</label>
                        <input type="text" name="procesador" id="procesador" class="form-control" required value="NA" />
                    </div>  
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="hdd" class="form-control-label">Disco Duro:</label>
                        <input type="text" name="hdd" id="hdd" class="form-control" required value="NA" />
                    </div>  
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="ram" class="form-control-label">Memoria RAM:</label>
                        <input type="text" name="ram" id="ram" class="form-control" required value="NA"/>
                    </div>  
                </div>
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="pantalla" class="form-control-label">Pantalla:</label>
                        <input type="text" name="pantalla" id="pantalla" class="form-control" required value="NA"/>
                    </div>  
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="observaciones" class="form-control-label">Observaciones:</label>
                        <input type="text" name="observaciones" id="observaciones" class="form-control" required  value="NA"/>
                    </div>  
                </div> 
                <div class="col-lg-6">
                    <div class="form-group">
                        <label for="file" class="form-control-label">Imagen:</label>
                        <input type="file" name="file" id="file" class="form-control" accept="image/x-png,image/gif,image/jpeg" />
                    </div>  
                </div> 
            </div> 
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            <button type="submit" class="btn btn-primary">Guardar</button>
        </div>
    </div> 
</form>

    </div>
  </div>
</div>
    <!--fin modal agregar equipo-->
    
                <!--MODAL PARA VER EL USUARIO ASIGNADO-->
<div class="modal fade" id="myModalAsig" role="dialog">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">ASIGNAR DISPOSITIVO A:</h4>
              </div>
                <form  action="#.jsp"  method="POST" >
              <div class="modal-body">
                  <table id="detalles" class="table table-striped table-hover   " >
      <thead>
        <tr>
          <th class="text-center">Id</th>
          <th class="text-center">Nombre Usuario</th>
          <th class="text-center">Asignar</th>
        </tr> 
      </thead>
    <% try{
      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
      Connection cn2 = DriverManager.getConnection(url, user, pass);
      String sql2 = "Select IDUSUARIO, NOMBRE||' '||APELLIDOS as nombre,IDROL,ESTADO From usuario where ESTADO='a' and  "
              + " Not IDUSUARIO In (select a.IDUSUARIO from INV_ASIGNACION a where a.ESTADO = 'A')  order by 2";
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center" >
      <tr>
        <td type="text" ><%= rs2.getString(1)%></td> 
        <td type="text" ><%= rs2.getString(2)%></td>
        <td>
            <a href="INV_InsertarAsignacion.jsp?idUsuario=<%=rs2.getString(1)%>&idEquipo=<%=idEquipoNew%>" class="btn btn-success ">
               <i class="material-icons " style="color:white;font-size:25px">person_add</i>
            </a>    
        </td>     
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
<!--      <button type="submit"  class="btn btn-primary">Guardar</button>-->
   </div>
   </form>
   </div>
   </div>
   </div>
 <!--fin modal asignar--> 
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
    <div id="myModal" class="modal">
        <span class="close">&times;</span>
        <img class="modal-content" id="img01">
        <div id="caption"></div>
      </div>
    <script>
    // Get the modal
    var modal = document.getElementById('myModal');

    // Get the image and insert it inside the modal - use its "alt" text as a caption
    var img = document.getElementById('myImg');
    var modalImg = document.getElementById("img01");
    var captionText = document.getElementById("caption");
    img.onclick = function(){
      modal.style.display = "block";
      modalImg.src = this.src;
      captionText.innerHTML = this.alt;
    }

    // Get the <span> element that closes the modal
    var span = document.getElementsByClassName("close")[0];

    // When the user clicks on <span> (x), close the modal
    span.onclick = function() { 
      modal.style.display = "none";
    }
    </script>
    <script src="js/chosen.jquery.js" type="text/javascript"></script>     
    <script src="js/init.js" type="text/javascript" ></script>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    </body>
</html>