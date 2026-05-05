<%-- 
    Document   : Editar Equipo
    Created on : 28-Febrero-2019, 12:12:01
    Author     : Jquinde
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>


<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String idInvEquipo = request.getParameter("idInvEquipo");    
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
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Editar Equipo</title> 
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css" > 
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        
    </head>
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
        <div class="navbar-header">
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
    <div class="container-fluid"  >
    <div class="container-fluid panel panel-default" style="padding-top:2em;">
<!--      <form class="form-horizontal" method = "post" role="form" action="INV_EditarEquipo.jsp?idInvEquipo=<%= idInvEquipo%>" enctype="multipart/form-data">-->
         <form class="form-horizontal" method = "post" role="form" action="INV_EditarEquipo?idInvEquipo=<%= idInvEquipo%>" enctype="multipart/form-data">
        <div class="form-group text-center">                              
           <button type="submit"  class="btn btn-success" ><span class="glyphicon glyphicon-save-file"  ></span> <b>Guardar</b></button>
           <a href="INV_ListadoEquipo.jsp" class="btn btn-info"><i class="glyphicon glyphicon-backward" aria-hidden="true"></i> Ver Lista de Equipo</a>                               
        </div>
         <% String sql ="";            
             try{
               DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
               Connection cn = DriverManager.getConnection(url, user, pass);               
                   sql = "select a.idinvequipo, to_char(a.fechacompra, 'yyyy-MM-dd'), a.ubicacionoficina, a.departamento, a.marca, a.modelo, a.serial, a.procesador, a.hdd, a.ram, a.pantalla, a.observaciones, a.estado, b.idusuario, c.nombre||' '||c.APELLIDOS, a.empresa,a.dispositivo,a.fichero "
                + " from inv_equipos a left join inv_asignacion b on b.idinvequipo = a.idinvequipo AND b.estado='A' left join usuario c on b.idusuario = c.idusuario where a.idinvequipo= "+idInvEquipo+ " and a.estado_ai ='A' "; ;            
               PreparedStatement st = cn.prepareStatement(sql);
               ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                %>
               <div class="form-group">
                  <label class="col-lg-1  control-label">Fecha de Compra:</label>
                  <div class="col-lg-2">
                    <input value="<%= rs.getString(2)%>" type="date"  name="fecha" class="form-control"  />
                  </div> 
                  <label  class="col-lg-1 control-label">Empresa</label>
                  <div class="col-lg-2">
                    <select class="form-control" id="empresa" name ="empresa" style="width:100%">   
                        <option value="<%=rs.getString(16)%>"><%=rs.getString(16)%></option>  
                        <option value="Buadnet S.A">Buadnet S.A</option>                      
                        <option value="Xp Audit Solutions">Xp Audit Solutions</option>                      
                        <option value="Latin Consulting">Latin Consulting</option>                      
                        <option value="Dk Work">Dk Work</option>  
                        <option value="Arthurs Audit Global">Arthurs Audit Global</option>   
                        <option value="N/A">N/A</option> 
                    </select>
                  </div>      
                  <label class="col-lg-1 control-label">Ubicacion/ Oficina:</label>
                  <div class="col-lg-2">
                    <select class="form-control" id="ubicacion" name ="ubicacion" style="width:100%">                                                                                       
                        <option value="<%=rs.getString(3)%>"><%=rs.getString(3)%></option>  
                        <option value="Norte">Norte</option>                      
                        <option value="Kennedy">Kennedy</option>                      
                        <option value="Outsourcing">Outsourcing</option> 
                        <option value="Magisterio">Magisterio</option> 
                        <option value="Romeria">Romeria</option> 
                    </select>
                  </div>   
                    <label  for="id" class="col-lg-1 control-label">Departamento:</label>
                  <div class="col-lg-2">
                    <select class="form-control" id="departamento" name ="departamento" style="width:100%">   
                        <option value="<%=rs.getString(4)%>"><%=rs.getString(4)%></option>  
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
               <div class="form-group">
                    <label  for="email" class="col-lg-1 control-label">Tipo de Dispositivo:</label>
                    <div class="col-lg-2">
                    <select class="form-control" id="dispositivo" name ="dispositivo" style="width:100%">   
                        <option value="<%=rs.getString(17)%>"><%=rs.getString(17)%></option>  
                        <option value="Laptop">Laptop</option>                      
                        <option value="Impresora">Impresora</option>                      
                        <option value="Proyector">Proyector</option>                      
                        <option value="Networking">Networking</option>  
                        <option value="CCTV">CCTV</option>   
                        <option value="Perifericos">Perifericos</option>   
                    </select>
                    </div>
                    <label class="col-lg-1 control-label">Marca:</label>
                    <div class="col-lg-2">
                        <input value="<%=rs.getString(5)%>" type="text"  name="marca" class="form-control" />
                    </div>
                    <label class="col-lg-1 control-label">Modelo:</label>
                    <div class="col-sm-2">
                        <input value="<%=rs.getString(6)%>" type="text"  name="modelo" class="form-control" />                      
                    </div>                
                    <label class="col-lg-1 control-label">Serial:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(7)%>" type="text"  name="serial" class="form-control"/>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-1 control-label">Procesador:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(8)%>" type="text"  name="procesador" class="form-control" />
                    </div>    
                    <label class="col-lg-1 control-label">Disco Duro:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(9)%>" type="text"  name="hdd" class="form-control" />
                    </div>
                    <label class="col-lg-1 control-label">Memoria RAM:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(10)%>" type="text"  name="ram" class="form-control" />
                    </div>
                    <label class="col-lg-1 control-label">Pantalla:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(11)%>" type="text"  name="pantalla" class="form-control" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-1 control-label">Estado:</label>
                    <div class="col-lg-2">
                        <select class="form-control" id="estado" name ="estado" style="width:100%"> 
                            <%if(rs.getString(13).equals("A")){%>
                                <option value="A" style="background-color: yellow">Asignado</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("D")){%>
                                <option value="D" style="background-color: #99ff66">Disponible</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("M")){%>
                                <option value="F" style="background-color: #ff9999">Mantenimiento</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("F")){%>
                                <option value="F" style="background-color: #ff9999">Fuera de Servicio</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("V")){%>
                                <option value="V" style="background-color: #ff9999">Vendido</option>                                 
                            <%}%>
                            <%if(rs.getString(13).equals("R")){%>
                                <option value="R" style="background-color: #ff9999">Robado</option>                                 
                            <%}%>  
                            <%if(rs.getString(13).equals("I")){%>
                                <option value="I" style="background-color: #ff9999">Infraestructura</option> 
                            <%}%>
                            <option value="D">Disponible</option>                      
                            <option value="M">Mantenimiento</option> 
                            <option value="F">Fuera de Servicio</option>                      
                            <option value="V">Vendido</option>  
                            <option value="R">Robado</option>                               
                            <option value="A">Asignado</option>                             
                            <option value="I">Infraestructura</option> 
                        </select>
                    </div>
                    <label class="col-lg-1 control-label">Asignado A:</label>
                    <div class="col-lg-2">
                        <input value="<%= rs.getString(15)%>" type="text"  name="asignado" class="form-control" readonly="true" />
                        <input value="<%= rs.getString(14)%>" type="text"  name="idusuario" class="form-control" readonly="true" style="visibility: hidden"/>
                    </div>        
                    <label class="col-lg-1 control-label">Observaciones:</label>
                    <div class="col-lg-4">
                        <input value="<%= rs.getString(12)%>" type="text"  name="observaciones" class="form-control" />
                    </div>
                    
                </div> 
                <div class="form-group">                                        
                    <label class="col-lg-1 control-label">Imagen:</label>
                    <div class="col-lg-2">
                        <img id="myImg" src="image/promanet/inventario/<%=rs.getString(18)%>" alt="pc" >
                    </div>        
                    <label class="col-lg-1 control-label">Cambiar Imagen:</label>
                    <div class="col-lg-4">
                        <input type="file" name="file" id="file" class="form-control" accept="image/x-png,image/gif,image/jpeg"  />
                    </div>                    
                </div> 
         <%} rs.close();
            st.close();
            cn.close();
         }catch(Exception e){
            e.printStackTrace();
         }%>  
      </form>
   </div>
   </div>      
   </div>
   </div>
      <script>
            $('#show_password').on('change',function(event){
            // Si el checkbox esta "checkeado"
            if($('#show_password').is(':checked')){
               // Convertimos el input de contraseña a texto.
               $('#password').get(0).type='text';
            // En caso contrario..
            } else {
               // Lo convertimos a contraseña.
               $('#password').get(0).type='password';
            }
         });
        </script>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
    </body>
</html>
