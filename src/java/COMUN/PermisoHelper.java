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
        Set<String> permisos = new HashSet<>();

        try (Connection cn = Conexion.getConnection()) {
            if (cn == null) return permisos;

            String sqlRol = "SELECT p.CODIGO FROM APP_ROL_PERMISO rp " +
                             "JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO " +
                             "WHERE rp.IDROL = ? AND p.ESTADO = 'A'";
            try (PreparedStatement st = cn.prepareStatement(sqlRol)) {
                st.setInt(1, idRol);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) permisos.add(rs.getString(1));
                }
            }

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

        return permisos;
    }

    @SuppressWarnings("unchecked")
    public static boolean tiene(HttpSession session, String codigo) {
        Object o = session.getAttribute("permisos");
        if (!(o instanceof Set)) return false;
        return ((Set<String>) o).contains(codigo);
    }
}
