<%-- 
    Document   : Insertar USUARIO
    Created on : 15-Agosto-2019, 11:43:59
    Author     : Jquinde
--%>

<%@page import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String nombre = (String) session.getAttribute("nombre");
    String nombreUsuario = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String telefono = request.getParameter("telefono");
    String email = request.getParameter("email");
    String usuario = request.getParameter("usuario");
    String passUsuario = request.getParameter("pass");
    String idRol = request.getParameter("idRol");
    String idCia = request.getParameter("idCia");
    String idRolTodo = request.getParameter("idRolTodo");
    String departamento = request.getParameter("departamento");
    String sueldo = request.getParameter("sueldo");
    
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")||nombre.equals("Jonathan")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Insertar Usuario</title>
    </head>
    <body>
        <%
        int idUser =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDUSUARIO),0)+1 secuencia from USUARIO";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idUser = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
     
        String sql2="";
        String estado = "a";
            sql2="insert into USUARIO (IDUSUARIO, NOMBRE,APELLIDOS,TELEFONO,EMAIL,USUARIO,CONTRASENA,IDCOMPANIA,IDROL,ESTADO, IDROLTODO, ID_ADM_DEPARTAMENTO, SUELDO) "
                    + "VALUES ("+idUser+",'"+nombreUsuario+"','"+apellido+"','"+telefono+"','"+email+"','"+usuario+"','"+passUsuario+"',"+idCia+","+idRol+",'"+estado+"',"+idRolTodo+","+departamento+","+sueldo+")";
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
            alert("Usuario Insertado Corecctamente!!")
        </script>
        <%}catch(Exception e){
             e.printStackTrace();
        }%> 
        <script type="text/javascript" class="init">
            location.href = 'PCN_ListadoUsuario.jsp'
        </script>
    </body>
</html>
