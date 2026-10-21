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

// Ajuste de stock de un producto de suministros: SUMA una cantidad a la
// existencia (caso tipico: el producto esta en 0 porque llego en cajas y
// solo hay que cargarle el stock) y deja constancia en
// INV_SUMINISTRO_AJUSTE (producto, cantidad, existencia antes/despues,
// motivo, usuario, fecha). Mismo permiso que registrar ingresos.
@WebServlet(name = "INV_AjustarStock", urlPatterns = {"/INV_AjustarStock"})
public class INV_AjustarStock extends HttpServlet {

    private static final int MAX_CANTIDAD = 100000;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }
        if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_INGRESOS")) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String volver = request.getContextPath() + "/Inventario/INV_Existencias_Dashboard.jsp";

        int idProducto, cantidad;
        try {
            idProducto = Integer.parseInt(request.getParameter("idProducto").trim());
            cantidad = Integer.parseInt(request.getParameter("cantidad").trim());
        } catch (Exception e) {
            session.setAttribute("msg_error", "Datos invalidos para el ajuste de stock.");
            response.sendRedirect(volver);
            return;
        }
        if (cantidad <= 0 || cantidad > MAX_CANTIDAD) {
            session.setAttribute("msg_error", "La cantidad debe estar entre 1 y " + MAX_CANTIDAD + ".");
            response.sendRedirect(volver);
            return;
        }
        String motivo = request.getParameter("motivo");
        if (motivo == null || motivo.trim().isEmpty()) {
            session.setAttribute("msg_error", "Indica el motivo del ajuste.");
            response.sendRedirect(volver);
            return;
        }
        motivo = motivo.trim();
        if (motivo.length() > 100) motivo = motivo.substring(0, 100);
        String obs = request.getParameter("observacion");
        obs = (obs == null || obs.trim().isEmpty()) ? null : (obs.trim().length() > 300 ? obs.trim().substring(0, 300) : obs.trim());

        int idUsuario = -1;
        try { idUsuario = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) {}

        Connection cn = null;
        try {
            cn = Servlets.Conexion.getConnection();
            if (cn == null) throw new Exception("No se pudo conectar a la base de datos");
            cn.setAutoCommit(false);

            String descProducto = null;
            try (PreparedStatement st = cn.prepareStatement("SELECT DESCRIPCION FROM INV_PRODUCTO WHERE ID_PRODUCTO = ?")) {
                st.setInt(1, idProducto);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) descProducto = rs.getString(1);
                }
            }
            if (descProducto == null) {
                cn.rollback();
                session.setAttribute("msg_error", "Producto no encontrado.");
                response.sendRedirect(volver);
                return;
            }

            long anterior = 0;
            int filas = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(SUM(EXISTENCIA),0), COUNT(*) FROM INV_SUMINISTRO_EXISTENCIA WHERE ID_PRODUCTO = ?")) {
                st.setInt(1, idProducto);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) { anterior = rs.getLong(1); filas = rs.getInt(2); }
                }
            }

            if (filas > 0) {
                // Si el producto tuviera varias filas de existencia, se suma a una sola
                // (la mas antigua): el total mostrado es la suma de todas.
                try (PreparedStatement st = cn.prepareStatement(
                        "UPDATE INV_SUMINISTRO_EXISTENCIA SET EXISTENCIA = NVL(EXISTENCIA,0) + ? " +
                        "WHERE ID_SUMINISTRO_EXISTENCIA = (SELECT MIN(ID_SUMINISTRO_EXISTENCIA) " +
                        "FROM INV_SUMINISTRO_EXISTENCIA WHERE ID_PRODUCTO = ?)")) {
                    st.setInt(1, cantidad);
                    st.setInt(2, idProducto);
                    st.executeUpdate();
                }
            } else {
                int nuevoId = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_SUMINISTRO_EXISTENCIA),0)+1 FROM INV_SUMINISTRO_EXISTENCIA");
                     ResultSet rs = st.executeQuery()) {
                    if (rs.next()) nuevoId = rs.getInt(1);
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO INV_SUMINISTRO_EXISTENCIA (ID_SUMINISTRO_EXISTENCIA, ID_PRODUCTO, EXISTENCIA) VALUES (?, ?, ?)")) {
                    st.setInt(1, nuevoId);
                    st.setInt(2, idProducto);
                    st.setInt(3, cantidad);
                    st.executeUpdate();
                }
            }

            // Registro del ajuste (reintenta si otro usuario tomo el mismo ID).
            int intentos = 0;
            boolean registrado = false;
            while (!registrado && intentos < 3) {
                intentos++;
                int idAjuste = 1;
                try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_AJUSTE),0)+1 FROM INV_SUMINISTRO_AJUSTE");
                     ResultSet rs = st.executeQuery()) {
                    if (rs.next()) idAjuste = rs.getInt(1);
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "INSERT INTO INV_SUMINISTRO_AJUSTE (ID_AJUSTE, ID_PRODUCTO, CANTIDAD, EXISTENCIA_ANTERIOR, " +
                        "EXISTENCIA_NUEVA, MOTIVO, OBSERVACION, ID_USUARIO, FECHA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATE)")) {
                    st.setInt(1, idAjuste);
                    st.setInt(2, idProducto);
                    st.setInt(3, cantidad);
                    st.setLong(4, anterior);
                    st.setLong(5, anterior + cantidad);
                    st.setString(6, motivo);
                    if (obs != null) st.setString(7, obs); else st.setNull(7, java.sql.Types.VARCHAR);
                    st.setInt(8, idUsuario);
                    st.executeUpdate();
                    registrado = true;
                } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
                    if (intentos >= 3) throw dup;
                }
            }

            cn.commit();
            COMUN.LogActividad.registrar(request, "INVENTARIO", "EDITAR",
                    "Ajuste de stock +" + cantidad + " a '" + descProducto + "' (#" + idProducto + "): "
                    + anterior + " -> " + (anterior + cantidad) + " [" + motivo + "]");
            session.setAttribute("msg_exito", "Ajuste registrado: +" + cantidad + " a " + descProducto
                    + " (de " + anterior + " a " + (anterior + cantidad) + ").");
        } catch (Exception e) {
            if (cn != null) try { cn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            // Se incluye el codigo/mensaje de Oracle (ej. ORA-00942: la tabla de ajustes
            // no existe porque falta ejecutar docs/inventario/ajuste_stock.sql).
            String detalle = e.getMessage() == null ? e.getClass().getSimpleName()
                    : e.getMessage().replaceAll("[\r\n]+", " ").trim();
            if (detalle.length() > 160) detalle = detalle.substring(0, 160);
            session.setAttribute("msg_error", "No se pudo registrar el ajuste. Detalle: " + detalle
                    + (detalle.contains("ORA-00942") ? " (falta ejecutar el script docs/inventario/ajuste_stock.sql)" : "")
                    + ". No se modifico ninguna existencia.");
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignore) {}
        }
        response.sendRedirect(volver);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Existencias_Dashboard.jsp");
    }
}
