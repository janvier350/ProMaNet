package VACACIONES;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

// Consulta si esta abierta la ventana para registrar vacaciones ya
// gozadas (VAC_RETRO_VENTANA). La ventana esta vigente si fue abierta
// (ACTIVA = 'S') y aun no pasa su fecha limite; el dia limite cuenta como
// habilitado. Si la tabla todavia no existe (script 040 sin correr) se
// responde "no habilitado": el sistema sigue en modo normal.
public class VAC_RetroHelper {

    /** Fecha limite de la ventana vigente, o null si no hay ninguna. */
    public static Date fechaLimiteVigente(Connection cn) {
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT FECHA_LIMITE FROM (SELECT FECHA_LIMITE FROM VAC_RETRO_VENTANA " +
                "WHERE ACTIVA = 'S' AND TRUNC(SYSDATE) <= TRUNC(FECHA_LIMITE) " +
                "ORDER BY ID_VENTANA DESC) WHERE ROWNUM = 1");
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return rs.getDate(1);
        } catch (Exception e) {
            // tabla inexistente u otro error: modo normal
        }
        return null;
    }

    public static boolean habilitada(Connection cn) {
        return fechaLimiteVigente(cn) != null;
    }
}
