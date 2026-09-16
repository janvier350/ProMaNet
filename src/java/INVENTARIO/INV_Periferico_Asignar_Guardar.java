/*
 * Guardar la entrega (asignacion) de un periferico a un usuario.
 *
 * Transaccion unica sobre una misma conexion:
 *   1) INSERT INV_PERIFERICO_ASIGNACION (ESTADO='A')
 *   2) UPDATE INV_PERIFERICO SET ESTADO='A'
 *   3) Si es reemplazo:
 *        a) UPDATE la asignacion activa del periferico reemplazado
 *           poniendo ESTADO='I', FECHADEVOLUCION=SYSDATE
 *        b) UPDATE INV_PERIFERICO del reemplazado con el nuevo estado
 *           lifecycle segun el codigo de motivo:
 *              REEMPLAZO_DANO      -> F (Fuera de servicio)
 *              REEMPLAZO_PERDIDA   -> X (Baja)
 *              REEMPLAZO_ROBO      -> X (Baja)
 *              REEMPLAZO_DESGASTE  -> X (Baja)
 *              (cualquier otro)    -> D (Disponible; vuelve al pool)
 *
 * Se usa executeUpdate() sobre INSERT/UPDATE (nunca executeQuery: ese
 * error rompio antes INV_ASIGNACION, ver
 * docs/migracion/inv_equipos_reparar_estado.sql). Todo con
 * PreparedStatement + setInt/setString + rollback al menor problema.
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
import java.sql.ResultSet;
import java.sql.Types;

@WebServlet(name = "INV_Periferico_Asignar_Guardar", urlPatterns = {"/INV_Periferico_Asignar_Guardar"})
public class INV_Periferico_Asignar_Guardar extends HttpServlet {

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

        String idPeriferico          = request.getParameter("idPeriferico");
        String idUsuario             = request.getParameter("idUsuario");
        String idMotivo              = request.getParameter("idMotivo");
        String observacionMotivo     = request.getParameter("observacionMotivo");
        String idPerifericoReemplaza = request.getParameter("idPerifericoReemplaza");
        Object idUsuarioSesionObj    = session.getAttribute("idUsuario");

        if (isBlank(idPeriferico) || isBlank(idUsuario) || isBlank(idMotivo)) {
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Datos incompletos"); return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No hay conexion a la base");
            cn.setAutoCommit(false);

            // 0) Traer el codigo del motivo para saber si obliga observacion
            //    y para el ajuste de estado del periferico reemplazado.
            String codigoMotivo = null;
            try (PreparedStatement stM = cn.prepareStatement(
                    "SELECT CODIGO FROM INV_PERIFERICO_MOTIVO WHERE ID_MOTIVO = ?")) {
                stM.setInt(1, Integer.parseInt(idMotivo.trim()));
                try (ResultSet rsM = stM.executeQuery()) {
                    if (rsM.next()) codigoMotivo = rsM.getString(1);
                }
            }
            if (codigoMotivo == null) {
                throw new Exception("Motivo invalido");
            }
            if (("OTRO".equals(codigoMotivo) || "PRESTAMO_TEMPORAL".equals(codigoMotivo))
                    && isBlank(observacionMotivo)) {
                cn.rollback();
                response.sendRedirect("Inventario/INV_Periferico_Asignar.jsp?idPeriferico=" + idPeriferico
                        + "&error=Observacion obligatoria para este motivo");
                return;
            }

            // 1) Verificar que el periferico este disponible (no A).
            String estadoActual = null;
            try (PreparedStatement stE = cn.prepareStatement(
                    "SELECT ESTADO FROM INV_PERIFERICO WHERE ID_PERIFERICO = ? AND ESTADO_AI = 'A'")) {
                stE.setInt(1, Integer.parseInt(idPeriferico.trim()));
                try (ResultSet rsE = stE.executeQuery()) {
                    if (rsE.next()) estadoActual = rsE.getString(1);
                }
            }
            if (estadoActual == null) {
                throw new Exception("Periferico no existe");
            }
            if ("A".equals(estadoActual)) {
                cn.rollback();
                response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Ya asignado, devolver primero");
                return;
            }

            // 2) Insertar asignacion.
            int nuevoIdAsig = 1;
            try (PreparedStatement stS = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_ASIGNACION),0)+1 FROM INV_PERIFERICO_ASIGNACION");
                 ResultSet rsS = stS.executeQuery()) {
                if (rsS.next()) nuevoIdAsig = rsS.getInt(1);
            }
            try (PreparedStatement stI = cn.prepareStatement(
                    "INSERT INTO INV_PERIFERICO_ASIGNACION (" +
                    " ID_ASIGNACION, ID_PERIFERICO, IDUSUARIO, ID_MOTIVO, OBSERVACION_MOTIVO, " +
                    " ID_PERIFERICO_REEMPLAZA, FECHAASIGNACION, ESTADO, ID_USUARIO_REGISTRA) " +
                    "VALUES (?, ?, ?, ?, ?, ?, SYSDATE, 'A', ?)")) {
                stI.setInt(1, nuevoIdAsig);
                stI.setInt(2, Integer.parseInt(idPeriferico.trim()));
                stI.setInt(3, Integer.parseInt(idUsuario.trim()));
                stI.setInt(4, Integer.parseInt(idMotivo.trim()));
                if (isBlank(observacionMotivo)) stI.setNull(5, Types.VARCHAR);
                else stI.setString(5, observacionMotivo.trim());
                if (isBlank(idPerifericoReemplaza)) stI.setNull(6, Types.NUMERIC);
                else stI.setInt(6, Integer.parseInt(idPerifericoReemplaza.trim()));
                if (idUsuarioSesionObj == null) stI.setNull(7, Types.NUMERIC);
                else {
                    try { stI.setInt(7, Integer.parseInt(idUsuarioSesionObj.toString().trim())); }
                    catch (Exception ex) { stI.setNull(7, Types.NUMERIC); }
                }
                stI.executeUpdate();
            }

            // 3) Marcar el periferico como asignado.
            try (PreparedStatement stU = cn.prepareStatement(
                    "UPDATE INV_PERIFERICO SET ESTADO = 'A' WHERE ID_PERIFERICO = ?")) {
                stU.setInt(1, Integer.parseInt(idPeriferico.trim()));
                stU.executeUpdate();
            }

            // 4) Si es reemplazo: cerrar asignacion previa del reemplazado y
            //    ajustar su estado lifecycle segun el motivo.
            if (!isBlank(idPerifericoReemplaza)) {
                int idAnterior = Integer.parseInt(idPerifericoReemplaza.trim());
                try (PreparedStatement stC = cn.prepareStatement(
                        "UPDATE INV_PERIFERICO_ASIGNACION " +
                        "   SET ESTADO = 'I', FECHADEVOLUCION = SYSDATE " +
                        " WHERE ID_PERIFERICO = ? AND ESTADO = 'A'")) {
                    stC.setInt(1, idAnterior);
                    stC.executeUpdate();
                }
                String nuevoEstadoAnterior;
                switch (codigoMotivo) {
                    case "REEMPLAZO_DANO":      nuevoEstadoAnterior = "F"; break;
                    case "REEMPLAZO_PERDIDA":
                    case "REEMPLAZO_ROBO":
                    case "REEMPLAZO_DESGASTE":  nuevoEstadoAnterior = "X"; break;
                    default:                     nuevoEstadoAnterior = "D"; break;
                }
                try (PreparedStatement stB = cn.prepareStatement(
                        "UPDATE INV_PERIFERICO SET ESTADO = ? WHERE ID_PERIFERICO = ?")) {
                    stB.setString(1, nuevoEstadoAnterior);
                    stB.setInt(2, idAnterior);
                    stB.executeUpdate();
                }
            }

            cn.commit();
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Error al asignar");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Inventario/INV_Perifericos.jsp?ok=Asignado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Inventario/INV_Perifericos.jsp");
    }

    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}
