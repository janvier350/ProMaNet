<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page contentType="text/html" 
        import=" java.util.Date"
%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import=" java.util.Date" %>

<%@page import="java.sql.*"%>
<%
    
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");    
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    String depart = "";
    
    String idUsuario = request.getParameter("idUsuario");
    if (idUsuario != null && !idUsuario.isEmpty()) {
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn3 = DriverManager.getConnection(url, user, pass);
            String historiaEquipo = "SELECT a.idinvequipo, b.fechacompra, b.dispositivo, b.marca, b.modelo, b.serial, b.estado, " +
                                    "a.fechaasignacion, a.fechadevolucion " +
                                    "FROM inv_asignacion a, inv_equipos b " +
                                    "WHERE a.idusuario = ? AND a.idinvequipo = b.idinvequipo";
            PreparedStatement st3 = cn3.prepareStatement(historiaEquipo);
            st3.setString(1, idUsuario);
            ResultSet rs3 = st3.executeQuery();
            while (rs3.next()) {
%>
    <tr>
        <td><p class="text-xs font-weight-bold mb-0"><%= rs3.getString(1) %></p></td>
        <td><p class="text-xs font-weight-bold mb-0"><%= rs3.getString(2) %></p></td>
        <td>
            <div class="d-flex px-2 py-1">
                <div><img src="../assets/img/team-2.jpg" class="avatar avatar-sm me-3" alt="user1"></div>
                <div class="d-flex flex-column justify-content-center">
                    <h6 class="mb-0 text-sm"><%= rs3.getString(4) %> - <%= rs3.getString(5) %></h6>
                    <p class="text-xs text-secondary mb-0"><%= rs3.getString(6) %></p>
                    <p class="text-xs text-secondary mb-0"><%= rs3.getString(8) %></p>
                    <p class="text-xs text-secondary mb-0"><%= rs3.getString(9) %></p>
                </div>
            </div>
        </td>
        <td><p class="text-xs font-weight-bold mb-0"><%= rs3.getString(7) %></p></td>
        <td class="align-middle text-center"><span class="text-secondary text-xs font-weight-bold"><%= rs3.getString(8) %></span></td>
        <td class="align-middle"><span class="text-secondary text-xs font-weight-bold"><%= rs3.getString(9) %></span></td>
    </tr>
<%
            }
            rs3.close();
            st3.close();
            cn3.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
