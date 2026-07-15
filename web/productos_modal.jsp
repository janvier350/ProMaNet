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

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS")) {
        response.sendRedirect("sesionInvalida.jsp"); return;
    }
%>
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

