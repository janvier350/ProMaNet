<%-- 
    Document   : Listado de jefes
    Created on : 21-mar-2018, 15:17:01
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"
        import ="java.sql.Connection"
        import ="java.sql.DriverManager"
        import ="java.sql.ResultSet"
        import ="java.sql.Statement"
        import ="java.sql.SQLException"
        import="java.sql.*"
        import=" java.util.Date"
%>
<%  String codigo = (String) session.getAttribute("cod");
    String compania = (String) session.getAttribute("compania");
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
        <meta http-equiv="Content-Type" content="text/html" charset="UTF-8">
        <title>ProMaNet|Listado de Jefes</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="Content/bootstrap/carousel/carousel.css" rel="stylesheet" type="text/css"/> 
        <link href="Content/Style.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>
        <script src="Content/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    </head>
<body>
    <header>
        <div class="container-fluid">
        <div class='row'>
        <div class="logo ">
            <img src="image/banner2020.png" class="img-responsive" > 
        </div>
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
            <div class="collapse navbar-collapse " id="navbar-1" >
                <ul class="nav navbar-nav">
                    <li><a href="Contactos.jsp" >CONTACTOS  
                             <!--<b><kbd style="background-color: orangered;color:white" >¡New!</kbd></b>-->
                        </a></li>
                    <%if(usuario.equals("uparrales")){%>
                       <li><a href="TODO_CabTrabXP.jsp">TO-DO</a></li> 
                    <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                       <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                    <%}%>
                    <li class="active"><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                    <li><a href="Mantenimiento.jsp">AVANCE</a></li>
                    <li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
                            PANEL DE CONTROL<span class="caret"></span> 
                            <!--<b><kbd style="background-color: orangered;color:white" >¡New!</kbd></b>-->
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
    <table class=" text-center" >
    <tr>
    <td style=""><b>Añadir Nuevo Mes</b></td>
    <%if(session.getAttribute("usuario")==null){
        response.sendRedirect("sesionExpirada.jsp");
        return;
    }else if (session.isNew()){
        response.sendRedirect("sesionExpirada.jsp");
        return;} 
    if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
    %> <td style=""><b>Ver Personal Asignado</b></td>
    <%  }else{
             }%>
    </tr>
    <tr>
    <th style="text-align:center"><a href="InsertarRepGas.jsp" class="btn btn-success" title="Añadir" style="width: 75px; border-radius: 5px;">
        <i class="fa fa-user-plus" style="font-size:20px"></i></a></th>
        <%if(session.getAttribute("usuario")==null){
            response.sendRedirect("sesionExpirada.jsp");
            return;
            }else if (session.isNew()){
            response.sendRedirect("sesionExpirada.jsp");
            return;
            } if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
        %>
        <th style="text-align:center"> <a href="ReporteGastos.jsp" title="Ver personal Asignado" class="btn btn-danger" style="width: 90%; border-radius: 5px;">
        <i class="fa fa-user" style="font-size:20px"></i></a> </th> 
        <%}else{
        }%>
    </tr>
    </table>
</div>
<br>                    
<div class="container">
<table  class="collaptable table table-striped  table-bordered "  >
    <thead>
    <tr>
        <th class="text-center">Id</th>
        <th class="text-center" >Mes</th>
        <th class="text-center">Fecha</th>
        <th class="text-center">Total</th>
        <th class="text-center" >Ver</th>
        <th class="text-center" >Imprimir</th>
    </tr> 
    </thead>
    <tbody>
    <tr data-id="2017" data-parent="">
        <td style= "font-weight:bold"></td><td>Año</td>
        <td style= "font-weight:bold">2017</td><td></td><td></td><td></td>
    </tr>     
    <tr data-id="2018" data-parent="">
        <td style= "font-weight:bold"></td><td>Año</td>
        <td style= "font-weight:bold">2018</td><td></td><td></td><td></td>
    </tr> 
    <%
    String M = "";
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select substr(A.FECHA,6,2) mes,a.IDREPGASCAB, a.FECHA,TO_CHAR(a.TOTAL, 'FM999G990D00')as total, "
                + "b.IDUSUARIO, b.USUARIO,substr(A.FECHA,1,4) ano "
                + "from repgascab a,usuario b "
                + "where a.idusuario = b.idusuario and a.idusuario ="+ codigo +"order by 7,1";
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
    %>
    <tr data-id="<%=rs.getString(2)%>" data-parent="<%=rs.getString(7)%>">
        <td><%=rs.getString(1)%></td>
        <td><%=M%></b></td>
        <td><%=rs.getString(3)%> </td>  
        <td><%="$"+rs.getString(4)%> </td>
        <td>
            <a href="ReporteDetalleModal.jsp?id=<%=rs.getString(2)%>&mes=<%=rs.getString(1)%>&flag=2" class="btn btn-primary ">
            <i class="material-icons " style="color:white;font-size:25px">visibility</i>
            </a>    
        </td> 
        <td>
            <a href="GenerarRepGasPDF.jsp?id=<%=rs.getString(2)%>&mes=<%=M%>&tot=<%=rs.getString(4)%>" target="_blank" class="btn btn-warning" >
            <i class="material-icons " style="color:white;font-size:25px">print</i>
            </a>
        </td>
    </tr>
    <% }     
        rs.close();
        st.close();
        cn.close();
    }catch(Exception e){
        e.printStackTrace();}%>    
    </tbody>        
</table>  
</div>  
<script src="js/jquery.aCollapTable.js"></script>                        
<script>
$(document).ready(function(){
  $('.collaptable').aCollapTable({ 
    startCollapsed: true,
    addColumn: false, 
    plusButton: '<span class="i">+</span>', 
    minusButton: '<span class="i">-</span>' 
  });
});
</script>
    </body>
</html>
