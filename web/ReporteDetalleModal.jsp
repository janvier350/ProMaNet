<%-- 
    Document   : ReporteDetalle
    Created on : 21-Mar-2017, 11:58:49
    Author     : Jquinde
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import ="java.sql.Connection"
        import ="java.sql.DriverManager"
        import ="java.sql.ResultSet"
        import ="java.sql.Statement"
        import ="java.sql.SQLException"
        import="java.sql.*"
        import ="java.util.Date"
        %>

<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
     String usuario = (String) session.getAttribute("usuario");
    String flag =request.getParameter("flag");
    String idCab =request.getParameter("id");
    String idHijo =request.getParameter("idHijo");
    String mes =request.getParameter("mes");
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
        if (!COMUN.PermisoHelper.tiene(session, "ACCESO_GENERAL")) {
         response.sendRedirect("sesionInvalida.jsp");
         return;
        }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet|Detalle Reporte de Gasto</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        
        <link rel="stylesheet"  type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" >
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/dataTables.bootstrap.min.css" >        
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css" >
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/responsive/2.1.1/css/responsive.dataTables.min.css" >            
        <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.js"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/dataTables.bootstrap.min.js"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.1.1/js/dataTables.responsive.min.js"></script>            
        <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="Content/bootstrap/carousel/carousel.css" rel="stylesheet" type="text/css"/> 
        <link href="Content/Style.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>        
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script type="text/javascript" class="init">
            $(document).ready(function() {
            $('#example').DataTable();
            } );
        </script>
        <!--contar letras--> 
         <style>
        .mensaje-error {
            color: red;
        }
    </style>
    <script>
        function contarLetras() {
            var inputTexto = document.getElementById('Obva').value;
            var longitudTexto = inputTexto.length;
            var maxCaracteres = 1000;

            var mensaje = document.getElementById('mensaje');
            mensaje.innerHTML = ''; // Limpiar el mensaje anterior

            if (longitudTexto > maxCaracteres) {
                mensaje.innerHTML = '<span class="mensaje-error">Has excedido el l�mite de 1000 caracteres por ' + (longitudTexto - maxCaracteres) + ' caracteres.</span>';
            } else {
                mensaje.innerHTML = 'Te faltan ' + (maxCaracteres - longitudTexto) + ' caracteres para alcanzar el l�mite de 1000.';
            }
        }
    </script>
    <!--fin contar letras-->
    </head>
    <body>
        <header>
            <div class="container-fluid">
            <div class="row">
            <div class="logo ">
                <img   src="image/banner2020.png" class="img-responsive"> 
            </div>
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
            <div  class="collapse navbar-collapse " id="navbar-1" >
                <ul class="nav navbar-nav" >
                    <li><a href="Contactos.jsp">CONTACTOS</a></li>
                    <%if(usuario.equals("uparrales")){%>
                       <li class="active"><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                    <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                       <li class="active"><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                    <%}%>
                    <li ><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
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
                     <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
                            PANEL DE CONTROL<span class="caret"></span>
                        </a>
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
        <div class="container" align="center">
        <%if(flag.equals("2")){%>
        
        <td style="text-align:center" colspan="5">
            <a href="generarReporteGastosMes" class="btn btn-warning" title="A�adir" style="width: 75px; border-radius: 5px;">
            <!--<i class="fa fa-calendar" style="font-size:20px"></i>-->
             <i class="material-icons" font-size:30px">date_range</i>
            </a>
        </td>
            <button type="submit" name="btnRegistro" class="btn btn-success" data-toggle="modal" data-target="#registrarModal" href="#" role="button" >
                <i class="fa fa-calendar" aria-hidden="true"></i> A�adir
            </button>
            <a href="ReporteGastosIndividual.jsp" class="btn btn-info"><i class="fa fa-backward" aria-hidden="true"></i> Otra Consulta</a>                
        <%}else{%>
            <button disabled="true" type="submit" name="btnRegistro" class="btn btn-success" >
                <i class="fa fa-calendar" aria-hidden="true"></i> A�adir
            </button>
            <a href="ReporteGastos.jsp?id=<%=idHijo%>" class="btn btn-info"><i class="fa fa-backward" aria-hidden="true"></i> Otra Consulta</a>                
        <%}%>
        </div><br> 
        <div class="container">
        <div class="form-group">
        <div class="table-responsive">
        <table id="example" class="table table-striped table-bordered" >
            <thead>
                <tr>
                    
                    <th>Fecha</th>
                    <th>Alimentaci�n</th>
                    <th>Transporte</th>
                    <th>Cliente</th>
                    <th>Observaci�n</th>
                    <th>Editar</th>
                    <th>Eliminar</th>
                </tr>
            </thead>
        <%  try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);
                String sql = "select b.IDREPGASDET, a.FECHA, TO_CHAR(b.TOTALIM,'FM999G990D00'), b.TRABREALIZADO, TO_CHAR(b.TOTMOVI,'FM999G990D00'),b.FECHA, c.CLIENTE  from repgascab a,repgasdet b, cliente c where a.idrepgascab = b.idrepgascab and a.idrepgascab=" + idCab +" and b.IDCLIENTE=c.IDCLIENTE order by b.FECHA";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();       
                while (rs.next()) {%>
            <tbody>    
            <tr>
                 
                <td> <%=rs.getString(6)%></td>  
                <td> <%="$"+rs.getString(3)%></td>
                <td> <%="$"+rs.getString(5)%></td>
                <td> <%=rs.getString(7)%></td>
                <td> <%=rs.getString(4)%></td>
                
        <%if(flag.equals("2")){%>
            <td align="center">
            <a href="ReporteDetalleModificar.jsp?idDet=<%=rs.getString(1)%>&mesCab=<%=mes%>&idCab=<%=idCab%>" class="btn btn-info" >
                <i class="material-icons" style="color:white;font-size:25px">mode_edit</i></a>
            </td>    
            <td align="center">    
            <a href="EliminarRepGasDet.jsp?id=<%=rs.getString(1)%>&mes=<%=mes%>&idCab=<%=idCab%>" class="btn btn-danger" >
                <i class="material-icons" style="color:white;font-size:25px">delete_forever</i></a>
            </td>    
        <%}else{%>
            <td align="center">
            <a disabled class="btn btn-info" >
               <i class="material-icons" style="color:white;font-size:25px">mode_edit</i></a>
            </td>   
            <td align="center">   
            <a disabled class="btn btn-danger" >
                <i class="material-icons" style="color:white;font-size:25px">delete_forever</i></a>
            </td>    
        <%}%>
             
            </tr>
        <%  }   rs.close();
                st.close();
                cn.close();
            }catch(Exception e){
                 e.printStackTrace();
            }
            Date td = new Date();
            String b = new String("");
            SimpleDateFormat format = new SimpleDateFormat("dd/MM/YYYY");
            b = format.format(td);
        %>
    <div class="modal fade" id="registrarModal">
     <section id="registrarModal" class="modal fade col middle in" tabindex="-1" style="display: block;">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button class="close" aria-hidden="true" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Reporte Diario</h4>
                </div>
                <div class="modal-body">
                <form class="form-horizontal" action="InsertarRepGasDet.jsp"  method="POST" align="center">
                        <div class="panel panel-default">                   
                            <div class="panel-heading">
                                <div style="text-align:center;" class="panel-title">
                                    Ingresar Datos de Reporte
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-12 control-label" for="fecha" >
                                Fecha
                            </label>
                            <div class="col-sm-12">
                                <input type="date" name="fecha" id="fecha" class="form-control" required />
                                <script>
                                document.getElementById('fecha').value = new Date().toISOString().substring(0, 10);
                                </script>
                            </div>     
                        </div>
                        <div class="form-group">
                            <label class="col-sm-12 control-label" for="Ali" >
                                Alimentaci�n
                            </label>
                            <div class="col-sm-12">
                                <input type="number" step="any" min ="0" name="alimentacion" id="Ali" value="3.50" class="form-control" required />
                            </div>                    
                        </div>
                        <div class="form-group">
                            <label class="col-sm-12 control-label" for="Trap" >
                                Transporte
                            </label>
                            <div class="col-sm-12">
                                <input type="number" step="any" min ="0" name="transporte" id="Trap" value="1.50" class="form-control" required />
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-12 control-label" for="Trap" >
                                Cliente
                            </label>
                            <div class="col-lg-12">
                              <select class=" form-control" id="cliente" name ="cliente">
                               <%
                                 try{
                                 DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                 Connection   cn = DriverManager.getConnection(url, user, pass);
                                 String sql = "select * from Cliente where estado = 'a' order by 1";
                                 PreparedStatement st = cn.prepareStatement(sql);
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
                        <div class="form-group">
                            <label class="col-sm-12 control-label" for="Obva">
                                Observaci�n
                            </label>
                            <div class="col-sm-12">
                                <input type="text" name="trabajo"  id="Obva"  value="Reporte de Gasto" class="form-control" oninput ="contarLetras()"/>
                                  <span id="mensaje"></span>
                            </div>    
                        </div>
                        <div class="row">   
                            <div class="form-group">
                                <div class="col-sm-12">
                                    <input  style="visibility:hidden" name="id" value=<%=idCab%> class="form-control" required />
                                </div> 
                            </div> 
                            <div class="form-group">
                                <div class="col-sm-12">
                                    <input  style="visibility:hidden" name="mesCab" value=<%=mes%> class="form-control" required />
                                </div>                    
                            </div>
                        </div> 
                        <div class="modal-footer">
                            <span class="btn btn-default" data-dismiss="modal">Cerrar</span>
                            <button type="submit"  class="btn btn-primary">Guardar</button>
                        </div>        
                </form>                                  
                    </div>
                    </div>
                    </div>
                    </section>
                    </div>
                    </tbody>
                    </table>  
                    </div>
                    </div>
                </div> 
   <script src="js/chosen.jquery.js" type="text/javascript"></script>     
   <script src="js/init.js" type="text/javascript" ></script>
   <script src="js/jquery.js"></script>
   <script src="js/bootstrap.min.js"></script>
    </body>
</html>
