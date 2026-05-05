<%-- 
    Document   : Insertar EQUIPO
    Created on : 26-Febrero-2019, 10:43:59
    Author     : Jquinde
--%>

<%@page import="java.util.Date"
        import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*, java.util.*" %>
<%--<%@page import="javax.servlet.http.*" %>--%>
<%@page import="org.apache.commons.fileupload.*" %>
<%@page import="org.apache.commons.fileupload.disk.*" %>
<%@page import="org.apache.commons.fileupload.servlet.*" %>
<%@page import="org.apache.commons.io.output.*" %>
<%@page import = "jakarta.servlet.ServletException" %>
<%@page import= "jakarta.servlet.annotation.WebServlet" %>
<%@page import ="jakarta.servlet.http.HttpServlet" %>
<%@page import ="jakarta.servlet.http.HttpServletRequest" %>
<%@page import ="jakarta.servlet.http.HttpServletResponse" %>
<%@page import ="jakarta.servlet.http.HttpSession" %>
    

<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%      
    String fechaini = request.getParameter("fecha");
    String ubicacionoficina = request.getParameter("ubicacion");
    String departamento = request.getParameter("departamento");
    String marca = request.getParameter("marca");
    String modelo = request.getParameter("modelo");
    String serial = request.getParameter("serial");
    String procesador = request.getParameter("procesador");
    String hdd = request.getParameter("hdd");
    String ram = request.getParameter("ram");
    String pantalla = request.getParameter("pantalla");
    String observaciones = request.getParameter("observaciones");
    String empresa = request.getParameter("empresa");
    String dispositivo = request.getParameter("dispositivo");
    
    
    Date td = new Date();                                        
    String b = new String("");
    String hour = new String("");
    String hourFichero = new String("");
    SimpleDateFormat format = new SimpleDateFormat("YYY-MM-dd");
    SimpleDateFormat formatHourFichero = new SimpleDateFormat("hhmmss");
    SimpleDateFormat formatHour = new SimpleDateFormat("hh:mm:ss");
    b = format.format(td);
    hour = formatHour.format(td);
    hourFichero = formatHourFichero.format(td);
    ArrayList<String> parameters = new ArrayList<String>();    
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
        if(cargo.equals("JEFE")||cargo.equals("ASISTENTE")){
           
        }else{
         response.sendRedirect("sesionInvalida.jsp");
        }
//        getParameter
//    String uploadfile = request.getParts("uploadfile");  
    
//    FileItemFactory factory = new DiskFileItemFactory();
//    ServletFileUpload upload = new ServletFileUpload(factory);
    // req es la HttpServletRequest que recibimos del formulario.
    // Los items obtenidos serán cada uno de los campos del formulario,
    // tanto campos normales como ficheros subidos.
//    List items = upload.parseRequest(request);
    String key="";
    String valor="";
    String ruta="";
//    int i=0;
    // Se recorren todos los items, que son de tipo FileItem
//    for (Object item : items) {
//       FileItem uploaded = (FileItem) item;

       // Hay que comprobar si es un campo de formulario. Si no lo es, se guarda el fichero
       // subido donde nos interese
//       if (!uploaded.isFormField()) {
          // No es campo de formulario, guardamos el fichero en algún sitio
//          ruta = application.getRealPath("/image/promanet/inventario/");
//          File fichero = new File(ruta, hourFichero+""+uploaded.getName());
//          key=hourFichero+""+uploaded.getName();
//          uploaded.write(fichero);
//       } else {
          // es un campo de formulario, podemos obtener clave y valor
//          parameters.add(uploaded.getString());
//          
//       }
       
//    }    
   %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Insertar Equipo</title>
    </head>
    <body>
        <p>
            <%=fechaini%>
        </p>
        <%   
        String idEquipo ="";
        String esta ="D";
        if(dispositivo.equals("Laptop")){
            esta ="D";
        }else{
            esta ="I";
        }            
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sql = "select nvl(max(IDINVEQUIPO),0)+1 secuencia from INV_EQUIPOS";
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                 idEquipo = rs.getString(1);           
             }     
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }     
        String sql2="";        
        
        
        sql2="insert into INV_EQUIPOS (IDINVEQUIPO, FECHACOMPRA,UBICACIONOFICINA,DEPARTAMENTO,MARCA,MODELO,SERIAL,PROCESADOR,HDD,RAM, PANTALLA,OBSERVACIONES,ESTADO,EMPRESA, DISPOSITIVO,ESTADO_AI,FICHERO) "
                    + "VALUES ("+idEquipo
                    +", to_date('"+fechaini+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss'),"
                    +"'"+ubicacionoficina+"','"+departamento+"','"+marca+"','"+modelo+"','"+serial+"','"+procesador+"','"+hdd+"','"+ram+"','"+pantalla+"','"+observaciones+"','"+esta+"','"+empresa+"','"+dispositivo+"','A','"+key+"')";
        
//            sql2="insert into INV_EQUIPOS (IDINVEQUIPO, FECHACOMPRA,UBICACIONOFICINA,DEPARTAMENTO,MARCA,MODELO,SERIAL,PROCESADOR,HDD,RAM, PANTALLA,OBSERVACIONES,ESTADO,EMPRESA, DISPOSITIVO,ESTADO_AI,FICHERO) "
//                    + "VALUES ("+idEquipo
//                    +", to_date('"+parameters.get(0)+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss'),"
//                    +"'"+parameters.get(2)+"','"+parameters.get(3)+"','"+parameters.get(5)+"','"+parameters.get(6)+"','"+parameters.get(7)+"','"+parameters.get(8)+"','"+parameters.get(9)+"','"+parameters.get(10)+"','"+parameters.get(11)+"','"+parameters.get(12)+"','"+esta+"','"+parameters.get(1)+"','"+parameters.get(4)+"','A','"+key+"')";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql2);
            %> 
            <p> <%=sql2%></p>
            <%
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();            
    %> 
        <script type="text/javascript" class="init">
            alert("Equipo Insertado Correctamente!!");
        </script>
        <%}catch(Exception e){
             e.printStackTrace();
        }%>
        
        
        <script type="text/javascript" class="init">
            
//            location.href = 'INV_ListadoEquipo.jsp'
        </script>
    </body>
</html>
