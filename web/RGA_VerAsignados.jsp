<%-- 
    Document   : LISTADO DE HIJOS
    Created on : 28-mar-2017, 14:11:01
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
<%  
    String idJefe = request.getParameter("id");
    String Jefe = request.getParameter("user");
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
        if(cargo.equals("CONTRALOR")||cargo.equals("JEFE")||nombre.equals("Jonathan")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet | Lista de Asignados</title>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
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
        function Insertar(){
            var texto
            texto = "El numero de opciones del select:" + document.formul.idHijo.length
            var indice = document.formul.idHijo.selectedIndex
            texto += "\nIndice de la opcion escogida:" + indice
            var valor = document.formul.idHijo.options[indice].value
            texto += "\nValor de la opcion escogida:" + valor
            
            var elem = valor.split('-');
            var idHijo = elem[0];
            location.href = 'RGA_InsertarHijo.jsp?idHijo='+idHijo+'&idJefe=<%=idJefe%>&Jefe=<%=Jefe%>'
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
                <%}else if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")){%>
                   <li><a href="TODO_Cab_Trabajo.jsp">TO-DO</a></li> 
                <%}%>
                <li class=""><a href="ReporteGastosIndividual.jsp">REPORTE DE GASTOS</a></li>
                <li><a href="Mantenimiento.jsp">AVANCE</a></li>
                <li class="dropdown active"><a id="dLabel" role="button" data-toggle="dropdown" href="#">
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
        <table>
            <tr>
                <td colspan="3">
                    <a href="RGA_Listado.jsp" class="btn btn-success" title="Regresar" style="width: 75px">
                    <i class="fa fa-mail-reply" style="font-size:20px"></i></a> 
                    <p style="color:black" align="center"><b>Regresar</b></p>
                </td>
                <td colspan="3">
                    <a onclick="Insertar()" class="btn btn-primary" title="Guardar" style="width: 75px">
                    <i class="fa fa-save" style="font-size:20px"></i></a> 
                    <p style="color:black" align="center"><b>Agregar</b></p>
                </td>
            </tr>
        </table>
    </div>    
                                
    <div class="container">
    <div class="form-group" >
        <h3>LISTADO DE HIJOS DEL JEFE: <%=Jefe%></h3>
    <form name="formul">                  
        <select class="form-control" id="idHijo" name ="idHijo">
        <option>Seleccione el Usuario para Agregarlo:</option>
        <%
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "Select IDUSUARIO, NOMBRE||' '||APELLIDOS as nombre,IDROL,ESTADO From usuario where ESTADO='a' and "
                    + " Not IDUSUARIO In (select a.IDUSUARIO from REPGASASIG a where a.IDUSUARIOASIG = "+idJefe+" ) and (IDROL=2 or IDROL=3) order by 2 ";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
        while (rs.next()) {%>
        <option><%=rs.getString(1)+"-"+rs.getString(2)%></option>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}%>
        </select>
    </form>
<br>
    <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered text-center " >
    <tr>
        <th class="text-center">Id</th>    
        <th class="text-center">Usuario</th>
        <th class="text-center">Rol</th>
        <th class="text-center">Jefe</th>  
        <th class="text-center">Eliminar</th>
    </tr>
    <%
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select a.IDREPGASASIG,a.IDUSUARIO, b.USUARIO,b.NOMBRE||' '||b.APELLIDOS as nombre, a.IDUSUARIOASIG, c.CARGO "
                + " from REPGASASIG a, usuario b, rol c "
                + " where a.IDUSUARIOASIG = "+idJefe+" and a.IDUSUARIO = b.IDUSUARIO and b.ESTADO='a' and b.IDROL= c.IDROL order by 4";
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();       
    while (rs.next()) {
       
    %>
    <tr>
        <td><%=rs.getString(1)%></td>
        <td><%=rs.getString(4)%></td>
        <td><%=rs.getString(6)%></td>
        <td><%=Jefe%></td>
        <td>
            <a href="RGA_EliminaHijo.jsp?idRepAsig=<%=rs.getString(1)%>&idJefe=<%=idJefe%>&user=<%=Jefe%>" class="btn btn-danger ">
            <i class="material-icons" style="color:white;font-size:25px">delete_forever</i>
            </a>    
        </td>
    </tr>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();}%>
    </table>
    </div>
    </div>   
    </div>  
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </body>
</html>