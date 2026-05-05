<%-- 
    Document   : Reporte de Gastos Individual
    Created on : 16-feb-2017, 16:57:01
    Author     : Jquinde
--%>

<%@page import="java.util.Calendar"%>
<%@page contentType="text/html" 
        import ="java.sql.Connection"
        import ="java.sql.DriverManager"
        import ="java.sql.ResultSet"
        import ="java.sql.Statement"
        import ="java.sql.SQLException"
        import="java.sql.*"
        import=" java.util.Date"
        
%>
<%  String codigo = (String) session.getAttribute("cod");
    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String anioSel = request.getParameter("anio");
    int year= 0;
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
        String EstA ="";
   if(anioSel==null || anioSel.equals(null)){
       Calendar cal= Calendar.getInstance();
        year= cal.get(Calendar.YEAR);
        EstA = "IS NOT NULL";
    }else {
       year= Integer.parseInt(anioSel);;
       EstA = "= '"+anioSel+"'";
    }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet | Reporte Gastos</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
        <link rel="stylesheet" href="css/portalv2.css">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>        
        <link href="Content/Style.css" rel="stylesheet" type="text/css"/>        
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>             
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="js/jquery.min.js" type="text/javascript"></script>
        <script src="js/highlight.min.js" type="text/javascript"></script>
        <script src="js/jquery.js"></script>      
        
        <!--script del grafico en barra-->
        <script src="js/Chart.min.js"></script>
        <script>
        function CambiaAnio(){
            var texto
            texto = "El numero de opciones del select:" + document.formul.miSelect.length
            var indice = document.formul.miSelect.selectedIndex
            texto += "\nIndice de la opcion escogida:" + indice
            var valor = document.formul.miSelect.options[indice].value
            texto += "\nValor de la opcion escogida:" + valor
            var textoEscogido = document.formul.miSelect.options[indice].text
            texto += "\nTexto de la opcion escogida:" + textoEscogido
            var elem = valor.split('-');
            var anio = elem[0];
            location.href = 'ReporteGastosIndividual.jsp?anio='+anio
        }
        </script>
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
    <table class=" " >
    <tr>
        <th style="text-align:center" >Buscar </th>
        <th style="text-align:center" colspan="5">Añadir Mes </th>
        <th style="text-align:center" colspan="4"> Graficos</th>
    <%if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){%> 
        <th style="text-align:center" colspan="4"><b> Personal Asignado</b></th>
    <%}else{ }%>
    </tr>
    <tr>
        <td align="center" >
        <input type="text" class="form-control" placeholder="Buscar.." style="width:80%"  id="myInput" required>
        </td> 
        <td style="text-align:center" colspan="5">
            <a href="generarReporteGastos" class="btn btn-success" title="Añadir" style="width: 75px; border-radius: 5px;">
            <!--<i class="fa fa-calendar" style="font-size:20px"></i>-->
             <i class="material-icons" font-size:30px">date_range</i>
            </a>
        </td>
        <!--prueba de servlet para generar automatico el mes de reporte de gastos-->
<!--        <td style="text-align:center" colspan="5">
            <a href="generarReporteGastosMes" class="btn btn-warning" title="Añadir" style="width: 75px; border-radius: 5px;">
            <i class="fa fa-calendar" style="font-size:20px"></i>
             <i class="material-icons" font-size:30px">date_range</i>
            </a>
        </td>-->
        <td style="text-align:center" colspan="5">
            <a href="generarReporteGastos" class="btn btn-danger" title="Añadir" style="width: 75px; border-radius: 5px;">
            <!--<i class="fa fa-calendar" style="font-size:20px"></i>-->
             <i class="material-icons" font-size:30px">date_range</i>
            </a>
        </td>
        <td></td>
        <td style="text-align:center" colspan="4" >
            <a href="RGA_Grafico.jsp" class="btn btn-info" title="Grafico" style="width: 75px; border-radius: 5px;">
                <!--<i class="fa fa-bar-chart" style="font-size:20px"></i>-->
                <i class="material-icons" font-size:30px">bar_chart</i>
            </a>
        </td>
    <%if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){%>
        <td style="text-align:center" colspan="3"> <a href="ReporteGastos.jsp" title="Ver personal Asignado" class="btn btn-danger" style="width: 75px; border-radius: 5px;">
            <!--<i class="fa fa-users" style="font-size:20px"></i>-->
            <i class="material-icons" font-size:30px">group</i>
            </a> 
        </td> 
    <%}else{}%>
    </tr>
    </table>
    <br>
    <form name="formul">                  
        <select class="form-control" name="miSelect" onChange='CambiaAnio()'>
        <option>Seleccione el Año:</option>
         <%try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection   cn = DriverManager.getConnection(url, user, pass);
                String sql = "SELECT COUNT (SUBSTR(FECHA,1,4) ), SUBSTR(FECHA,1,4)  FROM REPGASCAB where idusuario = "+codigo+" group by SUBSTR(FECHA,1,4) order by 2 ";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet rs = st.executeQuery();       
                while (rs.next()) {%>                                                                    
                    <option value="<%=rs.getString(2)%>"><%=rs.getString(2)%></option>
                <%} rs.close();st.close();cn.close();
                }catch(Exception e){ e.printStackTrace();}%>
       
        </select>
    </form>
</div>
<br>                    
<div class="container">
<table class="table table-striped table-hover table-bordered " >
    <thead>
      <tr class="success">
        <th class="text-center">Id</th>
        <th class="text-center" >Mes</th>
        <th class="text-center">Fecha</th>
        <th class="text-center">Total</th>
        <th class="text-center" >Ver</th>
        <th class="text-center" >Imprimir</th>
    </tr> 
    </thead>
   
    <%
    String M = "";
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        String sql = "select substr(A.FECHA,6,2) mes,a.IDREPGASCAB, a.FECHA,TO_CHAR(a.TOTAL, 'FM999G990D00')as total, "
                + "b.IDUSUARIO, b.USUARIO,substr(A.FECHA,1,4) ano "
                + "from repgascab a,usuario b "
                + "where a.idusuario = b.idusuario and a.idusuario ="+ codigo +" and substr(A.FECHA,1,4) = '"+year+"' order by 7,1";
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
        M = "Noviembre";
        if(rs.getString(1).equals("12"))
        M = "Diciembre";
    %>
     <tbody id="myTable">
    <tr>
        <td><%=rs.getString(1)%></td>
        <td><%=M%></b></td>
        <td><%=rs.getString(3)%> </td>  
        <td><%="$"+rs.getString(4)%> </td>
        <td style="text-align:center">
            <a href="ReporteDetalleModal.jsp?id=<%=rs.getString(2)%>&mes=<%=rs.getString(1)%>&flag=2" class="btn btn-primary ">
            <i class="material-icons " style="color:white;font-size:25px">visibility</i>
            </a>    
        </td> 
        <td style="text-align:center">
<!--            GenerarRepGasPDF-->
            <a href="reporteGasto?id=<%=rs.getString(2)%>&mes=<%=M%>&tot=<%=rs.getString(4)%>" target="_blank" class="btn btn-warning" >
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
   <div class="container">
   <div class="row justify-content-center align-items-center">
      <div style="width: 800px; height:500px ">
         <canvas id="Chart_bar" class="chartjs"  ></canvas>
      </div>
      <br>
   </div>
   </div>
    
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
                     text: 'Reporte de Gastos (2017-<%=year%>)'
                   }
                }
            });
      </script>
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
