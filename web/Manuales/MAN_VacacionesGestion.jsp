<%--
    Document   : MAN_VacacionesGestion
    Manual de usuario: GESTION de vacaciones por grupo (gestores de Romeria / Kennedy y
    administrador global). Corto, imprimible.

    Visible con VACACIONES_CONFIGURAR o VACACIONES_GESTIONAR. Muestra los grupos que gestiona
    quien lo abre (todos si es administrador global).
    Si cambian reglas (factor, permisos por horas, grupos) actualizar este archivo.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    boolean puedeConfigurar = COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR");
    boolean puedeGestionar  = COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR");
    if (!puedeConfigurar && !puedeGestionar) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }
    boolean esGlobal = VACACIONES.VAC_Alcance.esGlobal(session);
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    request.setAttribute("sidenav_active", "manuales");
    request.setAttribute("guiaSiempreVisible", Boolean.TRUE);

    // Grupos que gestiona quien abre el manual (todos, si es administrador global).
    java.util.List<String[]> misGrupos = new java.util.ArrayList<>();   // {nombre, gestores, nEmpleados}
    int sinAsignar = -1;
    try (java.sql.Connection cnG = Servlets.Conexion.getConnection()) {
        if (cnG != null) {
            java.util.List<Integer> ids = esGlobal ? null : VACACIONES.VAC_Alcance.grupos(cnG, VACACIONES.VAC_Alcance.idUsuario(session));
            try (java.sql.PreparedStatement st = cnG.prepareStatement(
                    "SELECT g.ID_GRUPO, g.NOMBRE, " +
                    "(SELECT LISTAGG(u.NOMBRE||' '||u.APELLIDOS, ', ') WITHIN GROUP (ORDER BY u.NOMBRE) FROM VAC_GRUPO_GESTOR gg " +
                    "  JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO WHERE gg.ID_GRUPO = g.ID_GRUPO), " +
                    "(SELECT COUNT(*) FROM VAC_CONFIG_USUARIO vc JOIN USUARIO u ON u.IDUSUARIO = vc.ID_USUARIO " +
                    "  WHERE vc.ID_GRUPO = g.ID_GRUPO AND u.ESTADO = 'a') " +
                    "FROM VAC_GRUPO g WHERE g.ESTADO = 'A' ORDER BY g.NOMBRE");
                 java.sql.ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    if (ids != null && !ids.contains(rs.getInt(1))) continue;
                    misGrupos.add(new String[]{rs.getString(2), rs.getString(3), rs.getString(4)});
                }
            }
            if (esGlobal) {
                try (java.sql.PreparedStatement st = cnG.prepareStatement(
                        "SELECT COUNT(*) FROM USUARIO u LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = u.IDUSUARIO " +
                        "WHERE u.ESTADO = 'a' AND vc.ID_GRUPO IS NULL");
                     java.sql.ResultSet rs = st.executeQuery()) {
                    if (rs.next()) sinAsignar = rs.getInt(1);
                }
            }
        }
    } catch (Exception exG) { /* sin grupos todavia */ }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manual - Gestion de vacaciones</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
<style>
    .regla i { width:1.4rem; }
    @media print {
        #iconNavbarSidenav, #sidenav-main, .no-print, .min-height-300 { display:none !important; }
        .main-content { margin-left:0 !important; }
        body { background:#fff !important; }
        .card { box-shadow:none !important; border:1px solid #ddd; page-break-inside: avoid; }
    }
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
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="MAN_Indice.jsp">Manuales</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Gestion de vacaciones</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manual: Gesti&oacute;n de vacaciones por grupo</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0"><i class="fa fa-user me-1"></i> <%=nombre%> <%=apellidos%></span>
            </div>
        </div>
    </nav>

    <div class="container-fluid py-4">
        <div class="row justify-content-center">
        <div class="col-xl-10">

            <div class="d-flex justify-content-between align-items-center flex-wrap mb-3">
                <p class="text-white text-sm mb-0">Para gestores de grupo y administrador global. Lectura: 4 minutos.</p>
                <button class="btn btn-sm btn-white mb-0 no-print" onclick="window.print()"><i class="fas fa-print me-1"></i> Imprimir / PDF</button>
            </div>

            <div class="card mb-4">
                <div class="card-body py-3">
                    <h6 class="mb-1"><i class="fas fa-people-group text-primary me-2"></i>C&oacute;mo est&aacute; organizada la gesti&oacute;n</h6>
                    <p class="text-sm mb-2">Las vacaciones se gestionan por <b>grupos</b>: hoy <b>Romer&iacute;a</b> y <b>Kennedy</b> (oficinas 401 y 403).
                        Cada empleado pertenece a un grupo, y cada gestor ve y modifica <b>solo a los empleados de su grupo</b>: no ve los del otro.
                        El grupo lo asigna el administrador global y es independiente de la oficina f&iacute;sica, as&iacute; que alguien de una oficina
                        puede ser gestionado por otro grupo.</p>
                    <% for (String[] g : misGrupos) { %>
                    <p class="text-sm mb-1"><span class="badge bg-gradient-primary me-1"><%=g[0]%></span>
                        Gestor: <b><%= g[1] != null ? g[1] : "-" %></b> &middot; <%=g[2]%> empleados</p>
                    <% } %>
                    <% if (misGrupos.isEmpty()) { %>
                    <p class="text-sm text-warning mb-0"><i class="fas fa-circle-exclamation me-1"></i>No tienes ning&uacute;n grupo asignado como gestor; no ver&aacute;s empleados hasta que el administrador te asigne uno.</p>
                    <% } %>
                    <% if (esGlobal && sinAsignar >= 0) { %>
                    <p class="text-sm mb-0 mt-1 <%= sinAsignar > 0 ? "text-danger" : "text-secondary" %>"><b>Sin asignar:</b> <%=sinAsignar%> empleados (solo los ve el administrador global).</p>
                    <% } %>
                </div>
            </div>

            <%@ include file="/_guias/guia_vacaciones_gestion.jspf" %>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-user-clock text-warning me-2"></i>Permisos por horas</h6></div>
                        <div class="card-body text-sm">
                            <p>En &laquo;Ver Saldo&raquo; del empleado &rarr; <b>Registrar permiso</b>: fecha (d&iacute;a h&aacute;bil), horas (hasta 8 por d&iacute;a), motivo y detalle.</p>
                            <table class="table table-sm align-middle mb-2">
                                <thead><tr><th>Motivo y horas</th><th>Vacaciones</th></tr></thead>
                                <tbody>
                                    <tr><td>Personal, <b>8 horas</b></td><td>Descarga <b>1.36 d&iacute;as</b></td></tr>
                                    <tr><td>Personal, 1 a 7 horas</td><td>No descarga</td></tr>
                                    <tr><td>Salud, estudio u otros (aunque sean 8 h)</td><td>No descarga</td></tr>
                                </tbody>
                            </table>
                            <p class="text-xs text-secondary mb-0">El descargo se crea solo como un ajuste enlazado (etiqueta &laquo;Permiso&raquo;). Si editas o eliminas el permiso, el ajuste se actualiza o se borra.</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-calculator text-primary me-2"></i>Ajustes hist&oacute;ricos</h6></div>
                        <div class="card-body text-sm">
                            <p>Para d&iacute;as ya gozados antes del sistema: <b>Nuevo ajuste</b> en &laquo;Ver Saldo&raquo;.</p>
                            <ul class="mb-2 ps-3">
                                <li>Con <b>fechas desde/hasta</b> el sistema calcula los d&iacute;as: h&aacute;biles (L-V) &times; 1.3636 (ej. 5 h&aacute;biles = 6.82).</li>
                                <li>Sin fechas, elige si lo que escribes son <b>d&iacute;as h&aacute;biles</b> (1 = 1.36) o d&iacute;as <b>ya calculados</b>.</li>
                                <li>Los ajustes que vienen de un permiso no se editan aqu&iacute;; se gestionan desde el permiso.</li>
                            </ul>
                            <p class="text-xs text-secondary mb-0">El saldo de quien a&uacute;n no cumple el a&ntilde;o muestra los d&iacute;as adelantados en negativo (ej. -2.73) y lo ganado a hoy de forma proporcional.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-unlock text-info me-2"></i>Vacaciones ya gozadas (fechas pasadas)</h6></div>
                        <div class="card-body text-sm">
                            <p>Normalmente los empleados no pueden pedir fechas pasadas. En el panel, en la tarjeta de <b>tu grupo</b>, pulsa <b>Habilitar fechas pasadas</b> y elige hasta cu&aacute;ndo (m&aacute;ximo 30 d&iacute;as).</p>
                            <ul class="mb-2 ps-3">
                                <li>Vale <b>solo para los empleados de ese grupo</b>.</li>
                                <li>Las solicitudes salen marcadas &laquo;Ya gozadas&raquo; y siguen el flujo normal (jefe &rarr; gestor).</li>
                                <li>Si el empleado a&uacute;n no cumple el a&ntilde;o, las registra como solicitud anticipada.</li>
                                <li>Se cierra sola al vencer la fecha, o con <b>Volver al modo normal</b>.</li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="card h-100">
                        <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-shield-halved text-success me-2"></i>Reglas de los grupos</h6></div>
                        <div class="card-body regla text-sm">
                            <p class="mb-2"><i class="fas fa-eye-slash text-info"></i> Un gestor <b>no ve</b> a los empleados del otro grupo ni a los sin asignar.</p>
                            <p class="mb-2"><i class="fas fa-ban text-info"></i> Si intentas abrir o modificar a alguien fuera de tu grupo, el sistema lo rechaza.</p>
                            <p class="mb-2"><i class="fas fa-user-gear text-info"></i> Solo el <b>administrador global</b> asigna o cambia el grupo de un empleado (columna <b>Grupo de gesti&oacute;n</b> en Configuraci&oacute;n).</p>
                            <p class="mb-0"><i class="fas fa-user-tie text-info"></i> El <b>jefe directo</b> sigue aprobando su paso; despu&eacute;s aprueba el gestor del grupo del empleado.</p>
                        </div>
                    </div>
                </div>
            </div>

            <% if (esGlobal) { %>
            <div class="card mb-4">
                <div class="card-header pb-0"><h6 class="mb-0"><i class="fas fa-users-gear text-primary me-2"></i>Solo administrador global: asignar empleados a un grupo</h6></div>
                <div class="card-body text-sm">
                    <ol class="mb-2 ps-3">
                        <li>Panel de Vacaciones &rarr; tarjeta <b>Grupos de gesti&oacute;n</b> &rarr; <b>Asignar empleados</b> (abre Configuraci&oacute;n filtrada por &laquo;Sin asignar&raquo;).</li>
                        <li>En la columna <b>Grupo de gesti&oacute;n</b> elige Romer&iacute;a o Kennedy para cada empleado y confirma. Desde ese momento el gestor de ese grupo lo ve.</li>
                        <li>El filtro de arriba (Todos / Romer&iacute;a / Kennedy / Sin asignar) te ayuda a revisar.</li>
                    </ol>
                    <p class="text-xs text-secondary mb-0">La oficina de cada empleado (Norte, Kennedy 401/403, Romer&iacute;a, Magisterio, Outsourcing) es solo un dato informativo y una sugerencia: lo que manda es el grupo.</p>
                </div>
            </div>
            <% } %>

            <p class="text-xs text-secondary text-center no-print">
                <a href="MAN_Indice.jsp">&larr; Todos los manuales</a> &middot; <a href="../Vacaciones/VAC_Dashboard.jsp">Ir al Panel de Vacaciones</a>
            </p>
        </div>
        </div>
    </div>
</main>
</body>
</html>
