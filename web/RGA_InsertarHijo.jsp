<%-- 
    Document   : Insertar Hijo
    Created on : 28-Mar-2018, 17:30:23
    Author     : Jonathan Quinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String idHijo = request.getParameter("idHijo");
    String idJefe = request.getParameter("idJefe");
    String Jefe = request.getParameter("Jefe");
    int idRepAsig =0;
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
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
    if (!COMUN.PermisoHelper.tiene(session, "REPORTES_GASTOS_ASIGNADOS")) {
             response.sendRedirect("sesionInvalida.jsp");
             return;
             }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insertar Hijo</title>
    </head>
    <body>
        <%try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDREPGASASIG),0)+1 secuencia from REPGASASIG";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idRepAsig = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        String sql = "insert into REPGASASIG values"
                    + "("+idRepAsig+","+idHijo+","+idJefe+")";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>
         <script type="text/javascript" class="init">
            alert("Datos Insertados Correctamente!");
            location.href = 'RGA_VerAsignados.jsp?id=<%=idJefe%>&user=<%=Jefe%>';
         </script>
    </body>
</html>
