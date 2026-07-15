<%-- 
    Document   : productos_modal.jsp
    Created on : 24 jun 2025, 16:26:05
    Author     : developer
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page contentType="text/html" 
        import=" java.util.Date"
%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>
<!DOCTYPE html>

<%@page import="java.sql.*"%>
<%
String id = request.getParameter("id");

String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    
    String roltodo = (String) session.getAttribute("roltodo");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
%>
  <head>
 <!--     Fonts and icons     -->
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
        <!-- Nucleo Icons -->
        <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <!-- Font Awesome Icons -->
        <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <!-- CSS Files -->
        <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
  </head>
  <!--
<table class="table table-striped table-hover">
    <thead>
        <tr>
            <th>Producto</th>
            <th>Cantidad</th>
        </tr>
    </thead>
    <tbody>
<%
try {


     DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                       Connection cn = DriverManager.getConnection(ip, user, pass);
                                       String sql2 ="";
                                       String query = "";

    sql2 = "SELECT * FROM INV_SUMINISTRO_INGRESO_DET WHERE ID_SUMINISTRO_INGRESO_CAB = ?";
    PreparedStatement st2 = cn.prepareStatement(sql2);
    st2.setInt(1, Integer.parseInt(id));
    ResultSet rs2 = st2.executeQuery();
    
        

    while (rs2.next()) {
%>
        <tr>
            <td><%= rs2.getString("ID_PRODUCTO") %></td>
            <td><%= rs2.getString("CANTIDAD") %></td>
        </tr>
<%
    
    }
    rs2.close();
    st2.close();
    cn.close();
} catch (Exception e) {
    out.println("<tr><td colspan='2'>Error: " + e.getMessage() + "</td></tr>");
}
%>
    </tbody> 
</table>
    -->
    <div class="card-body px-0 pt-0 pb-2">
                                <div class="table-responsive p-0">
                                    <table class="table align-items-center justify-content-center mb-0">
                                        <thead>
                                            <tr>
                                               <!-- <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">#</th> -->
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Producto</th>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Cantidad</th>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Presentacion</th>
                                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Unidad</th>
                                                <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">Quitar</th>-->
                                                
                                                <!--<th class="text-uppercase text-secondary text-xxs font-weight-bolder text-center opacity-7 ps-2">Avance</th>-->
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <%try{
                                   DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                                   Connection cn = DriverManager.getConnection(ip, user, pass);
                                   String sql ="";
                                   String query3 = "";
                                     if(roltodo.equals("JEFE")||roltodo.equals("CONTRALOR")){
                                          query3 = "SELECT " +
               "    a.id_producto, " +
               "    b.descripcion, " +
               "    a.cantidad, " +
               "    u.unidad, " +
               "    u.descripcion AS unidad, " + // Reemplazamos b.unidad por la información de la tabla unidades
               "    a.id_suministro_ingreso_cab, " +
               "    a.id_suministro_ingreso_det " +
               "FROM " +
               "    inv_suministro_ingreso_det a " +
               "INNER JOIN " +
               "    inv_producto b " +
               "    ON a.id_producto = b.id_producto " +
               "INNER JOIN " +
               "    inv_unidad_medida u " +
               "    ON b.id_unidad = u.id_unidad_medida " +
               "WHERE " +
               "    a.id_suministro_ingreso_cab = ? ";


                                     }else if(roltodo.equals("ASISTENTE")){
//
                                     }
                                   PreparedStatement st = cn.prepareStatement(query3);
                                   st.setInt(1, Integer.parseInt(id));
                                   ResultSet rs = st.executeQuery();
                                    boolean hasData = false;
                               while (rs.next()) {
                               hasData = true;
                                        %>   
                                        <tbody>
                                            <tr>
                                               <!-- <td>
                                                    <p class="text-sm font-weight-bold mb-0"><%= rs.getString(7)%></p>
                                                </td> -->
                                                <td>
                                                    <p class="text-sm font-weight-bold mb-0"><%= rs.getString(2)%></p>
                                                </td>
                                                <td>
                                                    <p class="text-sm font-weight-bold mb-0"><%= rs.getString(3)%></p>
                                                </td>
                                                <td>
                                                    <span class="text-xs font-weight-bold"><%= rs.getString(4)%>   </span>

                                                </td>
                                                <td>
                                                    <span class="text-xs font-weight-bold"><%= rs.getString(5)%></span>

                                                </td>



                                                
                                            </tr>

                                        </tbody>

                                        <%     if (!hasData) {
                                        %>
                                        <tr>
                                            <td colspan="5" style="text-align: center;">No se encontraron datos</td>
                                        </tr>
                                        <%
                                                }
                                        %>
                                        <%}rs.close();
                                     st.close();
                                     cn.close();
                                 }catch(Exception e){
                                      e.printStackTrace();
                                 }%>  
                                    </table>
                                </div>
                            </div>

