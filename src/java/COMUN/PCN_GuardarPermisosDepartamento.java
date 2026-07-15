package COMUN;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Enumeration;

@WebServlet(name = "PCN_GuardarPermisosDepartamento", urlPatterns = {"/PCN_GuardarPermisosDepartamento"})
public class PCN_GuardarPermisosDepartamento extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String departamento = request.getParameter("departamento");
        if (departamento == null || departamento.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/PCN_ListadoUsuario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            Enumeration<String> nombres = request.getParameterNames();
            while (nombres.hasMoreElements()) {
                String nombreParam = nombres.nextElement();
                if (!nombreParam.startsWith("permiso_")) continue;

                int idPermiso = Integer.parseInt(nombreParam.substring("permiso_".length()));
                String valor = request.getParameter(nombreParam);

                try (PreparedStatement stDel = cn.prepareStatement(
                        "DELETE FROM APP_DEPARTAMENTO_PERMISO WHERE UPPER(DEPARTAMENTO) = UPPER(?) AND ID_PERMISO = ?")) {
                    stDel.setString(1, departamento);
                    stDel.setInt(2, idPermiso);
                    stDel.executeUpdate();
                }

                if ("G".equals(valor) || "D".equals(valor)) {
                    try (PreparedStatement stIns = cn.prepareStatement(
                            "INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES (?, ?, ?)")) {
                        stIns.setString(1, departamento);
                        stIns.setInt(2, idPermiso);
                        stIns.setString(3, valor);
                        stIns.executeUpdate();
                    }
                }
            }

            session.setAttribute("msg_exito",
                "Permisos del departamento actualizados. El cambio se aplicara la proxima vez que cada persona de ese departamento inicie sesion.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al guardar los permisos: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        String deptoEncoded = URLEncoder.encode(departamento, StandardCharsets.UTF_8.toString());
        response.sendRedirect(request.getContextPath() + "/PCN_GestionPermisosDepartamento.jsp?depto=" + deptoEncoded);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/PCN_ListadoUsuario.jsp");
    }
}
