<%--
    Document   : PRO_Novedades
    Publicar / retirar las "Novedades" que aparecen en el dashboard. Permiso: NOVEDADES_GESTIONAR.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.util.*"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "NOVEDADES_GESTIONAR")) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    int uid = Integer.parseInt(((String) session.getAttribute("cod")).trim());
    String msg = null, err = null;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String accion = request.getParameter("accion");
            if ("crear".equals(accion)) {
                String titulo = request.getParameter("titulo") == null ? "" : request.getParameter("titulo").trim();
                String texto = request.getParameter("texto") == null ? "" : request.getParameter("texto").trim();
                String desde = request.getParameter("desde"), hasta = request.getParameter("hasta");
                if (titulo.isEmpty()) err = "El título es obligatorio.";
                else {
                    LocalDate d = (desde == null || desde.isEmpty()) ? LocalDate.now() : LocalDate.parse(desde);
                    LocalDate h = (hasta == null || hasta.isEmpty()) ? null : LocalDate.parse(hasta);
                    if (h != null && h.isBefore(d)) err = "La fecha final no puede ser anterior a la inicial.";
                    else {
                        int id = 0;
                        try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_NOVEDAD),0)+1 FROM APP_NOVEDAD"); ResultSet rs = st.executeQuery()) { if (rs.next()) id = rs.getInt(1); }
                        try (PreparedStatement st = cn.prepareStatement("INSERT INTO APP_NOVEDAD (ID_NOVEDAD, TITULO, TEXTO, FECHA_DESDE, FECHA_HASTA, ESTADO, ID_USUARIO) VALUES (?, ?, ?, ?, ?, 'A', ?)")) {
                            st.setInt(1, id); st.setString(2, titulo.length() > 120 ? titulo.substring(0, 120) : titulo);
                            st.setString(3, texto.length() > 1000 ? texto.substring(0, 1000) : texto);
                            st.setDate(4, java.sql.Date.valueOf(d));
                            if (h == null) st.setNull(5, Types.DATE); else st.setDate(5, java.sql.Date.valueOf(h));
                            st.setInt(6, uid);
                            st.executeUpdate();
                        }
                        COMUN.LogActividad.registrar(request, "PROYECTOS", "CREAR", "Publico novedad #" + id);
                        msg = "Novedad publicada.";
                    }
                }
            } else if ("estado".equals(accion) || "eliminar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "eliminar".equals(accion) ? "DELETE FROM APP_NOVEDAD WHERE ID_NOVEDAD = ?" : "UPDATE APP_NOVEDAD SET ESTADO = CASE ESTADO WHEN 'A' THEN 'I' ELSE 'A' END WHERE ID_NOVEDAD = ?";
                try (PreparedStatement st = cn.prepareStatement(sql)) { st.setInt(1, id); st.executeUpdate(); }
                COMUN.LogActividad.registrar(request, "PROYECTOS", "eliminar".equals(accion) ? "ELIMINAR" : "ACTUALIZAR", "Novedad #" + id);
                msg = "eliminar".equals(accion) ? "Novedad eliminada." : "Estado actualizado.";
            }
        }
        List<Object[]> lista = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_NOVEDAD, TITULO, TEXTO, TO_CHAR(FECHA_DESDE,'DD/MM/YYYY'), TO_CHAR(FECHA_HASTA,'DD/MM/YYYY'), ESTADO, " +
                "CASE WHEN ESTADO = 'A' AND FECHA_DESDE <= TRUNC(SYSDATE) AND (FECHA_HASTA IS NULL OR FECHA_HASTA >= TRUNC(SYSDATE)) THEN 1 ELSE 0 END FROM APP_NOVEDAD ORDER BY FECHA_DESDE DESC, ID_NOVEDAD DESC");
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) lista.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6), rs.getInt(7) == 1});
        }
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Novedades</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<a href="PRO_Dashboard.jsp" class="small">&larr; Volver al dashboard</a>
<h4 class="mt-2">Novedades del dashboard</h4>
<p class="text-muted">Avisos cortos que ven todos los usuarios en el dashboard mientras est&eacute;n vigentes (se muestran las 3 m&aacute;s recientes).</p>
<% if (msg != null) { %><div class="alert alert-success py-2"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger py-2"><%= esc(err) %></div><% } %>

<div class="card mb-4"><div class="card-body">
<h6>Nueva novedad</h6>
<form method="post" class="row g-2">
  <input type="hidden" name="accion" value="crear">
  <div class="col-12"><input name="titulo" class="form-control" maxlength="120" placeholder="T&iacute;tulo (obligatorio)" required></div>
  <div class="col-12"><textarea name="texto" class="form-control" rows="3" maxlength="1000" placeholder="Detalle (opcional)"></textarea></div>
  <div class="col-sm-4"><label class="form-label small mb-0">Visible desde</label><input type="date" name="desde" class="form-control" value="<%= LocalDate.now() %>"></div>
  <div class="col-sm-4"><label class="form-label small mb-0">Hasta (opcional)</label><input type="date" name="hasta" class="form-control"></div>
  <div class="col-sm-4 d-flex align-items-end"><button class="btn btn-primary w-100">Publicar</button></div>
</form></div></div>

<div class="card"><div class="card-body">
<h6>Publicadas</h6>
<% if (lista.isEmpty()) { %><p class="text-muted mb-0">A&uacute;n no hay novedades.</p><% } else { %>
<div class="table-responsive"><table class="table table-sm align-middle">
<thead><tr><th>T&iacute;tulo</th><th>Vigencia</th><th>Estado</th><th></th></tr></thead><tbody>
<% for (Object[] n : lista) { boolean vig = (Boolean) n[6]; %>
<tr><td><b><%= esc((String) n[1]) %></b><br><small class="text-muted"><%= esc((String) n[2]) %></small></td>
<td class="small"><%= n[3] %> &rarr; <%= n[4] == null ? "sin vencimiento" : n[4] %></td>
<td><span class="badge bg-<%= vig ? "success" : "secondary" %>"><%= vig ? "Visible" : ("A".equals(n[5]) ? "Fuera de fecha" : "Retirada") %></span></td>
<td class="text-end text-nowrap">
  <form method="post" class="d-inline"><input type="hidden" name="accion" value="estado"><input type="hidden" name="id" value="<%= n[0] %>"><button class="btn btn-sm btn-outline-secondary"><%= "A".equals(n[5]) ? "Retirar" : "Reactivar" %></button></form>
  <form method="post" class="d-inline" onsubmit="return confirm('¿Eliminar esta novedad?');"><input type="hidden" name="accion" value="eliminar"><input type="hidden" name="id" value="<%= n[0] %>"><button class="btn btn-sm btn-outline-danger">Eliminar</button></form>
</td></tr>
<% } %></tbody></table></div>
<% } %>
</div></div>
</div></body></html>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div style='font-family:sans-serif;padding:20px'>No se pudo cargar las novedades. &iquest;Se ejecut&oacute; el script 051 (tabla APP_NOVEDAD)? Detalle: " + esc(String.valueOf(e.getMessage())) + "</div>");
    }
%>
