<%-- 
    Document   : Editar Cab Agenda
    Created on : 06-sep-2023, 12:42:23
    Author     : jvaras
--%>


<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<!--se aplicara update-->
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String cargo = (String) session.getAttribute("cargo");
    
    String idRegistroAgenda = request.getParameter("idRegistroAgenda");
    String idEjecutivo = request.getParameter("idEjecutivo");
    String fechAgenda = request.getParameter("fechAgenda");
    String h_inicio = request.getParameter("h_inicio");
    String h_fin = request.getParameter("h_fin");
    String idCliente = request.getParameter("idCliente");
    String observacion = request.getParameter("observacion");
    String departamento = request.getParameter("departamento");
    
    
    
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
       
        <title>Editar Cab Agenda</title>
    </head>
    <body>
        <%
//            String sql = "update ADM_CAB_AGENDA set ID_USUARIO ="+idEjecutivo+",  "
//                + "FECHA_AGE_INI = to_date('"+fechAgenda+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'),"
//                + "HORA_AGE_INI ='"+h_inicio+"' ,HORA_AGE_FIN ='"+h_fin+"',"
//                + "ID_CLIENTE = "+cliente+" ,OBSERVACION ='"+observacion+"',"
//                + " AREA = '"+departamento+"' WHERE ID_ADM_CAB_AGENDA = "+idRegistroAgenda;
            
            String sql = "update ADM_CAB_AGENDA set ID_USUARIO ="+idEjecutivo+",  "
                + "FECHA_AGE_INI = to_date('"+fechAgenda+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'),"
                + "HORA_AGE_INI ='"+h_inicio+"' ,HORA_AGE_FIN ='"+h_fin+"',ID_CLIENTE = "+idCliente+" ,OBSERVACION ='"+observacion+"',"
                + " AREA = '"+departamento+"' WHERE ID_ADM_CAB_AGENDA = "+idRegistroAgenda;
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
        <!--<h1> <%=sql%> </h1>-->
        <script type="text/javascript" class="init">
                alert("Datos modificados correctamente!")
                location.href = 'Agenda.jsp';
            </script>
    </body>
</html>
