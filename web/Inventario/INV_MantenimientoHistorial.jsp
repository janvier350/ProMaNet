<%--
    Fragmento (sin layout) con el historial de mantenimientos de un equipo; lo carga por fetch el
    modal de INV_Mantenimientos.jsp. Permisos: INVENTARIO_MANTENIMIENTO_VER / _GESTIONAR.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    if (session.getAttribute("usuario") == null) { out.print("<p class='text-danger'>Sesion expirada.</p>"); return; }
    boolean puedeGestionar = COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR");
    if (!puedeGestionar && !COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER")) {
        out.print("<p class='text-danger'>Sin permiso.</p>"); return;
    }
    int idEquipo;
    try { idEquipo = Integer.parseInt(request.getParameter("id").trim()); } catch (Exception e) { out.print("<p class='text-danger'>Equipo invalido.</p>"); return; }
    boolean hay = false;
%>
<div class="table-responsive">
<table class="table table-sm align-middle mb-0">
    <thead><tr>
        <th class="text-xxs text-uppercase text-secondary">Fecha</th><th class="text-xxs text-uppercase text-secondary">Tipo</th>
        <th class="text-xxs text-uppercase text-secondary">Actividades</th><th class="text-xxs text-uppercase text-secondary">Realizado por</th>
        <th class="text-xxs text-uppercase text-secondary">Observaciones</th><% if (puedeGestionar) { %><th></th><% } %>
    </tr></thead>
    <tbody>
<%
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT m.ID_MANTENIMIENTO, TO_CHAR(m.FECHA_MANT,'DD/MM/YYYY'), m.TIPO, m.ACTIVIDADES, m.OBSERVACIONES, " +
                    "t.NOMBRE || ' ' || t.APELLIDOS FROM INV_MANTENIMIENTO m LEFT JOIN USUARIO t ON t.IDUSUARIO = m.ID_TECNICO " +
                    "WHERE m.IDINVEQUIPO = ? AND m.ESTADO = 'A' ORDER BY m.FECHA_MANT DESC, m.ID_MANTENIMIENTO DESC")) {
                st.setInt(1, idEquipo);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        hay = true;
%>
        <tr>
            <td class="text-xs"><%=rs.getString(2)%></td>
            <td><span class="badge badge-sm bg-gradient-<%= "PREVENTIVO".equals(rs.getString(3)) ? "success" : "warning" %>"><%=rs.getString(3)%></span></td>
            <td class="text-xs"><%=esc(rs.getString(4))%></td>
            <td class="text-xs"><%=esc(rs.getString(6))%></td>
            <td class="text-xs"><%=esc(rs.getString(5))%></td>
            <% if (puedeGestionar) { %>
            <td class="text-end">
                <form action="../INV_MantenimientoAccion" method="post" onsubmit="return confirm('Anular este registro de mantenimiento?');">
                    <input type="hidden" name="accion" value="ELIMINAR">
                    <input type="hidden" name="idMantenimiento" value="<%=rs.getString(1)%>">
                    <button type="submit" class="btn btn-xs btn-outline-danger py-1 mb-0"><i class="fas fa-trash"></i></button>
                </form>
            </td>
            <% } %>
        </tr>
<%
                    }
                }
            }
        }
    } catch (Exception e) { out.print("<tr><td colspan='6' class='text-danger text-xs'>No se pudo cargar el historial.</td></tr>"); }
    if (!hay) { out.print("<tr><td colspan='6' class='text-center text-secondary py-3'>Este equipo aun no tiene mantenimientos registrados.</td></tr>"); }
%>
    </tbody>
</table>
</div>
