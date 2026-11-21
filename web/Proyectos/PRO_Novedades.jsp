<%--
    Document   : PRO_Novedades
    Publicar / retirar las "Novedades" del dashboard. Permiso: NOVEDADES_GESTIONAR.
    Cada novedad puede ir dirigida a todos, a departamentos concretos o a usuarios concretos, y opcionalmente salir tambien
    como ventana emergente (una sola vez por persona). Requiere los scripts 051 y 055.
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
            try {
                cn.setAutoCommit(false);
                if ("crear".equals(accion)) {
                    String titulo = request.getParameter("titulo") == null ? "" : request.getParameter("titulo").trim();
                    String texto = request.getParameter("texto") == null ? "" : request.getParameter("texto").trim();
                    String desde = request.getParameter("desde"), hasta = request.getParameter("hasta");
                    String aud = request.getParameter("audiencia"); if (!"D".equals(aud) && !"U".equals(aud)) aud = "T";
                    String[] deptos = request.getParameterValues("depto"), usuarios = request.getParameterValues("usuario");
                    boolean modal = "S".equals(request.getParameter("modal"));
                    if (titulo.isEmpty()) throw new Exception("El título es obligatorio.");
                    if ("D".equals(aud) && (deptos == null || deptos.length == 0)) throw new Exception("Elige al menos un departamento.");
                    if ("U".equals(aud) && (usuarios == null || usuarios.length == 0)) throw new Exception("Elige al menos un usuario.");
                    LocalDate d = (desde == null || desde.isEmpty()) ? LocalDate.now() : LocalDate.parse(desde);
                    LocalDate h = (hasta == null || hasta.isEmpty()) ? null : LocalDate.parse(hasta);
                    if (h != null && h.isBefore(d)) throw new Exception("La fecha final no puede ser anterior a la inicial.");
                    int id = 0;
                    try (PreparedStatement st = cn.prepareStatement("SELECT NVL(MAX(ID_NOVEDAD),0)+1 FROM APP_NOVEDAD"); ResultSet rs = st.executeQuery()) { if (rs.next()) id = rs.getInt(1); }
                    try (PreparedStatement st = cn.prepareStatement("INSERT INTO APP_NOVEDAD (ID_NOVEDAD, TITULO, TEXTO, FECHA_DESDE, FECHA_HASTA, ESTADO, ID_USUARIO, AUDIENCIA, EN_MODAL) VALUES (?, ?, ?, ?, ?, 'A', ?, ?, ?)")) {
                        st.setInt(1, id); st.setString(2, titulo.length() > 120 ? titulo.substring(0, 120) : titulo);
                        st.setString(3, texto.length() > 1000 ? texto.substring(0, 1000) : texto);
                        st.setDate(4, java.sql.Date.valueOf(d));
                        if (h == null) st.setNull(5, Types.DATE); else st.setDate(5, java.sql.Date.valueOf(h));
                        st.setInt(6, uid); st.setString(7, aud); st.setString(8, modal ? "S" : "N");
                        st.executeUpdate();
                    }
                    String[] vals = "D".equals(aud) ? deptos : ("U".equals(aud) ? usuarios : new String[0]);
                    try (PreparedStatement st = cn.prepareStatement("INSERT INTO APP_NOVEDAD_DEST (ID_NOVEDAD, TIPO, VALOR) VALUES (?, ?, ?)")) {
                        for (String v : vals) { if (v == null || v.trim().isEmpty()) continue; st.setInt(1, id); st.setString(2, aud); st.setString(3, v.trim()); st.addBatch(); }
                        st.executeBatch();
                    }
                    COMUN.LogActividad.registrar(request, "PROYECTOS", "CREAR", "Publico novedad #" + id + " (" + aud + ")");
                    msg = "Novedad publicada.";
                } else if ("estado".equals(accion) || "eliminar".equals(accion)) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    if ("eliminar".equals(accion)) {
                        for (String t : new String[]{"APP_NOVEDAD_DEST", "APP_NOVEDAD_VISTA", "APP_NOVEDAD"}) {
                            try (PreparedStatement st = cn.prepareStatement("DELETE FROM " + t + " WHERE ID_NOVEDAD = ?")) { st.setInt(1, id); st.executeUpdate(); }
                        }
                    } else {
                        try (PreparedStatement st = cn.prepareStatement("UPDATE APP_NOVEDAD SET ESTADO = CASE ESTADO WHEN 'A' THEN 'I' ELSE 'A' END WHERE ID_NOVEDAD = ?")) { st.setInt(1, id); st.executeUpdate(); }
                    }
                    COMUN.LogActividad.registrar(request, "PROYECTOS", "eliminar".equals(accion) ? "ELIMINAR" : "ACTUALIZAR", "Novedad #" + id);
                    msg = "eliminar".equals(accion) ? "Novedad eliminada." : "Estado actualizado.";
                }
                cn.commit();
            } catch (Exception ex) { cn.rollback(); err = ex.getMessage(); }
            finally { cn.setAutoCommit(true); }
        }

        List<String[]> deptos = new ArrayList<>(), usuarios = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_DEPARTAMENTO, DEPARTAMENTO FROM ADM_DEPARTAMENTO WHERE DEPARTAMENTO IS NOT NULL ORDER BY DEPARTAMENTO"); ResultSet rs = st.executeQuery()) {
            while (rs.next()) deptos.add(new String[]{rs.getString(1), rs.getString(2)});
        }
        try (PreparedStatement st = cn.prepareStatement("SELECT IDUSUARIO, NOMBRE || ' ' || APELLIDOS FROM USUARIO WHERE ESTADO = 'a' ORDER BY NOMBRE, APELLIDOS"); ResultSet rs = st.executeQuery()) {
            while (rs.next()) usuarios.add(new String[]{rs.getString(1), rs.getString(2)});
        }
        Map<String, String> nomDepto = new HashMap<>(), nomUsu = new HashMap<>();
        for (String[] d : deptos) nomDepto.put(d[0], d[1]);
        for (String[] u : usuarios) nomUsu.put(u[0], u[1]);

        Map<Integer, List<String>> dest = new HashMap<>(); Map<Integer, Integer> vistas = new HashMap<>();
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_NOVEDAD, TIPO, VALOR FROM APP_NOVEDAD_DEST ORDER BY TIPO, VALOR"); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                String n = "D".equals(rs.getString(2)) ? nomDepto.get(rs.getString(3)) : nomUsu.get(rs.getString(3));
                dest.computeIfAbsent(rs.getInt(1), k -> new ArrayList<>()).add(n == null ? rs.getString(3) : n);
            }
        }
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_NOVEDAD, COUNT(*) FROM APP_NOVEDAD_VISTA GROUP BY ID_NOVEDAD"); ResultSet rs = st.executeQuery()) {
            while (rs.next()) vistas.put(rs.getInt(1), rs.getInt(2));
        }
        List<Object[]> lista = new ArrayList<>();
        try (PreparedStatement st = cn.prepareStatement("SELECT ID_NOVEDAD, TITULO, TEXTO, TO_CHAR(FECHA_DESDE,'DD/MM/YYYY'), TO_CHAR(FECHA_HASTA,'DD/MM/YYYY'), ESTADO, " +
                "CASE WHEN ESTADO = 'A' AND FECHA_DESDE <= TRUNC(SYSDATE) AND (FECHA_HASTA IS NULL OR FECHA_HASTA >= TRUNC(SYSDATE)) THEN 1 ELSE 0 END, AUDIENCIA, EN_MODAL " +
                "FROM APP_NOVEDAD ORDER BY FECHA_DESDE DESC, ID_NOVEDAD DESC");
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) lista.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6), rs.getInt(7) == 1, rs.getString(8), rs.getString(9)});
        }
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Novedades</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<style>.lista-check { max-height:200px; overflow:auto; border:1px solid #dee2e6; border-radius:6px; padding:8px 12px; background:#fff; }</style>
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<a href="PRO_Dashboard.jsp" class="small">&larr; Volver al dashboard</a>
<h4 class="mt-2">Novedades del dashboard</h4>
<p class="text-muted">Avisos que se muestran en el dashboard mientras est&eacute;n vigentes. Puedes dirigirlos a todos, a departamentos o a personas concretas, y adem&aacute;s hacer que salgan como ventana emergente (una sola vez por persona).</p>
<% if (msg != null) { %><div class="alert alert-success py-2"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger py-2"><%= esc(err) %></div><% } %>

<div class="card mb-4"><div class="card-body">
<h6>Nueva novedad</h6>
<form method="post" class="row g-2">
  <input type="hidden" name="accion" value="crear">
  <div class="col-12"><input name="titulo" class="form-control" maxlength="120" placeholder="T&iacute;tulo (obligatorio)" required></div>
  <div class="col-12"><textarea name="texto" class="form-control" rows="3" maxlength="1000" placeholder="Detalle (opcional)"></textarea></div>

  <div class="col-12 mt-2">
    <label class="form-label small mb-1 fw-bold">&iquest;Para qui&eacute;n es?</label><br>
    <div class="form-check form-check-inline"><input class="form-check-input" type="radio" name="audiencia" id="aT" value="T" checked><label class="form-check-label" for="aT">Todos</label></div>
    <div class="form-check form-check-inline"><input class="form-check-input" type="radio" name="audiencia" id="aD" value="D"><label class="form-check-label" for="aD">Departamentos</label></div>
    <div class="form-check form-check-inline"><input class="form-check-input" type="radio" name="audiencia" id="aU" value="U"><label class="form-check-label" for="aU">Personas concretas</label></div>
  </div>
  <div class="col-12" id="boxD" style="display:none">
    <div class="lista-check">
      <% for (String[] d : deptos) { %><div class="form-check"><input class="form-check-input" type="checkbox" name="depto" value="<%= esc(d[0]) %>" id="d<%= esc(d[0]) %>"><label class="form-check-label" for="d<%= esc(d[0]) %>"><%= esc(d[1]) %></label></div><% } %>
    </div>
  </div>
  <div class="col-12" id="boxU" style="display:none">
    <input type="text" id="filtroU" class="form-control form-control-sm mb-1" placeholder="Buscar persona..." autocomplete="off">
    <div class="lista-check" id="listaU">
      <% for (String[] u : usuarios) { %><div class="form-check fila-u"><input class="form-check-input" type="checkbox" name="usuario" value="<%= esc(u[0]) %>" id="u<%= esc(u[0]) %>"><label class="form-check-label" for="u<%= esc(u[0]) %>"><%= esc(u[1]) %></label></div><% } %>
    </div>
  </div>

  <div class="col-12 mt-2"><div class="form-check"><input class="form-check-input" type="checkbox" name="modal" value="S" id="chkModal"><label class="form-check-label" for="chkModal">Mostrarla tambi&eacute;n como <b>ventana emergente</b> al abrir el dashboard (una sola vez por persona)</label></div></div>

  <div class="col-sm-4"><label class="form-label small mb-0">Visible desde</label><input type="date" name="desde" class="form-control" value="<%= LocalDate.now() %>"></div>
  <div class="col-sm-4"><label class="form-label small mb-0">Hasta (opcional)</label><input type="date" name="hasta" class="form-control"></div>
  <div class="col-sm-4 d-flex align-items-end"><button class="btn btn-primary w-100">Publicar</button></div>
</form></div></div>

<div class="card"><div class="card-body">
<h6>Publicadas</h6>
<% if (lista.isEmpty()) { %><p class="text-muted mb-0">A&uacute;n no hay novedades.</p><% } else { %>
<div class="table-responsive"><table class="table table-sm align-middle">
<thead><tr><th>T&iacute;tulo</th><th>Dirigida a</th><th>Vigencia</th><th>Estado</th><th></th></tr></thead><tbody>
<% for (Object[] n : lista) { boolean vig = (Boolean) n[6]; int idn = (Integer) n[0]; String aud = (String) n[7]; List<String> dl = dest.get(idn); %>
<tr><td><b><%= esc((String) n[1]) %></b><br><small class="text-muted"><%= esc((String) n[2]) %></small></td>
<td class="small"><%= "T".equals(aud) ? "Todos" : ("D".equals(aud) ? "Departamentos: " : "Personas: ") + esc(dl == null ? "-" : (dl.size() > 4 ? String.join(", ", dl.subList(0, 4)) + " y " + (dl.size() - 4) + " más" : String.join(", ", dl))) %>
    <% if ("S".equals(n[8])) { %><br><span class="badge bg-info">Ventana emergente &middot; vista por <%= vistas.getOrDefault(idn, 0) %></span><% } %></td>
<td class="small"><%= n[3] %> &rarr; <%= n[4] == null ? "sin vencimiento" : n[4] %></td>
<td><span class="badge bg-<%= vig ? "success" : "secondary" %>"><%= vig ? "Visible" : ("A".equals(n[5]) ? "Fuera de fecha" : "Retirada") %></span></td>
<td class="text-end text-nowrap">
  <form method="post" class="d-inline"><input type="hidden" name="accion" value="estado"><input type="hidden" name="id" value="<%= idn %>"><button class="btn btn-sm btn-outline-secondary"><%= "A".equals(n[5]) ? "Retirar" : "Reactivar" %></button></form>
  <form method="post" class="d-inline" onsubmit="return confirm('¿Eliminar esta novedad?');"><input type="hidden" name="accion" value="eliminar"><input type="hidden" name="id" value="<%= idn %>"><button class="btn btn-sm btn-outline-danger">Eliminar</button></form>
</td></tr>
<% } %></tbody></table></div>
<% } %>
</div></div>
</div>
<script>
// Muestra el selector que corresponde a "Para quien es" y filtra la lista de personas
document.querySelectorAll('input[name=audiencia]').forEach(function (r) {
    r.addEventListener('change', function () {
        var v = document.querySelector('input[name=audiencia]:checked').value;
        document.getElementById('boxD').style.display = v === 'D' ? '' : 'none';
        document.getElementById('boxU').style.display = v === 'U' ? '' : 'none';
    });
});
function norm(x) { return (x || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, ''); }
document.getElementById('filtroU').addEventListener('input', function () {
    var ws = norm(this.value).split(/\s+/).filter(Boolean);
    document.querySelectorAll('#listaU .fila-u').forEach(function (f) {
        var t = norm(f.textContent); f.style.display = ws.every(function (w) { return t.indexOf(w) !== -1; }) ? '' : 'none';
    });
});
</script>
</body></html>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div style='font-family:sans-serif;padding:20px'>No se pudo cargar las novedades. &iquest;Se ejecutaron los scripts 051 y 055? Detalle: " + esc(String.valueOf(e.getMessage())) + "</div>");
    }
%>
