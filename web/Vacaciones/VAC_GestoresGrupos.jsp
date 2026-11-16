<%--
    Document   : VAC_GestoresGrupos
    Quien gestiona las vacaciones de cada grupo (oficina). Solo el administrador global (VACACIONES_GRUPOS).
    Agregar un gestor = lo registra en VAC_GRUPO_GESTOR y le concede VACACIONES_CONFIGURAR + VACACIONES_GESTIONAR.
    Quitarlo = lo retira del grupo y, si ya no gestiona ningun grupo, le retira esos dos permisos (solo la concesion
    individual; lo que tenga por cargo o departamento no se toca). La persona debe cerrar sesion y volver a entrar.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
    private static final String[] PERMISOS = {"VACACIONES_CONFIGURAR", "VACACIONES_GESTIONAR"};
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!VACACIONES.VAC_Alcance.esGlobal(session)) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    request.setCharacterEncoding("UTF-8");
    String msg = null, err = null;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String accion = request.getParameter("accion");
            try {
                int idGrupo = Integer.parseInt(request.getParameter("grupo"));
                int idUsu = Integer.parseInt(request.getParameter("usuario"));
                cn.setAutoCommit(false);
                if ("agregar".equals(accion)) {
                    try (PreparedStatement st = cn.prepareStatement(
                            "INSERT INTO VAC_GRUPO_GESTOR (ID_GRUPO, ID_USUARIO) SELECT ?, ? FROM DUAL " +
                            "WHERE NOT EXISTS (SELECT 1 FROM VAC_GRUPO_GESTOR WHERE ID_GRUPO = ? AND ID_USUARIO = ?)")) {
                        st.setInt(1, idGrupo); st.setInt(2, idUsu); st.setInt(3, idGrupo); st.setInt(4, idUsu);
                        st.executeUpdate();
                    }
                    for (String cod : PERMISOS) {
                        try (PreparedStatement st = cn.prepareStatement(
                                "MERGE INTO APP_USUARIO_PERMISO up USING (SELECT ? AS IDU, p.ID_PERMISO FROM APP_PERMISO p WHERE p.CODIGO = ?) src " +
                                "ON (up.IDUSUARIO = src.IDU AND up.ID_PERMISO = src.ID_PERMISO) " +
                                "WHEN MATCHED THEN UPDATE SET up.TIPO = 'G' " +
                                "WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDU, src.ID_PERMISO, 'G')")) {
                            st.setInt(1, idUsu); st.setString(2, cod); st.executeUpdate();
                        }
                    }
                    COMUN.LogActividad.registrar(request, "VACACIONES", "CREAR", "Agrego gestor " + idUsu + " al grupo " + idGrupo);
                    msg = "Gestor agregado. Debe cerrar sesión y volver a entrar para ver los cambios.";
                } else if ("quitar".equals(accion)) {
                    try (PreparedStatement st = cn.prepareStatement("DELETE FROM VAC_GRUPO_GESTOR WHERE ID_GRUPO = ? AND ID_USUARIO = ?")) {
                        st.setInt(1, idGrupo); st.setInt(2, idUsu); st.executeUpdate();
                    }
                    int restantes = 0;
                    try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM VAC_GRUPO_GESTOR WHERE ID_USUARIO = ?")) {
                        st.setInt(1, idUsu); try (ResultSet rs = st.executeQuery()) { if (rs.next()) restantes = rs.getInt(1); }
                    }
                    boolean retiroPermisos = false;
                    if (restantes == 0) {   // ya no gestiona ningun grupo: retirar la concesion individual (salvo administradores globales)
                        try (PreparedStatement st = cn.prepareStatement(
                                "DELETE FROM APP_USUARIO_PERMISO WHERE IDUSUARIO = ? AND ID_PERMISO IN (SELECT ID_PERMISO FROM APP_PERMISO WHERE CODIGO IN ('VACACIONES_CONFIGURAR','VACACIONES_GESTIONAR')) " +
                                "AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO x JOIN APP_PERMISO px ON px.ID_PERMISO = x.ID_PERMISO WHERE x.IDUSUARIO = ? AND px.CODIGO = 'VACACIONES_GRUPOS' AND x.TIPO = 'G')")) {
                            st.setInt(1, idUsu); st.setInt(2, idUsu); retiroPermisos = st.executeUpdate() > 0;
                        }
                    }
                    COMUN.LogActividad.registrar(request, "VACACIONES", "ELIMINAR", "Quito gestor " + idUsu + " del grupo " + idGrupo);
                    msg = "Gestor retirado del grupo." + (retiroPermisos ? " Como ya no gestiona ningún grupo, se le retiraron los permisos de Vacaciones." : "");
                }
                cn.commit();
            } catch (Exception ex) { cn.rollback(); err = "No se pudo guardar: " + ex.getMessage(); }
            finally { cn.setAutoCommit(true); }
        }

        List<Object[]> grupos = new ArrayList<>();   // {id, nombre, empleados}
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT g.ID_GRUPO, g.NOMBRE, (SELECT COUNT(*) FROM VAC_CONFIG_USUARIO vc WHERE vc.ID_GRUPO = g.ID_GRUPO) FROM VAC_GRUPO g WHERE g.ESTADO = 'A' ORDER BY g.NOMBRE");
             ResultSet rs = st.executeQuery()) { while (rs.next()) grupos.add(new Object[]{rs.getInt(1), rs.getString(2), rs.getInt(3)}); }
        Map<Integer, List<String[]>> gestores = new HashMap<>();   // grupo -> {idUsuario, nombre, login}
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT gg.ID_GRUPO, u.IDUSUARIO, u.NOMBRE || ' ' || u.APELLIDOS, u.USUARIO FROM VAC_GRUPO_GESTOR gg JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO ORDER BY u.APELLIDOS, u.NOMBRE");
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) gestores.computeIfAbsent(rs.getInt(1), k -> new ArrayList<>()).add(new String[]{rs.getString(2), rs.getString(3), rs.getString(4)});
        }
        List<String[]> usuarios = new ArrayList<>();   // {id, nombre} activos
        try (PreparedStatement st = cn.prepareStatement("SELECT IDUSUARIO, NOMBRE || ' ' || APELLIDOS FROM USUARIO WHERE ESTADO = 'a' ORDER BY NOMBRE, APELLIDOS");
             ResultSet rs = st.executeQuery()) { while (rs.next()) usuarios.add(new String[]{rs.getString(1), rs.getString(2)}); }
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Gestores por grupo</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<a href="VAC_Dashboard.jsp" class="small">&larr; Volver a Vacaciones</a>
<h4 class="mt-2">Gestores de vacaciones por grupo</h4>
<p class="text-muted">Cada grupo (oficina) tiene uno o varios gestores que configuran y aprueban las vacaciones de sus empleados.
Al agregar un gestor se le conceden autom&aacute;ticamente los permisos de Vacaciones; al quitar al &uacute;ltimo grupo, se le retiran. La persona debe cerrar sesi&oacute;n y volver a entrar.</p>
<% if (msg != null) { %><div class="alert alert-success py-2"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger py-2"><%= esc(err) %></div><% } %>

<% for (Object[] g : grupos) { int idg = (Integer) g[0]; List<String[]> gl = gestores.getOrDefault(idg, new ArrayList<>()); %>
<div class="card mb-3"><div class="card-body">
  <div class="d-flex justify-content-between align-items-center mb-2">
    <h6 class="mb-0"><%= esc((String) g[1]) %> <span class="badge bg-secondary ms-1"><%= g[2] %> empleados</span></h6>
  </div>
  <% if (gl.isEmpty()) { %><p class="text-danger small mb-2">Este grupo no tiene gestor: nadie puede aprobar sus vacaciones (solo el administrador global).</p><% } %>
  <ul class="list-group list-group-flush mb-2">
  <% for (String[] u : gl) { %>
    <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
      <span><%= esc(u[1]) %> <span class="text-muted small">&middot; <%= esc(u[2]) %></span></span>
      <form method="post" class="m-0" onsubmit="return confirm('¿Quitar a este gestor del grupo?');">
        <input type="hidden" name="accion" value="quitar"><input type="hidden" name="grupo" value="<%= idg %>"><input type="hidden" name="usuario" value="<%= u[0] %>">
        <button class="btn btn-sm btn-outline-danger">Quitar</button>
      </form>
    </li>
  <% } %>
  </ul>
  <form method="post" class="row g-2">
    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="grupo" value="<%= idg %>">
    <div class="col-sm-5"><input type="text" class="form-control form-control-sm filtro-usuario" placeholder="Buscar usuario..." autocomplete="off"></div>
    <div class="col-sm-5"><select name="usuario" class="form-select form-select-sm sel-usuario" required>
      <option value="">-- Elija un usuario --</option>
      <% for (String[] u : usuarios) { %><option value="<%= u[0] %>"><%= esc(u[1]) %></option><% } %>
    </select></div>
    <div class="col-sm-2"><button class="btn btn-sm btn-primary w-100">Agregar</button></div>
  </form>
</div></div>
<% } %>
<p class="small text-muted">Los empleados sin grupo se asignan en <a href="VAC_ConfigUsuarios.jsp?grupo=0">Configurar empleados</a>.</p>
</div>
<script>
// Busqueda rapida en cada selector de usuarios (sin tildes ni mayusculas; varias palabras en cualquier orden)
document.querySelectorAll('form').forEach(function (f) {
    var inp = f.querySelector('.filtro-usuario'), sel = f.querySelector('.sel-usuario'); if (!inp || !sel) return;
    var todos = []; for (var i = 1; i < sel.options.length; i++) todos.push({v: sel.options[i].value, t: sel.options[i].text});
    function norm(x) { return (x || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, ''); }
    inp.addEventListener('input', function () {
        var ws = norm(inp.value).split(/\s+/).filter(Boolean), n = 0;
        sel.innerHTML = '<option value="">-- Elija un usuario --</option>';
        todos.forEach(function (e) { var t = norm(e.t); if (ws.every(function (w) { return t.indexOf(w) !== -1; })) { var o = document.createElement('option'); o.value = e.v; o.text = e.t; sel.appendChild(o); n++; } });
        if (inp.value && n === 1) sel.selectedIndex = 1;
    });
});
</script>
</body></html>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div style='font-family:sans-serif;padding:20px'>No se pudo cargar: " + esc(String.valueOf(e.getMessage())) + "</div>");
    }
%>
