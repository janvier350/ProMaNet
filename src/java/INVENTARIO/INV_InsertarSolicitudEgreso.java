package INVENTARIO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

@WebServlet(name = "INV_InsertarSolicitudEgreso", urlPatterns = {"/INV_InsertarSolicitudEgreso"})
public class INV_InsertarSolicitudEgreso extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/sesionExpirada.jsp");
            return;
        }

        String cargo = (String) session.getAttribute("cargo");
        if (!(cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
                || cargo.equals("ASISTENTE")  || cargo.equals("PASANTE")
                || cargo.equals("CONTRALOR")  || cargo.equals("JEFE")
                || cargo.equals("ANALISTA"))) {
            response.sendRedirect(request.getContextPath() + "/sesionInvalida.jsp");
            return;
        }

        String   idDepartamento = request.getParameter("idDepartamento");
        String   idUsuarioAuto  = request.getParameter("idUsuarioAuto");
        String[] prodIds        = request.getParameterValues("prod_id");
        String[] prodCants      = request.getParameterValues("prod_cant");
        String   idUsuario      = (String) session.getAttribute("cod");

        if (prodIds == null || prodIds.length == 0) {
            session.setAttribute("msg_error", "Debe agregar al menos un producto a la solicitud.");
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Solicitar_Suministro_Detalle.jsp");
            return;
        }

        if (idDepartamento == null || idDepartamento.trim().isEmpty()) {
            session.setAttribute("msg_error", "No se pudo determinar el departamento.");
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Solicitar_Suministro_Detalle.jsp");
            return;
        }

        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip   = (String) session.getAttribute("ipDB");
        String url  = "" + ip;

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);
            cn.setAutoCommit(false);

            /* Obtener siguiente ID para CAB */
            PreparedStatement stMaxCab = cn.prepareStatement(
                "SELECT NVL(MAX(ID_SUMINISTRO_EGRESO_CAB), 0) + 1 FROM INV_SUMINISTRO_EGRESO_CAB");
            ResultSet rsMaxCab = stMaxCab.executeQuery();
            int idCab = rsMaxCab.next() ? rsMaxCab.getInt(1) : 1;
            rsMaxCab.close(); stMaxCab.close();

            /* Insertar cabecera */
            PreparedStatement stCab = cn.prepareStatement(
                "INSERT INTO INV_SUMINISTRO_EGRESO_CAB " +
                "(ID_SUMINISTRO_EGRESO_CAB, ID_DEPARTAMENTO, ID_USUARIO, ID_USUARIO_AUTO, FECHA_SOLICITUD, ESTADO_SOLICITUD) " +
                "VALUES (?, ?, ?, ?, SYSDATE, 'PENDIENTE')");
            stCab.setInt(1, idCab);
            stCab.setInt(2, Integer.parseInt(idDepartamento.trim()));
            stCab.setInt(3, Integer.parseInt(idUsuario.trim()));
            stCab.setInt(4, Integer.parseInt(idUsuarioAuto.trim()));
            stCab.executeUpdate();
            stCab.close();

            /* Obtener base para IDs de detalle */
            PreparedStatement stMaxDet = cn.prepareStatement(
                "SELECT NVL(MAX(ID_SUMINISTRO_EGRESO_DET), 0) FROM INV_SUMINISTRO_EGRESO_DET");
            ResultSet rsMaxDet = stMaxDet.executeQuery();
            int baseDetId = rsMaxDet.next() ? rsMaxDet.getInt(1) : 0;
            rsMaxDet.close(); stMaxDet.close();

            /* Insertar detalle por cada producto */
            for (int i = 0; i < prodIds.length; i++) {
                PreparedStatement stDet = cn.prepareStatement(
                    "INSERT INTO INV_SUMINISTRO_EGRESO_DET " +
                    "(ID_SUMINISTRO_EGRESO_DET, ID_SUMINISTRO_EGRESO_CAB, ID_PRODUCTO, CANTIDAD) " +
                    "VALUES (?, ?, ?, ?)");
                stDet.setInt(1, baseDetId + i + 1);
                stDet.setInt(2, idCab);
                stDet.setInt(3, Integer.parseInt(prodIds[i].trim()));
                stDet.setInt(4, Integer.parseInt(prodCants[i].trim()));
                stDet.executeUpdate();
                stDet.close();
            }

            cn.commit();
            cn.close();

            session.setAttribute("msg_exito", "Solicitud #" + idCab + " registrada correctamente. Pendiente de despacho.");
            boolean esAdmin = cargo.equals("ADMINISTRACION") || cargo.equals("ADMINISTRADOR")
                    || cargo.equals("CONTRALOR") || cargo.equals("JEFE");
            if (esAdmin) {
                response.sendRedirect(request.getContextPath() + "/Inventario/INV_Lista_Solicitudes_Suministro.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/Inventario/INV_Historial_Solicitudes_Departamento.jsp");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (cn != null) { cn.rollback(); cn.close(); } } catch (Exception e2) {}
            session.setAttribute("msg_error", "Error al registrar la solicitud: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/Inventario/INV_Solicitar_Suministro_Detalle.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Inventario/INV_Solicitar_Suministro_Detalle.jsp");
    }
}
