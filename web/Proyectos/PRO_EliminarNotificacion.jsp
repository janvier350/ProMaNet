<%-- 
    Document   : PRO_EliminarNotificacion
    Created on : 29-sep-2020, 13:45:20
    Author     : Sistemas-Pc
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idNotificacion = request.getParameter("idNotificacion");
    String cargo = (String) session.getAttribute("cargo");
    String departamento = (String) session.getAttribute("departamento");
    
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
        if (!COMUN.PermisoHelper.tiene(session, "ACCESO_GENERAL")) {
         response.sendRedirect("sesionInvalida.jsp");
         return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Eliminar Registro Agenda</title>
    </head>
    <body>
      <% String sql = "update ADM_NOTIFICACIONES set ESTADO ='I' WHERE IDNOTIFICACIONES  = "+idNotificacion;
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
            alert("Solicitud Eliminada Correctamente!")
            location.href = 'PRO_NuevoEjecutivo.jsp';
         </script>
    </body>
</html>
