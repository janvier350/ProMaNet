<%-- 
    Document   : Graficos de Reporte Mensual
    Created on : 20-Junio-2018, 10:11:01
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
    String codigo = (String) session.getAttribute("cod");
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
    String sql = "";
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
        <meta http-equiv="Content-Type" content="text/html" charset=UTF-8">
        <title>ProMaNet|Grafico</title>
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>
        <script src="Content/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        
        <script src="js/Chart.min.js"></script>
        
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
                <<%if(usuario.equals("uparrales")){%>
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
                            <li><a href="">Crear Usuario</a></li>
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
                           <li><a href="#">Asignacion Reporte de Gastos</a></li>
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
   <div class="container">
   <div class="row justify-content-center align-items-center">
      <div style="width: 800px; height:500px ">
         <canvas id="Chart_bar" class="chartjs"  ></canvas>
      </div>
      <br>
      <div  style="width: 800px; height:500px " >
         <canvas id="Chart_line" class="chartjs"></canvas>    
      </div>
   </div>
   </div>
   <table id= "tab" name= "tab" class="" style="visibility: hidden">
        <thead>
            <tr>
                <th>id</th>
                <th>mes</th>
                <th>anio</th>
                <th>total</th>
                <th>color</th>
                <th>borde</th>
            </tr> 
        </thead>
        <tbody>
       <%String M = "";String color = "";String borde = ""; try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
             sql = "select IDREPGASCAB, substr(FECHA,6,2) AS MES, substr(FECHA,0,4) AS ANIO, TOTAL "
                    + " from REPGASCAB where IDUSUARIO = "+codigo 
                    + " order by 1 ";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
        while (rs.next()) {
            if(rs.getString(2).equals("01")){
            M = "Ene";
            color = "rgba(255,99,132,0.2)";borde = "rgba(255,99,132)";}
            if(rs.getString(2).equals("02")){
            M = "Feb";color = "rgba(255,159,64,0.2)";borde = "rgba(255,159,64)";}
            if(rs.getString(2).equals("03")){
            M = "Mar";color = "rgba(255,205,86,0.2)";borde = "rgba(255,205,86)";}
            if(rs.getString(2).equals("04")){
            M = "Abr";color = "rgba(75,192,192,0.2)";borde = "rgba(75,192,192)";}
            if(rs.getString(2).equals("05")){
            M = "May";color = "rgba(54,162,235,0.2)";borde = "rgba(54,162,235)";}
            if(rs.getString(2).equals("06")){
            M = "Jun";color = "rgba(153,102,255,0.2)";borde = "rgba(153,102,255)";}
            if(rs.getString(2).equals("07")){
            M = "Jul";color = "rgba(201,203,207,0.2)";borde = "rgba(201,203,207)";}
            if(rs.getString(2).equals("08")){
            M = "Ago";color = "rgba(255,99,132,0.2)";borde = "rgba(255,99,132)";}
            if(rs.getString(2).equals("09")){
            M = "Sep";color = "rgba(255,159,64,0.2)";borde = "rgba(255,159,64)";}
            if(rs.getString(2).equals("10")){
            M = "Oct";color = "rgba(255,205,86,0.2)";borde = "rgba(255,205,86)";}
            if(rs.getString(2).equals("11")){
            M = "Nov";color = "rgba(75,192,192,0.2)";borde = "rgba(75,192,192)";}
            if(rs.getString(2).equals("12")){
            M = "Dic";color = "rgba(54,162,235,0.2)";borde = "rgba(54,162,235)";}
            %>
               <tr>
                  <td><%=rs.getInt(1)%></td>
                  <td><%=M+" "+rs.getInt(3)%></td>
                  <td><%=rs.getInt(3)%></td>
                  <td><%=rs.getDouble(4)%></td>
                  <td><%=color%></td>
                  <td><%=borde%></td>
               </tr>
        <%} rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
            e.printStackTrace();}%> 
         </tbody>  
         </table>    
          
         <script type="text/javascript" class="init">
            var ctx = document.getElementById("Chart_bar").getContext('2d');
            var t=document.getElementById('tab'); 
            var meses = [];
            var totales = [];   
            var color = [];   
            var borde = []; 
            for (var r = 1; r < t.rows.length; r++) {
               meses[r]=t.rows[r].cells[1].innerHTML;
               totales[r]=t.rows[r].cells[3].innerHTML;
               color[r]=t.rows[r].cells[4].innerHTML;
               borde[r]=t.rows[r].cells[5].innerHTML;
            }
            var datas ={
               "label" : "Total",
               "data" : totales,
               "fill":false,
               "backgroundColor": color,
               "borderColor": borde,
               "borderWidth" : 1
            }
            var myChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: [] = meses.slice(0),
                    datasets: [datas]
                },
                options: {
                    scales: {
                        yAxes: [{
                            ticks: {
                                beginAtZero:true
                            }
                        }]
                    },
                    title: {
                     display: true,
                     text: 'Reporte de Gastos (2017-2018)'
                   }
                }
            });
      </script>
      <script type="text/javascript" class="init">
            var ctx = document.getElementById("Chart_line").getContext('2d');
            var t=document.getElementById('tab'); 
            var meses = [];
            var totales = [];   
            for (var r = 1; r < t.rows.length; r++) {
               meses[r]=t.rows[r].cells[1].innerHTML;
               totales[r]=t.rows[r].cells[3].innerHTML;
            }
            var datas ={
               "label" : "Total",
               "data" : totales,
               borderColor: "#2874A6",
               "borderWidth" : 1
            }
            var myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [] = meses.slice(0),
                    datasets: [datas]
                },
                options: {
                    scales: {
                        yAxes: [{
                            ticks: {
                                beginAtZero:true
                            }
                        }]
                    }
                }
            });
      </script>
      <br><br>
      
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
         
    </body>
</html>