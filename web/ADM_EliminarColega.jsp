<%-- 
    Document   : ADM_EliminarAsistente
    Created on : 29-sep-2020, 13:45:20
    Author     : Sistemas-Pc
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idRegistroAgenda = request.getParameter("idDetAgenda");
    String idColega = request.getParameter("idColega");
    String cargo = (String) session.getAttribute("cargo");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Eliminar Colega Agenda</title>
    </head>
    <body>
         <!--'"+idColega+ " '      ' "+idRegistroAgenda+" '-->
      <% String sql = "update ADM_DET_AGENDA set ESTADO ='I' WHERE  ID_ADM_DET_AGENDA  =  "+idColega ;
      //        String sqlx = "update CLIENTE set estado =' "+estado+"' WHERE IDCLIENTE = "+idCliente;
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
        }
        %>
         <script type="text/javascript" class="init">
            alert("Registro de Colega Eliminados Correctamente!")
            location.href = 'Agenda.jsp';
         </script>
    </body>
</html>
