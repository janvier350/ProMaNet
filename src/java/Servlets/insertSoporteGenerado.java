package Servlets;

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

// Crear un ticket EN NOMBRE DE OTRO usuario (lo usan CEOs/gerentes
// que no abren sus tickets personalmente). Se diferencia de
// insertSoporte en que:
//  - La prioridad y descripcion llegan con nombres distintos
//    (prioridad_soporteGenerado, soporteGenerado) porque conviven en
//    la misma pantalla de Perfil.jsp con el formulario "crear mi
//    propio ticket".
//  - El idUsuario se recibe del dropdown; el idEquipo se autocompleta
//    con el equipo asignado activo del destinatario.
//
// Fix historico (mismo patron que insertSoporte): el codigo original
// hacia executeQuery() sobre un INSERT, lo que tiraba SQLException
// sin ejecutar la operacion. El ticket nunca se guardaba.
//
// Ademas los validadores viejos eran solo chequeos por cargo
// hardcoded, pero el dropdown de ejecutivo podia venir vacio y el
// servlet no validaba -- resultaba en 'VALUES (555,,null,...)' y
// ORA-00947. Ahora se validan los 3 campos minimos antes de tocar
// la base.
@WebServlet(name = "insertSoporteGenerado", urlPatterns = {"/insertSoporteGenerado"})
public class insertSoporteGenerado extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) {
            // Solo tecnicos / gerentes autorizados pueden crear ticket
            // en nombre de otro usuario (de lo contrario cualquiera
            // podria llenar tickets por otros).
            response.sendRedirect("sesionInvalida.jsp"); return;
        }

        String idUsuario = request.getParameter("idEjecutivo_soporteGenerado");
        String prioridad = request.getParameter("prioridad_soporteGenerado");
        String soporte   = request.getParameter("soporteGenerado");

        if (idUsuario == null || idUsuario.trim().isEmpty()
                || prioridad == null || prioridad.trim().isEmpty()
                || soporte == null || soporte.trim().isEmpty()) {
            response.sendRedirect("Proyectos/Perfil.jsp?error=Faltan datos: debes elegir ejecutivo, prioridad y describir el problema");
            return;
        }

        Connection cn = null;
        int idNuevo = -1;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            // 1. Buscar el equipo activo del destinatario. Si no tiene,
            //    no podemos crear el ticket (SOP_SOPORTE_CAB.IDEQUIPO
            //    no admite null en algunas bases).
            Integer idEquipo = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT a.IDINVEQUIPO FROM INV_EQUIPOS a " +
                    "LEFT JOIN INV_ASIGNACION b ON a.IDINVEQUIPO = b.IDINVEQUIPO " +
                    "WHERE b.IDUSUARIO = ? AND b.ESTADO = 'A' AND ROWNUM = 1")) {
                st.setInt(1, Integer.parseInt(idUsuario.trim()));
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) idEquipo = rs.getInt(1);
                }
            }
            if (idEquipo == null) {
                response.sendRedirect("Proyectos/Perfil.jsp?error=El ejecutivo elegido no tiene equipo asignado activo");
                return;
            }

            // 2. INSERT con reintentos ante colision de IDSOPORTE
            //    (mismo patron que insertSoporte -- previene el bug
            //    historico del duplicado #114).
            int intentos = 0;
            while (idNuevo < 0 && intentos < 3) {
                intentos++;
                try (PreparedStatement stSec = cn.prepareStatement(
                        "SELECT NVL(MAX(IDSOPORTE),0)+1 FROM SOP_SOPORTE_CAB");
                     ResultSet rs = stSec.executeQuery()) {
                    if (rs.next()) idNuevo = rs.getInt(1);
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO SOP_SOPORTE_CAB " +
                        "(IDSOPORTE, IDUSUARIO, IDEQUIPO, FECHA_SOLICITUD, SOPORTE, " +
                        " PRIORIDAD, ESTADO, REPORTE, FECHA_REPORTE, TECNICO) " +
                        "VALUES (?, ?, ?, SYSDATE, ?, ?, 'PENDIENTE', 'SIN REPORTE', SYSDATE, 'N/A')")) {
                    st.setInt(1, idNuevo);
                    st.setInt(2, Integer.parseInt(idUsuario.trim()));
                    st.setInt(3, idEquipo);
                    st.setString(4, soporte.trim());
                    st.setString(5, prioridad.trim());
                    st.executeUpdate();
                } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                    idNuevo = -1;
                    if (intentos >= 3) throw dup;
                }
            }
            cn.commit();

            COMUN.LogActividad.registrar(request, "SOPORTES", "CREAR",
                    "Creo ticket de soporte #" + idNuevo + " en nombre del usuario #" + idUsuario + " (prioridad " + prioridad + ")");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Proyectos/Perfil.jsp?error=Error al crear ticket: "
                    + (e.getMessage() == null ? "" : e.getMessage().replaceAll("[\\r\\n]"," ").substring(0, Math.min(80, e.getMessage().length()))));
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_ListaTickets.jsp?msj=Ticket #" + idNuevo + " creado en nombre del ejecutivo");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Proyectos/Perfil.jsp");
    }
}
