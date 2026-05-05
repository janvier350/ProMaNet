<%-- 
    Document   : ReporteDetalle
    Created on : 21-Mar-2017, 11:58:49
    Author     : Jquinde
--%>

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
    String mesCab = request.getParameter("mesCab");
    String idDetalle = request.getParameter("idDet");
    String idCab = request.getParameter("idCab");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet| Modificar Reporte de Gasto</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link rel="stylesheet" href="css/chosen.css">
        <link rel="stylesheet"  type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" >
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/dataTables.bootstrap.min.css" >        
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>       
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css" >
        <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/responsive/2.1.1/css/responsive.dataTables.min.css" >            
        <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.js"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/dataTables.bootstrap.min.js"></script>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.1.1/js/dataTables.responsive.min.js"></script>
        
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
                mensaje.innerHTML = '<span class="mensaje-error">Has excedido el límite de 1000 caracteres por ' + (longitudTexto - maxCaracteres) + ' caracteres.</span>';
            } else {
                mensaje.innerHTML = 'Te faltan ' + (maxCaracteres - longitudTexto) + ' caracteres para alcanzar el límite de 1000.';
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
                  <img   src="image/banner2020.png" class="img-responsive" > 
            </div>
            </div>
            </div>
        </header>
                  <div class="container-fluid">
                      <div class="row">
                        <nav class="navbar navbar-default"  id="nav2">
                    <div class="navbar-header">
                         <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-1" >
                             <span class="sr-only" >Menu</span>
                             <span class="icon-bar"></span>
                             <span class="icon-bar"></span>
                             <span class="icon-bar"></span>
                         </button>
                         <a href="Home.jsp" class="navbar-brand " >HOME</a>    
                    </div>
                    <div class="collapse navbar-collapse " id="navbar-1">
                         <ul class="nav navbar-nav " >
                             <li><a href="Contactos.jsp">CONTACTOS</a></li>
                             <%if(usuario.equals("uparrales")){%>
                                <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                             <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                                <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                             <%}%>
                             <li class="active"><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
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
        <%                      
        String fec ="";     
        String ali ="";
        String tra ="";
        String ob ="";
        String idcliente="";
        String client="";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select A.IDREPGASDET,A.FECHA,A.TOTALIM,A.TOTMOVI,A.TRABREALIZADO, B.CLIENTE, B.IDCLIENTE "
                    + " from  REPGASDET A, CLIENTE B  WHERE IDREPGASDET =" +idDetalle + "AND A.IDCLIENTE = B.IDCLIENTE ";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 fec = rs.getString(2);
                 ali = rs.getString(3);
                 tra = rs.getString(4);
                 ob = rs.getString(5);
                 client = rs.getString(6);
                 idcliente = rs.getString(7);
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>
          <div class="container"  >
                <div class="col-lg-offset-2 col-lg-8 col-sm-12" align="center" >
                    <div class="panel panel-info"  >
                        <div class="panel-heading ">
                           <h2><b>Modificar Reporte Diario</b></h2>
                        </div>
                        <div class="panel-body">
                            <form  action="ModificarRepGasDet.jsp?mesCab=<%=mesCab%>&idCab=<%=idCab%>&idDet=<%=idDetalle%>" method="post" >
                          
                             <div class="form-group" >
                                <label for="fecha">Fecha </label> 
                                <input type="date" name="fecha" value=<%=fec%>  class="form-control" placeholder="fecha" style="width:80%" required>
                            </div>
                            <div class="form-group">
                                <label for="ali">Alimentación</label>
                                <input type="number" step="any" min ="0" name="alimentacion" value=<%=ali%> class="form-control" placeholder="alimentacion" style="width:80%" required>
                            </div>                    
                             <div class="form-group">
                                <label for="trans">Transporte</label>
                                <input type="number" step="any" min ="0" name="transporte" value="<%=tra%>" class="form-control" placeholder="tranporte" style="width:80%" required>
                            </div>
                             
                            <div class="form-group">
                               <label for="obs">Cliente</label>
                            </div>
                            <div class="form-group">
                                <select class="chosen-select form-control" id="cliente" name ="cliente" style="width:80%">
                                    <option value="<%=idcliente%>"><%=client%></option>
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
                    <div class="form-group">
                                <label for="obs">Observación</label>
                                <input type="text" name="trabajo" id="Obva" value="<%=ob%>" class="form-control" placeholder="tranporte" style="width:80%" oninput ="contarLetras()" >
                                <span id="mensaje"></span>
                            </div>
                <div class="form-group">                              
                    <button type="submit"  class="btn btn-success" ><span class="glyphicon glyphicon-save-file"  ></span> <b>Guardar</b></button>
                    <a href="ReporteDetalleModal.jsp?id=<%=idCab%>&mes=<%=mesCab%>&flag=2" class="btn btn-info"><i class="glyphicon glyphicon-backward" aria-hidden="true"></i> Otra Consulta</a>                               
                </div>
            </form>  
           </div>
            </div>
            </div>      
            </div>
   <script src="js/chosen.jquery.js" type="text/javascript"></script>     
   <script src="js/init.js" type="text/javascript" ></script>
   <script src="js/jquery.js"></script>
    </body>
</html>
