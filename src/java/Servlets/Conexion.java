    /*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Servlets;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 *
 * @author Janvier
 */
public class Conexion {

    public static String driver = "oracle.jdbc.driver.OracleDriver";

    // Valores por defecto: base LOCAL de produccion.
    // En la nube se sobrescriben con el archivo externo db.properties
    // (ver bloque static de abajo), asi el mismo codigo/WAR sirve en ambos
    // ambientes sin editar nada.
    public static String url  = "jdbc:oracle:thin:@181.198.203.205:1521:xe";
    public static String user = "RRHH";
    public static String pass = "RRHH";

    static {
        // Si existe un archivo de configuracion externo, sus valores mandan.
        // Ubicacion: -Dpromanet.db.config=<ruta>  o  /opt/promanet/db.properties
        try {
            String ruta = System.getProperty("promanet.db.config", "/opt/promanet/db.properties");
            File f = new File(ruta);
            if (f.exists()) {
                Properties p = new Properties();
                FileInputStream in = new FileInputStream(f);
                try {
                    p.load(in);
                } finally {
                    in.close();
                }
                url  = p.getProperty("db.url",  url);
                user = p.getProperty("db.user", user);
                pass = p.getProperty("db.pass", pass);
                System.out.println("Conexion: configuracion cargada desde " + ruta);
            }
        } catch (Exception e) {
            System.out.println("Conexion: no se pudo cargar config externa, uso valores por defecto. " + e);
        }
    }


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
