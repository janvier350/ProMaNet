package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

@WebServlet(name = "INV_Terminar_Ingreso", urlPatterns = {"/INV_Terminar_Ingreso"})
public class INV_Terminar_Ingreso extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
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

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip   = (String) session.getAttribute("ipDB");
        String url  = "" + ip;

        /* Leer el ID desde el request (ya no hardcodeado) */
        String idParam = request.getParameter("idSuministroIngresoCab");
        if (idParam == null || idParam.replaceAll("[^0-9]", "").isEmpty()) {
            session.setAttribute("msg_error", "ID de ingreso inválido.");
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Ingreso_Suministro2.jsp");
            return;
        }
        int idCab = Integer.parseInt(idParam.replaceAll("[^0-9]", ""));

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            cn.setAutoCommit(false);

            /* 1. Cerrar el ingreso */
            PreparedStatement stCab = cn.prepareStatement(
                "UPDATE INV_SUMINISTRO_INGRESO_CAB SET ESTADO = 'C' WHERE ID_SUMINISTRO_INGRESO_CAB = ?");
            stCab.setInt(1, idCab);
            stCab.executeUpdate();
            stCab.close();

            /* 2. Obtener productos del detalle */
            PreparedStatement stDet = cn.prepareStatement(
                "SELECT ID_PRODUCTO, CANTIDAD FROM INV_SUMINISTRO_INGRESO_DET " +
                "WHERE ID_SUMINISTRO_INGRESO_CAB = ?");
            stDet.setInt(1, idCab);
            ResultSet rsDet = stDet.executeQuery();

            while (rsDet.next()) {
                int idProducto = rsDet.getInt(1);
                int cantidad   = rsDet.getInt(2);

                /* 3. Verificar si ya existe registro en existencia */
                PreparedStatement stCheck = cn.prepareStatement(
                    "SELECT COUNT(*) FROM INV_SUMINISTRO_EXISTENCIA WHERE ID_PRODUCTO = ?");
                stCheck.setInt(1, idProducto);
                ResultSet rsCheck = stCheck.executeQuery();
                int count = rsCheck.next() ? rsCheck.getInt(1) : 0;
                rsCheck.close(); stCheck.close();

                if (count > 0) {
                    /* Sumar cantidad al stock existente */
                    PreparedStatement stUpd = cn.prepareStatement(
                        "UPDATE INV_SUMINISTRO_EXISTENCIA SET EXISTENCIA = EXISTENCIA + ? " +
                        "WHERE ID_PRODUCTO = ?");
                    stUpd.setInt(1, cantidad);
                    stUpd.setInt(2, idProducto);
                    stUpd.executeUpdate();
                    stUpd.close();
                } else {
                    /* Insertar nuevo registro de existencia */
                    PreparedStatement stMaxId = cn.prepareStatement(
                        "SELECT NVL(MAX(ID_SUMINISTRO_EXISTENCIA), 0) + 1 FROM INV_SUMINISTRO_EXISTENCIA");
                    ResultSet rsMaxId = stMaxId.executeQuery();
                    int nuevoId = rsMaxId.next() ? rsMaxId.getInt(1) : 1;
                    rsMaxId.close(); stMaxId.close();

                    PreparedStatement stIns = cn.prepareStatement(
                        "INSERT INTO INV_SUMINISTRO_EXISTENCIA " +
                        "(ID_SUMINISTRO_EXISTENCIA, ID_PRODUCTO, EXISTENCIA) VALUES (?, ?, ?)");
                    stIns.setInt(1, nuevoId);
                    stIns.setInt(2, idProducto);
                    stIns.setInt(3, cantidad);
                    stIns.executeUpdate();
                    stIns.close();
                }
            }
            rsDet.close(); stDet.close();

            cn.commit();
            cn.close();

            session.setAttribute("msg_exito", "Ingreso #" + idCab + " finalizado. Existencias actualizadas correctamente.");
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Ingreso_Suministro2.jsp");

        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (cn != null) { cn.rollback(); cn.close(); } } catch (Exception e2) {}
            session.setAttribute("msg_error", "Error al finalizar el ingreso: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Ingreso_Suministro2.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Finaliza un ingreso de suministros y actualiza existencias";
    }
}
