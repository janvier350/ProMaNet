<%-- 
    Document   : InsertarDB
    Created on : 23-Mar-2017, 12:01:01
    Author     : Jquinde
--%>


<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idCab = request.getParameter("id");
    String mesCab = request.getParameter("mesCab");
    String detalle = request.getParameter("fecha");
    String [] fechaArray = detalle.split("-");
    String Mes = fechaArray[1];
    int mescab = Integer.parseInt(mesCab);
    int mes =Integer.parseInt(Mes);
    String clie = request.getParameter("cliente");
//    String [] clienteArray = clie.split("-");
//    String cliente = clienteArray[0];
    String alim = request.getParameter("alimentacion");
    String trans = request.getParameter("transporte");
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
        
        <title>Insertar Reporte Gasto Detalle</title>
    </head>
    <body>
        
         <%                      
         if(mescab==mes){
         int idDet =0;
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDREPGASDET),0)+1 secuencia from REPGASDET";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idDet = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
            String trabajo = request.getParameter("trabajo");
            double alimenta=Double.parseDouble(alim);
            double transport=Double.parseDouble(trans);
            double val = alimenta+Double.parseDouble(trans);
            String sql = "insert into REPGASDET values"
                    + "("+idDet+","+clie+",'"+detalle+"',"+val+",'"+trabajo+"',"+alimenta+","+transport+","+idCab+")";
            boolean r= true;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            r = rs.rowInserted();
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        double suma =0;
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
        }
         }else{ %> 
            <script type="text/javascript" class="init">
                alert("No se puede Añadir. Mes Invalido!!")
            </script>
        <%}%> 
        <script type="text/javascript">
            var str = <%=idCab%>+"&mes="+<%=mescab%>+"&flag=2"
            location.href = 'ReporteDetalleModal.jsp?id='+str;
        </script>
    </body>
</html>
