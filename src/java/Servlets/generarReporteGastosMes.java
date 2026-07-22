package Servlets;


import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import static java.lang.System.out;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

 import java.sql.*;


import java.sql.Connection;
import java.sql.DriverManager;
  import java.sql.ResultSet;
/**
 *
 * @author Backup
 */
@WebServlet(urlPatterns = {"/generarReporteGastosMes"})
public class generarReporteGastosMes extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(true);
 
    String codigo = (String) session.getAttribute("cod");
    String cargo = (String) session.getAttribute("cargo");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = (String) session.getAttribute("url");
    url = new String(""+ip);
    int numeroC=0;
    int numero=0;
    int idDet =0;
    String sql ="";
    String mes ="";
     int sigueCab = 0;
     int secuenciaCab =0;
     
    double totalAlimentMovil =0;
    
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
        
        
       
        
        
        int existe = 0 ;
        
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String consulta = "select * from rep_gascab WHERE idusuario = "+codigo+" and extract(MONTH from fecha) = EXTRACT(month from sysdate)";
//          String consulta = "SELECT CASE WHEN COUNT(*) > 0 THEN 'TRUE' ELSE 'FALSE' END AS tiene_registros FROM rep_gascab WHERE idusuario = "+codigo+" AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE)";
            PreparedStatement st = cn.prepareStatement(consulta);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                existe = rs.getInt(1); 
             }  
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        
      
        
        // Obtener la fecha actual
        Date currentDate = new Date();

        // Obtener el año actual
        int year = Calendar.getInstance().get(Calendar.YEAR);

        // Obtener el mes actual
        int month = Calendar.getInstance().get(Calendar.MONTH) + 1; // Se suma 1 porque en Calendar, enero es 0

        // Obtener la cantidad de días en el mes actual
        int daysInMonth = obtenerDiasEnMes(year, month);
        
         out.println("<p>Fecha actual: " + formatDate(currentDate) + "</p>");
        out.println("<p>Año actual: " + year + "</p>");
      
        out.println("<p>Mes actual: " + month + "</p>");
        out.println("<p>Días en el mes: " + daysInMonth + "</p>");
        out.println("<p>Día de la semana: " + obtenerDiaSemana(currentDate) + "</p>");
        
        out.println("<p>*********  Generando dias del mes  "+month+"</p>");  
        out.println("<p>"+existe+"</p>");
         out.println("</body></html>");
         
       
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet generarReporteGastosMes</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet generarReporteGastosMes at " + request.getContextPath() + "</h1>");
            
            
            
            
            
            
            out.println("<p>Fecha actual: " + formatDate(currentDate) + "</p>");
             
            out.println("<p>Año actual: " + year + "</p>");
//        if (month == 3) {
//            out.println("<p>Mes actual: Marzo </p>");
//             mes ="03";
//        }
        
//         if (month == 4) {
//            out.println("<p>Mes actual: Abril </p>");
//        }
        
        out.println("<p>Mes actual: " + month + "</p>");
        out.println("<p>Días en el mes: " + daysInMonth + "</p>");
        out.println("<p>*********  Generando dias del mes  "+month+"</p>");

            for( numeroC = 1; numeroC <= daysInMonth; numeroC = numeroC +1){
            out.println("<p>Dia numero c: " + numeroC + "</p>");
            String dia = String.valueOf(numeroC);
            String fecha = String.valueOf(month);
            String ano = String.valueOf(year);

            String cadena = dia +"/"+mes+"/"+ano ;       
            int sigue = 0;
           
//            inicio insertar cabecera
              if(existe == 0){
                     
                      int idCAB =0;
         try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
             sql = "select nvl(max(IDREPGASCAB),0)+1 secuencia from REP_GASCAB";
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
         
                      
                     
                   sql ="INSERT INTO rep_gascab  VALUES ("+secuenciaCab+","+codigo+", to_date(' "+cadena+" ','dd,mm,yyyy'),0,'S') ";
                    
                    try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn2 = DriverManager.getConnection(url, user, pass);
                        PreparedStatement st2 = cn2.prepareStatement(sql);
                        ResultSet rs2 = st2.executeQuery(); 
                        cn2.commit();
                        rs2.close();
                        st2.close();
                        cn2.close();
                    }catch(Exception e){
                         e.printStackTrace();
                    }
                  
                  
              
       }else{
                  sigue = secuencia( sigue);
      
       }
            
            
            
            
             out.println("<p>Dia: " + sigue + "</p>");    
            //sql ="INSERT INTO rep_gasdet  VALUES ("+sigue+",71,to_date('31/03/2024', 'dd,mm,yyyy'),1000,'probando un insert desde oracle probando fecha insert',100,150,9)";
               sql ="INSERT INTO rep_gasdet  VALUES ("+sigue+",1, to_date(' "+cadena+" ','dd,mm,yyyy'),5,'Reporte de gastos',3.5,1.5,"+sigueCab+") ";
                    out.println("<p>Dia: " + sql + "</p>");    
                    try{
                        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                        Connection cn2 = DriverManager.getConnection(url, user, pass);
                        PreparedStatement st2 = cn2.prepareStatement(sql);
                        ResultSet rs2 = st2.executeQuery(); 
                        cn2.commit();
                        rs2.close();
                        st2.close();
                        cn2.close();
                    }catch(Exception e){
                         e.printStackTrace();
                    }
         }
            
//            suma alimentacion y movilizacion     
     try{
                            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                            Connection cn = DriverManager.getConnection(url, user, pass);
                            String sumaTotal = "SELECT SUM(totalim) AS suma_totalim,sum(totmovi) as suma_totamovi  from rep_gasdet where idrepgascab = 9 AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE)";
                            PreparedStatement st = cn.prepareStatement(sumaTotal);
                            ResultSet rs = st.executeQuery();       
                            while (rs.next()) {
                             totalAlimentMovil = Double.valueOf(rs.getFloat(1))  +  Double.valueOf(rs.getFloat(2));
                         }
                        rs.close();
                        st.close();
                        cn.close();
                            }catch(Exception e){
                            e.printStackTrace();}
        
       
     
     String suma = "update rep_gascab set TOTAL ="+totalAlimentMovil+" WHERE IDUSUARIO = "+codigo+" ";
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            PreparedStatement st = cn.prepareStatement(suma);
            ResultSet rs = st.executeQuery(); 
            cn.commit();
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
                    
        out.println("<p>Día de la semana: " + obtenerDiaSemana(currentDate) + "</p>");
        
            out.println("</body>");
            out.println("</html>");
            response.sendRedirect("ReporteGastos/ReporteGastosIndivi.jsp");
        }
    }
    
    public static String url = Conexion.url;
    public static String user = Conexion.user;
    public static String pass = Conexion.pass;
    double totalAlimentMovil ;
    
 
    
    
    private  int secuencia(int secuencia) {      
        try{
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);
            String sqliDdET = "select nvl(max(IDREPGASDET),0)+1 secuencia from REP_GASDET";
            PreparedStatement st = cn.prepareStatement(sqliDdET);
            ResultSet rs = st.executeQuery();       
            while (rs.next()) {
                secuencia = rs.getInt(1); 
             }  
            rs.close();
            st.close();
            cn.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        return secuencia;
    }
     
    
    private int obtenerDiasEnMes(int year, int month) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, year);
        calendar.set(Calendar.MONTH, month - 1); // Restar 1 porque en Calendar, enero es 0
        return calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
    }

    private String formatDate(Date date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
        return dateFormat.format(date);
    }
    
    
    private String obtenerDiaSemana(Date date) {
        SimpleDateFormat dayFormat = new SimpleDateFormat("EEEE");
        return dayFormat.format(date);
    }
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
