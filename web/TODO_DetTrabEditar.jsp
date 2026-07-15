<%-- 
    Document   : Modificar Detalle de trabajo TODO
    Created on : 9-Ene-2019, 09:56:42
    Author     : Jquinde
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idCabTrab = request.getParameter("idCabTrab");
    String idDet = request.getParameter("idDet");
    String FechaInicio = request.getParameter("FechaInicio");
    String FechaFin = request.getParameter("FechaFin");    
    String Detalle = request.getParameter("Detalle");    
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
        if(!COMUN.PermisoHelper.tiene(session, "TODO_ACCESO")){
         response.sendRedirect("sesionInvalida.jsp");
         return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Modificar Datos</title>
    </head>
    <body>
         <%                      
         String sql = "update TODODETTRAB "
                 + "set detalle = '"+Detalle+"', FECHAHORAINICIO = "
                 +" to_date('"+FechaInicio+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), FECHAHORAFIN = "
                 +" to_date('"+FechaFin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss') WHERE IDTODODET = "+idDet;
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
       
        
        <script type="text/javascript">
            location.href = 'TODO_det_Trabajo.jsp?idCabTrab=<%=idCabTrab%>';
        </script>
    </body>
</html>
