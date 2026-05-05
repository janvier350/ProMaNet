<%-- 
    Document   : Crear Clientes
    Created on : 16-feb-2017, 16:57:01
    Author     : JVaras
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date"%>
<%  String compania = (String) session.getAttribute("compania");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Clientes</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/portalv2.css">
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
        
        <script>
            var tableToExcel = (function() {
            var uri = 'data:application/vnd.ms-excel;base64,'
            ,template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">\n\
                        <head>\n\
                            <!--[if gte mso 9]>\n\
                            <xml>\n\
                                <x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>\n\
                            </xml><![endif]-->\n\
                        </head>\n\
                        <body>\n\
                            <table>{table}\n\
                            </table>\n\
                        </body></html>'
            , base64 = function(s) { return window.btoa(unescape(encodeURIComponent(s))) }
            , format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
            return function(table, name) {
            if (!table.nodeType) table = document.getElementById(table)
                var ctx = {worksheet: name || 'Worksheet', table: table.innerHTML}
                window.location.href = uri + base64(format(template, ctx))
            }})()
        </script>
    </head>
    <body>
    <header>
        <div class="container-fluid">
        <div class="row">
        <div class="logo"><img   src="image/banner2020.png" class="img-responsive"></div>
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
    <div class="collapse navbar-collapse " id="navbar-1" >
        <ul class="nav navbar-nav " >
        <li><a href="Contactos.jsp">CONTACTOS</a></li>
          <li><a href="Agenda.jsp">AGENDA</a></li>
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
            <a tabindex="-1" href="#">Asignacion</a>
            <ul class="dropdown-menu">
               <!--  <li><a href="#">Asignacion Reporte de Gastos</a></li> -->
            </ul>
        </li>
    </ul>
    </li>
        <li class="dropdown active"><a id="dLabel" role="button" data-toggle="dropdown" href="#">PANEL DE CONTROL<span class="caret"></span></a>
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
        <thead >
            <tr><th class="text-center" style="font-size: 16px">Opciones</th></tr>
        </thead>
        <tbody>
            <tr>
            <td align="center" >
                <button type="button" class="btn btn-default " href="#" data-toggle="modal" data-target="#myModal">
                    <i class="material-icons"  style="font-size:30px;">person_add</i>
                </button> 
                <a type="button" class="btn btn-default" onclick="tableToExcel('detalles', 'W3C Example Table')" >
                    <i class="material-icons" style="font-size:30px">print</i>     
                </a>
            </td>
            </tr> 
        </tbody>
    </table>
    </div>  
    <div class="form-group">
    <div class="table-responsive">
        <table id="detalles" class="table table-striped table-hover table-bordered  " >
        <thead>
          <tr class="success">
            <th class="text-center ">Cliente</th>
            <th class="text-center  ">RUC</th>
            <th class="text-center  ">Direccion</th>
            <th class="text-center  ">Contacto</th>
            <th class="text-center  ">Telefono</th>
            <th class="text-center  ">Modificar</th>
            <th class="text-center  ">Eliminar</th>
        </tr> 
        </thead>
      <%
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select cliente, ruc, direccion,contacto,telefono,estado,idcliente from cliente where estado = 'a' order by cliente";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
        while (rs.next()) {%>
    <tbody align="center">
    <tr>
        <td type="text"><%= rs.getString(1)%></td>
        <td type="text"><%= rs.getString(2)%></td>
        <td type="text"><%= rs.getString(3)%></td>
        <td type="text"><%= rs.getString(4)%></td>
        <td type="text"><%= rs.getString(5)%></td>
        <td><a class="btn btn-info btn-sm" href="ADM_ClienteEditar.jsp?idCliente=<%= rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:15px">mode_edit</i></a></td> 
        <td><a class="btn btn-danger btn-sm" href="ADM_Eliminar_Cliente.jsp?idCliente=<%= rs.getString(7)%>"><i class="material-icons " style="color:white;font-size:15px">delete_forever</i></a></td>
    </tr>
    <%}%>
    </tbody>
    </table> 
<%          rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>  
    </div>
    </div>
    <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-lg">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Cliente Nuevo</h4>
    </div>
        <form  action="ADM_Insert_Client.jsp"  method="POST" >
        <div class="modal-body">
            <div class="container-fluid">
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="Cliente" >Cliente</label>
                <input type="text" name="Cliente" id="Cliente" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for="Ruc" >CI/RUC</label>
                <input type="text" name="ciruc" id="ciruc" class="form-control" required />
            </div>
            </div>
            </div>
            <div class="row">
            <div class="col-lg-6 ">
            <div class="form-group">
                <label class=" control-label" for=" Telefono" >Teléfono</label>
                <input type="text" name="telefono" id="telefono" class="form-control" required />
            </div>
            </div>
            <div class="col-lg-6">
            <div class="form-group">
                <label for="Contacto" class="form-control-label">Contacto</label>
                <input type="text" name="contacto" id="contacto" class="form-control" required />
            </div>  
            </div>
            </div>
            <div class="row">
            <div class="col-lg-12 ">
            <div class="form-group">
                <label class=" control-label" for="Correo">Email</label>
                <input type="text" name="Correo" class="form-control" required />
            </div>
            </div>
            </div>                                             
            <div class="row">
            <div class="col-lg-12">
                <div class="form-group">
                    <label for="Direccion" class="form-control-label">Direccion</label>
                    <textarea class="form-control" id="Direccion" name="Direccion"></textarea>
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
</html>