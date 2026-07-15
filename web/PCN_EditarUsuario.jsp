<%-- 
    Document   : Ediar usuario
    Created on : 15-Agosto-2018, 12:42:23
    Author     : Jquinde
--%>


<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<!--se aplicara update-->
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String idUser = request.getParameter("idUser");
    String nombreUser = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String telefono = request.getParameter("telefono");
    String email = request.getParameter("email");
    String usuario = request.getParameter("usuario");
    String contrasena = request.getParameter("contrasena");
    String idCia = request.getParameter("idCia");
    String idRol = request.getParameter("idRol");
    String idRolTodo = request.getParameter("idRolTodo");
    String idDepartamento = request.getParameter("idDepartamento");
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
        if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>

<!DOCTYPE html>
<html>
    <head>
        <title>Editar Usuario</title>
    </head>
    <body>
        <% String sql = "update USUARIO set NOMBRE ='"+nombreUser+"',  APELLIDOS ='"+apellido+"',TELEFONO ='"+telefono+"' ,EMAIL ='"+email+"',USUARIO ='"+usuario+"' "
                + ",CONTRASENA ='"+contrasena+"',IDCOMPANIA ="+idCia+",IDROL ="+idRol+",IDROLTODO ="+idRolTodo+", ID_ADM_DEPARTAMENTO ="+idDepartamento+" WHERE IDUSUARIO = "+idUser+" ";
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
<!--        <h1> <%=sql%> </h1>-->
        <script type="text/javascript" class="init">
                alert("Datos modificados correctamente!")
                location.href = 'PCN_ListadoUsuario.jsp';
            </script>
    </body>
</html>
