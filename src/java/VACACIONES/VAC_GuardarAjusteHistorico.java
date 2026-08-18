package VACACIONES;

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

// Carga un consumo historico de vacaciones (anterior a este modulo)
// para un periodo especifico de un empleado. Es lo que permite que el
// saldo calculado por VAC_CalculoSaldo arranque correcto en vez de
// asumir que nadie ha tomado vacaciones nunca.
@WebServlet(name = "VAC_GuardarAjusteHistorico", urlPatterns = {"/VAC_GuardarAjusteHistorico"})
public class VAC_GuardarAjusteHistorico extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idEmpleado = request.getParameter("idEmpleado");
        String numPeriodo = request.getParameter("numPeriodo");
        String diasGozados = request.getParameter("diasGozados");
        String fechaDesde = request.getParameter("fechaDesde"); // opcional, YYYY-MM-DD
        String fechaHasta = request.getParameter("fechaHasta"); // opcional, YYYY-MM-DD
        String observaciones = request.getParameter("observaciones");

        if (idEmpleado == null || numPeriodo == null || diasGozados == null
                || numPeriodo.trim().isEmpty() || diasGozados.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Datos incompletos");
            return;
        }

        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(ID_AJUSTE),0)+1 FROM VAC_HISTORICO_AJUSTE");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idNuevo = rsSec.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO VAC_HISTORICO_AJUSTE (ID_AJUSTE, ID_USUARIO, NUM_PERIODO, DIAS_GOZADOS, " +
                    "FECHA_DESDE, FECHA_HASTA, OBSERVACIONES, ID_USUARIO_REGISTRA, FECHA_REGISTRO) " +
                    "VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, SYSDATE)")) {
                st.setInt(1, idNuevo);
                st.setString(2, idEmpleado);
                st.setString(3, numPeriodo);
                st.setString(4, diasGozados);
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) st.setString(5, fechaDesde); else st.setNull(5, java.sql.Types.DATE);
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) st.setString(6, fechaHasta); else st.setNull(6, java.sql.Types.DATE);
                st.setString(7, observaciones);
                st.setInt(8, idGestor);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&msj=Ajuste registrado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_SaldoUsuario.jsp?id=" + idEmpleado + "&error=Error al registrar el ajuste");
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
