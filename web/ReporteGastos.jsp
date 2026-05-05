<%-- 
    Document   : REPORTE DE GASTO
    Created on : 16-feb-2017, 16:57:01
    Author     : JQUINDE
--%>

<%@page 
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
    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String idHi = request.getParameter("id");
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
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">       
        <title>ProMaNet|Reporte Gastos</title>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link rel="stylesheet" href="css/chosen.css">                        
        <link href="css/github.min.css" rel="stylesheet" type="text/css"/>
        <link href="dist/bootstrap-clockpicker.min.css" rel="stylesheet" type="text/css"/>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>               
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script>
        function EscogeUsuario(){
            var texto
            texto = "El numero de opciones del select:" + document.formul.miSelect.length
            var indice = document.formul.miSelect.selectedIndex
            texto += "\nIndice de la opcion escogida:" + indice
            var valor = document.formul.miSelect.options[indice].value
            texto += "\nValor de la opcion escogida:" + valor
            var textoEscogido = document.formul.miSelect.options[indice].text
            texto += "\nTexto de la opcion escogida:" + textoEscogido
//            var elem = valor.split('-');
//            var idHijo = elem[0];
            location.href = 'ReporteGastos.jsp?id='+valor
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
                <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                   <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                <%}%>
                <li class="active"><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
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
        <table class=" " >
        <tr>
            <th style="text-align:center" >Buscar </th>
            <th style="text-align:center" > </th>
        <tr>
            <td align="center" >
            <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
            </td> 
            <td align="center" >
                <a href="ReporteGastosIndividual.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
                <i class="material-icons" style="font-size:20px">arrow_back</i></a> 
                <p style="color:green"><b>Regresar</b></p>
            </td> 
        </tr>
        </table>
        
       
    </div>    
                                
    
    <div class="form-group" >
    <form name="formul">     
       <div class="form-group text-center">
        <select class="chosen-select form-control" name="miSelect"  onChange='EscogeUsuario()' style="width:80%">
        <option>Seleccione el Usuario:</option>
        <%try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select a.IDUSUARIO, a.NOMBRE,a.APELLIDOS, b.IDUSUARIOASIG from usuario a,repgasasig b where b.idusuario = a.idusuario and b.idusuarioasig =" +codigo + " and a.ESTADO = 'a' order by 3 ";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
        while (rs.next()) {%>
            <option value="<%=rs.getString(1)%>"><%=rs.getString(3)+" "+rs.getString(2)%></option>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}%>
        </select>
       </div>
    </form>
    
<br>
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
    <tr>
        <th class="text-center">Id</th>                  
        <th class="text-center">Usuario</th>  
        <th class="text-center">Mes</th>
        <th class="text-center">Fecha</th>
        <th class="text-center">Total</th>
        <th class="text-center">Ver</th>
        <th class="text-center">Imprimir</th>
        <th class="text-center">Aprobar</th>
        <th class="text-center">Desaprobar</th>
    </tr>
    <%  String M="";
        String aprob= "";
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select substr(A.FECHA,6,2) mes,a.IDREPGASCAB, a.FECHA,TO_CHAR(a.TOTAL, 'FM999G990D00')as tot, b.IDUSUARIO, "
                + "b.USUARIO, a.APROBADO,substr(A.FECHA,1,4) ano from repgascab a,usuario b where a.idusuario = b.idusuario and a.idusuario ="+ idHi +"order by 8 desc,1";
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {
        if(rs.getString(1).equals("01"))
        M = "Enero";
        if(rs.getString(1).equals("02"))
        M = "Febrero";
        String elMes = rs.getString(1);
        if(rs.getString(1).equals("03"))
        M = "Marzo";
         if(rs.getString(1).equals("04"))
        M = "Abril";
        if(rs.getString(1).equals("05"))
        M = "Mayo";
        if(rs.getString(1).equals("06"))
        M = "Junio";
        if(rs.getString(1).equals("07"))
        M = "Julio";
        if(rs.getString(1).equals("08"))
        M = "Agosto";
        if(rs.getString(1).equals("09"))
        M = "Septiembre";
        if(rs.getString(1).equals("10"))
        M = "Octubre";
        if(rs.getString(1).equals("11"))
        M = "noviembre";
        if(rs.getString(1).equals("12"))
        M = "Diciembre";
        if (rs.getString(7).equals("S"))
            aprob = "disable";
        else
            aprob = "enable";
    %>
    <tbody id="myTable">
    <tr>
        <td ><%=rs.getString(1)%></td>
        <td ><%=rs.getString(6)%></td>
        <td><%=M+" "+rs.getString(8)%></td>
        <td><%=rs.getString(3)%></td>  
        <td><%=rs.getString(4)%></td>
        <%
        if(cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
        %>
        <td align="center">
           <a href="ReporteDetalleModal.jsp?id=<%=rs.getString(2)%>&mes=<%=rs.getString(1)%>&flag=1&idHijo=<%=idHi%>"  class="btn btn-primary" >
           <i class="material-icons " style="color:white;font-size:25px">visibility</i> </a>
        </td> 
        <td align="center">
            <!--GenerarRepGasHijoPDF-->
            <a href="reporteGastoHijo?id=<%=rs.getString(2)%>&mes=<%=M%>&tot=<%=rs.getString(4)%>&idHijo=<%=idHi%>"  target="_blank" class="btn btn-warning" >
            <i class="material-icons " style="color:white;font-size:21px">print</i></a> 
        </td>        
        <%if(rs.getString(7).equals("S")){%>
        <td align="center">
            <a  disabled class="btn btn-success" type="button" >
            <i class="material-icons " style="color:green;font-size:27px">check_circle</i></a> 
        </td>        
        <%}else if(rs.getString(7).equals("N")){%> 
        <td align="center">
            <a  type="button" href="AprobarRepGas.jsp?id=<%=rs.getString(2)%>&idHijo=<%=idHi%>" class="btn btn-default" >
            <i class="material-icons " style="color:green;font-size:27px">check_circle</i></a> 
        </td>    
        <%}%>        
        <td align="center">
            <a disabled class="btn btn-danger" >
            <i class="material-icons " style="color:white;font-size:27px">close</i></a> 
        </td> 
        <%}else if(cargo.equals("ADMINISTRACION")){
            if(rs.getString(7).equals("S")){%>
            <td align="center">
                <a href="ReporteDetalleModal.jsp?id=<%=rs.getString(2)%>&mes=<%=rs.getString(1)%>&flag=1&idHijo=<%=idHi%>" class="btn btn-primary" >
                <i class="material-icons " style="color:white;font-size:25px">visibility</i> </a>
            </td>
<!--            <td align="center">
                GenerarRepGasHijoPDF.jsp
                <a href="reporteGastoHijo.java?id=<%=rs.getString(2)%>&mes=<%=M%>&tot=<%=rs.getString(4)%>&idHijo=<%=idHi%>"  target="_blank" class="btn btn-warning" >
                <i class="material-icons " style="color:white;font-size:21px">print</i></a> 
            </td>   -->
            <td align="center">
                <a disabled class="btn btn-success" >
                <i class="material-icons " style="color:green;font-size:27px">check_circle</i></a> 
            </td>
            <td align="center">
                <a href="DesaprobarRepGas.jsp?id=<%=rs.getString(2)%>&idHijo=<%=idHi%>" class="btn btn-danger" >
                <i class="material-icons " style="color:white;font-size:27px">close</i></a> 
            </td> 
        <%}else if(rs.getString(7).equals("N")){%>
            <td align="center">
                <a disabled class="btn btn-primary" >
                <i class="material-icons " style="color:white;font-size:25px">visibility</i> </a>
            </td>
            <td align="center">
                <a target="_blank" disabled class="btn btn-warning" >
                <i class="material-icons " style="color:white;font-size:21px">print</i></a> 
            </td>
            <td align="center">
                <a disabled class="btn btn-success" >
                <i class="material-icons " style="color:green;font-size:27px">check_circle</i></a> 
            </td>
            <td align="center">
                <a disabled class="btn btn-danger" >
                <i class="material-icons " style="color:white;font-size:27px">close</i></a> 
            </td> 
        <%}}%>
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
