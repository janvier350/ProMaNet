<%-- 
    Document   : Eliminar Cab Trabajo
    Created on : 18-Jun-2018, 15:42:23
    Author     : Jquinde
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idCab = request.getParameter("idCab");
    String cargo = (String) session.getAttribute("cargo");
    String idUser = (String) session.getAttribute("cod");
    String estado = "I";
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
        }
    int valida =0;    
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html ">
        <title>Eliminar Cabecera Trabajo</title>
    </head>
    <body>
        <% try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn2 = DriverManager.getConnection(url, user, pass);
        String sql2 = "SELECT  A.IDTODOCAB, A.IDUSUARIO FROM TODOCABTRAB A "
                + "WHERE A.IDTODOCAB = "+ idCab + " and A.IDUSUARIO =" +idUser ;
        PreparedStatement st2 = cn2.prepareStatement(sql2);
        ResultSet rs2 = st2.executeQuery();       
        while (rs2.next()) {
            valida = 1;
            
        } rs2.close();
          st2.close();
          cn2.close();
        }catch(Exception e){ e.printStackTrace();}
         
        if (valida ==1){    
        String sql = "update TODOCABTRAB set ESTADO ='"+estado+"' WHERE IDTODOCAB = "+idCab;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){ e.printStackTrace();}
        %> 
            <script type="text/javascript" class="init">
                alert("Datos Eliminados Correctamente!")
                location.href = 'TODO_Cab_Trabajo.jsp';
            </script>
        <% }else { %>
            <script type="text/javascript" class="init">
                alert("No tiene Permisos para realizar esta accion!")
                location.href = 'TODO_Cab_Trabajo.jsp';
            </script>
        <% } %>
         
    </body>
</html>
