<%-- 
    Document   : Insertar ASIGNACION
    Created on : 26-Febrero-2019, 10:43:59
    Author     : Jquinde
--%>

<%@page import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%          
    String idInvEquipo = request.getParameter("idEquipo");
    String IDUSUARIO = request.getParameter("idUsuario");        
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
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Insertar Asignacion</title>
    </head>
    <body>
        <%
        int idAsignacion =0;
        Date td = new Date();                                        
        String b = new String("");
        String hour = new String("");
        SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
        SimpleDateFormat formatHour = new SimpleDateFormat("hh:mm:ss");
        b = format.format(td);
        hour = formatHour.format(td);
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDINV_ASIGNACION),0)+1 secuencia from INV_ASIGNACION";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idAsignacion = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
     
        String sql2="";        
            sql2="insert into INV_ASIGNACION (IDINV_ASIGNACION, IDINVEQUIPO,FECHAASIGNACION,IDUSUARIO,ESTADO) "
                    + "VALUES ("+idAsignacion+","+idInvEquipo
                    +", to_date('"+b+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss') "
                    +","+IDUSUARIO+",'A')";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql2);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
            
        String sql3="";        
            sql3="UPDATE INV_EQUIPOS SET ESTADO ='A' WHERE IDINVEQUIPO = "+idInvEquipo+" ";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn3 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st3 = cn3.prepareStatement(sql3);
            ResultSet rs3 = st3.executeQuery(); 
            cn3.commit();
            rs3.close();
            st3.close();
            cn3.close();
        }catch(Exception e){
             e.printStackTrace();
        }    
            
    %> 
        <script type="text/javascript" class="init">
            alert("Equipo Asignado Correctamente!!")
        </script>
        <%}catch(Exception e){
             e.printStackTrace();
        }%> 
        <script type="text/javascript" class="init">
            location.href = 'Inventario/INV_Equipos.jsp'
        </script>
    </body>
</html>
