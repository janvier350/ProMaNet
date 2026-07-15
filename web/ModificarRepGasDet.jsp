<%-- 
    Document   : Modificar Detalle de Reporte de Gasto 
    Created on : 12-Apr-2017, 09:56:42
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idDet = request.getParameter("idDet");
    String idCab = request.getParameter("idCab");
    String mesCab = request.getParameter("mesCab");
    String detalle = request.getParameter("fecha");
    String [] fechaArray = detalle.split("-");
    String Mes = fechaArray[1];
    int mescab = Integer.parseInt(mesCab);
    int mes =Integer.parseInt(Mes);
    String alim = request.getParameter("alimentacion");
    String trans = request.getParameter("transporte");
    String trabajo = request.getParameter("trabajo");
    double alimenta=Double.parseDouble(alim);
    double transport=Double.parseDouble(trans);
    double val = alimenta+Double.parseDouble(trans);
    String clie = request.getParameter("cliente");
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
        if (!COMUN.PermisoHelper.tiene(session, "REPORTE_GASTOS_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modificar Datos</title>
    </head>
    <body>
         <%                      
            if(mescab==mes){
            String sql = "update REPGASDET set TOTALIM ="+alimenta+", TOTMOVI ="+transport+", VALOR = "+val+",TRABREALIZADO = '"+trabajo+"' , FECHA = '"+detalle+"', IDCLIENTE = "+clie+" WHERE IDREPGASDET = "+idDet;
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
        <% }%> 
        <script type="text/javascript">
            var str = <%=idCab%>+"&mes="+<%=mescab%>+"&flag=2"
            location.href = 'ReporteDetalleModal.jsp?id='+str;
        </script>
    </body>
</html>
