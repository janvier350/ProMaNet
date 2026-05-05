<%-- 
    Document   : pdf
    Created on : 19 sept 2023, 09:02:53
    Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="net.sf.jasperreports.engine.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="javax.servlet.ServletResponse"%>
<%@page import="net.sf.jasperreports.view.JasperViewer"%>
<%@page import="java.sql.*"%> 
<%@page import="java.sql.*"%> 

<%String id = request.getParameter("id");
    String tot = request.getParameter("tot");
    String idCompa = (String) session.getAttribute("idCompa");
    String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String mes = request.getParameter("mes");
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
            <link rel="shorcut icon" href="image/logo.png">
        <title>PDF GENERATOR</title>
    </head>
    <body>
       <% 
           String logotipo ="";
      
            if (idCompa.equals("1")){
                logotipo = "/image/buadnet2020.png";    
            }else if (idCompa.equals("2")){
                logotipo = "/image/XpAudit.png";    
            }else if (idCompa.equals("3")){
                logotipo = "/image/LatiSA.png";    
            }else if (idCompa.equals("4")){
                logotipo = "/image/Arthurs.png";    
            }else if (idCompa.equals("5")){
                logotipo = "/image/norte.png"; 
            }else if (idCompa.equals("6")){
                logotipo = "/image/CTSCONSTRUCTORES.png"; 
            }
        String ali ="";
        String movi ="1";
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
        
        <%
        
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn2 = DriverManager.getConnection(url, user, pass);
            
            File reportfile = new File (application.getRealPath(""));
            
            Map <String, Object> parameter = new HashMap<String, Object>();
            byte[] bytes = JasperRunManager.runReportToPdf(reportfile.getPath(), parameter,cn2);
           %>
    </body>
</html>
