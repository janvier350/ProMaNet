<%--
    Document   : PRO_MiDiaOrden
    Orden de las tarjetas del dashboard por usuario (drag & drop). GET: devuelve el orden guardado (texto "a,b,c"; 204 si no hay).
    POST orden=a,b,c: lo guarda; POST orden= (vacio): lo borra. Tabla APP_USUARIO_DASH (script 054). Sin la tabla responde 204 y el
    dashboard usa solo el orden guardado en el navegador.
--%>
<%@page contentType="text/plain;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    if (session.getAttribute("usuario") == null) { response.setStatus(401); return; }
    int uid;
    try { uid = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception e) { response.setStatus(204); return; }
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn == null) { response.setStatus(204); return; }
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String orden = request.getParameter("orden") == null ? "" : request.getParameter("orden").trim();
            if (orden.isEmpty()) {
                try (PreparedStatement st = cn.prepareStatement("DELETE FROM APP_USUARIO_DASH WHERE ID_USUARIO = ?")) { st.setInt(1, uid); st.executeUpdate(); }
            } else if (orden.length() <= 400 && orden.matches("[a-z_]+(,[a-z_]+)*")) {
                try (PreparedStatement st = cn.prepareStatement(
                        "MERGE INTO APP_USUARIO_DASH d USING (SELECT ? AS ID FROM DUAL) s ON (d.ID_USUARIO = s.ID) " +
                        "WHEN MATCHED THEN UPDATE SET d.ORDEN = ?, d.FECHA_ACT = SYSDATE " +
                        "WHEN NOT MATCHED THEN INSERT (ID_USUARIO, ORDEN, FECHA_ACT) VALUES (?, ?, SYSDATE)")) {
                    st.setInt(1, uid); st.setString(2, orden); st.setInt(3, uid); st.setString(4, orden); st.executeUpdate();
                }
            } else { response.setStatus(400); return; }
            response.setStatus(204);
        } else {
            try (PreparedStatement st = cn.prepareStatement("SELECT ORDEN FROM APP_USUARIO_DASH WHERE ID_USUARIO = ?")) {
                st.setInt(1, uid);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next() && rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) out.print(rs.getString(1).trim());
                    else response.setStatus(204);
                }
            }
        }
    } catch (Exception e) {
        response.setStatus(204);   // normalmente: falta la tabla (script 054); el navegador conserva su orden local
    }
%>
