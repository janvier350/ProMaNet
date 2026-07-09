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
import org.json.JSONObject;

@WebServlet(name = "MOV_VerificarDisponibilidad", urlPatterns = {"/MOV_VerificarDisponibilidad"})
public class MOV_VerificarDisponibilidad extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        JSONObject resultado = new JSONObject();

        if (session == null || session.getAttribute("usuario") == null
                || !PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) {
            resultado.put("disponible", false);
            resultado.put("error", "No autorizado");
            response.getWriter().write(resultado.toString());
            return;
        }

        String idMovilizador = request.getParameter("idMovilizador");
        String fecha = request.getParameter("fecha");
        String horaInicio = request.getParameter("horaInicio");
        String horaFin = request.getParameter("horaFin");
        String excluirId = request.getParameter("excluirId");

        if (idMovilizador == null || fecha == null || horaInicio == null || horaFin == null
                || horaFin.compareTo(horaInicio) <= 0) {
            resultado.put("disponible", false);
            resultado.put("error", "Datos incompletos");
            response.getWriter().write(resultado.toString());
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            boolean choque = Horario.hayChoque(cn, idMovilizador, fecha, horaInicio, horaFin, excluirId);
            resultado.put("disponible", !choque);
        } catch (Exception e) {
            e.printStackTrace();
            resultado.put("disponible", false);
            resultado.put("error", e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.getWriter().write(resultado.toString());
    }
}
