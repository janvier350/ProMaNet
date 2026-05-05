<%-- 
    Document   : InsertarRepGas
    Created on : 27-Mar-2017, 18:16:59
    Author     : JQuinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>

<%  String codigo = (String) session.getAttribute("cod");
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
        if(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insertar Datos</title>
    </head>
    <body>
        <%
         int idCAB =0;
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDREPGASCAB),0)+1 secuencia from REPGASCAB";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idCAB = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
   
            int valFecha =0;
            Date  fecha = new Date();
            SimpleDateFormat mes= new SimpleDateFormat("MM");
            SimpleDateFormat ano= new SimpleDateFormat("yyyy");
            String Mes = mes.format(fecha);
            String Ano = ano.format(fecha);
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select substr(FECHA,6,2) mes, substr(FECHA,0,4) yea FROM REPGASCAB WHERE IDUSUARIO="+codigo+"and substr(FECHA,6,2) = '"+Mes+"' and substr(FECHA,0,4)='"+Ano+"'";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 valFecha = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>
    
    <%     
        String sql="";
        if(valFecha==0){   
        SimpleDateFormat formato= new SimpleDateFormat("yyyy-MM-dd");
            String FechaText = formato.format(fecha);
        if(cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
            sql = "insert into REPGASCAB values"
                    + "("+idCAB+","+codigo+",'"+FechaText+"',0,'S')";
        }else if(cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("ADMINISTRACION")){   
            sql = "insert into REPGASCAB values"
                    + "("+idCAB+","+codigo+",' "+FechaText+" ',0,'N')";
        }    

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
        }else{
            %> 
            <script type="text/javascript" class="init">
                alert("No se puede Añadir. Mes Existente!!")
            </script>
        <%}%> 
        <script type="text/javascript" class="init">
            location.href = 'ReporteGastosIndividual.jsp'
        </script>
    </body>
</html>
