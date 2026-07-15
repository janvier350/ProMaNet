<%-- 
    Document   : Editar Cliente
    Created on : 06-Apr-2017, 12:42:23
    Author     : Jquinde
--%>


<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<!--se aplicara update-->
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String cargo = (String) session.getAttribute("cargo");
    String idCliente = request.getParameter("idCliente");
    String Cliente = request.getParameter("Cliente");
    String Direccion = request.getParameter("Direccion");
    String Ruc = request.getParameter("Ruc");
    String Telefono = request.getParameter("Telefono");
    String Contacto = request.getParameter("Contacto");
    String Email = request.getParameter("Email");
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
        if (!COMUN.PermisoHelper.tiene(session, "CLIENTES_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>

<!DOCTYPE html>
<html>
    <head>
       
        <title>Editar Cliente</title>
    </head>
    <body>
        <% String sql = "update CLIENTE set CLIENTE ='"+Cliente+"',  DIRECCION ='"+Direccion+"',RUC ='"+Ruc+"' ,TELEFONO ='"+Telefono+"',CONTACTO ='"+Contacto+"' ,EMAIL ='"+Email+"' WHERE IDCLIENTE = "+idCliente+" ";
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
                location.href = 'Crear_Clientes.jsp';
            </script>
    </body>
</html>
