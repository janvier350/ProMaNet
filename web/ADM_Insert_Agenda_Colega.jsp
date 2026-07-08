<%-- 
    Document   : Insertar Hijo
    Created on : 28-Mar-2018, 17:30:23
    Author     : Jonathan Quinde
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="jdk.javadoc.internal.doclets.formats.html.markup.Script"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  
    String idHijo = request.getParameter("idHijo");
    String idJefe = request.getParameter("idJefe");
    String Jefe = request.getParameter("Jefe");
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
//    ArrayList listaColegas = (ArrayList)request.getSession().getAttribute("lista");
//   
//    for(int i=0; i < listaColegas.size(); i++){
//        out.println("Saludos");
//    }
    
//    PARA GENERAR EL ID CABECERA DE DETALLE AGENDA
    int idDetAgenda =0;
    
//    PARAMETROS QUE RECIBO DE aGREGARaGENDAcOLEGA
     String idCadAgenda = request.getParameter("idRegistroAgenda"); 
     
     
     
    
    String cbm_anio = request.getParameter("cbm_anio");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insertar Colegas en Agenda</title>
    </head>
    <body>
  <script type="text/javascript" class="init">
            alert("listado de array!"+<%=idDetAgenda%>);
         
         
      
         </script>
    
           <%
//            
//            
            try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(ID_ADM_DET_AGENDA),0)+1 secuencia from ADM_DET_AGENDA";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idDetAgenda = rs.getInt(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
//        
//        String sql = "insert into REPGASASIG values"
//                    + "("+idRepAsig+","+idHijo+","+idJefe+")";
//        try{
//            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
//            Connection cn = DriverManager.getConnection(url, user, pass);
//            PreparedStatement st = cn.prepareStatement(sql);
//            ResultSet rs = st.executeQuery(); 
//            cn.commit();
//            rs.close();
//            st.close();
//            cn.close();
//        }catch(Exception e){
//             e.printStackTrace();
//        }%>

    <script type="text/javascript" class="init">
            alert("IDREGISTRO AGENDA!"+<%=idDetAgenda%>);
         
         
      
         </script>
        <script type="text/javascript" class="init">
            alert("Datos Insertados Correctamente!"+<%=idDetAgenda%>+<%=idCadAgenda%>);
          //  console.log(<%=idDetAgenda%>);
//         location.href = 'Agenda_Agregar_Colega.jsp?id=<%=idDetAgenda%>&idRA=<%=idCadAgenda%>';
         </script>
    </body>
</html>
