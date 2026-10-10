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

// Cambios de estado de un ticket que no estan en el flujo clasico de
// "atender y cerrar" (ese sigue siendo InsertReporteTecnico). Un solo
// servlet con "accion" para los 3 casos nuevos:
//
//   EN_PROGRESO     requiere SOPORTES_ATENDER       estado -> EN_PROGRESO,
//                                                  setea FECHA_PRIMERA_ATENCION
//                                                  si estaba null, asigna
//                                                  tecnico = yo.
//   REASIGNAR       requiere SOPORTES_REASIGNAR    estado -> REASIGNADO,
//                                                  asigna ID_TECNICO_ASIGNADO
//                                                  al idUsuario que viene.
//   SIN_SOLUCION    requiere SOPORTES_ATENDER      estado -> CERRADO_SIN_SOLUCION,
//                                                  guarda nota en REPORTE
//                                                  y FECHA_REPORTE = SYSDATE.
@WebServlet(name = "SOP_CambiarEstado", urlPatterns = {"/SOP_CambiarEstado"})
public class SOP_CambiarEstado extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }

        String idSolicitud  = request.getParameter("idSolicitud");
        String accion       = request.getParameter("accion");     // EN_PROGRESO | REASIGNAR | SIN_SOLUCION
        String comentario   = request.getParameter("comentario"); // opcional / obligatorio segun accion
        String idTecnicoStr = request.getParameter("idTecnico");  // solo para REASIGNAR

        if (idSolicitud == null || idSolicitud.trim().isEmpty() || accion == null) {
            response.sendRedirect("Soportes/SOP_ListaTickets.jsp?error=Datos incompletos");
            return;
        }

        // Permisos por accion
        boolean ok = false;
        switch (accion) {
            case "EN_PROGRESO":
            case "SIN_SOLUCION":
                ok = COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER");
                break;
            case "REASIGNAR":
                ok = COMUN.PermisoHelper.tiene(session, "SOPORTES_REASIGNAR");
                break;
            default:
                response.sendRedirect("Soportes/SOP_ListaTickets.jsp?error=Accion no reconocida");
                return;
        }
        if (!ok) { response.sendRedirect("sesionInvalida.jsp"); return; }

        // Validaciones de datos por accion
        if ("REASIGNAR".equals(accion) && (idTecnicoStr == null || idTecnicoStr.trim().isEmpty())) {
            response.sendRedirect("Soportes/SOP_ListaTickets.jsp?error=Falta tecnico");
            return;
        }
        if ("SIN_SOLUCION".equals(accion) && (comentario == null || comentario.trim().isEmpty())) {
            response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud
                    + "&error=Debes indicar por que se cierra sin solucion");
            return;
        }

        Integer idYo = null;
        try {
            Object cod = session.getAttribute("cod");
            if (cod != null) idYo = Integer.parseInt(cod.toString().trim());
        } catch (Exception ignore) {}
        String loginYo = (String) session.getAttribute("usuario");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");
            int idSolInt = Integer.parseInt(idSolicitud.trim());

            String descripcionLog;
            switch (accion) {
                case "EN_PROGRESO": {
                    try (PreparedStatement st = cn.prepareStatement(
                            "UPDATE SOP_SOPORTE_CAB SET " +
                            "  ESTADO = 'EN_PROGRESO', " +
                            "  ID_TECNICO_ASIGNADO = NVL(ID_TECNICO_ASIGNADO, ?), " +
                            "  TECNICO = NVL(TECNICO, ?), " +
                            "  FECHA_PRIMERA_ATENCION = NVL(FECHA_PRIMERA_ATENCION, SYSDATE) " +
                            "WHERE IDSOPORTE = ?")) {
                        if (idYo == null) st.setNull(1, java.sql.Types.NUMERIC);
                        else              st.setInt(1, idYo);
                        st.setString(2, loginYo);
                        st.setInt(3, idSolInt);
                        st.executeUpdate();
                    }
                    descripcionLog = "Marco ticket #" + idSolicitud + " como EN PROGRESO";
                    break;
                }
                case "REASIGNAR": {
                    int idTecNuevo = Integer.parseInt(idTecnicoStr.trim());
                    try (PreparedStatement st = cn.prepareStatement(
                            "UPDATE SOP_SOPORTE_CAB SET " +
                            "  ESTADO = 'REASIGNADO', " +
                            "  ID_TECNICO_ASIGNADO = ?, " +
                            "  TECNICO = (SELECT USUARIO FROM USUARIO WHERE IDUSUARIO = ?) " +
                            "WHERE IDSOPORTE = ?")) {
                        st.setInt(1, idTecNuevo);
                        st.setInt(2, idTecNuevo);
                        st.setInt(3, idSolInt);
                        st.executeUpdate();
                    }
                    descripcionLog = "Reasigno ticket #" + idSolicitud + " a usuario #" + idTecNuevo
                            + (comentario != null && !comentario.trim().isEmpty() ? " (" + comentario.trim() + ")" : "");
                    break;
                }
                case "SIN_SOLUCION": {
                    try (PreparedStatement st = cn.prepareStatement(
                            "UPDATE SOP_SOPORTE_CAB SET " +
                            "  ESTADO = 'CERRADO_SIN_SOLUCION', " +
                            "  REPORTE = ?, " +
                            "  FECHA_REPORTE = SYSDATE, " +
                            "  TECNICO = NVL(TECNICO, ?), " +
                            "  ID_TECNICO_ASIGNADO = NVL(ID_TECNICO_ASIGNADO, ?), " +
                            "  FECHA_PRIMERA_ATENCION = NVL(FECHA_PRIMERA_ATENCION, SYSDATE) " +
                            "WHERE IDSOPORTE = ?")) {
                        st.setString(1, comentario.trim());
                        st.setString(2, loginYo);
                        if (idYo == null) st.setNull(3, java.sql.Types.NUMERIC);
                        else              st.setInt(3, idYo);
                        st.setInt(4, idSolInt);
                        st.executeUpdate();
                    }
                    descripcionLog = "Cerro ticket #" + idSolicitud + " sin solucion";
                    break;
                }
                default:
                    throw new Exception("accion desconocida");
            }
            cn.commit();
            COMUN.LogActividad.registrar(request, "SOPORTES", "ACTUALIZAR", descripcionLog);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud
                    + "&error=Error al cambiar estado");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud + "&msj=Estado actualizado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
