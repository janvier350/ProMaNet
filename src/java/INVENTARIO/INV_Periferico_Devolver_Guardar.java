/*
 * Guardar la devolucion de un periferico.
 *
 * Transaccion unica sobre una misma conexion:
 *   1) UPDATE INV_PERIFERICO_ASIGNACION SET ESTADO='I', FECHADEVOLUCION=SYSDATE
 *      (y anexa la observacion al final del campo si viene)
 *   2) UPDATE INV_PERIFERICO SET ESTADO = <nuevoEstado>
 *
 * nuevoEstado permitido: D, BK, F, X. Se rechaza cualquier otro.
 */
package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet(name = "INV_Periferico_Devolver_Guardar", urlPatterns = {"/INV_Periferico_Devolver_Guardar"})
public class INV_Periferico_Devolver_Guardar extends HttpServlet {

    private static final Set<String> ESTADOS_VALIDOS =
            new HashSet<>(Arrays.asList("D", "BK", "F", "X"));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp"); return;
        }

        String idPeriferico = request.getParameter("idPeriferico");
        String nuevoEstado  = request.getParameter("nuevoEstado");
        String observacion  = request.getParameter("observacion");

        if (idPeriferico == null || idPeriferico.trim().isEmpty()
                || nuevoEstado == null || !ESTADOS_VALIDOS.contains(nuevoEstado)) {
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No hay conexion a la base");
            cn.setAutoCommit(false);

            int idPerifInt = Integer.parseInt(idPeriferico.trim());

            // 1) Cerrar la asignacion activa. Si viene observacion, se
            //    concatena al final del OBSERVACION_MOTIVO (respetando lo
            //    que la persona ya escribio en la entrega). Se hace en un
            //    solo UPDATE.
            String sqlCierra =
                    "UPDATE INV_PERIFERICO_ASIGNACION " +
                    "   SET ESTADO = 'I', " +
                    "       FECHADEVOLUCION = SYSDATE, " +
                    "       OBSERVACION_MOTIVO = " +
                    "         CASE WHEN ? IS NULL THEN OBSERVACION_MOTIVO " +
                    "              WHEN OBSERVACION_MOTIVO IS NULL THEN ? " +
                    "              ELSE SUBSTR(OBSERVACION_MOTIVO || ' | Devolucion: ' || ?, 1, 500) " +
                    "         END " +
                    " WHERE ID_PERIFERICO = ? AND ESTADO = 'A'";
            try (PreparedStatement st = cn.prepareStatement(sqlCierra)) {
                String obs = (observacion == null || observacion.trim().isEmpty()) ? null : observacion.trim();
                if (obs == null) {
                    st.setNull(1, java.sql.Types.VARCHAR);
                    st.setNull(2, java.sql.Types.VARCHAR);
                    st.setNull(3, java.sql.Types.VARCHAR);
                } else {
                    st.setString(1, obs);
                    st.setString(2, "Devolucion: " + obs);
                    st.setString(3, obs);
                }
                st.setInt(4, idPerifInt);
                st.executeUpdate();
            }

            // 2) Ajustar estado del periferico.
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE INV_PERIFERICO SET ESTADO = ? WHERE ID_PERIFERICO = ?")) {
                st.setString(1, nuevoEstado);
                st.setInt(2, idPerifInt);
                st.executeUpdate();
            }

            cn.commit();
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Error al devolver");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Inventario/INV_Perifericos.jsp?ok=Devuelto");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Inventario/INV_Perifericos.jsp");
    }
}
