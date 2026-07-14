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

@WebServlet(name = "MOV_ModificarHora", urlPatterns = {"/MOV_ModificarHora"})
public class MOV_ModificarHora extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        String idSolicitud = request.getParameter("idSolicitud");
        String fechaNueva = request.getParameter("fecha");
        String horaInicio = request.getParameter("horaInicio");
        String horaFin = request.getParameter("horaFin");
        String idMovilizadorNuevo = request.getParameter("idMovilizador");
        String idUsuarioSesion = (String) session.getAttribute("cod");
        boolean puedeGestionar = PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR");

        if (idSolicitud == null || horaInicio == null || horaFin == null
                || horaFin.compareTo(horaInicio) <= 0) {
            session.setAttribute("msg_error", "Datos invalidos para modificar la hora.");
            response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String idMovilizadorActual = null, fechaActual = null, estado = null, idDueno = null;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT ID_MOVILIZADOR, TO_CHAR(FECHA,'YYYY-MM-DD'), ESTADO, IDUSUARIO " +
                    "FROM MOV_SOLICITUD WHERE ID_MOV_SOLICITUD = ?")) {
                st.setInt(1, Integer.parseInt(idSolicitud));
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        idMovilizadorActual = rs.getString(1);
                        fechaActual = rs.getString(2);
                        estado = rs.getString(3);
                        idDueno = rs.getString(4);
                    }
                }
            }

            if (idMovilizadorActual == null) {
                session.setAttribute("msg_error", "La solicitud no existe.");
                response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                return;
            }

            boolean esDueno = idUsuarioSesion.equals(idDueno);
            boolean autorizado = puedeGestionar || (esDueno && "PENDIENTE".equals(estado));
            if (!autorizado) {
                response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
                return;
            }

            // Solo quien gestiona (Smoran) puede reagendar la fecha o
            // cambiar el movilizador; el solicitante solo puede ajustar
            // la hora del mismo dia con el mismo movilizador.
            String fecha = (puedeGestionar && fechaNueva != null && !fechaNueva.trim().isEmpty())
                    ? fechaNueva : fechaActual;
            String idMovilizador = (puedeGestionar && idMovilizadorNuevo != null && !idMovilizadorNuevo.trim().isEmpty())
                    ? idMovilizadorNuevo : idMovilizadorActual;

            if (Horario.hayChoque(cn, idMovilizador, fecha, horaInicio, horaFin, idSolicitud)) {
                session.setAttribute("msg_error", "Ese movilizador ya tiene otra solicitud en ese horario.");
                response.sendRedirect(request.getContextPath() + "/Movilizacion/MOV_Calendario.jsp");
                return;
            }

            try (PreparedStatement stUpd = cn.prepareStatement(
                    "UPDATE MOV_SOLICITUD SET FECHA = TO_DATE(?,'YYYY-MM-DD'), HORA_INICIO = ?, HORA_FIN = ?, ID_MOVILIZADOR = ? WHERE ID_MOV_SOLICITUD = ?")) {
                stUpd.setString(1, fecha);
                stUpd.setString(2, horaInicio);
                stUpd.setString(3, horaFin);
                stUpd.setInt(4, Integer.parseInt(idMovilizador));
                stUpd.setInt(5, Integer.parseInt(idSolicitud));
                stUpd.executeUpdate();
            }

            session.setAttribute("msg_exito", "Hora actualizada correctamente.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al modificar la hora: " + e.getMessage());
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
