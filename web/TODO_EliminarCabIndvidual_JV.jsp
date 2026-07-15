<%-- 
    Document   : Eliminar cabecera trabajo individual
    Created on : 18-octubre-2021, 15:42:23
    Author     : jvaras
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idCab = request.getParameter("idCab");
    String cargo = (String) session.getAttribute("cargo");
    String idUser = (String) session.getAttribute("cod");
    String estado = "I";

    String idCabTodoCabIndv = request.getParameter("idCabTodoCabIndv");
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
    int valida =0;    
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html ">
        <title>Eliminar Cabecera Trabaho Individual</title>
    </head>
    <body>
        <% 
            
    String sql = "update TODOCABTRABINDV set ESTADO ='"+estado+"' WHERE IDTODOCABINDV =  "+idCabTodoCabIndv+" ";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        %><script type="text/javascript" class="init">
            alert("Datos Eliminados Correctamente!   cabecera")
            location.href = 'TODO_TRABAJO_INDIVIDUAL_JV.jsp';
         </script>
         <%
        }catch(Exception e){ 
            e.printStackTrace();} 

        %>

         
    </body>
    <!-- "+idCabTrabJv+" "; -->
</html>
