<%-- 
    Document   : Modificar EQUIPO
    Created on : 28-Feb-2019, 14:56:42
    Author     : Jquinde
--%>

<%@page import="java.sql.*"
        import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<%@page import="org.apache.commons.fileupload.*" %>
<%@page import="org.apache.commons.fileupload.disk.*" %>
<%@page import="org.apache.commons.fileupload.servlet.*" %>
<%@page import="org.apache.commons.io.output.*" %>

<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%  String cargo = (String) session.getAttribute("cargo");
    String idInvEquipo = request.getParameter("idInvEquipo");
//    String fecha = request.getParameter("fecha");
//    String empresa = request.getParameter("empresa");
//    String ubicacion = request.getParameter("ubicacion");
//    String departamento = request.getParameter("departamento");
//    String dispositivo = request.getParameter("dispositivo");
//    String marca = request.getParameter("marca");
//    String modelo = request.getParameter("modelo");
//    String serial = request.getParameter("serial");
//    String procesador = request.getParameter("procesador");
//    String hdd = request.getParameter("hdd");
//    String ram = request.getParameter("ram");
//    String pantalla = request.getParameter("pantalla");
//    String observaciones = request.getParameter("observaciones");
//    String estado = request.getParameter("estado");
//    String idusuario = request.getParameter("idusuario");
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
    String uploadfile = request.getParameter("uploadfile");  
    
    FileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);
    // req es la HttpServletRequest que recibimos del formulario.
    // Los items obtenidos serán cada uno de los campos del formulario,
    // tanto campos normales como ficheros subidos.
    List items = upload.parseRequest(request);
    String key="";
    String valor="";
    String ruta="";
    int i=0;
    // Se recorren todos los items, que son de tipo FileItem
    for (Object item : items) {
       FileItem uploaded = (FileItem) item;

       // Hay que comprobar si es un campo de formulario. Si no lo es, se guarda el fichero
       // subido donde nos interese
       if (!uploaded.isFormField()) {
          // No es campo de formulario, guardamos el fichero en algún sitio
          ruta = application.getRealPath("/image/promanet/inventario/");
          File fichero = new File(ruta, hourFichero+""+uploaded.getName());
          key=hourFichero+""+uploaded.getName();
          uploaded.write(fichero);
       } else {
          // es un campo de formulario, podemos obtener clave y valor
          parameters.add(uploaded.getString());
          
       }
       
    }    
   %>
<!DOCTYPE html>
<html>
    <head>
        
        <title>Modificar Equipo</title>
    </head>
    <body>
         <%   
         String sql3="";       
         String sql = "update INV_EQUIPOS "
                 + "set FECHACOMPRA = "
                 +" to_date('"+parameters.get(0)+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss'), UBICACIONOFICINA = '"+parameters.get(2) +"', DEPARTAMENTO= '"+parameters.get(3)+"', MARCA= '"+parameters.get(5)
                 +"', MODELO= '"+parameters.get(6)+"', SERIAL= '"+parameters.get(7)+"', PROCESADOR= '"+parameters.get(8)+"', HDD= '"+parameters.get(9)+"', RAM= '"+parameters.get(10)+"', PANTALLA= '"+parameters.get(11)+"', OBSERVACIONES= '"+parameters.get(15)
                 +"', ESTADO= '"+parameters.get(12)+"', EMPRESA= '"+parameters.get(1)+"', DISPOSITIVO= '"+parameters.get(4)+"', FICHERO= '"+key +"' WHERE IDINVEQUIPO = "+idInvEquipo;
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(sql);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        if(parameters.get(12).equals("A")){
            
        }else {
                   
            sql3="UPDATE INV_ASIGNACION SET ESTADO ='I',FECHADEVOLUCION= "
            +" to_date('"+b+" "+hour+"', 'yyyy/mm/dd hh24:mi:ss')  WHERE IDINVEQUIPO = "+idInvEquipo+" and idusuario ="+parameters.get(14) + " and estado ='A'";
            try{
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn3 = DriverManager.getConnection(url, user, pass);
                PreparedStatement st3 = cn3.prepareStatement(sql3);
                ResultSet rs3 = st3.executeQuery(); 
                cn3.commit();
                rs3.close();
                st3.close();
                cn3.close();
            }catch(Exception e){
                 e.printStackTrace();
            }   
        } 
         %>          
        <script type="text/javascript" class="init">
            alert("Equipo Editado Correctamente!!")
        </script>        
        <script type="text/javascript">
            location.href = 'INV_ListadoEquipo.jsp';
        </script>
    </body>
</html>
