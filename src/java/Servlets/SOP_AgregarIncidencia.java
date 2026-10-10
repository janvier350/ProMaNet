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

// Agrega una incidencia (nota, intento, diagnostico, escalamiento, etc.)
// al historial de un ticket. Si el ticket estaba PENDIENTE lo pasa
// automaticamente a EN_PROGRESO -- la idea es que no haga falta un
// paso aparte para "tomarlo", basta con registrar lo que se hizo.
//
// Setea tambien ID_TECNICO_ASIGNADO + FECHA_PRIMERA_ATENCION si estaban
// vacios (NVL para no pisar valores previos).
//
// Permiso: SOPORTES_ATENDER (solo los tecnicos agregan actividad).
@WebServlet(name = "SOP_AgregarIncidencia", urlPatterns = {"/SOP_AgregarIncidencia"})
public class SOP_AgregarIncidencia extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) {
            response.sendRedirect("sesionInvalida.jsp"); return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String tipo        = request.getParameter("tipo");
        String descripcion = request.getParameter("descripcion");
        String resultado   = request.getParameter("resultado"); // opcional

        if (idSolicitud == null || idSolicitud.trim().isEmpty()
                || tipo == null || tipo.trim().isEmpty()
                || descripcion == null || descripcion.trim().isEmpty()) {
            response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud
                    + "&error=Faltan datos de la incidencia");
            return;
        }
        if (descripcion.length() > 2000) descripcion = descripcion.substring(0, 2000);

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
            cn.setAutoCommit(false);

            int idSolInt = Integer.parseInt(idSolicitud.trim());

            // 1. Insert incidencia
            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_INCIDENCIA),0)+1 FROM SOP_SOPORTE_INCIDENCIA");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO SOP_SOPORTE_INCIDENCIA " +
                    "(ID_INCIDENCIA, IDSOPORTE, FECHA_HORA, ID_USUARIO, USUARIO_LOGIN, TIPO, DESCRIPCION, RESULTADO) " +
                    "VALUES (?, ?, SYSDATE, ?, ?, ?, ?, ?)")) {
                st.setInt(1, idNuevo);
                st.setInt(2, idSolInt);
                if (idYo == null) st.setNull(3, java.sql.Types.NUMERIC);
                else              st.setInt(3, idYo);
                st.setString(4, loginYo);
                st.setString(5, tipo.trim());
                st.setString(6, descripcion.trim());
                if (resultado == null || resultado.trim().isEmpty()) st.setNull(7, java.sql.Types.VARCHAR);
                else st.setString(7, resultado.trim());
                st.executeUpdate();
            }

            // 2. Pasar a EN_PROGRESO si todavia estaba PENDIENTE o REASIGNADO
            //    (no tiene sentido quedar ahi si ya se le esta trabajando).
            //    Tambien asigna tecnico y fecha primera atencion si faltan.
            //    Si el tipo es CIERRE o CIERRE_SIN_SOLUCION, no se toca el
            //    estado -- eso lo maneja InsertReporteTecnico o
            //    SOP_CambiarEstado.
            if (!"CIERRE".equals(tipo) && !"CIERRE_SIN_SOLUCION".equals(tipo)) {
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE SOP_SOPORTE_CAB SET " +
                        "  ESTADO = CASE WHEN ESTADO IN ('PENDIENTE','REASIGNADO') THEN 'EN_PROGRESO' ELSE ESTADO END, " +
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
            }

            cn.commit();
            COMUN.LogActividad.registrar(request, "SOPORTES", "ACTUALIZAR",
                    "Agrego incidencia (" + tipo + ") al ticket #" + idSolicitud);
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
            response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud
                    + "&error=Error al registrar incidencia");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_AtenderTicket.jsp?idSolicitud=" + idSolicitud
                + "&msj=Incidencia registrada");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
