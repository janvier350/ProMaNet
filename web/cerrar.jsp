<%-- 
    Document   : cerrar
    Created on : mar 29, 2017, 4:04:50 p.m.
    Author     : Janvier
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<% session.invalidate(); //cierra la session%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sistema | Cerrar Sesión</title>
        <link rel="stylesheet" href="css/bootstrap.min.css"> 
            <!--<link rel="stylesheet" href="css/portalv2.css">-->
    </head>
    <body>
         
        
    </body>
     <script type="text/javascript">
            
            location.href = 'index.jsp';
        </script>
</html>
