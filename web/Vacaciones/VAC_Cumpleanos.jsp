<%--
    Document   : VAC_Cumpleanos
    Dia y mes de cumpleanos por usuario (sin anio). Alimenta la tarjeta "Cumpleanos" del dashboard.
    Permiso: VACACIONES_CONFIGURAR. Cada gestor ve a los empleados de su grupo; el administrador global, a todos.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
    private static final String[] MESES = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"};
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    String msg = null, err = null;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        // Empleados activos dentro del alcance del usuario (la misma regla de grupos de vacaciones).
        String sqlLista = "SELECT u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS, d.DEPARTAMENTO, c.MES, c.DIA FROM USUARIO u " +
                "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO " +
                "LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
                "LEFT JOIN USUARIO_CUMPLE c ON c.ID_USUARIO = u.IDUSUARIO " +
                "WHERE u.ESTADO = 'a' " + VACACIONES.VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO") +
                "ORDER BY u.APELLIDOS, u.NOMBRE";
        List<Object[]> lista = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement(sqlLista); ResultSet rs = st.executeQuery()) {
            while (rs.next()) lista.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getString(3), rs.getObject(4) == null ? 0 : rs.getInt(4), rs.getObject(5) == null ? 0 : rs.getInt(5)});
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            int guardados = 0, quitados = 0;
            cn.setAutoCommit(false);
            try {
                for (Object[] u : lista) {
                    int id = (Integer) u[0];
                    String ms = request.getParameter("mes_" + id), ds = request.getParameter("dia_" + id);
                    if (ms == null || ds == null) continue;
                    int mes = ms.isEmpty() ? 0 : Integer.parseInt(ms), dia = ds.isEmpty() ? 0 : Integer.parseInt(ds);
                    if (mes == 0 && dia == 0) {
                        if ((Integer) u[3] != 0) {
                            try (PreparedStatement st = cn.prepareStatement("DELETE FROM USUARIO_CUMPLE WHERE ID_USUARIO = ?")) { st.setInt(1, id); st.executeUpdate(); quitados++; }
                        }
                    } else if (mes >= 1 && mes <= 12 && dia >= 1 && dia <= 31) {
                        if (mes == (Integer) u[3] && dia == (Integer) u[4]) continue;   // sin cambios
                        try (PreparedStatement st = cn.prepareStatement(
                                "MERGE INTO USUARIO_CUMPLE c USING (SELECT ? AS ID FROM DUAL) s ON (c.ID_USUARIO = s.ID) " +
                                "WHEN MATCHED THEN UPDATE SET c.MES = ?, c.DIA = ? WHEN NOT MATCHED THEN INSERT (ID_USUARIO, MES, DIA) VALUES (?, ?, ?)")) {
                            st.setInt(1, id); st.setInt(2, mes); st.setInt(3, dia); st.setInt(4, id); st.setInt(5, mes); st.setInt(6, dia);
                            st.executeUpdate(); guardados++;
                        }
                    } else { throw new Exception("Falta el mes o el día de " + u[1]); }
                }
                cn.commit();
                msg = "Cambios guardados: " + guardados + " actualizados, " + quitados + " quitados.";
            } catch (Exception ex) { cn.rollback(); err = "No se guardó: " + ex.getMessage(); }
            finally { cn.setAutoCommit(true); }
            if (err == null) {   // recargar con lo nuevo
                lista.clear();
                try (PreparedStatement st = cn.prepareStatement(sqlLista); ResultSet rs = st.executeQuery()) {
                    while (rs.next()) lista.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getString(3), rs.getObject(4) == null ? 0 : rs.getInt(4), rs.getObject(5) == null ? 0 : rs.getInt(5)});
                }
                COMUN.LogActividad.registrar(request, "VACACIONES", "ACTUALIZAR", "Actualizo cumpleanos de empleados");
            }
        }
        int sin = 0; for (Object[] u : lista) if ((Integer) u[3] == 0) sin++;
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cumplea&ntilde;os</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<a href="VAC_Dashboard.jsp" class="small">&larr; Volver a Vacaciones</a>
<h4 class="mt-2">Cumplea&ntilde;os de los empleados</h4>
<p class="text-muted">D&iacute;a y mes (sin a&ntilde;o). Todos los usuarios ven en su dashboard los cumplea&ntilde;os de los pr&oacute;ximos 30 d&iacute;as. Para dejar a alguien sin cumplea&ntilde;os, deja ambos campos vac&iacute;os.
Sin fecha: <b><%= sin %></b> de <%= lista.size() %>.</p>
<% if (msg != null) { %><div class="alert alert-success py-2"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger py-2"><%= esc(err) %></div><% } %>
<form method="post">
<div class="card"><div class="card-body p-2"><div class="table-responsive"><table class="table table-sm align-middle mb-0">
<thead><tr><th>Empleado</th><th>Departamento</th><th style="width:170px">Mes</th><th style="width:90px">D&iacute;a</th></tr></thead><tbody>
<% for (Object[] u : lista) { int id = (Integer) u[0]; int m = (Integer) u[3], d = (Integer) u[4]; %>
<tr class="<%= m == 0 ? "table-warning" : "" %>"><td><%= esc((String) u[1]) %></td><td class="small text-muted"><%= esc((String) u[2]) %></td>
<td><select name="mes_<%= id %>" class="form-select form-select-sm"><option value=""></option>
<% for (int i = 1; i <= 12; i++) { %><option value="<%= i %>" <%= i == m ? "selected" : "" %>><%= MESES[i - 1] %></option><% } %></select></td>
<td><select name="dia_<%= id %>" class="form-select form-select-sm"><option value=""></option>
<% for (int i = 1; i <= 31; i++) { %><option value="<%= i %>" <%= i == d ? "selected" : "" %>><%= i %></option><% } %></select></td></tr>
<% } %></tbody></table></div></div></div>
<div class="mt-3 text-end"><button class="btn btn-primary">Guardar cambios</button></div>
</form>
</div></body></html>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div style='font-family:sans-serif;padding:20px'>No se pudo cargar. &iquest;Se ejecut&oacute; el script 051 (tabla USUARIO_CUMPLE)? Detalle: " + esc(String.valueOf(e.getMessage())) + "</div>");
    }
%>
