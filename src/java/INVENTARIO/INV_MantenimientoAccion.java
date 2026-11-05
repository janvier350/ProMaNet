package INVENTARIO;

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

// Acciones menores del seguimiento de mantenimientos (INVENTARIO_MANTENIMIENTO_GESTIONAR):
//   accion=ELIMINAR  idMantenimiento   -> anula un registro cargado por error (ESTADO = 'X')
//   accion=EXCLUIR   idEquipo          -> el equipo deja de requerir mantenimiento (MANT_APLICA = 'N')
//   accion=INCLUIR   idEquipo          -> vuelve al plan (MANT_APLICA = 'S')
@WebServlet(name = "INV_MantenimientoAccion", urlPatterns = {"/INV_MantenimientoAccion"})
public class INV_MantenimientoAccion extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        String base = request.getContextPath() + "/Inventario/INV_Mantenimientos.jsp";
        String accion = request.getParameter("accion");
        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);
            String msj;
            if ("ELIMINAR".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("idMantenimiento").trim());
                int n;
                try (PreparedStatement st = cn.prepareStatement("UPDATE INV_MANTENIMIENTO SET ESTADO = 'X' WHERE ID_MANTENIMIENTO = ? AND ESTADO = 'A'")) {
                    st.setInt(1, id);
                    n = st.executeUpdate();
                }
                cn.commit();
                if (n == 0) { response.sendRedirect(base + "?error=" + enc("Registro no encontrado")); return; }
                COMUN.LogActividad.registrar(request, "INVENTARIO", "ELIMINAR", "Anulo el registro de mantenimiento #" + id);
                msj = "Registro de mantenimiento anulado";
            } else if ("EXCLUIR".equals(accion) || "INCLUIR".equals(accion)) {
                int idEquipo = Integer.parseInt(request.getParameter("idEquipo").trim());
                boolean incluir = "INCLUIR".equals(accion);
                try (PreparedStatement st = cn.prepareStatement("UPDATE INV_EQUIPOS SET MANT_APLICA = ? WHERE IDINVEQUIPO = ?")) {
                    st.setString(1, incluir ? "S" : "N");
                    st.setInt(2, idEquipo);
                    st.executeUpdate();
                }
                cn.commit();
                COMUN.LogActividad.registrar(request, "INVENTARIO", "EDITAR",
                        (incluir ? "Incluyo" : "Excluyo") + " el equipo #" + idEquipo + " del plan de mantenimiento");
                msj = incluir ? "Equipo incluido en el plan de mantenimiento" : "Equipo excluido del plan de mantenimiento";
            } else {
                response.sendRedirect(base + "?error=" + enc("Accion invalida"));
                return;
            }
            response.sendRedirect(base + "?msj=" + enc(msj));
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(base + "?error=" + enc("No se pudo completar la accion"));
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
        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Mantenimientos.jsp");
    }
}
