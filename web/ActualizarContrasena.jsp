<%-- 
    Document   : Actualizar Contraseña
    Created on : 11-Apr-2017, 14:21:18
    Author     : Jquinde
--%>

<%@page contentType="text/html" %>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String codigo = (String) session.getAttribute("cod");
    String cargo = (String) session.getAttribute("cargo");
    String contraActual = request.getParameter("pass1");
    String contra = request.getParameter("pass2");
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
     %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Actualiza Contrasena</title>
        <link rel="shorcut icon" href="image/logo.png">
    </head>
    <body>
        <%
            boolean validacontra =false; 
            try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql2 = "select * from USUARIO WHERE IDUSUARIO ="+codigo +"AND CONTRASENA ='"+contraActual+"'";
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 validacontra = true;
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
            if(validacontra==true){
                String sql3 = "update USUARIO set CONTRASENA ='"+contra+"' WHERE IDUSUARIO = "+codigo;
     
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql3);
            ResultSet rs = st.executeQuery(); 
            
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>
         <script type="text/javascript">
            alert("Contraseña Cambiada Correctamente!!")
            location.href = 'index.jsp';
         </script>
         <% }else{ %>
            <script type="text/javascript" class="init">
               alert("No se puede Actualizar. Contraseña Invalida!!")
               location.href = 'Home.jsp';
            </script>
        <%}%> 
    </body>
</html>
