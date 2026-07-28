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
import java.sql.Types;

@WebServlet(name = "CAP_ActualizarSeminario", urlPatterns = {"/CAP_ActualizarSeminario"})
public class CAP_ActualizarSeminario extends HttpServlet {

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
        String idSeminario = request.getParameter("idSeminario");
        String accion = request.getParameter("accion");

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            if ("eliminar".equals(accion) || "restaurar".equals(accion)) {
                String nuevoActivo = "restaurar".equals(accion) ? "A" : "I";
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE CAPACITACIONES_SEMINARIO SET ACTIVO = ? WHERE ID_SEMINARIO = ?")) {
                    st.setString(1, nuevoActivo);
                    st.setInt(2, Integer.parseInt(idSeminario.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito",
                        "restaurar".equals(accion) ? "Capacitacion restaurada." : "Capacitacion eliminada.");
            } else {
                String nombreSeminario = request.getParameter("nombreSeminario");
                String estadoPago = request.getParameter("estadoPago");

                if (nombreSeminario == null || nombreSeminario.trim().isEmpty()
                        || estadoPago == null || estadoPago.trim().isEmpty()) {
                    session.setAttribute("msg_error", "Debe indicar al menos el nombre del seminario y el estado.");
                    response.sendRedirect(request.getContextPath() + "/Capacitaciones/CAP_Seminarios.jsp");
                    return;
                }

                Integer idEmpresa = CAP_InsertarSeminario.parseInt(request.getParameter("idEmpresa"));
                String formaPago = request.getParameter("formaPago");
                String aprobacion = request.getParameter("aprobacion");
                String horario = request.getParameter("horario");
                String fechaCapacitacion = request.getParameter("fechaCapacitacion");
                Double duracionHoras = CAP_InsertarSeminario.parseDouble(request.getParameter("duracionHoras"));
                String modalidad = request.getParameter("modalidad");
                String ubicacion = request.getParameter("ubicacion");
                Integer noParticipantes = CAP_InsertarSeminario.parseInt(request.getParameter("noParticipantes"));
                String nombreParticipantes = request.getParameter("nombreParticipantes");
                Double subtotalD = CAP_InsertarSeminario.parseDouble(request.getParameter("subtotal"));
                Double ivaPorcentajeD = CAP_InsertarSeminario.parseDouble(request.getParameter("ivaPorcentaje"));
                Double ivaValorD = CAP_InsertarSeminario.parseDouble(request.getParameter("ivaValor"));
                Double totalFacturaD = CAP_InsertarSeminario.parseDouble(request.getParameter("totalFactura"));
                Double retencionD = CAP_InsertarSeminario.parseDouble(request.getParameter("retencion"));
                Double totalPagadoD = CAP_InsertarSeminario.parseDouble(request.getParameter("totalPagado"));
                Integer idCompaniaFactura = CAP_InsertarSeminario.parseInt(request.getParameter("idCompaniaFactura"));
                String fechaFacturaStr = request.getParameter("fechaFactura");

                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE CAPACITACIONES_SEMINARIO SET ID_EMPRESA = ?, NOMBRE_SEMINARIO = ?, " +
                        "ESTADO_PAGO = ?, FORMA_PAGO = ?, APROBACION = ?, HORARIO = ?, FECHA_CAPACITACION = ?, " +
                        "DURACION_HORAS = ?, MODALIDAD = ?, UBICACION = ?, NO_PARTICIPANTES = ?, " +
                        "NOMBRE_PARTICIPANTES = ?, SUBTOTAL = ?, IVA_PORCENTAJE = ?, IVA_VALOR = ?, " +
                        "TOTAL_FACTURA = ?, RETENCION = ?, TOTAL_PAGADO = ?, ID_COMPANIA_FACTURA = ?, " +
                        "FECHA_FACTURA = ? WHERE ID_SEMINARIO = ?")) {
                    if (idEmpresa != null) st.setInt(1, idEmpresa); else st.setNull(1, Types.INTEGER);
                    st.setString(2, nombreSeminario.trim());
                    st.setString(3, estadoPago.trim());
                    st.setString(4, formaPago != null && !formaPago.trim().isEmpty() ? formaPago.trim() : null);
                    st.setString(5, aprobacion != null ? aprobacion.trim() : null);
                    st.setString(6, horario != null ? horario.trim() : null);
                    st.setString(7, fechaCapacitacion != null ? fechaCapacitacion.trim() : null);
                    if (duracionHoras != null) st.setDouble(8, duracionHoras); else st.setNull(8, Types.NUMERIC);
                    st.setString(9, modalidad != null && !modalidad.trim().isEmpty() ? modalidad.trim() : null);
                    st.setString(10, ubicacion != null ? ubicacion.trim() : null);
                    if (noParticipantes != null) st.setInt(11, noParticipantes); else st.setNull(11, Types.INTEGER);
                    st.setString(12, nombreParticipantes != null ? nombreParticipantes.trim() : null);
                    st.setDouble(13, subtotalD != null ? subtotalD : 0);
                    st.setDouble(14, ivaPorcentajeD != null ? ivaPorcentajeD : 15);
                    st.setDouble(15, ivaValorD != null ? ivaValorD : 0);
                    st.setDouble(16, totalFacturaD != null ? totalFacturaD : 0);
                    st.setDouble(17, retencionD != null ? retencionD : 0);
                    st.setDouble(18, totalPagadoD != null ? totalPagadoD : 0);
                    if (idCompaniaFactura != null) st.setInt(19, idCompaniaFactura); else st.setNull(19, Types.INTEGER);
                    if (fechaFacturaStr != null && !fechaFacturaStr.trim().isEmpty()) {
                        st.setDate(20, Date.valueOf(fechaFacturaStr.trim()));
                    } else {
                        st.setNull(20, Types.DATE);
                    }
                    st.setInt(21, Integer.parseInt(idSeminario.trim()));
                    st.executeUpdate();
                }
                session.setAttribute("msg_exito", "Capacitacion actualizada.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg_error", "Error al actualizar: " + e.getMessage());
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
