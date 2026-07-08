<%-- 
    Document   : Insertar detalle de trabajo
    Created on : 23-Mar-2017, 12:01:01
    Author     : Jquinde
--%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"
        import=" java.sql.Connection"
%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<% 
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String idCab = request.getParameter("idCab");
    String idCabTarea = request.getParameter(" idCabTarea1");
    String fechaini = request.getParameter("fechaini");
    String fechafin = request.getParameter("fechafin");
    String detalle = request.getParameter("Trabajo");
    String usu = request.getParameter("usuario");
    String [] usuarioArray = usu.split("-");
    String userAsig = usuarioArray[0];
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
            int idDET =0;
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDTODODET),0)+1 secuencia from TODODETTRAB";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idDET = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        String sql2 = "insert into TODODETTRAB values ("
        +idDET+","+idCab+",'"+detalle+"',"
        +" to_date('"+fechaini+" 09:00:00', 'yyyy/mm/dd hh24:mi:ss'),'A', "
        + " to_date('"+fechafin+" 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),'P') ";
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
        }
        
        int idASIG =0;
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDTODOASIGTAREA),0)+1 secuencia from TODOASIGTAREA";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idASIG = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
         
        String sql3 = "insert into TODOASIGTAREA values ("
        +idASIG+","+userAsig+","+idDET+","
        +" to_date('"+ b+" 12:00:00', 'yyyy/mm/dd hh24:mi:ss'),'A') ";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            PreparedStatement st2 = cn2.prepareStatement(sql3);
            ResultSet rs2 = st2.executeQuery(); 
            
            cn2.commit();
            rs2.close();
            st2.close();
            cn2.close();
        }catch(Exception e){
             e.printStackTrace();
        }%>   
        
        <script type="text/javascript">
            var str = <%=idCab%>
            var str2 = <%=idCabTarea%>
              alert("Trabajo Registrado Correctamente!"+<%=idCabTarea%>);
                location.href = 'Proyectos/PRO_Detalle_Trabajo.jsp?idCabTrab=' + str + '&idCabTarea=' + str2;

//            location.href = 'Proyectos/PRO_Detalle_Trabajo.jsp?idCabTrab='+str&idCabTarea=+idCabTarea;
//             location.href = 'TODO_Cab_Trabajo.jsp?idCabTrab='+str;
//            location.href = 'TODO_det_Trabajo.jsp?idCabTrab='+str;
        </script>
        
    </body>
</html>
