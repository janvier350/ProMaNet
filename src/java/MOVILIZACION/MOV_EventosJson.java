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
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "MOV_EventosJson", urlPatterns = {"/MOV_EventosJson"})
public class MOV_EventosJson extends HttpServlet {

    private static String colorEstado(String estado) {
        switch (estado) {
            case "PENDIENTE": return "#ffc107";
            case "APROBADA": return "#28a745";
            case "RECHAZADA": return "#dc3545";
            case "CANCELADA": return "#6c757d";
            case "MOVILIZADO": return "#17a2b8";
            default: return "#6c757d";
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        JSONArray eventos = new JSONArray();

        if (session == null || session.getAttribute("usuario") == null
                || !PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) {
            response.getWriter().write(eventos.toString());
            return;
        }

        String start = request.getParameter("start");
        String end = request.getParameter("end");
        if (start != null && start.length() >= 10) start = start.substring(0, 10);
        if (end != null && end.length() >= 10) end = end.substring(0, 10);
        String estadoFiltro = request.getParameter("estado");
        if (estadoFiltro != null && estadoFiltro.trim().isEmpty()) estadoFiltro = null;

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            String sql = "SELECT s.ID_MOV_SOLICITUD, TO_CHAR(s.FECHA,'YYYY-MM-DD'), s.HORA_INICIO, s.HORA_FIN, " +
                    "s.ESTADO, s.COMENTARIO, s.MOTIVO_RECHAZO, m.NOMBRE AS MOVILIZADOR, mo.DESCRIPCION AS MOTIVO, " +
                    "u.NOMBRE||' '||u.APELLIDOS AS SOLICITANTE, u.IDUSUARIO, d.DEPARTAMENTO, " +
                    "ug.NOMBRE||' '||ug.APELLIDOS AS GESTIONADO_POR, TO_CHAR(s.FECHA_SOLICITUD,'DD/MM/YYYY HH24:MI') AS FECHA_SOLICITUD, " +
                    "s.ID_MOVILIZADOR, de.DESCRIPCION AS DESTINO, s.ID_DESTINO, s.ID_MOTIVO " +
                    "FROM MOV_SOLICITUD s " +
                    "JOIN MOV_MOVILIZADOR m ON s.ID_MOVILIZADOR = m.ID_MOVILIZADOR " +
                    "JOIN MOV_MOTIVO mo ON s.ID_MOTIVO = mo.ID_MOTIVO " +
                    "JOIN USUARIO u ON s.IDUSUARIO = u.IDUSUARIO " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON TO_CHAR(s.ID_DEPARTAMENTO) = d.ID_DEPARTAMENTO " +
                    "LEFT JOIN USUARIO ug ON s.IDUSUARIO_GESTIONA = ug.IDUSUARIO " +
                    "LEFT JOIN MOV_DESTINO de ON s.ID_DESTINO = de.ID_DESTINO " +
                    "WHERE (? IS NULL OR TO_CHAR(s.FECHA,'YYYY-MM-DD') >= ?) " +
                    "AND (? IS NULL OR TO_CHAR(s.FECHA,'YYYY-MM-DD') < ?) " +
                    "AND (? IS NULL OR s.ESTADO = ?) " +
                    "ORDER BY s.FECHA, s.HORA_INICIO";

            try (PreparedStatement st = cn.prepareStatement(sql)) {
                st.setString(1, start); st.setString(2, start);
                st.setString(3, end); st.setString(4, end);
                st.setString(5, estadoFiltro); st.setString(6, estadoFiltro);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        String fecha = rs.getString(2);
                        String horaInicio = rs.getString(3);
                        String horaFin = rs.getString(4);
                        String estado = rs.getString(5);

                        String destinoTitulo = rs.getString(16);

                        int idSolicitante = rs.getInt(11);
                        String motivoStr = rs.getString(9);

                        JSONObject ev = new JSONObject();
                        ev.put("id", rs.getInt(1));
                        ev.put("title", rs.getString(10)
                                + (motivoStr != null ? " - " + motivoStr : "")
                                + (destinoTitulo != null ? " - " + destinoTitulo : ""));
                        ev.put("start", fecha + "T" + horaInicio);
                        ev.put("end", fecha + "T" + horaFin);
                        ev.put("color", colorEstado(estado));

                        JSONObject props = new JSONObject();
                        props.put("estado", estado);
                        props.put("fecha", fecha);
                        props.put("horaInicio", horaInicio);
                        props.put("horaFin", horaFin);
                        props.put("movilizador", rs.getString(8));
                        props.put("motivo", motivoStr != null ? motivoStr : "");
                        props.put("solicitante", rs.getString(10));
                        props.put("idUsuario", idSolicitante);
                        props.put("departamento", rs.getString(12) != null ? rs.getString(12) : "");
                        props.put("comentario", rs.getString(6) != null ? rs.getString(6) : "");
                        props.put("gestionadoPor", rs.getString(13) != null ? rs.getString(13) : "");
                        props.put("motivoRechazo", rs.getString(7) != null ? rs.getString(7) : "");
                        props.put("fechaSolicitud", rs.getString(14));
                        props.put("idMovilizador", rs.getInt(15));
                        props.put("destino", rs.getString(16) != null ? rs.getString(16) : "-");
                        props.put("idDestino", rs.getInt(17));
                        props.put("idMotivo", rs.getInt(18));
                        ev.put("extendedProps", props);

                        eventos.put(ev);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.getWriter().write(eventos.toString());
    }
}
