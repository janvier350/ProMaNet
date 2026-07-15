<%-- 
    Document   : ReporteDetalleNew
    Created on : 21-Mar-2017, 15:33:10
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
<%   String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
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
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProMaNet| Nuevo Gasto</title>
        <link rel="shorcut icon" href="image/logo.png">
        <link rel="stylesheet"  type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />
            <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/dataTables.bootstrap.min.css" />        
            <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css" />
            <link rel="stylesheet"  type="text/css" href="https://cdn.datatables.net/responsive/2.1.1/css/responsive.dataTables.min.css" />            
            <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.js"></script>
            <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
            <script type="text/javascript" src="https://cdn.datatables.net/1.10.13/js/dataTables.bootstrap.min.js"></script>
            <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.1.1/js/dataTables.responsive.min.js"></script>            
            <script type="text/javascript" class="init">
                $(document).ready(function() {
                $('#example').DataTable();
                } );
            </script>
    </head>
    <body>
        <header>
              <div class="container-fluid">
                <div class="logo ">
                    <img   src="image/banner2020.png" width="1335px" height="150px" > 
               </div>
                  <nav class="navbar navbar-default" id="nav2">
                 <div class="container-fluid">   
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
                             <li ><a href="TODOasist.jsp">TO-DO</a></li> 
                             <li class="active"><a href="ReporteGastosIndividual.jsp">Reporte de Gastos</a></li>
                             <li><a href="Avance.jsp">Avance</a></li>
                             <li><a href="cerrar.jsp">Cerrar Sesión</a></li>
                         </ul>
                     </div>
                 </div>   
                </nav>
                  
                  <div class="container-fluid">
                      <div class="form-group">
                          <table class="table table-bordered table-hover">
                            <caption></caption>
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
        <%String idCab =request.getParameter("id");%>
        <form action="InsertarRepGasDet.jsp" method="post">
        <table id="example" class="table table-striped table-bordered" width="100%" cellspacing="0">
        <thead>
            <tr>
                <th>IdCab</th>
                <th>Fecha</th>
                <th>Alimentacion</th>
                <th>Transporte</th>
                <th>Observacion</th>
            </tr>
        </thead>
        <tbody>    
          <tr>
              <td><input type="hidden" name="id" class="form-control" value=<%=idCab%>></td>
              <td><input type="date" name ="fecha" class="form-control"></td>
              <td><input type="number" step ="any" name="alimentacion" value="0" class="form-control"></td>
              <td><input type="number" step ="any" name="transporte" value="0" class="form-control"></td>                    
              <td><input type="text" name="trabajo" class="form-control"></td>     
          </tr>
        </tbody>
        </table>
            <div class="form-group">                              
               <button type="submit"  class="btn btn-primary">Guardar</button>
            </div>
        </form> 
    </body>
</html>
