package COMUN;

import Servlets.Conexion;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Set;

public class PermisoHelper {

    public static Set<String> cargarPermisos(int idUsuario, int idRol) {
        return cargarPermisos(idUsuario, idRol, null);
    }

    /**
     * Resuelve los permisos de un usuario en tres capas, de mas general a
     * mas especifica: 1) por cargo (APP_ROL_PERMISO), 2) por departamento
     * (APP_DEPARTAMENTO_PERMISO, para restringir o ampliar un departamento
     * entero sin tocar cargos), 3) por usuario individual
     * (APP_USUARIO_PERMISO, la mas especifica: siempre gana al final).
     */
    public static Set<String> cargarPermisos(int idUsuario, int idRol, String departamento) {
        Set<String> permisos = new HashSet<>();

        try (Connection cn = Conexion.getConnection()) {
            if (cn == null) return permisos;

            // Cada capa se resuelve en su propio try/catch: si una capa falla
            // (por ejemplo, APP_DEPARTAMENTO_PERMISO todavia no existe porque
            // no se ha corrido ese script), las demas capas igual se aplican
            // en vez de abortar por completo (antes una falla en el paso 2
            // dejaba sin efecto tambien el paso 3, las concesiones individuales).
            try {
                String sqlRol = "SELECT p.CODIGO FROM APP_ROL_PERMISO rp " +
                                 "JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO " +
                                 "WHERE rp.IDROL = ? AND p.ESTADO = 'A'";
                try (PreparedStatement st = cn.prepareStatement(sqlRol)) {
                    st.setInt(1, idRol);
                    try (ResultSet rs = st.executeQuery()) {
                        while (rs.next()) permisos.add(rs.getString(1));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (departamento != null && !departamento.trim().isEmpty()) {
                try {
                    String sqlDepto = "SELECT p.CODIGO, dp.TIPO FROM APP_DEPARTAMENTO_PERMISO dp " +
                                       "JOIN APP_PERMISO p ON dp.ID_PERMISO = p.ID_PERMISO " +
                                       "WHERE UPPER(dp.DEPARTAMENTO) = UPPER(?) AND p.ESTADO = 'A'";
                    try (PreparedStatement st = cn.prepareStatement(sqlDepto)) {
                        st.setString(1, departamento.trim());
                        try (ResultSet rs = st.executeQuery()) {
                            while (rs.next()) {
                                String codigo = rs.getString(1);
                                String tipo = rs.getString(2);
                                if ("D".equals(tipo)) {
                                    permisos.remove(codigo);
                                } else {
                                    permisos.add(codigo);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            try {
                String sqlUsuario = "SELECT p.CODIGO, up.TIPO FROM APP_USUARIO_PERMISO up " +
                                     "JOIN APP_PERMISO p ON up.ID_PERMISO = p.ID_PERMISO " +
                                     "WHERE up.IDUSUARIO = ? AND p.ESTADO = 'A'";
                try (PreparedStatement st = cn.prepareStatement(sqlUsuario)) {
                    st.setInt(1, idUsuario);
                    try (ResultSet rs = st.executeQuery()) {
                        while (rs.next()) {
                            String codigo = rs.getString(1);
                            String tipo = rs.getString(2);
                            if ("D".equals(tipo)) {
                                permisos.remove(codigo);
                            } else {
                                permisos.add(codigo);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return permisos;
    }

    @SuppressWarnings("unchecked")
    public static boolean tiene(HttpSession session, String codigo) {
        Object o = session.getAttribute("permisos");
        if (!(o instanceof Set)) return false;
        Set<String> permisos = (Set<String>) o;
        // Quien tiene SUPERADMIN_ACCESO_TOTAL pasa cualquier chequeo de permiso,
        // sin importar el codigo pedido. Reemplaza los antiguos hardcodes de
        // nombre/apellido esparcidos por el codigo (ej. "Varas Herrera").
        if (permisos.contains("SUPERADMIN_ACCESO_TOTAL")) return true;
        return permisos.contains(codigo);
    }
}
