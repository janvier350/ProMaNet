<%-- 
    Document   : Eliminar Detalle De Actividades Individual de asistentes
    Created on : 09-Jul-2018, 12:42:23
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String idDetTare = request.getParameter("idDetTare");
    String idCab = request.getParameter("idCab");
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
    if(!(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE"))){
             response.sendRedirect("sesionInvalida.jsp");
             return;
             }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html">
        <title>Eliminar Detalle de Tarea</title>
    </head>
    <body>
        <% String sql = "update TODODETTAREA set ESTADO ='I' WHERE IDTODODETTAREA="+idDetTare;
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
         alert("Datos eliminados Correctamente!")
         var str = "idCabTrab="+<%=idCab%>
         location.href = 'TODO_det_Trabajo.jsp?'+str;
      </script>
    </body>
</html>
