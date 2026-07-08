<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    if (session.getAttribute("usuario") == null) { out.print("<span class='text-danger'>Sesión expirada.</span>"); return; }
    String cargo = (String) session.getAttribute("cargo");
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_SOLICITAR")) {
        out.print("<span class='text-danger'>No autorizado.</span>"); return;
    }
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) { out.print("<span class='text-danger'>Parámetro inválido.</span>"); return; }
    String sql =
        "SELECT p.DESCRIPCION, p.UNIDAD, d.CANTIDAD, " +
        "       NVL((SELECT e.EXISTENCIA FROM INV_SUMINISTRO_EXISTENCIA e WHERE e.ID_PRODUCTO = p.ID_PRODUCTO AND ROWNUM=1), 0) AS STOCK " +
        "FROM INV_SUMINISTRO_EGRESO_DET d " +
        "JOIN INV_PRODUCTO p ON d.ID_PRODUCTO = p.ID_PRODUCTO " +
        "WHERE d.ID_SUMINISTRO_EGRESO_CAB = " + idParam.replaceAll("[^0-9]", "");
    boolean hayStock = true;
%>
<table class="table table-sm mb-0">
    <thead><tr style="font-size:.78rem;background:#f8f9fb;"><th>Producto</th><th class="text-center">Solicitado</th><th class="text-center">En stock</th><th class="text-center">Disponibilidad</th></tr></thead>
    <tbody>
<%
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);
        PreparedStatement st = cn.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        boolean hay = false;
        while (rs.next()) {
            hay = true;
            String desc = rs.getString(1); String unidad = rs.getString(2) != null ? rs.getString(2) : "";
            int solicitado = rs.getInt(3); int stock = rs.getInt(4); boolean ok = stock >= solicitado;
            if (!ok) hayStock = false;
%>
        <tr><td><%=desc%> <small class="text-muted">(<%=unidad%>)</small></td>
            <td class="text-center font-weight-bold"><%=solicitado%></td>
            <td class="text-center <%=ok?"stock-ok":"stock-fail"%>"><%=stock%></td>
            <td class="text-center"><% if(ok){ %><span class="badge badge-success"><i class="fa fa-check"></i> Suficiente</span><% }else{ %><span class="badge badge-danger"><i class="fa fa-times"></i> Insuficiente</span><% } %></td>
        </tr>
<%      }
        if (!hay) { %><tr><td colspan="4" class="text-center text-muted py-2">Sin productos registrados.</td></tr><% }
        rs.close(); st.close(); cn.close();
    } catch (Exception ex) { ex.printStackTrace(); %>
        <tr><td colspan="4" class="text-danger py-2"><i class="fa fa-exclamation-triangle mr-1"></i><%=ex.getMessage()%></td></tr>
<%  } %>
    </tbody>
</table>
<% if (!hayStock) { %>
<div class="alert alert-warning mt-2 mb-0 py-2" style="font-size:.84rem;">
    <i class="fa fa-exclamation-triangle mr-1"></i><strong>Atención:</strong> Algunos productos no tienen stock suficiente.
</div>
<% } %>
