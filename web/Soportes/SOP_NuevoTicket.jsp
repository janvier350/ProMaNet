<%--
    Document   : SOP_NuevoTicket
    Pantalla amigable para crear un ticket, pensada para usuarios que
    casi nunca lo hacen (no se acuerdan de donde era, no saben el
    modelo exacto, etc.).

    Diferencias con el flujo tradicional (Perfil.jsp lado derecho,
    que sigue intacto para los usuarios habituales):
      - Dropdown "Elegi tu equipo" prellenado con los equipos ya
        asignados al usuario. Si solo tiene uno, se preselecciona.
      - Textarea con placeholder guiado.
      - 3 cards de prioridad en vez de dropdown chico, cada una con
        explicacion clara ("Alta = no puedo trabajar", etc.).
      - Boton grande "Enviar solicitud".

    Postea al mismo servlet insertSoporte (sin cambios de backend) para
    que los tickets caigan en el mismo lugar que los de Perfil.
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
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigoStr = (String) session.getAttribute("cod");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    // Esta pantalla la puede abrir cualquier usuario logueado: la idea
    // es facilitar la creacion para quien no suele hacerlo. No se exige
    // SOPORTES_ACCESO (ese es para gestionar).
    int idUsuario = -1;
    try { idUsuario = Integer.parseInt(codigoStr.trim()); } catch (Exception ignore) {}

    // Equipos actualmente asignados al usuario (una fila por equipo)
    java.util.List<String[]> misEquipos = new java.util.ArrayList<>();
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null && idUsuario > 0) {
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT e.IDINVEQUIPO, e.MARCA || ' ' || e.MODELO, NVL(e.SERIAL,'-'), NVL(e.DISPOSITIVO,'Equipo') " +
                    "FROM INV_ASIGNACION a " +
                    "JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDINVEQUIPO " +
                    "WHERE a.IDUSUARIO = ? AND a.ESTADO = 'A' AND e.ESTADO_AI = 'A' " +
                    "ORDER BY e.MARCA, e.MODELO")) {
                st.setInt(1, idUsuario);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        misEquipos.add(new String[]{
                            rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4)
                        });
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ProMaNet - Nuevo ticket</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .card-prio { cursor: pointer; transition: all .15s; border: 2px solid transparent; }
    .card-prio:hover { transform: translateY(-2px); box-shadow: 0 .5rem 1rem rgba(0,0,0,.15); }
    .card-prio.selected { border-color: #5e72e4; box-shadow: 0 .3rem .6rem rgba(94,114,228,.3); }
    .card-prio .icono-prio { font-size: 2rem; }
</style>
</head>
<body class="g-sidenav-show bg-gray-100">
<%@ include file="/_sidenav.jspf" %>
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Nuevo ticket</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Nuevo ticket de soporte</h6>
            </nav>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card mb-4">
                    <div class="card-header pb-0">
                        <h5 class="mb-0">¿En que podemos ayudarte, <%=esc(nombre)%>?</h5>
                        <p class="text-sm text-secondary mb-0">Contanos que esta pasando y el equipo de Soporte se encarga.</p>
                    </div>
                    <div class="card-body p-4">
                        <form action="../insertSoporte" method="post" id="formNuevo">
                            <input type="hidden" name="idUsuario" value="<%=idUsuario%>">
                            <input type="hidden" name="prioridad" id="hidPrioridad" value="">

                            <!-- Equipo -->
                            <div class="form-group mb-4">
                                <label class="text-sm font-weight-bold">1. ¿Que equipo tiene el problema?</label>
                                <% if (misEquipos.isEmpty()) { %>
                                <div class="alert alert-warning mb-0">
                                    <i class="fa fa-info-circle me-1"></i>
                                    No tenes equipos asignados en el sistema. Pedi el ticket a traves de
                                    <a href="../Proyectos/Perfil.jsp">tu Perfil</a>, o contacta a Soporte directamente.
                                </div>
                                <% } else { %>
                                <select name="idEquipo" class="form-control form-control-lg" required>
                                    <% if (misEquipos.size() == 1) { String[] e = misEquipos.get(0); %>
                                    <option value="<%=e[0]%>" selected><%=esc(e[3])%> &mdash; <%=esc(e[1])%> (S/N <%=esc(e[2])%>)</option>
                                    <% } else { %>
                                    <option value="">-- Elegi tu equipo --</option>
                                    <% for (String[] e : misEquipos) { %>
                                    <option value="<%=e[0]%>"><%=esc(e[3])%> &mdash; <%=esc(e[1])%> (S/N <%=esc(e[2])%>)</option>
                                    <% } } %>
                                </select>
                                <small class="text-xs text-muted">Solo aparecen los equipos actualmente asignados a vos.</small>
                                <% } %>
                            </div>

                            <!-- Descripcion -->
                            <div class="form-group mb-4">
                                <label class="text-sm font-weight-bold">2. ¿Que problema tenes?</label>
                                <textarea name="soporte" class="form-control" rows="5" required maxlength="2000"
                                          placeholder="Contanos con detalle que pasa. Ejemplos:
- Mi laptop se apaga sola cada 10 minutos.
- No puedo imprimir desde Office, me da error 'driver no disponible'.
- Mi correo no abre adjuntos de Excel."></textarea>
                                <small class="text-xs text-muted">Mientras mas detalle incluyas (que estabas haciendo, cuando empezo, mensaje de error) mas rapido te atienden.</small>
                            </div>

                            <!-- Prioridad -->
                            <div class="form-group mb-4">
                                <label class="text-sm font-weight-bold mb-2">3. ¿Que tan urgente es?</label>
                                <div class="row g-2">
                                    <div class="col-md-4">
                                        <div class="card card-prio text-center p-3" data-prio="Alta">
                                            <div class="icono-prio text-danger"><i class="fa fa-fire"></i></div>
                                            <p class="font-weight-bold mb-1 mt-2">Alta</p>
                                            <p class="text-xs text-secondary mb-0">No puedo trabajar hasta que se resuelva.</p>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card card-prio text-center p-3" data-prio="Media">
                                            <div class="icono-prio text-warning"><i class="fa fa-exclamation-triangle"></i></div>
                                            <p class="font-weight-bold mb-1 mt-2">Media</p>
                                            <p class="text-xs text-secondary mb-0">Me retrasa pero puedo seguir con otras cosas.</p>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card card-prio text-center p-3" data-prio="Baja">
                                            <div class="icono-prio text-info"><i class="fa fa-info-circle"></i></div>
                                            <p class="font-weight-bold mb-1 mt-2">Baja</p>
                                            <p class="text-xs text-secondary mb-0">Es una mejora o consulta, no es urgente.</p>
                                        </div>
                                    </div>
                                </div>
                                <small class="text-xs text-danger d-block mt-2" id="prioError" style="display:none !important;">Elegi un nivel de prioridad.</small>
                            </div>

                            <div class="d-flex justify-content-between align-items-center">
                                <a href="../Proyectos/PRO_Dashboard.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                                    <i class="fa fa-arrow-left me-1"></i>Volver
                                </a>
                                <button type="submit" class="btn bg-gradient-primary btn-lg mb-0" <% if (misEquipos.isEmpty()) { %>disabled<% } %>>
                                    <i class="fa fa-paper-plane me-1"></i>Enviar solicitud
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    (function(){
        var cards = document.querySelectorAll('.card-prio');
        var hid = document.getElementById('hidPrioridad');
        var err = document.getElementById('prioError');
        cards.forEach(function(c){
            c.addEventListener('click', function(){
                cards.forEach(function(x){ x.classList.remove('selected'); });
                this.classList.add('selected');
                hid.value = this.getAttribute('data-prio');
                err.style.display = 'none';
            });
        });
        document.getElementById('formNuevo').addEventListener('submit', function(e){
            if (!hid.value) {
                e.preventDefault();
                err.style.display = 'block';
                err.scrollIntoView({behavior:'smooth', block:'center'});
            }
        });
    })();
</script>
</body>
</html>
