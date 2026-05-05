<%-- 
    Document   : Notificacion
    Created on : 14-Mayo-2024, 14:21:18
    Author     : JVaras
--%>

<%@page contentType="text/html" %>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String codigo = (String) session.getAttribute("cod");
//int codigo2 = 2;// Integer.parseInt(codigo);
    String cargo = (String) session.getAttribute("cargo");
    String fechaIngreso = request.getParameter("fechaIngreso");
    String compania = request.getParameter("compania");
    String nombres = request.getParameter("nombres");
     String apellidos = request.getParameter("apellidos");
     String jefeInmediato = request.getParameter("jefeInmediato");
     String actividades = request.getParameter("actividades");
     String ubicacion = request.getParameter("ubicacion");
      String nuevoCorreo = request.getParameter("nuevoCorreo");
       String lugar = request.getParameter("lugar");
      String rol = request.getParameter("rol");
      String kit = request.getParameter("kit");
      String observaciones= nuevoCorreo + lugar  ;
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
        }
     %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Actualiza Contrasena</title>
        <link rel="shorcut icon" href="image/logo.png">
    </head>
    <body>
        <%
            
                     int idnotificaciones =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(idnotificaciones),0)+1 secuencia from ADM_NOTIFICACIONES";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idnotificaciones = rs.getInt(1);           
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
            String insertNotificacion = "INSERT INTO ADM_NOTIFICACIONES VALUES (" + idnotificaciones + ", to_date('" + fechaIngreso + "', 'yyyy/mm/dd'), '" + compania + "', '" + nombres + "', '" + apellidos + "', '" + rol + "', '" + jefeInmediato + "', '" + actividades + "', " + codigo + ", 'PENDIENTE', SYSDATE, '" + observaciones + "', '" + kit + "')";

//           String insertNotificacion = "INSERT INTO ADM_NOTIFICACIONES VALUES ("+idnotificaciones+", to_date(' "+fechaIngreso+" ','dd/mm/yyyy') , '" +compania+'",'" +nombres+'", '" +apellidos+'", '" +rol+'", '"+jefeInmediato+'", '"+actividades+'", " +codigo+",'PENDIENTE',SYSDATE )"; 
            PreparedStatement st2 = cn2.prepareStatement(insertNotificacion);
            ResultSet rs2 = st2.executeQuery();
//            r = rs2.rowInserted();

            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
            %>
                  
          <script type="text/javascript">
            location.href = 'Proyectos/PRO_NuevoEjecutivo.jsp';
         </script>
            <%
        }catch(Exception e){

             e.printStackTrace();
            }

           %>
        
           
         
    </body>
</html>
