package CAPACITACIONES;

import COMUN.PermisoHelper;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;

@WebServlet(name = "CAP_InsertarSeminario", urlPatterns = {"/CAP_InsertarSeminario"})
public class CAP_InsertarSeminario extends HttpServlet {

    static Integer parseInt(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    static Double parseDouble(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Double.parseDouble(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!PermisoHelper.tiene(session, "CAPACITACIONES_ACCESO")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String nombreSeminario = request.getParameter("nombreSeminario");
        String estadoPago = request.getParameter("estadoPago");
        String idUsuario = (String) session.getAttribute("cod");

        if (nombreSeminario == null || nombreSeminario.trim().isEmpty()
                || estadoPago == null || estadoPago.trim().isEmpty()) {
            session.setAttribute("msg_error", "Debe indicar al menos el nombre del seminario y el estado.");
            response.sendRedirect(request.getContextPath() + "/Capacitaciones/CAP_Seminarios.jsp");
            return;
        }

        Integer idEmpresa = parseInt(request.getParameter("idEmpresa"));
        String formaPago = request.getParameter("formaPago");
        String aprobacion = request.getParameter("aprobacion");
        String horario = request.getParameter("horario");
        String fechaCapacitacion = request.getParameter("fechaCapacitacion");
        Double duracionHoras = parseDouble(request.getParameter("duracionHoras"));
        String modalidad = request.getParameter("modalidad");
        String ubicacion = request.getParameter("ubicacion");
        Integer noParticipantes = parseInt(request.getParameter("noParticipantes"));
        String nombreParticipantes = request.getParameter("nombreParticipantes");
        double subtotal = parseDouble(request.getParameter("subtotal")) != null ? parseDouble(request.getParameter("subtotal")) : 0;
        double ivaPorcentaje = parseDouble(request.getParameter("ivaPorcentaje")) != null ? parseDouble(request.getParameter("ivaPorcentaje")) : 15;
        double ivaValor = parseDouble(request.getParameter("ivaValor")) != null ? parseDouble(request.getParameter("ivaValor")) : 0;
        double totalFactura = parseDouble(request.getParameter("totalFactura")) != null ? parseDouble(request.getParameter("totalFactura")) : 0;
        double retencion = parseDouble(request.getParameter("retencion")) != null ? parseDouble(request.getParameter("retencion")) : 0;
        double totalPagado = parseDouble(request.getParameter("totalPagado")) != null ? parseDouble(request.getParameter("totalPagado")) : 0;
        String companiaFactura = request.getParameter("companiaFactura");
        String fechaFacturaStr = request.getParameter("fechaFactura");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            int idNuevo = 1;
            try (PreparedStatement stSec = cn.prepareStatement(
                    "SELECT NVL(MAX(ID_SEMINARIO),0)+1 FROM CAPACITACIONES_SEMINARIO");
                 ResultSet rs = stSec.executeQuery()) {
                if (rs.next()) idNuevo = rs.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO CAPACITACIONES_SEMINARIO (ID_SEMINARIO, ID_EMPRESA, NOMBRE_SEMINARIO, " +
                    "ESTADO_PAGO, FORMA_PAGO, APROBACION, HORARIO, FECHA_CAPACITACION, DURACION_HORAS, " +
                    "MODALIDAD, UBICACION, NO_PARTICIPANTES, NOMBRE_PARTICIPANTES, SUBTOTAL, IVA_PORCENTAJE, " +
                    "IVA_VALOR, TOTAL_FACTURA, RETENCION, TOTAL_PAGADO, COMPANIA_FACTURA, FECHA_FACTURA, " +
                    "ID_USUARIO_CREA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
                st.setInt(1, idNuevo);
                if (idEmpresa != null) st.setInt(2, idEmpresa); else st.setNull(2, Types.INTEGER);
                st.setString(3, nombreSeminario.trim());
                st.setString(4, estadoPago.trim());
                st.setString(5, formaPago != null && !formaPago.trim().isEmpty() ? formaPago.trim() : null);
                st.setString(6, aprobacion != null ? aprobacion.trim() : null);
                st.setString(7, horario != null ? horario.trim() : null);
                st.setString(8, fechaCapacitacion != null ? fechaCapacitacion.trim() : null);
                if (duracionHoras != null) st.setDouble(9, duracionHoras); else st.setNull(9, Types.NUMERIC);
                st.setString(10, modalidad != null && !modalidad.trim().isEmpty() ? modalidad.trim() : null);
                st.setString(11, ubicacion != null ? ubicacion.trim() : null);
                if (noParticipantes != null) st.setInt(12, noParticipantes); else st.setNull(12, Types.INTEGER);
                st.setString(13, nombreParticipantes != null ? nombreParticipantes.trim() : null);
                st.setDouble(14, subtotal);
                st.setDouble(15, ivaPorcentaje);
                st.setDouble(16, ivaValor);
                st.setDouble(17, totalFactura);
                st.setDouble(18, retencion);
                st.setDouble(19, totalPagado);
                st.setString(20, companiaFactura != null ? companiaFactura.trim() : null);
                if (fechaFacturaStr != null && !fechaFacturaStr.trim().isEmpty()) {
                    st.setDate(21, Date.valueOf(fechaFacturaStr.trim()));
                } else {
                    st.setNull(21, Types.DATE);
                }
                st.setInt(22, Integer.parseInt(idUsuario.trim()));
                st.executeUpdate();
            }

            session.setAttribute("msg_exito", "Capacitacion #" + idNuevo + " registrada.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al registrar: " + e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        response.sendRedirect(request.getContextPath() + "/Capacitaciones/CAP_Seminarios.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Capacitaciones/CAP_Seminarios.jsp");
    }
}
