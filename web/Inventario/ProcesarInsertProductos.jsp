<%-- 
    Document   : ProcesarInsertProductos
    Created on : 1 jul 2025, 21:51:05
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
<%@page import="java.sql.*, org.json.*, java.util.*"%>
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


    request.setCharacterEncoding("UTF-8");

    String idCab = request.getParameter("idSuministroIngresoCab");
    String productosJson = request.getParameter("productosAgregados");
    String idAutorizador = request.getParameter("idAutorizador");

    // Verificación básica
    if (idCab == null || productosJson == null || productosJson.trim().isEmpty()) {
        out.println("<script>alert('Error: Datos incompletos.'); window.history.back();</script>");
        return;
    }

    Connection cn = null;
    PreparedStatement ps = null;

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        cn = DriverManager.getConnection(ip, user, pass);

        JSONArray productos = new JSONArray(productosJson);

        for (int i = 0; i < productos.length(); i++) {
            JSONObject prod = productos.getJSONObject(i);
            String idProducto = prod.getString("idProducto");
            String cantidad = prod.getString("cantidad");

            String sql = "INSERT INTO INV_INGRESO_DETALLE (ID_INGRESO_CAB, ID_PRODUCTO, CANTIDAD) VALUES (?, ?, ?)";
            ps = cn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idCab));
            ps.setInt(2, Integer.parseInt(idProducto));
            ps.setInt(3, Integer.parseInt(cantidad));
            ps.executeUpdate();
            ps.close();
        }

        // Si necesitás guardar el autorizador, hacelo aquí (opcional)
        /*
        String sql2 = "UPDATE INV_INGRESO_CAB SET ID_USUARIO_AUTORIZA = ? WHERE ID_INGRESO_CAB = ?";
        ps = cn.prepareStatement(sql2);
        ps.setInt(1, Integer.parseInt(idAutorizador));
        ps.setInt(2, Integer.parseInt(idCab));
        ps.executeUpdate();
        ps.close();
        */

        out.println("<script>alert('Productos insertados correctamente'); window.location.href='INV_Ingreso_Suministro2.jsp';</script>");

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "") + "'); window.history.back();</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (cn != null) try { cn.close(); } catch (Exception e) {}
    }
%>
