package VACACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

// Elimina un permiso cargado por error y, si descargaba dias a vacaciones,
// elimina tambien su ajuste enlazado (el saldo se restituye).
@WebServlet(name = "VAC_EliminarPermiso", urlPatterns = {"/VAC_EliminarPermiso"})
public class VAC_EliminarPermiso extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        String idEmpleadoP = request.getParameter("idEmpleado");
        String base = request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleadoP;

        int idEmpleado, idPermiso;
        try {
            idEmpleado = Integer.parseInt(idEmpleadoP.trim());
            idPermiso = Integer.parseInt(request.getParameter("idPermiso").trim());
        } catch (Exception e) {
            response.sendRedirect(base + "&error=" + enc("Datos incompletos"));
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            Integer idAjuste = null;
            boolean existe = false;
            try (PreparedStatement st = cn.prepareStatement("SELECT ID_AJUSTE FROM VAC_PERMISO WHERE ID_PERMISO = ? AND ID_USUARIO = ?")) {
                st.setInt(1, idPermiso);
                st.setInt(2, idEmpleado);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) { existe = true; int v = rs.getInt(1); if (!rs.wasNull()) idAjuste = v; }
                }
            }
            if (!existe) {
                cn.rollback();
                response.sendRedirect(base + "&error=" + enc("Permiso no encontrado"));
                return;
            }
            if (idAjuste != null) {
                try (PreparedStatement st = cn.prepareStatement("DELETE FROM VAC_HISTORICO_AJUSTE WHERE ID_AJUSTE = ? AND ID_USUARIO = ?")) {
                    st.setInt(1, idAjuste);
                    st.setInt(2, idEmpleado);
                    st.executeUpdate();
                }
            }
            try (PreparedStatement st = cn.prepareStatement("DELETE FROM VAC_PERMISO WHERE ID_PERMISO = ? AND ID_USUARIO = ?")) {
                st.setInt(1, idPermiso);
                st.setInt(2, idEmpleado);
                st.executeUpdate();
            }
            cn.commit();
            COMUN.LogActividad.registrar(request, "VACACIONES", "ELIMINAR",
                    "Elimino permiso #" + idPermiso + " del usuario #" + idEmpleado + (idAjuste != null ? " y su descargo a vacaciones" : ""));
            response.sendRedirect(base + "&msj=" + enc("Permiso eliminado" + (idAjuste != null ? " (se restituyo el descargo de vacaciones)" : "")));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(base + "&error=" + enc("Error al eliminar el permiso"));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
