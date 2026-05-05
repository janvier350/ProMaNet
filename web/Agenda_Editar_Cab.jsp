<%-- 
    Document   : Editar Cliente
    Created on : 16-feb-2017, 16:57:01
    Author     : JVaras
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>
<%--<%@import('https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.0/css/bootstrap.min.css')%>--%>


<%  String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String usuario = (String) session.getAttribute("usuario");
    String idCliente = request.getParameter("idCliente");
    
//    LLEGAN DE AGENDA
    String idRegistroAgenda = request.getParameter("idRegistroAgenda");
    String observacion = request.getParameter("observacion");
    String h_inicio = request.getParameter("h_inicio");
    String h_fin = request.getParameter("h_fin");
     String jefe = request.getParameter("jefe");
     String fechaAgenda = request.getParameter("fechaAgenda");
     
   String nombreEjecutivo = request.getParameter("nombreEjecutivo");
   String idEjecutivo = request.getParameter("idEjecutivo");
   
  String  idClienteAsig = request.getParameter("idClienteAsig");
   String  nombreCliente = request.getParameter("nombreCliente");
   
  String  idDepartamento = request.getParameter("idDepartamento");
  String  nombreDepartamento = request.getParameter("nombreDepartamento");
//    RECIBO EL GRUPO  DE TRABAJO
    String cbm_anio = request.getParameter("cbm_anio");
    
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
        <title>ProMaNet|Editar Cliente</title> 
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
        
          <script src="js/highlight.min.js" type="text/javascript"></script>
        <script src="dist/jquery-clockpicker.min.js" type="text/javascript"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="css/dropdown.css" rel="stylesheet" type="text/css"/>
        
         <link rel="stylesheet" href="css/chosen.css">
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    
    <style>
 

.checkbox.checbox-switch {
    padding-left: 0;
}

.checkbox.checbox-switch label,
.checkbox-inline.checbox-switch {
    display: inline-block;
    position: relative;
    padding-left: 0;
}
.checkbox.checbox-switch label input,
.checkbox-inline.checbox-switch input {
    display: none;
}
.checkbox.checbox-switch label span,
.checkbox-inline.checbox-switch span {
    width: 35px;
    border-radius: 20px;
    height: 18px;
    border: 1px solid #dbdbdb;
    background-color: rgb(255, 255, 255);
    border-color: rgb(223, 223, 223);
    box-shadow: rgb(223, 223, 223) 0px 0px 0px 0px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s;
    display: inline-block;
    vertical-align: middle;
    margin-right: 5px;
}
.checkbox.checbox-switch label span:before,
.checkbox-inline.checbox-switch span:before {
    display: inline-block;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: rgb(255,255,255);
    content: " ";
    top: 0;
    position: relative;
    left: 0;
    transition: all 0.3s ease;
    box-shadow: 0 1px 4px rgba(0,0,0,0.4);
}
.checkbox.checbox-switch label > input:checked + span:before,
.checkbox-inline.checbox-switch > input:checked + span:before {
    left: 17px;
}


/* Switch Default */
.checkbox.checbox-switch label > input:checked + span,
.checkbox-inline.checbox-switch > input:checked + span {
    background-color: rgb(180, 182, 183);
    border-color: rgb(180, 182, 183);
    box-shadow: rgb(180, 182, 183) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch label > input:checked:disabled + span,
.checkbox-inline.checbox-switch > input:checked:disabled + span {
    background-color: rgb(220, 220, 220);
    border-color: rgb(220, 220, 220);
    box-shadow: rgb(220, 220, 220) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch label > input:disabled + span,
.checkbox-inline.checbox-switch > input:disabled + span {
    background-color: rgb(232,235,238);
    border-color: rgb(255,255,255);
}
.checkbox.checbox-switch label > input:disabled + span:before,
.checkbox-inline.checbox-switch > input:disabled + span:before {
    background-color: rgb(248,249,250);
    border-color: rgb(243, 243, 243);
    box-shadow: 0 1px 4px rgba(0,0,0,0.1);
}



/* Switch Danger */
.checkbox.checbox-switch.switch-danger label > input:checked + span,
.checkbox-inline.checbox-switch.switch-danger > input:checked + span {
    background-color: rgb(200, 35, 51);
    border-color: rgb(200, 35, 51);
    box-shadow: rgb(200, 35, 51) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}
.checkbox.checbox-switch.switch-danger label > input:checked:disabled + span,
.checkbox-inline.checbox-switch.switch-danger > input:checked:disabled + span {
    background-color: rgb(216, 119, 129);
    border-color: rgb(216, 119, 129);
    box-shadow: rgb(216, 119, 129) 0px 0px 0px 8px inset;
    transition: border 0.4s ease 0s, box-shadow 0.4s ease 0s, background-color 1.2s ease 0s;
}



</style>

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
                 <li class="active"><a href="Agenda.jsp">AGENDA</a></li>
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
                                        <li><a href="#">Otros</a></li>
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
                <li><a href="cerrar.jsp">CERRAR SESIÓN</a></li>
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
                        <div class=" container panel-success" align="center">
		<div class="panel-heading">
                                                <h3 class="panel-title"><b>Editar agenda de la reunión</b></h3>
                                                <!--<span class="pull-right clickable"><i class="glyphicon glyphicon-chevron-up"></i></span>-->
                                    </div>
		<div class="panel-body"> <%String idCabeceraDetalle = idRegistroAgenda;%>
                    <form  action="ADM_Editar_Agenda_Cab.jsp"  method="POST" >
                            <div class="modal-body">
                                <div class="container-fluid">
                                <div class="row">
                                <div class="col-lg-6 ">
                                <div class="form-group">
                                    <!--(5)nombre ejecutivo (6)Cliente nombres consultar fecha"-->
                                    <input type="hidden" class= "form-group" id="idRegistroAgenda" name="idRegistroAgenda" value="<%=idRegistroAgenda%>">
                                    <label class=" control-label" for="Cliente">Ejecutivo</label>
                                    <div class="form-group">
                                                    <select class="chosen-select form-control" id="idEjecutivo" name ="idEjecutivo" >
                                                        <option value="<%=idEjecutivo%>"><%=nombreEjecutivo%></option>
                                                        <%
                                                            try{
                                                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                            Connection   cn = DriverManager.getConnection(url, user, pass);
                                                            String sql = "select * from Usuario where estado = 'a'  order by 2";
                                                            PreparedStatement st = cn.prepareStatement(sql);
                                                            ResultSet rs = st.executeQuery();       
                                                            while (rs.next()) {
                                                            %>                                                                    
                                                            <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> <%=rs.getString(3)%></option>
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
                                </div>



                                </div>
                                <div class="col-lg-6 ">
                                <div class="form-group">
                                    <label class=" control-label" for="Ruc" >FECHA</label>
                                    <input type="date" name="fechAgenda" id="fechAgenda" class="form-control" value="<%=fechaAgenda%>" required />
                                    <script>
                                                document.getElementById('fechaAgenda').value = new Date().toISOString().substring(0, 10);
                                </script>
                                </div>
                                </div>
                                </div>
                                <div class="row">
                                <div class="col-lg-6 ">
                                <div class="form-group">
                                    <label class=" control-label" for=" Telefono" >HORA INICIO</label>
                                    <input type="time" name="h_inicio" id="h_inicio" class="form-control"  value="<%=h_inicio%>"  />
                                    <!--<input type="time" name="horaarribo" min="12:00" max="18:00" step="600">-->
                                </div>
                                </div>
                                <div class="col-lg-6">
                                <div class="form-group">
                                    <label for="Contacto" class="form-control-label">HORA FIN</label>
                                    <input type="time" name="h_fin" id="h_fin" class="form-control" placeholder="15:00" value="<%=h_fin%>"   />
                                </div>  
                                </div>
                                </div>
                                <div class="row">
                                <div class="col-lg-12 ">
                                <div class="form-group">
                                    <label class=" control-label" for="Cliente" >Cliente</label>
                                    <%--<%=nombreCliente%>--%>
                                    <!--<input type="text" name="idCliente" id="idCliente" class="form-control" value="<%=idClienteAsig%> " />-->
                                    <div class="form-group">
                                                    <select class="chosen-select form-control" id="idCliente" name ="idCliente">
                                                  <option value="<%=idClienteAsig%>"><%=nombreCliente%></option>
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
                                </div>
                                        <div class="form-group">
                                          
                                         <label class=" control-label" for="Cliente">Departamento</label>
                                         <div class="form-group">
                                            
                                             <select class="chosen-select form-control" name="departamento" id="departamento">
                                               
                                                 <option value="<%=nombreDepartamento%>"><%=nombreDepartamento%></option>
                                      <%try{
                                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                        Connection   cn = DriverManager.getConnection(url, user, pass);
                                        String sql2 = "select A.IDTODOCABGRUPO, A.NOMBREGRUPO, A.ESTADO from TODOCABGRUPO A where  A.IDTODOCABGRUPO>1 AND ESTADO = 'A' ORDER BY 2";
                                        PreparedStatement st = cn.prepareStatement(sql2);
                                        ResultSet rs = st.executeQuery();       
                                        while (rs.next()){%>   
                                            <option value="<%=rs.getString(2)%>"><%=rs.getString(2)%></option>
                                      <% }     
                                        rs.close();
                                        st.close();
                                        cn.close();
                                      }catch(Exception e){
                                         e.printStackTrace();
                                      }%> 
                                   </select>
                                         </div>
                                     </div>
                                </div>
                                </div>                                             
                                <div class="row">
                                <div class="col-lg-12">
                                    <div class="form-group">
                                        <label for="Observacion" class="form-control-label">Observación</label>
                                        <input class="form-control" id="observacion" name="observacion"  value="<%=observacion%>">
                                        <!--<textarea type="text" class="form-control" id="observacion" name="observacion" value="<%=observacion%>"></textarea>-->
                                    </div>  
                                </div>
                                </div>
                                </div>
                                <div class="modal-footer">
                                   <a class = "btn btn-danger" type="button" href="Agenda.jsp">Cerrar</a>
                                    <button type="submit"  class="btn btn-primary">Guardar</button>
                                </div>
                            </div> 
                   </form>
               
               

                                    
                                    </div>
                        </div>
         
        </div>
        <section class="">
                    <!-- Footer -->
                    <footer class="text-center text-white" style="background-color: #0a4275;">
                      <!-- Grid container -->
                      <div class="container p-4 pb-0">
                        <!-- Section: CTA -->

                        <!-- Section: CTA -->
                      </div>
                      <!-- Grid container -->

                      <!-- Copyright -->
                      <div class="text-center text-warning p-3" style="background-color: #0a4275;">
                        © 2023 Copyright:
                        <a class="text-white" href="https://overclocking.com.ec/">overclocking.com.ec</a>
                      </div>
                      <!-- Copyright -->
                    </footer>
                    <!-- Footer -->
          </section>
                   
   </div>
   </div>      
   </div>
   </div>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
      
       <script src="js/chosen.jquery.js" type="text/javascript"></script>     
    <script src="js/init.js" type="text/javascript" ></script>
    
    </body>
    
    
</html>
