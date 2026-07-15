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
    String idcabtarea  = request.getParameter("Trabajo");
    String area = request.getParameter("area");
    String cliente = request.getParameter("cliente");
    String Descripcion = request.getParameter("Descripcion");
    String Comentario = request.getParameter("Comentario");
    String grupo = request.getParameter("grupo");
    
    String CompromisoValor = request.getParameter("CompromisoValor");
    
     String idjefeasig = request.getParameter("idJefeAsignado"); //responsable
     String idEncargado1 =request.getParameter("idEncargado1"); 
     String idEncargado2 =request.getParameter("idEncargado2");
     
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
         return;
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
            String sql = "select nvl(max(IDTODOCAB),0)+1 secuencia from TODOCABTRAB";
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
        String sql2 = "insert into TODOCABTRAB values ("
        +idCAB+","+codigo+",'"+CompromisoValor+"','"+trabajo
        +"', to_date('"+fechaini+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), "
        + " to_date('"+fechafin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+b+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+fechaleg+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " 
        + " to_date('"+fechacont+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), " +cliente+" , 'A' , '"+Comentario+"' , "+area+" , 'P',"+grupo+","+idjefeasig+","+idcabtarea+")";
        boolean r= true;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st2 = cn2.prepareStatement(sql2);
            ResultSet rs2 = st2.executeQuery(); 
            %>
           <h1> <%=sql2%> </h1>
         <%   r = rs2.rowInserted();
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        }catch(Exception e){
             e.printStackTrace();
        }%> 
    
         <script type="text/javascript">
             location.href = 'Proyectos/PRO_Dashboard.jsp'
//            location.href = 'TODO_Cab_Trabajo.jsp';
         </script>
    </body>
</html>
