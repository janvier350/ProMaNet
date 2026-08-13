package AUDITORIA;

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

// Registrar un anticipo a nombre de otro ejecutivo (solo gestor). Pensado
// para gente que no tiene como auto-solicitar su anticipo en ProMaNet
// (ej. personal de servicios generales sin usuario/computadora): el
// gestor lo registra el mismo cuando toca procesar los anticipos del mes.
// Restringido igual que AUD_AsignarSueldo: solo a ejecutivos que ya
// tienen acceso al modulo (mismo departamento u concesion individual).
@WebServlet(name = "AUD_InsertarAnticipoManual", urlPatterns = {"/AUD_InsertarAnticipoManual"})
public class AUD_InsertarAnticipoManual extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idEjecutivo = request.getParameter("idEjecutivo");
        double anticipo;
        try {
            anticipo = Double.parseDouble(request.getParameter("anticipo"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Monto invalido");
            return;
        }
        if (idEjecutivo == null || anticipo <= 0) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Datos incompletos");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // 1. El ejecutivo debe tener acceso al modulo (mismo chequeo
            // que AUD_AsignarSueldo: departamento con permiso o concesion
            // individual, sin una revocacion individual).
            double sueldo = -1;
            try (PreparedStatement stCheck = cn.prepareStatement(
                    "SELECT u.SUELDO FROM USUARIO u WHERE u.IDUSUARIO = ? AND (" +
                    "  EXISTS (SELECT 1 FROM ADM_DEPARTAMENTO d JOIN APP_DEPARTAMENTO_PERMISO dp ON UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO) " +
                    "          JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO " +
                    "          WHERE d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO AND p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G') " +
                    "  OR EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO " +
                    "             WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up.TIPO = 'G' AND up.IDUSUARIO = u.IDUSUARIO) " +
                    ") AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up2 JOIN APP_PERMISO p2 ON p2.ID_PERMISO = up2.ID_PERMISO " +
                    "                  WHERE p2.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up2.TIPO = 'D' AND up2.IDUSUARIO = u.IDUSUARIO)")) {
                stCheck.setString(1, idEjecutivo);
                try (ResultSet rsCheck = stCheck.executeQuery()) {
                    if (!rsCheck.next()) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ese ejecutivo no tiene acceso al modulo de Anticipos Auditoria");
                        return;
                    }
                    sueldo = rsCheck.getDouble(1);
                }
            }
            if (sueldo <= 0) {
                cn.rollback();
                response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ese ejecutivo no tiene sueldo asignado");
                return;
            }

            // 2. Plazo vigente.
            try (PreparedStatement stCorte = cn.prepareStatement(
                    "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1");
                 ResultSet rsCorte = stCorte.executeQuery()) {
                if (rsCorte.next()) {
                    java.sql.Date fechaCorte = rsCorte.getDate(1);
                    if (fechaCorte != null && new java.util.Date().after(fechaCorte)) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=El plazo para registrar anticipos ya vencio");
                        return;
                    }
                }
            }

            // 3. Tope: 50% del sueldo.
            double limite = sueldo * 0.50;
            if (anticipo > limite) {
                cn.rollback();
                response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=El monto excede el 50% del sueldo ($" + limite + ")");
                return;
            }

            // 4. Solo 1 solicitud pendiente a la vez.
            try (PreparedStatement stContar = cn.prepareStatement(
                    "SELECT COUNT(*) FROM AUD_ANTICIPOS WHERE ID_USUARIO = ? AND ESTADO = 'PENDIENTE'")) {
                stContar.setString(1, idEjecutivo);
                try (ResultSet rsContar = stContar.executeQuery()) {
                    if (rsContar.next() && rsContar.getInt(1) >= 1) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Ese ejecutivo ya tiene una solicitud pendiente");
                        return;
                    }
                }
            }

            // 5. Insertar.
            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(ID_AUD_ANTICIPO),0)+1 FROM AUD_ANTICIPOS");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idNuevo = rsSec.getInt(1);
            }
            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO AUD_ANTICIPOS (ID_AUD_ANTICIPO, ID_USUARIO, SUELDO, ANTICIPO, FECHA_SOLICITUD, ESTADO) " +
                    "VALUES (?, ?, ?, ?, SYSDATE, 'PENDIENTE')")) {
                st.setInt(1, idNuevo);
                st.setString(2, idEjecutivo);
                st.setDouble(3, sueldo);
                st.setDouble(4, anticipo);
                st.executeUpdate();
            }

            cn.commit();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?msj=Anticipo registrado correctamente");
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_Dashboard.jsp?error=Error al registrar el anticipo");
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
