<%-- 
    Document   : Generar PDF de Hijos
    Created on : 06-Apr-2017, 17:37:07
    Author     : Jquinde
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="net.sf.jasperreports.engine.*"
        import="java.io.*"
        import="java.util.*"
        import="javax.servlet.ServletResponse"
        import="net.sf.jasperreports.view.JasperViewer"
        import="java.sql.*"%>
<%String id = request.getParameter("id");
    String tot = request.getParameter("tot");
    String idCompa = "";
    String compania = "";
    String cargo = (String) session.getAttribute("cargo");
    String nombre = "";
    String apellidos = "";
    String mes = request.getParameter("mes");
    String idHijo = request.getParameter("idHijo");
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
        <title>ProMaNet| Imprime Reporte</title>
        <link rel="shorcut icon" href="image/logo.png">
    </head>
    <body>
        <%
        String ali ="";
        String movi ="";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select TO_CHAR(SUM(totalim),'FM999G990D00'), TO_CHAR(SUM(totmovi),'FM999G990D00') from repgasdet where idrepgascab = "+id+"order by idrepgascab";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 ali = rs.getString(1);           
                 movi = rs.getString(2);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select a.idusuario,a.idcompania,b.compania, c.cargo, a.nombre, a.apellidos from usuario a , COMPANIA b , rol c where a.IDUSUARIO = '"+idHijo+"' and a.IDCOMPANIA = b.IDCOMPANIA and a.IDROL = c.IDROL";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idCompa = rs.getString(2);           
                 compania = rs.getString(3);  
                 cargo = rs.getString(4);  
                 nombre = rs.getString(5);  
                 apellidos = rs.getString(6);  
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        String logotipo ="";
        
            if (idCompa.equals("1")){
                logotipo = "/image/BuadnetSA.png";    
            }else if (idCompa.equals("2")){
                logotipo = "/image/XpAudit.png";    
            }else if (idCompa.equals("3")){
                logotipo = "/image/LatiSA.png";    
            }else if (idCompa.equals("4")){
                logotipo = "/image/Arthurs.png";    
            }
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            File reportfile = new File(application.getRealPath("reporteGasto.jasper"));
            Map<String,Object> parameter=new HashMap<String,Object>(); 
            parameter.put("idCab", id);
            parameter.put("nombre", nombre+" "+apellidos);
            parameter.put("compania", compania);
            parameter.put("cargo", cargo);
            parameter.put("mes", mes);
            parameter.put("ali", ali);
            parameter.put("movi", movi);
            parameter.put("tot", tot);
            parameter.put("logo", this.getClass().getResourceAsStream(logotipo));
            byte[] bytes= JasperRunManager.runReportToPdf(reportfile.getPath(), parameter, cn);
            response.setContentType("application/pdf");
            response.setContentLength(bytes.length);
            ServletOutputStream outputstram= response.getOutputStream();
            outputstram.write(bytes,0,bytes.length);
            outputstram.flush();
            outputstram.close();
            
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        %>
    </body>
</html>
