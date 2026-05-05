<%-- 
    Document   : InsertarRepGas
    Created on : 27-Mar-2017, 18:16:59
    Author     : Desarrollo
--%>

<%@page import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cliente = request.getParameter("Cliente");
    String ci = request.getParameter("ciruc");
    String telefono = request.getParameter("telefono");
    String contacto = request.getParameter("contacto");
    String direccion = request.getParameter("Direccion");
    String correo = request.getParameter("Correo");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insertar Cliente</title>
    </head>
    <body>
        <%
        int idCAB =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDCLIENTE),0)+1 secuencia from CLIENTE";
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
        String sql2="";
        String estado = "a";
        if(1==1){
            sql2="insert into CLIENTE (IDCLIENTE, CLIENTE,DIRECCION,ESTADO,RUC,CONTACTO,TELEFONO,EMAIL) VALUES ("+idCAB+",'"+cliente+"','"+direccion+"','"+estado+"','"+ci+"','"+contacto+"','"+telefono+"','"+correo+"')";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();%> 
        <script type="text/javascript" class="init">
            alert("Insert Ok !!")
        </script>
        <%}catch(Exception e){
             e.printStackTrace();
        }}else{%> 
            <script type="text/javascript" class="init">
                alert("No se puede Añadir. No tiene permisos para esta opción !!")
            </script>
        <%}%> 
        <script type="text/javascript" class="init">
            location.href = 'Crear_Clientes.jsp'
        </script>
    </body>
</html>
