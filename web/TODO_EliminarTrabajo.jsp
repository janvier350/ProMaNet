<%-- 
    Document   : Eliminar Detalle De trabajo de asignados
    Created on : 08-Agosto-2018, 18:42:23
    Author     : Jquinde
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String idDetTrab = request.getParameter("idDetTrab");
    String idCab = request.getParameter("idCab");
    String idTrabajo = request.getParameter("idTrabajo");
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
        <title>Eliminar Detalle de Trabajo</title>
    </head>
    <body>
        <% 
        String sql = "UPDATE TODODETTRAB set ESTADO ='I' where IDTODODET="+idDetTrab;
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
                alert("Trabajo Eliminado Correctamente!")
                var str = "idCabTrab="+<%=idCab%>
                var str2 = "idTrab="+<%=idTrabajo%>
//                location.href = 'TODO_det_Trabajo_1.jsp?'+str;
//                location.href = 'TODO_Cab_Trabajo.jsp?'+str;
            location.href = 'Proyectos/PRO_Detalle_Trabajo.jsp?'+str;

             </script>
      
    </body>
</html>
