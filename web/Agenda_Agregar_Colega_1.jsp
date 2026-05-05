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
                 <li><a href="Agenda.jsp">AGENDA</a></li>
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
                                                <h3 class="panel-title"><b>Selección de colegas que lo acompañaran en la reunión</b></h3>
                                                <!--<span class="pull-right clickable"><i class="glyphicon glyphicon-chevron-up"></i></span>-->
                                    </div>
		<div class="panel-body"> <%String idCabeceraDetalle = idRegistroAgenda;%>
                    <form  action="FormulariosServlet?idRegistroAgenda=<%=idCabeceraDetalle%>"  method="POST" >
                                        <input type="hidden" class="form-control " name="idRegistroAgenda"  id="idRegistroAgenda" value="<%=idRegistroAgenda = request.getParameter("idRegistroAgenda")%>" disabled="true" >
                                    
                                     <div>
                                         <span class="control-label-addon" for="inputdefault">   </span>
                                                         <select class="form-control " style="width:35%" id="cbm_anio" name="cbm_anio" onChange='cargarDatos()'>
                                                             <option value=""><%=idRegistroAgenda%>Seleccione Departamento</option>
                                                             <%try{
                                                             Connection   cn = DriverManager.getConnection(url, user, pass);
                                                             String sql = "SELECT * FROM adm_departamento where estado = 'A' ";
                                                             PreparedStatement st = cn.prepareStatement(sql);
                                                             ResultSet rs = st.executeQuery();       
                                                             while (rs.next()) {%>                                                                    
                                                                 <option value="<%=rs.getString(1)%>"><%=rs.getString(2) %></option>

                                                             <%} rs.close();st.close();cn.close();
                                                             }catch(Exception e){ e.printStackTrace();}%>                        
                                                         </select>    

                                                       <!--aqui va el corte--> 

                                                         <!--tabla-->
                                                        
                                                         <br>
                                                         <table class="table table-hover" id="dev-table">
                                                                <thead>
                                                                  <tr>
                                                                      <th align ="center">#</th>
                                                                     <th align ="center">DEPARTAMENTO</th>
                                                                    <th align ="center">APELLIDOS</th>
                                                                     <th align ="center">NOMBRES</th>
                                                                     <th align="" >AGREGAR</th>
                                                                  </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <% int contador =0;
                                                                                    try{
                                                                                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                                                                    Connection   cn = DriverManager.getConnection(url, user, pass);
                                                                                    String sql = "Select a.idusuario, a.apellidos, a.nombre, b.departamento from usuario a, adm_departamento b where a.id_adm_departamento = b.id_departamento and a.estado = 'a' AND a.id_adm_departamento = "+cbm_anio+" ";
                                                                                    PreparedStatement st = cn.prepareStatement(sql);
                                                                                    ResultSet rs = st.executeQuery();       
                                                                                    while (rs.next()) {
                                                                                        contador++;
                                                                                    %>  
                                                                                    <div class="form-check">
                                                                                    <tr>
                                                                                        <td><%=contador%></td>
                                                                                        <td><%=rs.getString(4) %>     :      </td>
                                                                                        <td><label class="form-check-label">        <%=rs.getString(2)%> </label></td>
                                                                                         <td><label class="form-check-label">        <%=rs.getString(3)%> </label></td>
                                                                                        <td align="center" >
                                                                                            <input class="form-check-input valores" type="checkbox" id="colega" name="colega " value="<%=rs.getString(1)%> " > </td>                                          
                                                                                    </tr>
                                                                                    <% }     
                                                                                        rs.close();  st.close();cn.close();
                                                                                    }catch(Exception e){
                                                                                         e.printStackTrace();
                                                                                    }  %> 
                                                               </tbody>
                                                         </table>
                                                               <br>
                                             <h3>Colegas seleccionados</h3>
                                             <u  class="container-fluid " id="lista_u" name="lista_u" class="list-group">
                                                 
                                             </u>  
                                            
                                             <div class="modal-footer">
                                             <button type="button" id="boton" class="btn btn-success"> Confirmar selección </button>
                                                <a class = "btn btn-danger" type="button" href="Agenda.jsp">Cerrar</a>
                                                <button type="submit"  class="btn btn-primary">Guardar</button>
                                            </div> 
                                         <!--</div>-->
                                         </div>           
                                     </form>   
                                    <script>
                                       function cargarDatos(){ 
                                           var cbm_anio = document.getElementById("cbm_anio").value;
                                           var cabAgenda = document.getElementById("idRegistroAgenda").value;
                               //            var idRegistroAgenda = document.getElementById("idRegistroAgenda").value;
                              // paso de dos variables a otra jsp en la misma pagina 
                              
                                           location.href = 'Agenda_Agregar_Colega.jsp?cbm_anio='+cbm_anio+'&idRegistroAgenda='+cabAgenda;    
 
                              //                        location.href = 'FAC_ReportGasto_Mes_Anio.jsp?cbm_anio='+cbm_anio+'&cbm_mes='+arrayMes[0]+'&mesSeleccinado='+arrayMes[1];                          
                             //                location.href = 'Home.jsp?status=1&id='+cliente;
                                       } 
                                   </script>
                                    
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
           <script> 
                var boton = document.getElementById('boton');
                var lista = document.getElementById('lista_u');
                var checks = document.querySelectorAll('.valores');
                var idcabeceraagenda = document.getElementById('cabeceraAgenda');
                
                boton.addEventListener('click', function (){
                    lista.innerHTML = '';
                          checks.forEach((e)=>{
                        if(e.checked == true){
                            console.log(e.value);
                            var elemento = document.createElement('input');
                            
                            elemento.className='list-group-item';
                            elemento.name = 'lista_input';
                            elemento.value = e.name;
                            elemento.innerHTML = e.value + e.name;
                            
                            lista.appendChild(elemento);
                           // request.getSession().setAttribute("lista", lista);
                        }
                    });
                    
                  
//                    localStorage.setItem("listaColegas", JSON.stringify(lista));
                    
                   
                });
                </script>          
   </div>
   </div>      
   </div>
   </div>
      <script src="js/jquery.js"></script>
      <script src="js/bootstrap.min.js"></script>
    </body>
    
    <style >
            

                    .funkyradio div {
                      clear: both;
                      overflow: hidden;
                    }

                    .funkyradio label {
                      width: 100%;
                      border-radius: 3px;
                      border: 1px solid #D1D3D4;
                      font-weight: normal;
                    }

                    .funkyradio input[type="radio"]:empty,
                    .funkyradio input[type="checkbox"]:empty {
                      display: none;
                    }

                    .funkyradio input[type="radio"]:empty ~ label,
                    .funkyradio input[type="checkbox"]:empty ~ label {
                      position: relative;
                      line-height: 2.5em;
                      text-indent: 3.25em;
                      margin-top: 2em;
                      cursor: pointer;
                      -webkit-user-select: none;
                         -moz-user-select: none;
                          -ms-user-select: none;
                              user-select: none;
                    }

                    .funkyradio input[type="radio"]:empty ~ label:before,
                    .funkyradio input[type="checkbox"]:empty ~ label:before {
                      position: absolute;
                      display: block;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      content: '';
                      width: 2.5em;
                      background: #D1D3D4;
                      border-radius: 3px 0 0 3px;
                    }

                    .funkyradio input[type="radio"]:hover:not(:checked) ~ label,
                    .funkyradio input[type="checkbox"]:hover:not(:checked) ~ label {
                      color: #888;
                    }

                    .funkyradio input[type="radio"]:hover:not(:checked) ~ label:before,
                    .funkyradio input[type="checkbox"]:hover:not(:checked) ~ label:before {
                      content: '\2714';
                      text-indent: .9em;
                      color: #C2C2C2;
                    }

                    .funkyradio input[type="radio"]:checked ~ label,
                    .funkyradio input[type="checkbox"]:checked ~ label {
                      color: #777;
                    }

                    .funkyradio input[type="radio"]:checked ~ label:before,
                    .funkyradio input[type="checkbox"]:checked ~ label:before {
                      content: '\2714';
                      text-indent: .9em;
                      color: #333;
                      background-color: #ccc;
                    }

                    .funkyradio input[type="radio"]:focus ~ label:before,
                    .funkyradio input[type="checkbox"]:focus ~ label:before {
                      box-shadow: 0 0 0 3px #999;
                    }

                    .funkyradio-default input[type="radio"]:checked ~ label:before,
                    .funkyradio-default input[type="checkbox"]:checked ~ label:before {
                      color: #333;
                      background-color: #ccc;
                    }

                    .funkyradio-primary input[type="radio"]:checked ~ label:before,
                    .funkyradio-primary input[type="checkbox"]:checked ~ label:before {
                      color: #fff;
                      background-color: #337ab7;
                    }

                    .funkyradio-success input[type="radio"]:checked ~ label:before,
                    .funkyradio-success input[type="checkbox"]:checked ~ label:before {
                      color: #fff;
                      background-color: #5cb85c;
                    }

                    .funkyradio-danger input[type="radio"]:checked ~ label:before,
                    .funkyradio-danger input[type="checkbox"]:checked ~ label:before {
                      color: #fff;
                      background-color: #d9534f;
                    }

                    .funkyradio-warning input[type="radio"]:checked ~ label:before,
                    .funkyradio-warning input[type="checkbox"]:checked ~ label:before {
                      color: #fff;
                      background-color: #f0ad4e;
                    }

                    .funkyradio-info input[type="radio"]:checked ~ label:before,
                    .funkyradio-info input[type="checkbox"]:checked ~ label:before {
                      color: #fff;
                      background-color: #5bc0de;
                    }

                    /* SCSS STYLES */
                    /*
                    .funkyradio {

                        div {
                            clear: both;
                            overflow: hidden;
                        }

                        label {
                            width: 100%;
                            border-radius: 3px;
                            border: 1px solid #D1D3D4;
                            font-weight: normal;
                        }

                        input[type="radio"],
                        input[type="checkbox"] {

                            &:empty {
                                display: none;

                                ~ label {
                                    position: relative;
                                    line-height: 2.5em;
                                    text-indent: 3.25em;
                                    margin-top: 2em;
                                    cursor: pointer;
                                    user-select: none;

                                    &:before {
                                        position: absolute;
                                        display: block;
                                        top: 0;
                                        bottom: 0;
                                        left: 0;
                                        content: '';
                                        width: 2.5em;
                                        background: #D1D3D4;
                                        border-radius: 3px 0 0 3px;
                                    }
                                }
                            }

                            &:hover:not(:checked) ~ label {
                                color: #888;

                                &:before {
                                    content: '\2714';
                                    text-indent: .9em;
                                    color: #C2C2C2;
                                }
                            }

                            &:checked ~ label {
                                color: #777;

                                &:before {
                                    content: '\2714';
                                    text-indent: .9em;
                                    color: #333;
                                    background-color: #ccc;
                                }
                            }

                            &:focus ~ label:before {
                                box-shadow: 0 0 0 3px #999;
                            }
                        }

                        &-default {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #333;
                                    background-color: #ccc;
                                }
                            }
                        }

                        &-primary {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #fff;
                                    background-color: #337ab7;
                                }
                            }
                        }

                        &-success {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #fff;
                                    background-color: #5cb85c;
                                }
                            }
                        }

                        &-danger {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #fff;
                                    background-color: #d9534f;
                                }
                            }
                        }

                        &-warning {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #fff;
                                    background-color: #f0ad4e;
                                }
                            }
                        }

                        &-info {
                            input[type="radio"],
                            input[type="checkbox"] {
                                &:checked ~ label:before {
                                    color: #fff;
                                    background-color: #5bc0de;
                                }
                            }
                        }
                    }
                    */

         </style>
</html>
