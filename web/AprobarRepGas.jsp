<%-- 
    Document   : AprobarRepGas
    Created on : 18-Apr-2017, 09:15:10
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idCab = request.getParameter("id");
    String idHijo = request.getParameter("idHijo");
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
        if (!COMUN.PermisoHelper.tiene(session, "REPORTE_GASTOS_APROBAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ProMaNet|Aprobar Reporte Gastos</title>
        <link rel="shorcut icon" href="image/logo.png">
    </head>
    <body>
      <% String sql = "update REPGASCAB set APROBADO ='S' WHERE IDREPGASCAB = "+idCab;
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
         alert("Datos Procesados Correctamente!!")
         location.href = 'ReporteGastos.jsp?id='+<%=idHijo%>
      </script>
    </body>
</html>
