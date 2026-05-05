    /*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Servlets;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Janvier
 */
public class Conexion {
    
    public static String driver="oracle.jdbc.driver.OracleDriver";
   public static String url="jdbc:oracle:thin:@181.198.203.205:1521:xe";
 //    public static String url="jdbc:oracle:thin:@192.168.0.70:1521:xe";
    public static String user="RRHH";
    public static String pass="RRHH";
    
    
    public static Connection getConnection(){
        Connection cn=null;
        
        try {
            Class.forName(driver).newInstance();
            cn= DriverManager.getConnection(url,user,pass);
            
        } catch(SQLException e){
            System.out.println(e.toString());
            cn= null;
        
        }catch (Exception e) {
            System.out.println(e.toString());
            cn= null;
        }
    return cn;
    }
    
    public static String mensaje(){
        Connection cn=null;
        String menss = "";
        try {
            Class.forName(driver).newInstance();
           cn =DriverManager.getConnection(url,user,pass);
            
        } catch(SQLException e){
            System.out.println(e.toString());
            cn= null;
            menss = e.toString();
        
        }catch (Exception e) {
            System.out.println(e.toString());
            cn= null;
            menss = e.toString();
        }
    return menss;
    }
}
