/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Servlets;


import java.sql.*;
import java.util.Vector;
/**
 *
 * @author Janvier
 */
public class Sql {
    
    static public String ejecuta(String sql){
        String mensaje=null;
        
        try {
            Conexion db = new Conexion();
            Connection cn = db.getConnection();
             String men = db.mensaje();
             
            if(cn == null){
                //mensaje = "No hay conexión";
                mensaje = men;
            }else{
                Statement st = cn.createStatement();
                st.execute(sql);
                st.close();
                cn.close();
            }
        } catch(SQLException e){
            mensaje = e.getMessage();
        } catch (Exception e) {
            mensaje = e.getMessage();
        }
        
        return mensaje;
    }
    
    
    static public Vector consulta(String sql){
        Vector regs = new Vector();
        
        try {
            Conexion  db= new Conexion();
            Connection cn = db.getConnection();
            
            if(cn == null){
                regs = null;
                
            }else{
                Statement   st= cn.createStatement();
                ResultSet   rs = st.executeQuery(sql);
                ResultSetMetaData rm= rs.getMetaData();
                int numCols = rm.getColumnCount();
                
                String[] titCols = new String[numCols];
                
                for(int i=0; i<numCols; ++i)
                    titCols[i]= rm.getColumnName(i+1);
                
                regs.add(titCols);
                
                while(rs.next()){
                    String[] reg= new String[numCols];
                    
                    for(int i=0; i<numCols; ++i){
                        reg[i] = rs.getString(i+1);
                    }
                    
                    regs.add(reg);
                }
                
                rs.close();
                st.close();
                cn.close();
            }
        } catch (SQLException e) {
            regs = null;
        }catch (Exception e) {
            regs = null;
        }
    return regs;
    }
    
    static public String[] getFila(String sql){
        Vector vector = consulta(sql);
        String[] fila= null;
        
        if(vector!=null)
            if(vector.size()>1)
                fila = (String[]) vector.get(1);
        
        return fila;
    }
    
    static public String getCampo(String sql){
        String[] fila = getFila(sql);
        String campo = null;
        
        if(fila!=null)
            campo = fila[0];
        
            
          return campo;
        
    
    }
}
