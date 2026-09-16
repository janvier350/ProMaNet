/*
 * Guardar (crear o actualizar) un periferico.
 *
 * Form: web/Inventario/INV_Periferico_Editar.jsp
 *  - Sin idPeriferico  -> INSERT (nuevo)
 *  - Con idPeriferico   -> UPDATE (edicion)
 *
 * Se usa PreparedStatement en todo (no concat) y una sola conexion por
 * request. El insert obtiene la secuencia con NVL(MAX(ID_PERIFERICO),0)+1
 * -- mismo patron que el resto del proyecto para no depender de secuencias
 * Oracle nombradas que ya se hayan creado o no.
 */
package INVENTARIO;

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
import java.sql.Types;

@WebServlet(name = "INV_Periferico_Guardar", urlPatterns = {"/INV_Periferico_Guardar"})
public class INV_Periferico_Guardar extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        String idPeriferico = request.getParameter("idPeriferico");
        String idTipo       = request.getParameter("idTipo");
        String estado       = request.getParameter("estado");
        String marca        = request.getParameter("marca");
        String modelo       = request.getParameter("modelo");
        String serial       = request.getParameter("serial");
        String fechaCompra  = request.getParameter("fechaCompra");   // yyyy-MM-dd
        String ubicacion    = request.getParameter("ubicacion");
        String empresa      = request.getParameter("empresa");
        String observaciones= request.getParameter("observaciones");

        if (idTipo == null || idTipo.trim().isEmpty()
                || estado == null || estado.trim().isEmpty()) {
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Datos incompletos");
            return;
        }

        boolean esEdicion = idPeriferico != null && !idPeriferico.trim().isEmpty();

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No hay conexion a la base");
            cn.setAutoCommit(false);

            if (esEdicion) {
                String sql = "UPDATE INV_PERIFERICO SET " +
                        "ID_TIPO = ?, MARCA = ?, MODELO = ?, SERIAL = ?, " +
                        "FECHACOMPRA = TO_DATE(?, 'YYYY-MM-DD'), UBICACIONOFICINA = ?, " +
                        "EMPRESA = ?, OBSERVACIONES = ?, ESTADO = ? " +
                        "WHERE ID_PERIFERICO = ? AND ESTADO_AI = 'A'";
                try (PreparedStatement st = cn.prepareStatement(sql)) {
                    st.setInt(1, Integer.parseInt(idTipo.trim()));
                    setStr(st, 2, marca);
                    setStr(st, 3, modelo);
                    setStr(st, 4, serial);
                    setStr(st, 5, nullIfBlank(fechaCompra));
                    setStr(st, 6, ubicacion);
                    setStr(st, 7, empresa);
                    setStr(st, 8, observaciones);
                    st.setString(9, estado);
                    st.setInt(10, Integer.parseInt(idPeriferico.trim()));
                    st.executeUpdate();
                }
            } else {
                int nuevoId = 1;
                try (PreparedStatement stSec = cn.prepareStatement(
                        "SELECT NVL(MAX(ID_PERIFERICO),0)+1 FROM INV_PERIFERICO");
                     ResultSet rsSec = stSec.executeQuery()) {
                    if (rsSec.next()) nuevoId = rsSec.getInt(1);
                }

                String sql = "INSERT INTO INV_PERIFERICO (" +
                        "ID_PERIFERICO, ID_TIPO, MARCA, MODELO, SERIAL, FECHACOMPRA, " +
                        "UBICACIONOFICINA, EMPRESA, OBSERVACIONES, ESTADO, ESTADO_AI) " +
                        "VALUES (?, ?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, 'A')";
                try (PreparedStatement st = cn.prepareStatement(sql)) {
                    st.setInt(1, nuevoId);
                    st.setInt(2, Integer.parseInt(idTipo.trim()));
                    setStr(st, 3, marca);
                    setStr(st, 4, modelo);
                    setStr(st, 5, serial);
                    setStr(st, 6, nullIfBlank(fechaCompra));
                    setStr(st, 7, ubicacion);
                    setStr(st, 8, empresa);
                    setStr(st, 9, observaciones);
                    st.setString(10, estado);
                    st.executeUpdate();
                }
                idPeriferico = String.valueOf(nuevoId);
            }

            cn.commit();
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
            response.sendRedirect("Inventario/INV_Perifericos.jsp?error=Error al guardar");
            return;
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }

        // Si es alta, redirige al editar del nuevo id para permitir subir la foto.
        if (esEdicion) {
            response.sendRedirect("Inventario/INV_Perifericos.jsp?ok=Actualizado");
        } else {
            response.sendRedirect("Inventario/INV_Periferico_Editar.jsp?idPeriferico=" + idPeriferico + "&ok=Creado");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Inventario/INV_Perifericos.jsp");
    }

    private static void setStr(PreparedStatement st, int idx, String v) throws java.sql.SQLException {
        if (v == null || v.trim().isEmpty()) st.setNull(idx, Types.VARCHAR);
        else st.setString(idx, v.trim());
    }
    private static String nullIfBlank(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}
