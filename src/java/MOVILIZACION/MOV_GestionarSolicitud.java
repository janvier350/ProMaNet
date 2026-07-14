package MOVILIZACION;

import COMUN.PermisoHelper;
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

@WebServlet(name = "MOV_GestionarSolicitud", urlPatterns = {"/MOV_GestionarSolicitud"})
public class MOV_GestionarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String accion = request.getParameter("accion"); // APROBAR | RECHAZAR | MOVILIZAR
        String motivoRechazo = request.getParameter("motivoRechazo");
        String fechaNueva = request.getParameter("fecha");
        String horaInicio = request.getParameter("horaInicio");
        String horaFin = request.getParameter("horaFin");
        String idMovilizadorNuevo = request.getParameter("idMovilizador");
        String idUsuarioSesion = (String) session.getAttribute("cod");

        if (idSolicitud == null
                || !("APROBAR".equals(accion) || "RECHAZAR".equals(accion) || "MOVILIZAR".equals(accion))) {
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if ("APROBAR".equals(accion) && horaInicio != null && horaFin != null
                    && !horaInicio.trim().isEmpty() && !horaFin.trim().isEmpty()) {

                if (horaFin.compareTo(horaInicio) <= 0) {
                    session.setAttribute("msg_error", "La hora fin debe ser posterior a la hora de inicio.");
                    response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                    return;
                }

                String idMovilizadorActual = null, fechaActual = null;
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT ID_MOVILIZADOR, TO_CHAR(FECHA,'YYYY-MM-DD') FROM MOV_SOLICITUD WHERE ID_MOV_SOLICITUD = ?")) {
                    st.setInt(1, Integer.parseInt(idSolicitud));
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) { idMovilizadorActual = rs.getString(1); fechaActual = rs.getString(2); }
                    }
                }

                String fecha = (fechaNueva != null && !fechaNueva.trim().isEmpty()) ? fechaNueva : fechaActual;
                String idMovilizador = (idMovilizadorNuevo != null && !idMovilizadorNuevo.trim().isEmpty())
                        ? idMovilizadorNuevo : idMovilizadorActual;

                if (idMovilizador != null && Horario.hayChoque(cn, idMovilizador, fecha, horaInicio, horaFin, idSolicitud)) {
                    session.setAttribute("msg_error", "Ese movilizador ya tiene otra solicitud en ese horario.");
                    response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                    return;
                }

                try (PreparedStatement stHora = cn.prepareStatement(
                        "UPDATE MOV_SOLICITUD SET FECHA = TO_DATE(?,'YYYY-MM-DD'), HORA_INICIO = ?, HORA_FIN = ?, ID_MOVILIZADOR = ? WHERE ID_MOV_SOLICITUD = ?")) {
                    stHora.setString(1, fecha);
                    stHora.setString(2, horaInicio);
                    stHora.setString(3, horaFin);
                    stHora.setInt(4, Integer.parseInt(idMovilizador));
                    stHora.setInt(5, Integer.parseInt(idSolicitud));
                    stHora.executeUpdate();
                }
            }

            String nuevoEstado;
            switch (accion) {
                case "APROBAR": nuevoEstado = "APROBADA"; break;
                case "MOVILIZAR": nuevoEstado = "MOVILIZADO"; break;
                default: nuevoEstado = "RECHAZADA";
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE MOV_SOLICITUD SET ESTADO = ?, IDUSUARIO_GESTIONA = ?, FECHA_GESTION = SYSDATE, MOTIVO_RECHAZO = ? " +
                    "WHERE ID_MOV_SOLICITUD = ?")) {
                st.setString(1, nuevoEstado);
                st.setInt(2, Integer.parseInt(idUsuarioSesion));
                st.setString(3, "RECHAZAR".equals(accion) ? motivoRechazo : null);
                st.setInt(4, Integer.parseInt(idSolicitud));
                st.executeUpdate();
            }

            String msgAccion = "APROBAR".equals(accion) ? "aprobada" : "MOVILIZAR".equals(accion) ? "marcada como movilizada" : "rechazada";
            session.setAttribute("msg_exito", "Solicitud " + msgAccion + " correctamente.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al procesar la solicitud: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
    }
}
