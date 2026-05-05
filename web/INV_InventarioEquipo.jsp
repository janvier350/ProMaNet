<%-- 
    Document   : Inventario completo DE EQUIPO
    Created on : 28-Febrero-2019, 15:21:01
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
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet | Lista de Equipo</title>
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
        <script src="js/jspdf.js"></script>
        <script>
            var id =<%=idEqui%>;
                     if(id>0){
                        $(window).load(function(){
                        $('#myModalAsig').modal('show');}
                   );
            }  
        </script>                 
        <script type="text/javascript">
            function loadTable(){
                document.getElementById('tbldiv').width=screen.availWidth;
                document.getElementById('tbldiv').height=screen.availHeight;
            }
        var tableToExcel = (function() {
            var uri = 'data:application/vnd.ms-excel;base64,'
              , template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" \n\
                            xmlns="http://www.w3.org/TR/REC-html40">\n\
                            <head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>\n\
                            <x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>\n\
                            </x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->\n\
                            </head>\n\
                            <body>\n\
                            <table>{table}</table>\n\
                            </body></html>'
              , base64 = function(s) { return window.btoa(unescape(encodeURIComponent(s))) }
              , format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
            return function(table, name) {
              if (!table.nodeType) table = document.getElementById(table)
              var ctx = {worksheet: name || 'Worksheet', table: table.innerHTML}
              window.location.href = uri + base64(format(template, ctx))
            }
          })()
        </script>
        <script type="text/javascript">
            function printPDF() {
                var printDoc = new jsPDF();
                printDoc.fromHTML($('#tblGrp').get(0), 10, 10, {'width': 180});
                printDoc.autoPrint();
                printDoc.output("dataurlnewwindow"); // this opens a new popup,  after this the PDF opens the print window view but there are browser inconsistencies with how this is handled
            }
        </script>
        <script>
            function open_win(url_add)
            {
            window.open(url_add,'welcome','width=300,height=200,menubar=no,status=no,location=no,toolbar=no,scrollbars=no');
            }
            function myNewWindow(url_add) {
                window.open(url_add, "newWindow", "height=200,width=200,status=yes,menubar=no,status=no,location=no,toolbar=no,scrollbars=no")
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
                <%if(usuario.equals("uparrales")){%>
                   <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                <%}else if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){%>
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
        <a href="INV_ListadoEquipo.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
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
                        <th class="text-center" style="font-size: 16px">Filtrar</th>
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
                        <a type="button" class="btn btn-default " href="INV_ListadoEquipo.jsp">
                            <i class="material-icons" style="color:#000 ;font-size:30px;">business</i></a>                        
                    </td>
                    <td align="center">
                        <a type="button" class="btn btn-default " onclick="tableToExcel('tblGrp', 'Inventario')">
                            <i class="material-icons" style="color:#000;font-size:30px">description</i>     
                        </a>
                        <a type="button" class="btn btn-default" onclick="javascript:printPDF();" >
                           <i class="material-icons" style="color:#000;font-size:30px">picture_as_pdf</i>    
                        </a>
                    </td>
                </tr> 
                </tbody>
            </table>
        </div>
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center"  >
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
        <th class="text-center">Historico</th>                
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select a.idinvequipo, a.fechacompra, a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where a.estado_ai ='A' ORDER BY a.estado, c.nombre, c.apellidos";                
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
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
        <td><img id="myImg" src="image/promanet/inventario/<%=rs.getString(18)%>" alt="pc" width="50" height="50"></td>
        <%if(rs.getString(13).equals("A")){%>
            <td type="text"title="Asignado." style="background-color: yellow"> Asignado</td>
            <td></td>
        <%}%>
        <%if(rs.getString(13).equals("D")){%>
            <td type="text"title="Disponible." style="background-color: #99ff66">  Disponible</td>
            <td></td>
        <%}%>
        <%if(rs.getString(13).equals("F")){%>
            <td type="text"title="Fuera de Servicio." style="background-color: #ff9999">  Fuera de Servicio</td>
            <td>
                <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
                   <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
                </a>    
            </td> 
        <%}%>
        <%if(rs.getString(13).equals("V")){%>
            <td type="text"title="Vendido." style="background-color: #a6e1ec">Vendido</td>
            <td>
                <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
                   <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
                </a>    
            </td> 
        <%}%>
        <%if(rs.getString(13).equals("R")){%>
            <td type="text"title="Robado." style="background-color: #ccc">Robado</td>
            <td>
                <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
                   <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
                </a>    
            </td> 
        <%}%>
         <%if(rs.getString(13).equals("M")){%>
            <td type="text"title="Mantenimiento." style="background-color: #00ffff">Mantenimiento</td>
            <td>
                <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
                   <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
                </a>    
            </td> 
        <%}%>
        <%if(rs.getString(13).equals("I")){%>
            <td type="text"title="Infraestructura." style="background-color: #ffdddd">Infraestructura</td>
            <td>
                <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
                   <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
                </a>    
            </td> 
        <%}%>
      
<!--            <a href="INV_EquipoEditar.jsp?idInvEquipo=<%=rs.getString(1)%>" class="btn btn-info ">
               <i class="material-icons " style="color:white;font-size:25px">mode_edit</i>
            </a>    
        </td>                        -->
        <td><a  class="btn btn-primary " href="INV_InventarioEquipo.jsp?id=<%=rs.getString(1)%>"><i class="material-icons " style="color:white;font-size: 21px" >people</i></a></td>                         
     
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
    <div class="table-responsive">
        <table class="table table-striped table-hover table-bordered text-center" id="tblGrp" style=" display: none">
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
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select a.idinvequipo, a.fechacompra, a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where a.estado_ai ='A' ORDER BY a.estado, c.nombre, c.apellidos";                
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {%>
    <tbody align="center" id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
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
        <td><img id="myImg" src="image/promanet/inventario/<%=rs.getString(18)%>" alt="pc" width="50" height="50"></td>
        <%if(rs.getString(13).equals("A")){%>
            <td type="text"title="Asignado." style="background-color: yellow"> Asignado</td>
        <%}%>
        <%if(rs.getString(13).equals("D")){%>
            <td type="text"title="Disponible." style="background-color: #99ff66">  Disponible</td>
        <%}%>
        <%if(rs.getString(13).equals("F")){%>
            <td type="text"title="Fuera de Servicio." style="background-color: #ff9999">  Fuera de Servicio</td>
        <%}%>
        <%if(rs.getString(13).equals("V")){%>
            <td type="text"title="Vendido." style="background-color: #a6e1ec">Vendido</td>
        <%}%>
        <%if(rs.getString(13).equals("R")){%>
            <td type="text"title="Robado." style="background-color: #ccc">Robado</td> 
        <%}%>
         <%if(rs.getString(13).equals("M")){%>
            <td type="text"title="Mantenimiento." style="background-color: #00ffff">Mantenimiento</td>           
        <%}%>
        <%if(rs.getString(13).equals("I")){%>
            <td type="text"title="Infraestructura." style="background-color: #ffdddd">Infraestructura</td>          
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
    
    <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Agregar Nuevo Equipo</h4>
    </div>
        <form  action="INV_InsertarEquipo.jsp" enctype="multipart/form-data"  method="POST" >
        <div class="modal-body">
            <div class="container-fluid">
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Fecha de Compra:</label>
                <input type="date" name="fecha" id="fecha" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Empresa</label>                
                <select class="form-control" id="empresa" name ="empresa" style="width:100%">                                                                                       
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
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Ubicacion/ Oficina:</label>                
                <select class="form-control" id="ubicacion" name ="ubicacion" style="width:100%">                                                                                       
                    <option value="Norte">Norte</option>                      
                    <option value="Kennedy">Kennedy</option>                      
                    <option value="Trino">Trino</option>                      
                </select>
            </div>
            </div>
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Departamento:</label>                
                <select class="form-control" id="departamento" name ="departamento" style="width:100%">                                                                                       
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
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="" >Tipo de Dispositivo:</label>                
                <select class="form-control" id="dispositivo" name ="dispositivo" style="width:100%">                                                                                       
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
                <label for="" class="form-control-label">Marca:</label>
                <input type="text" name="marca" id="marca" class="form-control" required />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="">Modelo:</label>
                <input type="text" name="modelo" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Serial:</label>
               <input type="text" name="serial" class="form-control"  />
            </div>  
            </div>
            </div>                                             
            <div class="row">
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Procesador:</label>
               <input type="text" name="procesador" id="procesador" class="form-control" required />
            </div>  
            </div>
            <div class="col-lg-6">
            <div class="form-group">
                <label for="" class="form-control-label">Disco Duro:</label>
                <input type="text" name="hdd" id="hdd" class="form-control" required />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Memoria RAM:</label>
               <input type="text" name="ram" id="ram" class="form-control" required />
            </div>  
            </div>
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Pantalla:</label>
               <input type="text" name="pantalla" id="pantalla" class="form-control" required />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Observaciones:</label>
               <input type="text" name="observaciones" id="observaciones" class="form-control" required />
            </div>  
            </div> 
            <div class="col-lg-6">
            <div class="form-group">
               <label for="" class="form-control-label">Imagen:</label>
               <input type="file" name="file" id="file" class="form-control" accept="image/x-png,image/gif,image/jpeg"  />
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
                <!--MODAL PARA VER EL USUARIO ASIGNADO-->
<div class="modal fade" id="myModalAsig" role="dialog">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">HISTORICO DE ASIGNACIONES</h4>
              </div>
                <form  action="#.jsp"  method="POST" >
              <div class="modal-body">
                  <table id="detalles" class="table table-striped table-hover   " >
      <thead>
        <tr>
          <th class="text-center">Id</th>
          <th class="text-center">Fecha Inicio</th>
          <th class="text-center">Fecha Fin</th>
          <th class="text-center">Nombre Usuario</th>
          <th class="text-center">Estado</th>
        </tr> 
      </thead>
    <% try{
      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
      Connection cn2 = DriverManager.getConnection(url, user, pass);
      String sql2 = "SELECT A.IDINV_ASIGNACION, a.fechaasignacion, a.fechadevolucion, a.idusuario, b.NOMBRE||' '||b.APELLIDOS, a.estado "
              + " FROM INV_ASIGNACION A inner join USUARIO B on a.idusuario= b.idusuario where a.idinvequipo = "+idEqui;
      PreparedStatement st2 = cn2.prepareStatement(sql2);
      ResultSet rs2 = st2.executeQuery();       
  while (rs2.next()) {%>
      <tbody align="center" >
      <tr>
        <td type="text" ><%= rs2.getString(1)%></td> 
        <td type="text" ><%= rs2.getString(2)%></td>
        <td type="text" ><%= rs2.getString(3)%></td>
        <td type="text" ><%= rs2.getString(5)%></td>
        <%if(rs2.getString(6).equals("A")){%>
            <td type="text"title="Asignado." style="background-color: #99ff66"> Asignado</td>
        <%}%>
        <%if(rs2.getString(6).equals("I")){%>
            <td type="text"title="Inactivo." style="background-color: #ff9999">  Inactivo</td>
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
<!--      <button type="submit"  class="btn btn-primary">Guardar</button>-->
   </div>
   </form>
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
</html>