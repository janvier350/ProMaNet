<%-- 
    Document   : Modificar cabecera TODO PARA XP
    Created on : 08-Agosto-2018, 09:56:42
    Author     : Jquinde
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idCab = request.getParameter("idCab");
    String FechaInicio = request.getParameter("FechaInicio");
    String FechaFin = request.getParameter("FechaFin");
    String FechaLegal = request.getParameter("FechaLegal");
    String FechaContrato = request.getParameter("FechaContrato");
    String Trabajo = request.getParameter("Trabajo");
    String Descripcion = request.getParameter("Descripcion");
    String Comentario = request.getParameter("Comentario");
    String jefe = request.getParameter("jefe");
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
         String sql = "update TODOCABTRAB "
                 + "set DESCRIPCION = '"+Descripcion+"', TRABAJO = '"+Trabajo+"', FECHAINCIO = "
                 +" to_date('"+FechaInicio+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), FECHAFIN = "
                 +" to_date('"+FechaFin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), FECHALEGAL = "
                 +" to_date('"+FechaLegal+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), FECHACONTRATO = "
                 +" to_date('"+FechaContrato+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss') "
                 + ", COMENTARIO = '"+Comentario +"', IDJEFEASIG= "+jefe +" WHERE IDTODOCAB = "+idCab;
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
            location.href = 'TODO_CabTrabXP.jsp';
        </script>
    </body>
</html>
