<%-- 
    Document   : cambiar de estado a Terminado en Detalle de Trabajo SOLO JEFES 
    Created on : 06-Apr-2017, 12:42:23
    Author     : Jquinde
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idDet = request.getParameter("DetTrab");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){

        }else{
         response.sendRedirect("sesionInvalida.jsp");
         return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Reversar Trabajo</title>
    </head>
    <body>
      <% String sql = "update TODODETTRAB set EST_DET_TRAB ='R' WHERE IDTODODET = "+idDet;
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
            alert("Datos Guardados Correctamente!")
            var str = "idCabTrab="+<%=idCab%>
//         location.href = 'TODO_det_Trabajo.jsp?'+str;
            location.href = 'TODO_det_Trabajo_1.jsp?'+str;
         </script>
    </body>
</html>
