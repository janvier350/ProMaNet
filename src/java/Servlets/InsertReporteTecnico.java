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

// Cierra un ticket registrando el reporte tecnico. Lo marca como
// ATENDIDO y guarda quien lo atendio (TECNICO = login) + fecha.
//
// Fix historico: antes concatenaba el texto del reporte directo al SQL
// -- un apostrofe lo rompia y era vector de SQL injection. Ahora usa
// PreparedStatement. Tambien se setea FECHA_PRIMERA_ATENCION si no
// estaba, para poder calcular tiempos de respuesta.
@WebServlet(name = "InsertReporteTecnico", urlPatterns = {"/InsertReporteTecnico"})
public class InsertReporteTecnico extends HttpServlet {

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

        String usuarioLogin   = (String) session.getAttribute("usuario");
        String idSolicitudTxt = request.getParameter("idSolicitudTicket");
        String reporte        = request.getParameter("reporte");

        if (idSolicitudTxt == null || idSolicitudTxt.trim().isEmpty()) {
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Falta idSolicitud");
            return;
        }

        Integer idTecnicoAsignado = null;
        try {
            Object cod = session.getAttribute("cod");
            if (cod != null) idTecnicoAsignado = Integer.parseInt(cod.toString().trim());
        } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            // Si el ticket no tenia FECHA_PRIMERA_ATENCION, la ponemos
            // al mismo tiempo que lo cerramos (caso tipico: se atiende
            // de una sola vez sin pasar por EN_PROGRESO). Si ya estaba
            // seteada (porque alguien lo tomo antes y recien ahora lo
            // cierra), no se pisa.
            try (PreparedStatement st = cn.prepareStatement(
                    "UPDATE SOP_SOPORTE_CAB SET " +
                    "  REPORTE = ?, " +
                    "  ESTADO = 'ATENDIDO', " +
                    "  FECHA_REPORTE = SYSDATE, " +
                    "  TECNICO = ?, " +
                    "  ID_TECNICO_ASIGNADO = NVL(ID_TECNICO_ASIGNADO, ?), " +
                    "  FECHA_PRIMERA_ATENCION = NVL(FECHA_PRIMERA_ATENCION, SYSDATE) " +
                    "WHERE IDSOPORTE = ?")) {
                st.setString(1, reporte);
                st.setString(2, usuarioLogin);
                if (idTecnicoAsignado == null) st.setNull(3, java.sql.Types.NUMERIC);
                else                           st.setInt(3, idTecnicoAsignado);
                st.setInt(4, Integer.parseInt(idSolicitudTxt.trim()));
                st.executeUpdate();
            }
            cn.commit();

            COMUN.LogActividad.registrar(request, "SOPORTES", "APROBAR",
                    "Atendio y cerro ticket #" + idSolicitudTxt);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?error=Error al registrar el reporte");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Soportes/SOP_ListaSolicitudes.jsp?msj=Reporte registrado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
