<%-- 
    Document   : Registro de Atraso
    Created on : 11-Apr-2017, 14:21:18
    Author     : Jvaras
--%>

<%@page contentType="text/html" %>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idEjecutivo = (String) session.getAttribute("cod");
    String cargo = (String) session.getAttribute("cargo");
  
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String motivo = request.getParameter("motivo");
    
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
        
        <title>Registrar Atraso</title>
        <link rel="shorcut icon" href="image/logo.png">
    </head>
    <body>
        <%
                int id_rep_biom_atraso =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(id_rep_biom_atraso),0)+1 secuencia from rep_biom_atraso";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 id_rep_biom_atraso = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
          try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
           String insertAgenda = "INSERT INTO rep_biom_atraso VALUES ("+id_rep_biom_atraso+", "+idEjecutivo+", SYSDATE,  " +motivo+" ,'A','N/A' )"; 
            PreparedStatement st2 = cn2.prepareStatement(insertAgenda);
            ResultSet rs2 = st2.executeQuery(); 
//            r = rs2.rowInserted();
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        }catch(Exception e){
             e.printStackTrace();
        }%> 
        
        <script type="text/javascript" class="init">
//             alert("Atraso Ingresado Correctamente! ")
         location.href = '../ProMaNet/Proyectos/PRO_Dashboard.jsp';
         </script>
        
    </body>
</html>
