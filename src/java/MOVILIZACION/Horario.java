package MOVILIZACION;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Horario {

    public static String sumarUnaHora(String horaInicio) {
        String[] partes = horaInicio.split(":");
        int h = Integer.parseInt(partes[0]);
        int m = Integer.parseInt(partes[1]);
        h = (h + 1) % 24;
        return String.format("%02d:%02d", h, m);
    }

    /**
     * true si existe otra solicitud PENDIENTE/APROBADA del mismo movilizador
     * y fecha cuyo rango de horas se superpone con [horaInicio, horaFin).
     * excluirId permite ignorar la propia solicitud al editarla.
     */
    public static boolean hayChoque(Connection cn, String idMovilizador, String fecha,
            String horaInicio, String horaFin, String excluirId) throws Exception {

        String sql = "SELECT COUNT(*) FROM MOV_SOLICITUD " +
                "WHERE ID_MOVILIZADOR = ? AND FECHA = TO_DATE(?,'YYYY-MM-DD') " +
                "AND ESTADO IN ('PENDIENTE','APROBADA') " +
                "AND HORA_INICIO < ? AND HORA_FIN > ?" +
                (excluirId != null ? " AND ID_MOV_SOLICITUD != ?" : "");

        try (PreparedStatement st = cn.prepareStatement(sql)) {
            st.setInt(1, Integer.parseInt(idMovilizador));
            st.setString(2, fecha);
            st.setString(3, horaFin);
            st.setString(4, horaInicio);
            if (excluirId != null) st.setInt(5, Integer.parseInt(excluirId));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
}
