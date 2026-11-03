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

// Asigna a un empleado a un grupo de gestion de Vacaciones (o lo deja "Sin asignar").
// Solo el administrador global (VACACIONES_GRUPOS): los gestores de cada grupo no mueven
// empleados entre grupos. Si el empleado aun no tiene fila en VAC_CONFIG_USUARIO se crea
// solo con el grupo (la fecha de ingreso y el jefe se cargan despues).
@WebServlet(name = "VAC_AsignarGrupo", urlPatterns = {"/VAC_AsignarGrupo"})
public class VAC_AsignarGrupo extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, VAC_Alcance.PERM_GLOBAL)) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        String vol = request.getParameter("volver");
        String base = request.getContextPath() + "/Vacaciones/VAC_ConfigUsuarios.jsp";
        String q = (vol != null && vol.matches("[0-9]+")) ? "?grupo=" + vol + "&" : "?";

        int idEmpleado;
        Integer idGrupo = null;
        try {
            idEmpleado = Integer.parseInt(request.getParameter("idEmpleado").trim());
            String g = request.getParameter("idGrupo");
            if (g != null && !g.trim().isEmpty()) idGrupo = Integer.parseInt(g.trim());
        } catch (Exception e) {
            response.sendRedirect(base + q + "error=" + enc("Datos invalidos"));
            return;
        }
        int idGestor = VAC_Alcance.idUsuario(session);

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            String nombreGrupo = "Sin asignar";
            if (idGrupo != null) {
                String n = null;
                try (PreparedStatement st = cn.prepareStatement("SELECT NOMBRE FROM VAC_GRUPO WHERE ID_GRUPO = ? AND ESTADO = 'A'")) {
                    st.setInt(1, idGrupo);
                    try (ResultSet rs = st.executeQuery()) { if (rs.next()) n = rs.getString(1); }
                }
                if (n == null) {
                    cn.rollback();
                    response.sendRedirect(base + q + "error=" + enc("Grupo no encontrado"));
                    return;
                }
                nombreGrupo = n;
            }
            String empleado = null;
            try (PreparedStatement st = cn.prepareStatement("SELECT NOMBRE||' '||APELLIDOS FROM USUARIO WHERE IDUSUARIO = ? AND ESTADO = 'a'")) {
                st.setInt(1, idEmpleado);
                try (ResultSet rs = st.executeQuery()) { if (rs.next()) empleado = rs.getString(1); }
            }
            if (empleado == null) {
                cn.rollback();
                response.sendRedirect(base + q + "error=" + enc("Empleado no encontrado"));
                return;
            }

            int filas;
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE VAC_CONFIG_USUARIO SET ID_GRUPO = ?, ID_USUARIO_ACTUALIZA = ?, FECHA_ACTUALIZACION = SYSDATE WHERE ID_USUARIO = ?")) {
                if (idGrupo != null) st.setInt(1, idGrupo); else st.setNull(1, java.sql.Types.NUMERIC);
                st.setInt(2, idGestor);
                st.setInt(3, idEmpleado);
                filas = st.executeUpdate();
            }
            if (filas == 0) {
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO VAC_CONFIG_USUARIO (ID_USUARIO, ID_GRUPO, ID_USUARIO_ACTUALIZA, FECHA_ACTUALIZACION) VALUES (?, ?, ?, SYSDATE)")) {
                    st.setInt(1, idEmpleado);
                    if (idGrupo != null) st.setInt(2, idGrupo); else st.setNull(2, java.sql.Types.NUMERIC);
                    st.setInt(3, idGestor);
                    st.executeUpdate();
                }
            }
            cn.commit();
            COMUN.LogActividad.registrar(request, "VACACIONES", "EDITAR",
                    "Asigno a " + empleado + " (#" + idEmpleado + ") al grupo de gestion: " + nombreGrupo);
            response.sendRedirect(base + q + "msj=" + enc(empleado + " asignado a: " + nombreGrupo));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(base + q + "error=" + enc("Error al asignar el grupo (verifica que el script 044 este ejecutado)"));
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
