package Servlets;

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

// Asignar o EDITAR el sueldo de un ejecutivo (base para el tope de los
// anticipos). Lo usa ADM_Asignar_Sueldo.jsp: el boton "Asignar Sueldo"
// (usuarios con sueldo 0) y el boton "Editar sueldo" (usuarios con
// sueldo ya cargado) postean aqui.
//
// Reescrito: la version anterior concatenaba sueldo e idEjecutivo en el
// SQL (SQL injection), hacia executeQuery() sobre un UPDATE, aceptaba
// GET (cambiar un sueldo desde un enlace) y no dejaba rastro de quien
// cambio que. Ahora: solo POST, bind params, executeUpdate, solo afecta
// usuarios activos de los mismos departamentos que lista la pantalla, y
// registra en LogActividad el sueldo anterior y el nuevo.
@WebServlet(name = "ADM_Asignar_Sueldo", urlPatterns = {"/ADM_Asignar_Sueldo"})
public class ADM_Asignar_Sueldo extends HttpServlet {

    // Mismos departamentos que consulta ADM_Asignar_Sueldo.jsp.
    private static final String[] DEPARTAMENTOS = {
        "MARKETING", "TECNOLOGÍA", "IMPUESTOS", "ADMINISTRACIÓN", "CONTABILIDAD", "LEGAL"
    };

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String base = request.getContextPath() + "/Control/ADM_Asignar_Sueldo.jsp";

        int idEjecutivo;
        double sueldo;
        try {
            idEjecutivo = Integer.parseInt(request.getParameter("idEjecutivo").trim());
            sueldo = Double.parseDouble(request.getParameter("sueldo").trim());
        } catch (Exception e) {
            response.sendRedirect(base + "?error=" + enc("Datos invalidos"));
            return;
        }
        if (sueldo < 0 || Double.isNaN(sueldo) || Double.isInfinite(sueldo)) {
            response.sendRedirect(base + "?error=" + enc("El sueldo no puede ser negativo"));
            return;
        }

        String inDeptos = "?,?,?,?,?,?";
        String filtro =
                "FROM USUARIO a JOIN ADM_DEPARTAMENTO b ON a.ID_ADM_DEPARTAMENTO = b.ID_DEPARTAMENTO " +
                "WHERE a.IDUSUARIO = ? AND a.ESTADO = 'a' AND b.DEPARTAMENTO IN (" + inDeptos + ")";

        Connection cn = null;
        try {
            cn = Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            // 1. Sueldo y nombre actuales (para validar y para el log)
            String nombre = null;
            double anterior = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT a.NOMBRE || ' ' || a.APELLIDOS, NVL(a.SUELDO,0) " + filtro)) {
                st.setInt(1, idEjecutivo);
                for (int i = 0; i < DEPARTAMENTOS.length; i++) st.setString(2 + i, DEPARTAMENTOS[i]);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) { nombre = rs.getString(1); anterior = rs.getDouble(2); }
                }
            }
            if (nombre == null) {
                response.sendRedirect(base + "?error=" + enc("Ejecutivo no encontrado o fuera de los departamentos permitidos"));
                return;
            }

            // 2. UPDATE con la misma restriccion
            int filas;
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE USUARIO SET SUELDO = ? WHERE IDUSUARIO = ? AND ESTADO = 'a' " +
                    "AND ID_ADM_DEPARTAMENTO IN (SELECT ID_DEPARTAMENTO FROM ADM_DEPARTAMENTO WHERE DEPARTAMENTO IN (" + inDeptos + "))")) {
                st.setDouble(1, sueldo);
                st.setInt(2, idEjecutivo);
                for (int i = 0; i < DEPARTAMENTOS.length; i++) st.setString(3 + i, DEPARTAMENTOS[i]);
                filas = st.executeUpdate();
            }
            cn.commit();
            if (filas == 0) {
                response.sendRedirect(base + "?error=" + enc("No se pudo actualizar el sueldo"));
                return;
            }

            boolean edicion = anterior > 0;
            COMUN.LogActividad.registrar(request, "ADMINISTRACION", edicion ? "EDITAR" : "CREAR",
                    (edicion ? "Edito" : "Asigno") + " el sueldo de " + nombre + " (#" + idEjecutivo + "): $"
                    + String.format(java.util.Locale.US, "%.2f", anterior) + " -> $"
                    + String.format(java.util.Locale.US, "%.2f", sueldo));

            response.sendRedirect(base + "?msj=" + enc("Sueldo de " + nombre + " " + (edicion ? "actualizado" : "asignado") + " correctamente"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(base + "?error=" + enc("Error al guardar el sueldo"));
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
    }

    // El sueldo ya no se cambia por GET (enlace); se vuelve a la pantalla.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Control/ADM_Asignar_Sueldo.jsp");
    }

    private static String enc(String s) {
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }
}
