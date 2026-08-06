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

// Solicitud de anticipo del modulo exclusivo de Auditoria. El sueldo se
// lee siempre del lado servidor (USUARIO.SUELDO), nunca del formulario,
// para que nadie pueda inflar su propio tope enviando un sueldo falso.
@WebServlet(name = "AUD_InsertarAnticipo", urlPatterns = {"/AUD_InsertarAnticipo"})
public class AUD_InsertarAnticipo extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        int idUsuario;
        try {
            idUsuario = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        double anticipo;
        try {
            anticipo = Double.parseDouble(request.getParameter("anticipo"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=Monto invalido");
            return;
        }
        if (anticipo <= 0) {
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=El monto debe ser mayor a cero");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // 1. Plazo vigente.
            try (PreparedStatement stCorte = cn.prepareStatement(
                    "SELECT FECHA_CORTE FROM (SELECT FECHA_CORTE FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1");
                 ResultSet rsCorte = stCorte.executeQuery()) {
                if (rsCorte.next()) {
                    java.sql.Date fechaCorte = rsCorte.getDate(1);
                    if (fechaCorte != null && new java.util.Date().after(fechaCorte)) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=El plazo para solicitar anticipos ya vencio");
                        return;
                    }
                }
            }

            // 2. Sueldo real, del lado servidor.
            double sueldo = 0;
            try (PreparedStatement stSueldo = cn.prepareStatement("SELECT SUELDO FROM USUARIO WHERE IDUSUARIO = ?")) {
                stSueldo.setInt(1, idUsuario);
                try (ResultSet rsSueldo = stSueldo.executeQuery()) {
                    if (rsSueldo.next()) sueldo = rsSueldo.getDouble(1);
                }
            }
            if (sueldo <= 0) {
                cn.rollback();
                response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=No tienes un sueldo asignado, contacta a RRHH");
                return;
            }

            // 3. Tope: 50% del sueldo.
            double limite = sueldo * 0.50;
            if (anticipo > limite) {
                cn.rollback();
                response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=El monto excede el 50% del sueldo ($" + limite + ")");
                return;
            }

            // 4. Solo 1 solicitud pendiente a la vez.
            try (PreparedStatement stContar = cn.prepareStatement(
                    "SELECT COUNT(*) FROM AUD_ANTICIPOS WHERE ID_USUARIO = ? AND ESTADO = 'PENDIENTE'")) {
                stContar.setInt(1, idUsuario);
                try (ResultSet rsContar = stContar.executeQuery()) {
                    if (rsContar.next() && rsContar.getInt(1) >= 1) {
                        cn.rollback();
                        response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=Ya tienes una solicitud pendiente");
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
                st.setInt(2, idUsuario);
                st.setDouble(3, sueldo);
                st.setDouble(4, anticipo);
                st.executeUpdate();
            }

            cn.commit();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?msj=Solicitud registrada correctamente");
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Auditoria/AUD_SolicitarAnticipo.jsp?error=Error al registrar la solicitud");
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
