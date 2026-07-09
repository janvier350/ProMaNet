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

@WebServlet(name = "MOV_InsertarSolicitud", urlPatterns = {"/MOV_InsertarSolicitud"})
public class MOV_InsertarSolicitud extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String fecha = request.getParameter("fecha");
        String horaInicio = request.getParameter("horaInicio");
        String horaFin = request.getParameter("horaFin");
        String idMovilizador = request.getParameter("idMovilizador");
        String idMotivo = request.getParameter("idMotivo");
        String comentario = request.getParameter("comentario");

        String idUsuario = (String) session.getAttribute("cod");
        String idDepartamento = (String) session.getAttribute("idDepartamento");

        if (fecha == null || horaInicio == null || idMovilizador == null || idMotivo == null
                || fecha.trim().isEmpty() || horaInicio.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar fecha, hora de inicio, movilizador y motivo.");
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        if (horaFin == null || horaFin.trim().isEmpty()) {
            horaFin = Horario.sumarUnaHora(horaInicio);
        }

        if (horaFin.compareTo(horaInicio) <= 0) {
            session.setAttribute("msg_error", "La hora fin debe ser posterior a la hora de inicio.");
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if (Horario.hayChoque(cn, idMovilizador, fecha, horaInicio, horaFin, null)) {
                session.setAttribute("msg_error", "Ese movilizador ya tiene una solicitud pendiente o aprobada en ese horario.");
                response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                return;
            }

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_MOV_SOLICITUD),0)+1 FROM MOV_SOLICITUD");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO MOV_SOLICITUD (ID_MOV_SOLICITUD, ID_MOVILIZADOR, ID_MOTIVO, FECHA, " +
                    "HORA_INICIO, HORA_FIN, IDUSUARIO, ID_DEPARTAMENTO, COMENTARIO, ESTADO) " +
                    "VALUES (?, ?, ?, TO_DATE(?,'YYYY-MM-DD'), ?, ?, ?, ?, ?, 'PENDIENTE')")) {
                st.setInt(1, idNuevo);
                st.setInt(2, Integer.parseInt(idMovilizador));
                st.setInt(3, Integer.parseInt(idMotivo));
                st.setString(4, fecha);
                st.setString(5, horaInicio);
                st.setString(6, horaFin);
                st.setInt(7, Integer.parseInt(idUsuario));
                st.setInt(8, Integer.parseInt(idDepartamento));
                st.setString(9, comentario);
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Solicitud de movilizacion #" + idNuevo + " registrada. Pendiente de aprobacion.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al registrar la solicitud: " + e.getMessage());
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
