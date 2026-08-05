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

@WebServlet(name = "AUD_InsertarFechaCorte", urlPatterns = {"/AUD_InsertarFechaCorte"})
public class AUD_InsertarFechaCorte extends HttpServlet {

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

        String corte = request.getParameter("corte");
        if (corte == null || corte.trim().isEmpty()) {
            response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?error=La fecha de corte es requerida");
            return;
        }

        int idGestor;
        try {
            idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim());
        } catch (Exception e) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            // Solo una fecha de corte activa por mes.
            try (PreparedStatement stVerificar = cn.prepareStatement(
                    "SELECT COUNT(*) FROM AUD_FECHA_CORTE_ANTICIPO " +
                    "WHERE TO_CHAR(FECHA_CORTE, 'YYYY-MM') = TO_CHAR(TO_DATE(?, 'YYYY-MM-DD'), 'YYYY-MM') " +
                    "AND ESTADO = 'A'")) {
                stVerificar.setString(1, corte);
                try (ResultSet rsVerificar = stVerificar.executeQuery()) {
                    if (rsVerificar.next() && rsVerificar.getInt(1) > 0) {
                        cn.rollback();
                        response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?error=Ya existe una fecha de corte activa para ese mes");
                        return;
                    }
                }
            }

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(ID_FECHA_CORTE),0)+1 FROM AUD_FECHA_CORTE_ANTICIPO");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idNuevo = rsSec.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO AUD_FECHA_CORTE_ANTICIPO (ID_FECHA_CORTE, FECHA_CORTE, ESTADO, ID_USUARIO) " +
                    "VALUES (?, TO_DATE(?, 'YYYY-MM-DD'), 'A', ?)")) {
                st.setInt(1, idNuevo);
                st.setString(2, corte);
                st.setInt(3, idGestor);
                st.executeUpdate();
            }

            cn.commit();
            response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?msj=Fecha de corte registrada correctamente");
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect("../Auditoria/AUD_Dashboard.jsp?error=Error al registrar la fecha de corte");
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
