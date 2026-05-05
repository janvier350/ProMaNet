<%-- 
    Document   : Eliminar Equipo
    Created on : 28-Febrero-2019, 12:04:23
    Author     : Jquinde
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String idInvEquipo = request.getParameter("idInvEquipo");
    String cargo = (String) session.getAttribute("cargo");
    String estado = "I";
    String nombre = (String) session.getAttribute("nombre");
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
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <title>Eliminar Equipo</title>
    </head>
    <body>
      <% String sql = "update INV_EQUIPOS set ESTADO_AI ='"+estado+"' WHERE IDINVEQUIPO = "+idInvEquipo;
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
            alert("Equipo Eliminado Correctamente!")
            location.href = 'INV_ListadoEquipo.jsp';
         </script>
    </body>
</html>
