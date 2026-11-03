package VACACIONES;

import COMUN.PermisoHelper;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

// Alcance (a quien puede gestionar) cada usuario en Vacaciones.
//
// Vacaciones se gestiona por GRUPOS de gestion (VAC_GRUPO: hoy Romeria y
// Kennedy). Cada empleado pertenece a un grupo (VAC_CONFIG_USUARIO.ID_GRUPO,
// null = "Sin asignar") y cada grupo tiene sus gestores (VAC_GRUPO_GESTOR).
// Un gestor solo ve y modifica a los empleados de sus grupos; quien tiene el
// permiso VACACIONES_GRUPOS (administrador global) ve todo, incluidos los
// "Sin asignar", y es quien asigna empleados a grupos.
//
// Los permisos VACACIONES_CONFIGURAR / VACACIONES_GESTIONAR siguen siendo la
// puerta de entrada a cada pantalla; esta clase agrega el "a quien".
public class VAC_Alcance {

    public static final String PERM_GLOBAL = "VACACIONES_GRUPOS";

    public static boolean esGlobal(HttpSession session) {
        return PermisoHelper.tiene(session, PERM_GLOBAL);
    }

    public static int idUsuario(HttpSession session) {
        try { return Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception e) { return -1; }
    }

    /** Ids de los grupos que gestiona el usuario. Si la tabla no existe, lista vacia. */
    public static List<Integer> grupos(Connection cn, int idUsuario) {
        List<Integer> r = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT g.ID_GRUPO FROM VAC_GRUPO_GESTOR g JOIN VAC_GRUPO v ON v.ID_GRUPO = g.ID_GRUPO " +
                "WHERE g.ID_USUARIO = ? AND v.ESTADO = 'A' ORDER BY g.ID_GRUPO")) {
            st.setInt(1, idUsuario);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) r.add(rs.getInt(1));
            }
        } catch (Exception e) { /* sin tabla: sin grupos */ }
        return r;
    }

    /** Grupo de gestion del empleado, o null si esta "Sin asignar". */
    public static Integer grupoDe(Connection cn, int idEmpleado) {
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_GRUPO FROM VAC_CONFIG_USUARIO WHERE ID_USUARIO = ?")) {
            st.setInt(1, idEmpleado);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) { int v = rs.getInt(1); if (!rs.wasNull()) return v; }
            }
        } catch (Exception e) { }
        return null;
    }

    /** true si el usuario de la sesion puede gestionar (configurar/aprobar) a ese empleado. */
    public static boolean puedeSobre(HttpSession session, Connection cn, int idEmpleado) {
        if (esGlobal(session)) return true;
        Integer g = grupoDe(cn, idEmpleado);
        return g != null && grupos(cn, idUsuario(session)).contains(g);
    }

    /** true si puede gestionar el grupo (id) dado. */
    public static boolean puedeSobreGrupo(HttpSession session, Connection cn, Integer idGrupo) {
        if (esGlobal(session)) return true;
        return idGrupo != null && grupos(cn, idUsuario(session)).contains(idGrupo);
    }

    /**
     * Condicion SQL (con " AND " inicial) que restringe a los empleados del alcance del usuario.
     * columnaGrupo: expresion con el ID_GRUPO del empleado (ej. "vc.ID_GRUPO"). Para un
     * administrador global no restringe. Los ids se obtienen de la base (enteros): no hay inyeccion.
     */
    public static String filtroSql(HttpSession session, Connection cn, String columnaGrupo) {
        if (esGlobal(session)) return "";
        List<Integer> gs = grupos(cn, idUsuario(session));
        if (gs.isEmpty()) return " AND 1 = 0 ";
        StringBuilder sb = new StringBuilder(" AND " + columnaGrupo + " IN (");
        for (int i = 0; i < gs.size(); i++) sb.append(i > 0 ? "," : "").append(gs.get(i).intValue());
        return sb.append(") ").toString();
    }
}
