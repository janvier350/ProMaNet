package INVENTARIO;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "INV_Confirmar_Despacho", urlPatterns = {"/INV_Confirmar_Despacho"})
public class INV_Confirmar_Despacho extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("ProMaNet/sesionExpirada.jsp"); return;
        }
        String cargo = (String) session.getAttribute("cargo");
        if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
                || cargo.equals("CONTRALOR") || cargo.equals("JEFE"))) {
            response.sendRedirect("ProMaNet/sesionInvalida.jsp"); return;
        }

        String idCabParam = request.getParameter("idCab");
        String forzar     = request.getParameter("forzar");
        if (idCabParam == null || idCabParam.replaceAll("[^0-9]", "").isEmpty()) {
            response.sendRedirect("ProMaNet/Inventario/INV_Lista_Solicitudes_Suministro.jsp"); return;
        }
        int idCab = Integer.parseInt(idCabParam.replaceAll("[^0-9]", ""));

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip   = (String) session.getAttribute("ipDB");
        String url  = "" + ip;

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            cn.setAutoCommit(false);

            // 1. Verificar que la solicitud existe y está PENDIENTE
            PreparedStatement stCheck = cn.prepareStatement(
                "SELECT ESTADO_SOLICITUD FROM INV_SUMINISTRO_EGRESO_CAB WHERE ID_SUMINISTRO_EGRESO_CAB = ?");
            stCheck.setInt(1, idCab);
            ResultSet rsCheck = stCheck.executeQuery();
            if (!rsCheck.next() || !"PENDIENTE".equals(rsCheck.getString(1))) {
                rsCheck.close(); stCheck.close(); cn.rollback(); cn.close();
                session.setAttribute("msg_error", "La solicitud no existe o ya fue procesada.");
                response.sendRedirect("ProMaNet/Inventario/INV_Lista_Solicitudes_Suministro.jsp"); return;
            }
            rsCheck.close(); stCheck.close();

            // 2. Obtener productos
            PreparedStatement stDet = cn.prepareStatement(
                "SELECT ID_PRODUCTO, CANTIDAD FROM INV_SUMINISTRO_EGRESO_DET WHERE ID_SUMINISTRO_EGRESO_CAB = ?");
            stDet.setInt(1, idCab);
            ResultSet rsDet = stDet.executeQuery();
            java.util.List<Integer> productos  = new java.util.ArrayList<>();
            java.util.List<Integer> cantidades = new java.util.ArrayList<>();
            while (rsDet.next()) { productos.add(rsDet.getInt(1)); cantidades.add(rsDet.getInt(2)); }
            rsDet.close(); stDet.close();

            // 3. Verificar stock si no se fuerza
            if (!"true".equals(forzar)) {
                for (int i = 0; i < productos.size(); i++) {
                    PreparedStatement stStock = cn.prepareStatement(
                        "SELECT NVL(EXISTENCIA,0) FROM INV_SUMINISTRO_EXISTENCIA WHERE ID_PRODUCTO=? AND ROWNUM=1");
                    stStock.setInt(1, productos.get(i));
                    ResultSet rsStock = stStock.executeQuery();
                    int stockActual = rsStock.next() ? rsStock.getInt(1) : 0;
                    rsStock.close(); stStock.close();
                    if (stockActual < cantidades.get(i)) {
                        cn.rollback(); cn.close();
                        session.setAttribute("msg_error", "Stock insuficiente. Marque la casilla para forzar el despacho.");
                        response.sendRedirect("ProMaNet/Inventario/INV_Despachar_Suministro.jsp?id=" + idCab); return;
                    }
                }
            }

            // 4. Descontar existencia
            for (int i = 0; i < productos.size(); i++) {
                int idProd = productos.get(i); int cantidad = cantidades.get(i);
                PreparedStatement stExCheck = cn.prepareStatement(
                    "SELECT COUNT(*) FROM INV_SUMINISTRO_EXISTENCIA WHERE ID_PRODUCTO=?");
                stExCheck.setInt(1, idProd);
                ResultSet rsExCheck = stExCheck.executeQuery();
                int exCount = rsExCheck.next() ? rsExCheck.getInt(1) : 0;
                rsExCheck.close(); stExCheck.close();
                if (exCount > 0) {
                    PreparedStatement stUpd = cn.prepareStatement(
                        "UPDATE INV_SUMINISTRO_EXISTENCIA SET EXISTENCIA = EXISTENCIA - ? WHERE ID_PRODUCTO = ?");
                    stUpd.setInt(1, cantidad); stUpd.setInt(2, idProd);
                    stUpd.executeUpdate(); stUpd.close();
                }
            }

            // 5. Marcar como ENTREGADO
            PreparedStatement stUpCab = cn.prepareStatement(
                "UPDATE INV_SUMINISTRO_EGRESO_CAB SET ESTADO_SOLICITUD='ENTREGADO' WHERE ID_SUMINISTRO_EGRESO_CAB=?");
            stUpCab.setInt(1, idCab); stUpCab.executeUpdate(); stUpCab.close();

            cn.commit(); cn.close();
            session.setAttribute("msg_exito", "Solicitud #" + idCab + " despachada correctamente. Stock actualizado.");
            response.sendRedirect("ProMaNet/Inventario/INV_Lista_Solicitudes_Suministro.jsp");

        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception e2) {}
            try { if (cn != null) cn.close();   } catch (Exception e2) {}
            session.setAttribute("msg_error", "Error al procesar el despacho: " + ex.getMessage());
            response.sendRedirect("ProMaNet/Inventario/INV_Despachar_Suministro.jsp?id=" + idCab);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("ProMaNet/Inventario/INV_Lista_Solicitudes_Suministro.jsp");
    }
}
