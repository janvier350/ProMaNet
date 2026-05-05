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
    String fechaini = request.getParameter("fechaini");
    String fechafin = request.getParameter("fechafin");
    String fechaleg = request.getParameter("fechaleg");
    String fechacont = request.getParameter("fechacont");
    String trabajo = request.getParameter("Trabajo");
    String area = request.getParameter("area");
    String cliente = request.getParameter("cliente");
    String Descripcion = request.getParameter("Descripcion");
    String Comentario = request.getParameter("Comentario");
    String grupo = request.getParameter("grupo");
    String idJefe = request.getParameter("idJefe");
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
        if(cargo.equals("ADMINISTRADOR")||cargo.equals("ASISTENTE")||cargo.equals("PASANTE")||cargo.equals("CONTRALOR")||cargo.equals("JEFE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
   %>
   
<!DOCTYPE html>
<html>
    <head>
        <title>Insertar Todo Cabecera</title>
    </head>
    <body>
     <%                      
        Date td = new Date();                                        
        String b = new String("");
        SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
        b = format.format(td);
        int idCAB =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDTODOCABINDV),0)+1 secuencia from TODOCABTRABINDV";
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

        String insert = "INSERT INTO TODOCABTRABINDV (IDTODOCABINDV, IDUSUARIO, DESCRIPCION, TRABAJO, FECHAINICIO, FECHAFIN, FECHAHORAASIG, FECHALEGAL, FECHACONTRATO, IDCLIENTE, ESTADO, COMENTARIO, IDTODOAREA, ESTTRAB, IDJEFEASIG) VALUES ("
        +idCAB+", "
        +codigo+", '"+Descripcion+"', '"+trabajo+"', TO_DATE('2021-11-11 16:38:24', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-11-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-11-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-11-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-11-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), " +cliente+" , 'A', '"+Comentario+"',"+area+", 'PENDIENTE', "+idJefe+")"; 

        String sql2 = "insert into TODOCABTRABINDV values ("
        +idCAB+","+codigo+",'"+Descripcion+"','"+trabajo
        +"', to_date('"+fechaini+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), "
        + " to_date('"+fechafin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+b+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+fechaleg+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+fechacont+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " +cliente+" , 'A' , '"+Comentario+"' , "+area+" , 'PENDIENTE',"+idJefe+")";
        boolean r= true;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st2 = cn2.prepareStatement(sql2);
            ResultSet rs2 = st2.executeQuery(); 
            r = rs2.rowInserted();
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        }catch(Exception e){
             e.printStackTrace();
        }%> 
         <script type="text/javascript">
            location.href = 'TODO_TRABAJO_INDIVIDUAL_JV.jsp';
         </script>
    </body>
</html>
