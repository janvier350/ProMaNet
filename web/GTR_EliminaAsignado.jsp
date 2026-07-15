<%-- 
    Document   : Eliminar Hijo
    Created on : 28-Mar-2018, 16:42:23
    Author     : Jonathan Quinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String idDetGrupo = request.getParameter("id");
    String idCabGrupo = request.getParameter("idCabGrupo");
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
    if(!(cargo.equals("CONTRALOR")||cargo.equals("JEFE"))){
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
        <title>Eliminar Hijo</title>
    </head>
    <body>
        <% 
        String sql = "DELETE FROM TODODETGRUPO where IDTODODETGRUPO="+idDetGrupo;
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
            alert("Datos eliminados Correctamente!");
            location.href = 'GTR_VerAsignados.jsp?id=<%=idCabGrupo%>';
         </script>
    </body>
</html>
