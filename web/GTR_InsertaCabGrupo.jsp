<%-- 
    Document   : Insertar Cab Grupo de Trabajo
    Created on : 31-May-2018, 9:57:01
    Author     : Jquinde
--%>

<%@page import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String Nombre = request.getParameter("Nombre");
    String nombre = (String) session.getAttribute("nombre");
    String cargo = (String) session.getAttribute("cargo");
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
        if(nombre.equals("Jonathan")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insertar Cab Grupo de Trabajo</title>
    </head>
    <body>
        <%
        int idCAB =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDTODOCABGRUPO),0)+1 secuencia from TODOCABGRUPO";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idCAB = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
    %>
    <%     
        String sql2="";
        if(1==1){
            sql2="insert into TODOCABGRUPO(IDTODOCABGRUPO, NOMBREGRUPO,ESTADO) VALUES ("+idCAB+",'"+Nombre+"','A')";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
    %> 
        <script type="text/javascript" class="init">
            alert("Datos Insertados Correctamente !!")
        </script>
        <%}catch(Exception e){
             e.printStackTrace();
        }}else{%> 
            <script type="text/javascript" class="init">
                alert("No se puede Añadir. No tiene permisos para esta opción !!")
            </script>
        <%}%> 
        <script type="text/javascript" class="init">
            location.href = 'Grupo_Trabajo.jsp'
        </script>
    </body>
</html>
