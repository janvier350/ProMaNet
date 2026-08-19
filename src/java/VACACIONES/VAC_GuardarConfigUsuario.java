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

// Fase 1 del modulo de Vacaciones: guarda/actualiza la fecha de
// ingreso real y el jefe directo de un empleado. Es un simple upsert
// (MERGE) sobre VAC_CONFIG_USUARIO -- todavia no hay calculo de saldo
// ni solicitudes, eso es la Fase 2/3.
@WebServlet(name = "VAC_GuardarConfigUsuario", urlPatterns = {"/VAC_GuardarConfigUsuario"})
public class VAC_GuardarConfigUsuario extends HttpServlet {

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
        String fechaIngreso = request.getParameter("fechaIngreso"); // YYYY-MM-DD
        String idJefe = request.getParameter("idJefe"); // puede venir vacio
        String cedula = request.getParameter("cedula"); // puede venir vacia
        String empresaIess = request.getParameter("empresaIess"); // puede venir vacia

        if (idEmpleado == null || fechaIngreso == null || fechaIngreso.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_ConfigUsuarios.jsp?error=Falta el empleado o la fecha de ingreso");
            return;
        }
        if (idJefe != null && idJefe.trim().equals(idEmpleado.trim())) {
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_ConfigUsuarios.jsp?error=Un empleado no puede ser su propio jefe directo");
            return;
        }

        int idGestor = -1;
        try { idGestor = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");

            try (PreparedStatement st = cn.prepareStatement(
                    "MERGE INTO VAC_CONFIG_USUARIO v USING (SELECT ? AS ID_USUARIO FROM DUAL) src " +
                    "ON (v.ID_USUARIO = src.ID_USUARIO) " +
                    "WHEN MATCHED THEN UPDATE SET " +
                    "  FECHA_INGRESO = TO_DATE(?, 'YYYY-MM-DD'), " +
                    "  ID_JEFE_DIRECTO = ?, " +
                    "  CEDULA = ?, " +
                    "  EMPRESA_IESS = ?, " +
                    "  ID_USUARIO_ACTUALIZA = ?, " +
                    "  FECHA_ACTUALIZACION = SYSDATE " +
                    "WHEN NOT MATCHED THEN INSERT (ID_USUARIO, FECHA_INGRESO, ID_JEFE_DIRECTO, CEDULA, EMPRESA_IESS, ID_USUARIO_ACTUALIZA, FECHA_ACTUALIZACION) " +
                    "VALUES (?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, SYSDATE)")) {
                st.setString(1, idEmpleado);
                st.setString(2, fechaIngreso);
                if (idJefe != null && !idJefe.trim().isEmpty()) st.setString(3, idJefe); else st.setNull(3, java.sql.Types.NUMERIC);
                if (cedula != null && !cedula.trim().isEmpty()) st.setString(4, cedula.trim()); else st.setNull(4, java.sql.Types.VARCHAR);
                if (empresaIess != null && !empresaIess.trim().isEmpty()) st.setString(5, empresaIess.trim()); else st.setNull(5, java.sql.Types.VARCHAR);
                st.setInt(6, idGestor);
                st.setString(7, idEmpleado);
                st.setString(8, fechaIngreso);
                if (idJefe != null && !idJefe.trim().isEmpty()) st.setString(9, idJefe); else st.setNull(9, java.sql.Types.NUMERIC);
                if (cedula != null && !cedula.trim().isEmpty()) st.setString(10, cedula.trim()); else st.setNull(10, java.sql.Types.VARCHAR);
                if (empresaIess != null && !empresaIess.trim().isEmpty()) st.setString(11, empresaIess.trim()); else st.setNull(11, java.sql.Types.VARCHAR);
                st.setInt(12, idGestor);
                st.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_ConfigUsuarios.jsp?msj=Datos guardados correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Vacaciones/VAC_ConfigUsuarios.jsp?error=Error al guardar");
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
