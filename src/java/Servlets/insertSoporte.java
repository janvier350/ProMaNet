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

// Crear un ticket de soporte.
//
// Fix historico (misma clase de bug que corregimos en INV_InsertarAsignacion,
// SOP_EditarSolicitud y InsertReporteTecnico): el codigo original hacia
// executeQuery() sobre un INSERT, lo que lanza SQLException sin ejecutar
// la operacion (Oracle driver: "statement did not return a result set").
// El catch se tragaba la excepcion con un printStackTrace y nunca se
// alcanzaba el commit, por eso los tickets no aparecian aunque la UI
// aparentaba exito. Pasa a usar PreparedStatement con bind params y
// executeUpdate.
//
// Ademas:
//  - Concatenaba texto libre al SQL (soporte, prioridad) -- vulnerabilidad
//    de SQL injection + rompia con un apostrofe. Pasa a bind.
//  - Chequeo por cargo hardcoded se reemplaza por nada (cualquier usuario
//    logueado puede crear un ticket -- la pantalla de Perfil.jsp y la
//    nueva SOP_NuevoTicket.jsp son abiertas; antes el filtro era
//    inconsistente con la UI).
//  - Secuencia por NVL(MAX)+1 en una transaccion unica, con lock
//    optimista -- si falla por duplicado, el UPDATE retorna 0 filas y
//    reintenta hasta 3 veces. Esto evita el caso #114 que detectamos.
@WebServlet(name = "insertSoporte", urlPatterns = {"/insertSoporte"})
public class insertSoporte extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp"); return;
        }

        String idUsuario = request.getParameter("idUsuario");
        String idEquipo  = request.getParameter("idEquipo");
        String prioridad = request.getParameter("prioridad");
        String soporte   = request.getParameter("soporte");

        if (idUsuario == null || idUsuario.trim().isEmpty()
                || idEquipo == null || idEquipo.trim().isEmpty()
                || prioridad == null || prioridad.trim().isEmpty()
                || soporte == null || soporte.trim().isEmpty()) {
            response.sendRedirect("Proyectos/Perfil.jsp?error=Faltan datos del ticket");
            return;
        }

        Connection cn = null;
        int idNuevo = -1;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base");

            // Reintentos para evitar el caso de IDSOPORTE duplicado si
            // dos usuarios insertan al mismo tiempo (ver SOP_SOPORTE_CAB
            // IDSOPORTE=114 historico). Hasta 3 intentos.
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
                    st.setInt(3, Integer.parseInt(idEquipo.trim()));
                    st.setString(4, soporte.trim());
                    st.setString(5, prioridad.trim());
                    st.executeUpdate();
                } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                    // Otro usuario tomo el mismo IDSOPORTE antes que nosotros.
                    // Reintentamos con el siguiente MAX.
                    idNuevo = -1;
                    if (intentos >= 3) throw dup;
                }
            }
            cn.commit();

            COMUN.LogActividad.registrar(request, "SOPORTES", "CREAR",
                    "Creo ticket de soporte #" + idNuevo + " (prioridad " + prioridad + ")");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Proyectos/Perfil.jsp?error=Error al crear ticket: "
                    + (e.getMessage() == null ? "" : e.getMessage().replaceAll("[\\r\\n]"," ").substring(0, Math.min(80, e.getMessage().length()))));
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        response.sendRedirect("Proyectos/PRO_Dashboard.jsp?msj="
                + java.net.URLEncoder.encode("Ticket #" + idNuevo + " creado", "UTF-8"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Si alguien entra por GET al servlet directo, se lo lleva al
        // formulario amigable en vez de romper.
        response.sendRedirect("Soportes/SOP_NuevoTicket.jsp");
    }
}
