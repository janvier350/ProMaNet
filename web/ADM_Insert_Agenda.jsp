<%-- 
    Document   : InsertarDB
    Created on : 23-Mar-2017, 12:01:01
    Author     : Jquinde
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"
        import=" java.sql.Connection"
        %>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String codigo = (String) session.getAttribute("cod");
    String cargo = (String) session.getAttribute("cargo");
    //String fechaini = request.getParameter("fechaini");
    String idEjecutivo = request.getParameter("idEjecutivo");
    String fechAgenda = request.getParameter("fechAgenda");
    String h_inicio = request.getParameter("h_inicio");
    String h_fin = request.getParameter("h_fin");
   // String area = request.getParameter("area");
    String cliente = request.getParameter("cliente");
    String grupo = request.getParameter("grupo");
    String observacion = request.getParameter("observacion");
    //String Comentario = request.getParameter("Comentario");
   // String grupo = request.getParameter("grupo");
    //String idJefe = request.getParameter("idJefe");
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
        if (!COMUN.PermisoHelper.tiene(session, "AGENDA_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }
   %>
   
<!DOCTYPE html>
<html>
    <head>
        <title>Insertar Agenda Cabecera</title>
    </head>
    <body>
        
     
        
     <%                      
        Date td = new Date();                                        
        String b = new String("");
        SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
        b = format.format(td);
        int idCABAgenda =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(ID_ADM_CAB_AGENDA),0)+1 secuencia from ADM_CAB_AGENDA";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idCABAgenda = rs.getInt(1);           
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
           String insertAgenda = "INSERT INTO ADM_CAB_AGENDA VALUES ("+idCABAgenda+", "+idEjecutivo+", to_date( '"+fechAgenda+"', 'yyyy/mm/dd'),  '"+h_inicio+"', '"+h_fin+"' ," +cliente+" , '"+observacion+"', 'PENDIENTE','A', '"+grupo+"' )"; 
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
             alert("Datos Ingresados Correctamente! ")
         location.href = 'Agenda.jsp';
         </script>
         
<!--          <script type="text/javascript" class="init">
            alert("Datos Ingresados Correctamente! "+repetido+"erewr")
            location.href = 'FAC_Ingresos.jsp'
        </script>-->
    </body>
</html>
