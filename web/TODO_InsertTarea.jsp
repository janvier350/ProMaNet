<%-- 
    Document   : Insertar Detalle de Tarea
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
    String idDetTrab = request.getParameter("idDetTrab");
    String idCabTrab = request.getParameter("idCabTrab");
    String fechaini = request.getParameter("ASISfechaini");
    String fechafin = request.getParameter("ASISfechafin");
    String detalle = request.getParameter("ASISTrabajo");
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
    if(!(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE"))){
             response.sendRedirect("sesionInvalida.jsp");
             return;
             }
%>
   
<!DOCTYPE html>
<html>
    <head>
        <title>Insertar Datos</title>
    </head>
    <body>
         <%                      
            Date td = new Date();                                        
            String b = new String("");
            SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
            b = format.format(td);
            int idTAREA =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDTODODETTAREA),0)+1 secuencia from TODODETTAREA";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idTAREA = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        String sql2 = "insert into TODODETTAREA values ("
        +idTAREA+","+idDetTrab+","
        +" to_date('"+fechaini+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), "
        + " to_date('"+fechafin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),'A','"+detalle +"') ";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st2 = cn2.prepareStatement(sql2);
            ResultSet rs2 = st2.executeQuery(); 
            
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        }catch(Exception e){
             e.printStackTrace();
        }%> 
        <script type="text/javascript">
            alert("Tarea Insertada Correctamente!")
            var str = '&idCabTrab='+<%=idCabTrab%>
            location.href = 'TODO_det_Trabajo.jsp?'+str;
        </script>
        
    </body>
</html>
