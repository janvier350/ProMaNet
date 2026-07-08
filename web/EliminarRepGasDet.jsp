<%-- 
    Document   : Eliminar detalle de Reporte de Gasto.
    Created on : 06-Apr-2017, 12:42:23
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String cargo = (String) session.getAttribute("cargo");
    String idDet = request.getParameter("idDet");
    String idCab = request.getParameter("idCab");
    String mesCab = request.getParameter("mes");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
     double suma =0;
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
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Eliminar Reporte Gasto Detalle</title>
    </head>
    <body>
        <% String sql = "DELETE FROM REPGASDET where IDREPGASDET="+idDet;
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
       
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql2 = "select sum(VALOR) from REPGASDET WHERE IDREPGASCAB ="+idCab;
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 suma = rs.getDouble(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        String sql3 = "update REPGASCAB set TOTAL ="+suma+" WHERE IDREPGASCAB = "+idCab;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql3);
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
         var str = <%=idCab%>+"&mes="+<%=mesCab%>+"&flag=2"
         location.href = 'ReporteDetalleModal.jsp?id='+str;
      </script>
    </body>
</html>
