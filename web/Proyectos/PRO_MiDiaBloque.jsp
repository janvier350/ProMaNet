<%--
    Document   : PRO_MiDiaBloque
    Bloques del panel "Hoy para ti" del dashboard (PRO_Dashboard.jsp). Cada bloque es un fragmento HTML
    independiente que el dashboard pide por fetch (?b=nombre) despues de cargar la pagina: asi el dashboard abre
    rapido y un bloque que falle no afecta a los demas. Si un bloque no aplica al usuario responde 204 y el
    dashboard lo quita.

    Bloques: pendientes | movilizacion | tickets | vacaciones | anticipos | equipo | ausentes | aniversarios | ticketsdia | accesos | novedades | cumpleanos | usados
    Todo se filtra por el usuario de la sesion y sus permisos.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.time.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private static String cabecera(String icono, String color, String titulo) {
        return "<div class='card h-100'><div class='card-body p-3'>"
             + "<div class='d-flex align-items-center mb-2'><div class='icon icon-shape icon-sm bg-gradient-" + color + " shadow text-center rounded-circle me-2' style='width:2rem;height:2rem;'>"
             + "<i class='" + icono + " text-white text-sm' style='line-height:2rem;'></i></div>"
             + "<span class='text-xs text-uppercase font-weight-bold text-secondary'>" + titulo + "</span></div>";
    }
    private static String pie() { return "</div></div>"; }
    private static String cuando(LocalDate f, LocalDate hoy) {
        long d = java.time.temporal.ChronoUnit.DAYS.between(hoy, f);
        if (d == 0) return "Hoy";
        if (d == 1) return "Mañana";
        return new SimpleDateFormat("EEEE d 'de' MMMM", new Locale("es", "EC")).format(java.sql.Date.valueOf(f));
    }
%>
<%
    if (session.getAttribute("usuario") == null) { response.setStatus(401); return; }
    String b = request.getParameter("b");
    if (b == null) { response.setStatus(204); return; }
    int uid = -1;
    try { uid = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (uid <= 0) { response.setStatus(204); return; }
    String ctx = request.getContextPath();
    LocalDate hoy = LocalDate.now();
    StringBuilder html = new StringBuilder();
    boolean aplica = true;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn == null) throw new Exception("sin conexion");

        // ---------------------------------------------------------------- MOVILIZACION
        if ("movilizacion".equals(b)) {
            if (!COMUN.PermisoHelper.tiene(session, "MOVILIZACION_SOLICITAR")) aplica = false;
            else {
                html.append(cabecera("fas fa-car-side", "info", "Mi movilización"));
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT * FROM (SELECT s.FECHA, s.HORA_INICIO, s.HORA_FIN, s.ESTADO, d.DESCRIPCION, m.NOMBRE, mo.DESCRIPCION " +
                        "FROM MOV_SOLICITUD s LEFT JOIN MOV_DESTINO d ON d.ID_DESTINO = s.ID_DESTINO " +
                        "LEFT JOIN MOV_MOVILIZADOR m ON m.ID_MOVILIZADOR = s.ID_MOVILIZADOR LEFT JOIN MOV_MOTIVO mo ON mo.ID_MOTIVO = s.ID_MOTIVO " +
                        "WHERE s.IDUSUARIO = ? AND s.FECHA >= TRUNC(SYSDATE) AND s.ESTADO IN ('PENDIENTE','APROBADA') " +
                        "ORDER BY s.FECHA, s.HORA_INICIO) WHERE ROWNUM <= 1")) {
                    st.setInt(1, uid);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            LocalDate f = rs.getDate(1).toLocalDate();
                            boolean aprobada = "APROBADA".equals(rs.getString(4));
                            html.append("<h5 class='mb-0 font-weight-bolder'>").append(esc(cuando(f, hoy))).append(" &middot; ").append(esc(rs.getString(2))).append(" - ").append(esc(rs.getString(3))).append("</h5>");
                            html.append("<p class='text-sm mb-1'>").append(esc(rs.getString(5) != null ? rs.getString(5) : rs.getString(7))).append("</p>");
                            html.append("<p class='text-xs text-secondary mb-2'>Movilizador: ").append(esc(rs.getString(6))).append("</p>");
                            html.append("<span class='badge badge-sm bg-gradient-").append(aprobada ? "success" : "warning").append("'>").append(aprobada ? "Aprobada" : "Pendiente de aprobación").append("</span>");
                        } else {
                            html.append("<p class='text-sm mb-2'>No tienes movilizaciones agendadas.</p>");
                        }
                    }
                }
                html.append("<div class='mt-3'><a href='").append(ctx).append("/Movilizacion/MOV_Calendario.jsp' class='btn btn-sm btn-outline-info mb-0'>Ver calendario / solicitar</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- TICKETS
        } else if ("tickets".equals(b)) {
            html.append(cabecera("fas fa-ticket", "danger", "Mis tickets"));
            int abiertos = 0; List<String> filas = new ArrayList<>();
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT IDSOPORTE, ESTADO, TRUNC(SYSDATE - FECHA_SOLICITUD), SUBSTR(SOPORTE, 1, 60) FROM SOP_SOPORTE_CAB " +
                    "WHERE IDUSUARIO = ? AND ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO') ORDER BY FECHA_SOLICITUD DESC")) {
                st.setInt(1, uid);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        abiertos++;
                        if (filas.size() < 3) {
                            boolean prog = "EN_PROGRESO".equals(rs.getString(2));
                            filas.add("<li class='list-group-item border-0 px-0 py-1 d-flex justify-content-between'><span class='text-xs'>#" + rs.getInt(1) + " "
                                    + esc(rs.getString(4)) + "</span><span class='badge badge-sm bg-gradient-" + (prog ? "info" : "warning") + "'>" + (prog ? "En atención" : "En espera") + "</span></li>");
                        }
                    }
                }
            }
            if (abiertos == 0) html.append("<p class='text-sm mb-2'><i class='fas fa-check-circle text-success me-1'></i>No tienes tickets abiertos.</p>");
            else {
                html.append("<h5 class='mb-1 font-weight-bolder'>").append(abiertos).append(abiertos == 1 ? " ticket abierto" : " tickets abiertos").append("</h5><ul class='list-group list-group-flush'>");
                for (String f : filas) html.append(f);
                html.append("</ul>");
            }
            html.append("<div class='mt-3'><a href='").append(ctx).append("/Soportes/SOP_MisTickets.jsp' class='btn btn-sm btn-outline-danger mb-0 me-1'>Ver mis tickets</a>")
                .append("<a href='").append(ctx).append("/Soportes/SOP_NuevoTicket.jsp' class='btn btn-sm btn-link text-secondary mb-0'>Crear ticket</a></div>");
            html.append(pie());

        // ---------------------------------------------------------------- VACACIONES
        } else if ("vacaciones".equals(b)) {
            if (!COMUN.PermisoHelper.tiene(session, "VACACIONES_SOLICITAR")) aplica = false;
            else {
                html.append(cabecera("fas fa-umbrella-beach", "warning", "Mis vacaciones"));
                VACACIONES.VAC_CalculoSaldo.Saldo saldo = VACACIONES.VAC_CalculoSaldo.calcular(cn, uid);
                if (!saldo.configurado) {
                    html.append("<p class='text-sm mb-1'>Tu fecha de ingreso aún no está configurada. Avisa al gestor de vacaciones de tu oficina.</p>");
                } else {
                    html.append("<h5 class='mb-0 font-weight-bolder'>").append(String.format(Locale.US, "%.2f", saldo.saldoNeto)).append(" días</h5>")
                        .append("<p class='text-xs text-secondary mb-2'>disponibles hoy</p>");
                }
                // proximas vacaciones aprobadas y solicitudes en trámite
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT (SELECT TO_CHAR(MIN(FECHA_DESDE),'DD/MM/YYYY') FROM VAC_SOLICITUD WHERE ID_USUARIO = ? AND ESTADO IN ('APROBADO','RECIBIDO') AND FECHA_HASTA >= TRUNC(SYSDATE)), " +
                        "       (SELECT COUNT(*) FROM VAC_SOLICITUD WHERE ID_USUARIO = ? AND ESTADO IN ('PENDIENTE_JEFE','PENDIENTE_ADMIN')) FROM DUAL")) {
                    st.setInt(1, uid); st.setInt(2, uid);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            if (rs.getString(1) != null) html.append("<p class='text-xs mb-1'><i class='fas fa-calendar-check text-success me-1'></i>Próximas vacaciones: <b>").append(esc(rs.getString(1))).append("</b></p>");
                            if (rs.getInt(2) > 0) html.append("<p class='text-xs mb-1'><i class='fas fa-hourglass-half text-warning me-1'></i>").append(rs.getInt(2)).append(rs.getInt(2) == 1 ? " solicitud en trámite" : " solicitudes en trámite").append("</p>");
                        }
                    }
                }
                html.append("<div class='mt-3'><a href='").append(ctx).append("/Vacaciones/VAC_MiSaldo.jsp' class='btn btn-sm btn-outline-warning mb-0'>Ver / solicitar</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- ANTICIPOS
        } else if ("anticipos".equals(b)) {
            boolean aud = COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_ACCESO");
            boolean ctrl = !aud && COMUN.PermisoHelper.tiene(session, "CONTROL_ACCESO");
            if (!aud && !ctrl) aplica = false;
            else {
                html.append(cabecera("fas fa-hand-holding-dollar", "primary", "Mi anticipo"));
                String tCorte = aud ? "AUD_FECHA_CORTE_ANTICIPO" : "CTRL_FECHA_CORTE_ANTICIPO", tAnt = aud ? "AUD_ANTICIPOS" : "CTRL_ANTICIPOS";
                String colId = aud ? "ID_USUARIO" : "ID_USUARIO";
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT TRUNC(FECHA_CORTE) - TRUNC(SYSDATE), TO_CHAR(FECHA_CORTE,'DD/MM/YYYY') FROM (SELECT FECHA_CORTE FROM " + tCorte +
                        " WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1");
                     ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        int dias = rs.getInt(1);
                        if (dias >= 0) html.append("<h5 class='mb-0 font-weight-bolder'>").append(dias == 0 ? "Hoy es el corte" : "Faltan " + dias + (dias == 1 ? " día" : " días")).append("</h5>")
                                .append("<p class='text-xs text-secondary mb-2'>para pedir tu anticipo (corte ").append(esc(rs.getString(2))).append(")</p>");
                        else html.append("<p class='text-sm mb-2'>El plazo de este mes ya venció (").append(esc(rs.getString(2))).append(").</p>");
                    } else html.append("<p class='text-sm mb-2'>Aún no se define la fecha de corte de este mes.</p>");
                }
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT * FROM (SELECT ANTICIPO, ESTADO, TO_CHAR(FECHA_SOLICITUD,'DD/MM/YYYY') FROM " + tAnt + " WHERE " + colId + " = ? ORDER BY FECHA_SOLICITUD DESC) WHERE ROWNUM <= 1")) {
                    st.setInt(1, uid);
                    try (ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            boolean pagado = "PAGADO".equals(rs.getString(2));
                            html.append("<p class='text-xs mb-1'>Último: <b>$ ").append(String.format(Locale.US, "%.2f", rs.getDouble(1))).append("</b> (").append(esc(rs.getString(3))).append(") ")
                                .append("<span class='badge badge-sm bg-gradient-").append(pagado ? "success" : "warning").append("'>").append(esc(rs.getString(2))).append("</span></p>");
                        }
                    }
                }
                html.append("<div class='mt-3'><a href='").append(ctx).append(aud ? "/Auditoria/AUD_SolicitarAnticipo.jsp" : "/Control/ADM_Solicitar_Anticipo.jsp")
                    .append("' class='btn btn-sm btn-outline-primary mb-0'>Ver / solicitar</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- EQUIPO
        } else if ("equipo".equals(b)) {
            List<INVENTARIO.INV_MantenimientoHelper.Fila> eq = new ArrayList<>();
            boolean avisos = false;
            try { eq = INVENTARIO.INV_MantenimientoHelper.cargarDeUsuario(cn, uid); avisos = INVENTARIO.INV_MantenimientoHelper.avisosActivos(cn); } catch (Exception exEq) { }
            if (eq.isEmpty()) aplica = false;
            else {
                html.append(cabecera("fas fa-laptop", "success", "Mi equipo"));
                java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
                for (INVENTARIO.INV_MantenimientoHelper.Fila f : eq) {
                    html.append("<p class='text-sm font-weight-bold mb-0'>").append(esc((f.dispositivo + " " + f.marca + " " + f.modelo).trim())).append("</p>");
                    if (avisos && f.proxima != null) {
                        boolean req = INVENTARIO.INV_MantenimientoHelper.requiereAviso(f, hoy);
                        html.append("<p class='text-xs mb-2'>Mantenimiento: <span class='badge badge-sm bg-gradient-").append(req ? "warning" : "success").append("'>")
                            .append(req ? "Te toca pronto" : "Al día").append("</span> <span class='text-secondary'>próximo ").append(INVENTARIO.INV_MantenimientoHelper.fechaAviso(f).format(fmt)).append("</span></p>");
                    } else html.append("<p class='text-xs text-secondary mb-2'>S/N ").append(esc(f.serial.isEmpty() ? "-" : f.serial)).append("</p>");
                }
                html.append(pie());
            }

        // ---------------------------------------------------------------- QUIEN ESTA FUERA (alcance segun el rol)
        } else if ("ausentes".equals(b)) {
            boolean gestor = COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR") || COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR") || VACACIONES.VAC_Alcance.esGlobal(session);
            int equipo = 0;
            try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM VAC_CONFIG_USUARIO WHERE ID_JEFE_DIRECTO = ?")) {
                st.setInt(1, uid);
                try (ResultSet rs = st.executeQuery()) { if (rs.next()) equipo = rs.getInt(1); }
            } catch (Exception ex) { }
            String filtro, ambito;
            if (gestor) { filtro = VACACIONES.VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO"); ambito = "tu grupo"; }
            else if (equipo > 0) { filtro = " AND vc.ID_JEFE_DIRECTO = " + uid + " "; ambito = "tu equipo"; }
            else { filtro = " AND u.IDUSUARIO <> " + uid + " AND u.ID_ADM_DEPARTAMENTO = (SELECT ID_ADM_DEPARTAMENTO FROM USUARIO WHERE IDUSUARIO = " + uid + ") "; ambito = "tu departamento"; }
            List<VACACIONES.VAC_EventosHelper.Evento> evs = VACACIONES.VAC_EventosHelper.cargarConFiltro(cn, hoy, hoy.plusDays(7), filtro);
            java.time.format.DateTimeFormatter dm = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
            Map<String, String> hoyFuera = new LinkedHashMap<>(), proximos = new LinkedHashMap<>();
            for (VACACIONES.VAC_EventosHelper.Evento e : evs) {
                if (!e.esVacacion()) continue;
                if (!e.desde.isAfter(hoy) && !e.hasta.isBefore(hoy)) hoyFuera.put(e.idUsuario + "", e.nombre + "|regresa " + dm.format(e.hasta.plusDays(1)));
                else if (e.desde.isAfter(hoy)) proximos.put(e.idUsuario + "|" + e.desde, e.nombre + "|" + dm.format(e.desde) + " al " + dm.format(e.hasta));
            }
            if (hoyFuera.isEmpty() && proximos.isEmpty() && !gestor && equipo == 0) aplica = false;
            else {
                html.append(cabecera("fas fa-user-clock", "warning", "Quién está fuera &middot; " + ambito));
                html.append("<p class='text-xs text-secondary mb-1'>Hoy</p>");
                if (hoyFuera.isEmpty()) html.append("<p class='text-sm mb-2'>Nadie est&aacute; de vacaciones hoy.</p>");
                else {
                    html.append("<ul class='list-group list-group-flush mb-2'>"); int c = 0;
                    for (String v : hoyFuera.values()) { if (c++ >= 5) break; String[] x = v.split("\\|");
                        html.append("<li class='list-group-item border-0 px-0 py-1 d-flex justify-content-between'><span class='text-sm'>").append(esc(x[0])).append("</span><span class='text-xs text-secondary'>").append(esc(x[1])).append("</span></li>"); }
                    html.append("</ul>");
                    if (hoyFuera.size() > 5) html.append("<p class='text-xs text-secondary'>y ").append(hoyFuera.size() - 5).append(" m&aacute;s</p>");
                }
                html.append("<p class='text-xs text-secondary mb-1'>Pr&oacute;ximos 7 d&iacute;as</p>");
                if (proximos.isEmpty()) html.append("<p class='text-sm mb-0'>Sin salidas programadas.</p>");
                else {
                    html.append("<ul class='list-group list-group-flush'>"); int c = 0;
                    for (String v : proximos.values()) { if (c++ >= 4) break; String[] x = v.split("\\|");
                        html.append("<li class='list-group-item border-0 px-0 py-1 d-flex justify-content-between'><span class='text-sm'>").append(esc(x[0])).append("</span><span class='text-xs text-secondary'>").append(esc(x[1])).append("</span></li>"); }
                    html.append("</ul>");
                    if (proximos.size() > 4) html.append("<p class='text-xs text-secondary mb-0'>y ").append(proximos.size() - 4).append(" m&aacute;s</p>");
                }
                if (gestor) html.append("<div class='mt-3'><a href='").append(ctx).append("/Vacaciones/VAC_Estadisticas.jsp' class='btn btn-sm btn-outline-warning mb-0'>Ver dashboard de vacaciones</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- ANIVERSARIOS LABORALES (gestores de vacaciones)
        } else if ("aniversarios".equals(b)) {
            if (!(COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR") || COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR"))) aplica = false;
            else {
                List<Object[]> lista = new ArrayList<>();   // {fecha, nombre, anios}
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT u.NOMBRE || ' ' || u.APELLIDOS, vc.FECHA_INGRESO FROM VAC_CONFIG_USUARIO vc JOIN USUARIO u ON u.IDUSUARIO = vc.ID_USUARIO " +
                        "WHERE u.ESTADO = 'a' AND vc.FECHA_INGRESO IS NOT NULL " + VACACIONES.VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO"));
                     ResultSet rs = st.executeQuery()) {
                    while (rs.next()) {
                        LocalDate fi = rs.getDate(2).toLocalDate();
                        LocalDate a = fi.withYear(hoy.getYear());
                        if (a.isBefore(hoy)) a = fi.withYear(hoy.getYear() + 1);
                        long dd = java.time.temporal.ChronoUnit.DAYS.between(hoy, a);
                        int anios = a.getYear() - fi.getYear();
                        if (anios >= 1 && dd <= 30) lista.add(new Object[]{a, rs.getString(1), anios});
                    }
                }
                if (lista.isEmpty()) aplica = false;
                else {
                    lista.sort((x, y) -> ((LocalDate) x[0]).compareTo((LocalDate) y[0]));
                    java.time.format.DateTimeFormatter dm = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
                    html.append(cabecera("fas fa-cake-candles", "success", "Aniversarios laborales &middot; 30 d&iacute;as"));
                    html.append("<ul class='list-group list-group-flush'>"); int c = 0;
                    for (Object[] o : lista) { if (c++ >= 6) break; LocalDate f = (LocalDate) o[0]; int an = (Integer) o[2];
                        html.append("<li class='list-group-item border-0 px-0 py-1 d-flex justify-content-between'><span class='text-sm'>").append(esc((String) o[1]))
                            .append(" <span class='badge badge-sm bg-gradient-success'>").append(an).append(an == 1 ? " a&ntilde;o" : " a&ntilde;os").append("</span></span><span class='text-xs text-secondary'>")
                            .append(f.equals(hoy) ? "Hoy" : dm.format(f)).append("</span></li>"); }
                    html.append("</ul>");
                    if (lista.size() > 6) html.append("<p class='text-xs text-secondary mb-0'>y ").append(lista.size() - 6).append(" m&aacute;s</p>");
                    html.append(pie());
                }
            }

        // ---------------------------------------------------------------- TICKETS DEL DIA (Tecnologia)
        } else if ("ticketsdia".equals(b)) {
            if (!COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) aplica = false;
            else {
                html.append(cabecera("fas fa-headset", "danger", "Soporte hoy"));
                try (PreparedStatement st = cn.prepareStatement(
                        "SELECT NVL(SUM(CASE WHEN ESTADO IN ('PENDIENTE','REASIGNADO') THEN 1 ELSE 0 END),0), " +
                        "       NVL(SUM(CASE WHEN ESTADO = 'EN_PROGRESO' THEN 1 ELSE 0 END),0), " +
                        "       NVL(SUM(CASE WHEN TRUNC(FECHA_SOLICITUD) = TRUNC(SYSDATE) THEN 1 ELSE 0 END),0), " +
                        "       NVL(SUM(CASE WHEN ESTADO IN ('ATENDIDO','CERRADO_SIN_SOLUCION') AND TRUNC(FECHA_REPORTE) = TRUNC(SYSDATE) THEN 1 ELSE 0 END),0), " +
                        "       MIN(CASE WHEN ESTADO IN ('PENDIENTE','REASIGNADO') THEN TRUNC(SYSDATE - FECHA_SOLICITUD) END) " +
                        "FROM SOP_SOPORTE_CAB WHERE ESTADO IN ('PENDIENTE','REASIGNADO','EN_PROGRESO') OR TRUNC(FECHA_SOLICITUD) = TRUNC(SYSDATE) OR TRUNC(FECHA_REPORTE) = TRUNC(SYSDATE)");
                     ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        html.append("<div class='row text-center mb-2'>")
                            .append("<div class='col-6 col-sm-3'><h4 class='mb-0 text-danger'>").append(rs.getInt(1)).append("</h4><span class='text-xxs text-secondary'>sin tomar</span></div>")
                            .append("<div class='col-6 col-sm-3'><h4 class='mb-0 text-info'>").append(rs.getInt(2)).append("</h4><span class='text-xxs text-secondary'>en atenci&oacute;n</span></div>")
                            .append("<div class='col-6 col-sm-3'><h4 class='mb-0'>").append(rs.getInt(3)).append("</h4><span class='text-xxs text-secondary'>nuevos hoy</span></div>")
                            .append("<div class='col-6 col-sm-3'><h4 class='mb-0 text-success'>").append(rs.getInt(4)).append("</h4><span class='text-xxs text-secondary'>cerrados hoy</span></div></div>");
                    }
                }
                if (COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER") || COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR")) {
                    try {
                        int[] r = INVENTARIO.INV_MantenimientoHelper.resumen(cn);
                        html.append("<p class='text-xs mb-0'><i class='fas fa-broom text-success me-1'></i>Mantenimientos: <b>").append(r[0]).append("</b> vencidos, <b>").append(r[1]).append("</b> pr&oacute;ximos</p>");
                    } catch (Exception ex) { }
                }
                html.append("<div class='mt-3'><a href='").append(ctx).append("/Soportes/SOP_ListaTickets.jsp' class='btn btn-sm btn-outline-danger mb-0'>Ir a los tickets</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- ACCESOS DIRECTOS + RESUMEN DE ANTICIPOS (gestores)
        } else if ("accesos".equals(b)) {
            List<String[]> links = new ArrayList<>();   // {icono, texto, url}
            if (COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR")) {
                links.add(new String[]{"fas fa-clipboard-check", "Aprobar vacaciones", ctx + "/Vacaciones/VAC_AprobacionesAdmin.jsp"});
                links.add(new String[]{"fas fa-chart-pie", "Dashboard de vacaciones", ctx + "/Vacaciones/VAC_Estadisticas.jsp"});
            }
            if (COMUN.PermisoHelper.tiene(session, "VACACIONES_CONFIGURAR")) {
                links.add(new String[]{"fas fa-users-gear", "Configurar empleados", ctx + "/Vacaciones/VAC_ConfigUsuarios.jsp"});
                links.add(new String[]{"fas fa-cake-candles", "Cumplea&ntilde;os", ctx + "/Vacaciones/VAC_Cumpleanos.jsp"});
            }
            if (COMUN.PermisoHelper.tiene(session, "NOVEDADES_GESTIONAR")) links.add(new String[]{"fas fa-bullhorn", "Novedades", ctx + "/Proyectos/PRO_Novedades.jsp"});
            if (COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
                links.add(new String[]{"fas fa-calendar-day", "Fecha de corte (Control)", ctx + "/Control/ADM_Asignar_Fecha_Corte_Anticipos.jsp"});
                links.add(new String[]{"fas fa-hand-holding-dollar", "Anticipos Control", ctx + "/Control/ADM_Dashboard.jsp"});
            }
            if (COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) links.add(new String[]{"fas fa-hand-holding-dollar", "Anticipos Auditor&iacute;a / fecha de corte", ctx + "/Auditoria/AUD_Dashboard.jsp"});
            if (COMUN.PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR")) links.add(new String[]{"fas fa-car-side", "Calendario de movilizaci&oacute;n", ctx + "/Movilizacion/MOV_Calendario.jsp"});
            if (COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) links.add(new String[]{"fas fa-ticket", "Tickets por atender", ctx + "/Soportes/SOP_ListaTickets.jsp"});
            if (COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER")) links.add(new String[]{"fas fa-broom", "Mantenimientos de equipos", ctx + "/Inventario/INV_Mantenimientos.jsp"});
            if (links.isEmpty()) aplica = false;
            else {
                html.append(cabecera("fas fa-bolt", "primary", "Accesos directos"));
                // Resumen de anticipos del mes para quienes los gestionan: dias al corte y solicitudes recibidas
                String[][] mods = {{"CONTROL_GESTIONAR", "CTRL_FECHA_CORTE_ANTICIPO", "CTRL_ANTICIPOS", "Control"}, {"ANTICIPOS_AUD_GESTIONAR", "AUD_FECHA_CORTE_ANTICIPO", "AUD_ANTICIPOS", "Auditor&iacute;a"}};
                for (String[] m : mods) {
                    if (!COMUN.PermisoHelper.tiene(session, m[0])) continue;
                    try (PreparedStatement st = cn.prepareStatement(
                            "SELECT (SELECT TRUNC(FECHA_CORTE) - TRUNC(SYSDATE) FROM (SELECT FECHA_CORTE FROM " + m[1] + " WHERE ESTADO = 'A' ORDER BY FECHA_CORTE DESC) WHERE ROWNUM = 1), " +
                            "       COUNT(*), NVL(SUM(CASE WHEN ESTADO = 'PENDIENTE' THEN 1 ELSE 0 END),0) FROM " + m[2] + " WHERE TRUNC(FECHA_SOLICITUD,'MM') = TRUNC(SYSDATE,'MM')");
                         ResultSet rs = st.executeQuery()) {
                        if (rs.next()) {
                            Object dias = rs.getObject(1);
                            html.append("<p class='text-xs mb-1'><i class='fas fa-hand-holding-dollar text-primary me-1'></i>Anticipos ").append(m[3]).append(": ")
                                .append(dias == null ? "sin fecha de corte este mes" : (rs.getInt(1) < 0 ? "plazo cerrado" : (rs.getInt(1) == 0 ? "hoy es el corte" : "corte en " + rs.getInt(1) + " d&iacute;as")))
                                .append(" &middot; <b>").append(rs.getInt(2)).append("</b> solicitudes del mes (").append(rs.getInt(3)).append(" por pagar)</p>");
                        }
                    } catch (Exception ex) { }
                }
                html.append("<div class='d-flex flex-wrap gap-1 mt-2'>");
                for (String[] l : links)
                    html.append("<a href='").append(l[2]).append("' class='btn btn-sm btn-outline-primary mb-1'><i class='").append(l[0]).append(" me-1'></i>").append(l[1]).append("</a>");
                html.append("</div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- NOVEDADES (avisos publicados por la empresa)
        } else if ("novedades".equals(b)) {
            boolean gest = COMUN.PermisoHelper.tiene(session, "NOVEDADES_GESTIONAR");
            List<String[]> nov = new ArrayList<>();
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT TITULO, TEXTO, TO_CHAR(FECHA_DESDE,'DD/MM') FROM APP_NOVEDAD WHERE ESTADO = 'A' AND FECHA_DESDE <= TRUNC(SYSDATE) " +
                    "AND (FECHA_HASTA IS NULL OR FECHA_HASTA >= TRUNC(SYSDATE)) ORDER BY FECHA_DESDE DESC, ID_NOVEDAD DESC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next() && nov.size() < 3) nov.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3)});
            }
            if (nov.isEmpty() && !gest) aplica = false;
            else {
                html.append(cabecera("fas fa-bullhorn", "info", "Novedades"));
                if (nov.isEmpty()) html.append("<p class='text-sm text-secondary mb-0'>No hay novedades publicadas.</p>");
                for (String[] n : nov) {
                    html.append("<div class='mb-2'><p class='text-sm font-weight-bold mb-0'>").append(esc(n[0])).append(" <span class='text-xs text-secondary font-weight-normal'>&middot; ").append(esc(n[2])).append("</span></p>");
                    if (n[1] != null && !n[1].trim().isEmpty()) html.append("<p class='text-xs mb-0' style='white-space:pre-line'>").append(esc(n[1])).append("</p>");
                    html.append("</div>");
                }
                if (gest) html.append("<div class='mt-2'><a href='").append(ctx).append("/Proyectos/PRO_Novedades.jsp' class='btn btn-sm btn-outline-info mb-0'>Administrar novedades</a></div>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- CUMPLEANOS (todos)
        } else if ("cumpleanos".equals(b)) {
            List<Object[]> cu = new ArrayList<>();   // {fecha, nombre, depto, esMio}
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT c.ID_USUARIO, u.NOMBRE || ' ' || u.APELLIDOS, c.MES, c.DIA, d.DEPARTAMENTO FROM USUARIO_CUMPLE c JOIN USUARIO u ON u.IDUSUARIO = c.ID_USUARIO " +
                    "LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO WHERE u.ESTADO = 'a'");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int mes = rs.getInt(3), dia = rs.getInt(4);
                    LocalDate f;
                    try { f = LocalDate.of(hoy.getYear(), mes, Math.min(dia, YearMonth.of(hoy.getYear(), mes).lengthOfMonth())); } catch (Exception ex) { continue; }
                    if (f.isBefore(hoy)) f = f.plusYears(1);
                    if (java.time.temporal.ChronoUnit.DAYS.between(hoy, f) <= 30)
                        cu.add(new Object[]{f, rs.getString(2), rs.getString(5), rs.getInt(1) == uid});
                }
            }
            if (cu.isEmpty()) aplica = false;
            else {
                cu.sort((x, y) -> ((LocalDate) x[0]).compareTo((LocalDate) y[0]));
                java.time.format.DateTimeFormatter dm = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
                html.append(cabecera("fas fa-cake-candles", "success", "Cumplea&ntilde;os"));
                int c = 0;
                html.append("<ul class='list-group list-group-flush'>");
                for (Object[] o : cu) {
                    LocalDate f = (LocalDate) o[0]; boolean esHoy = f.equals(hoy), mio = (Boolean) o[3];
                    if (!esHoy && c >= 5) break; c++;
                    html.append("<li class='list-group-item border-0 px-0 py-1 d-flex justify-content-between align-items-center'><span class='text-sm'>");
                    if (esHoy) html.append("<i class='fas fa-gift text-success me-1'></i>");
                    html.append(esc((String) o[1])).append(esHoy ? (mio ? " <b>&iexcl;Feliz cumplea&ntilde;os!</b>" : " <b>&iexcl;hoy!</b>") : "");
                    if (o[2] != null) html.append(" <span class='text-xs text-secondary'>&middot; ").append(esc((String) o[2])).append("</span>");
                    html.append("</span><span class='text-xs text-secondary'>").append(esHoy ? "Hoy" : dm.format(f)).append("</span></li>");
                }
                html.append("</ul>");
                if (cu.size() > c) html.append("<p class='text-xs text-secondary mb-0'>y ").append(cu.size() - c).append(" m&aacute;s este mes</p>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- LO QUE MAS USAS (ultimos 30 dias, segun LOG_ACTIVIDAD)
        } else if ("usados".equals(b)) {
            Map<String, String[]> pag = new HashMap<>();   // archivo -> {etiqueta, icono}
            pag.put("MOV_Calendario.jsp", new String[]{"Movilizaci&oacute;n", "fas fa-car-side"});
            pag.put("SOP_MisTickets.jsp", new String[]{"Mis tickets", "fas fa-ticket"});
            pag.put("SOP_NuevoTicket.jsp", new String[]{"Crear ticket", "fas fa-plus"});
            pag.put("SOP_ListaTickets.jsp", new String[]{"Tickets por atender", "fas fa-headset"});
            pag.put("VAC_MiSaldo.jsp", new String[]{"Mis vacaciones", "fas fa-umbrella-beach"});
            pag.put("VAC_MiPanel.jsp", new String[]{"Panel de vacaciones", "fas fa-umbrella-beach"});
            pag.put("VAC_AprobacionesJefe.jsp", new String[]{"Aprobar a mi equipo", "fas fa-clipboard-check"});
            pag.put("VAC_AprobacionesAdmin.jsp", new String[]{"Aprobar vacaciones", "fas fa-clipboard-check"});
            pag.put("VAC_Estadisticas.jsp", new String[]{"Dashboard de vacaciones", "fas fa-chart-pie"});
            pag.put("VAC_ConfigUsuarios.jsp", new String[]{"Configurar empleados", "fas fa-users-gear"});
            pag.put("AUD_SolicitarAnticipo.jsp", new String[]{"Mi anticipo", "fas fa-hand-holding-dollar"});
            pag.put("ADM_Solicitar_Anticipo.jsp", new String[]{"Mi anticipo", "fas fa-hand-holding-dollar"});
            pag.put("AUD_Dashboard.jsp", new String[]{"Anticipos Auditor&iacute;a", "fas fa-hand-holding-dollar"});
            pag.put("ADM_Dashboard.jsp", new String[]{"Anticipos Control", "fas fa-hand-holding-dollar"});
            pag.put("INV_Mantenimientos.jsp", new String[]{"Mantenimientos", "fas fa-broom"});
            List<String[]> top = new ArrayList<>();   // {etiqueta, icono, href, veces}
            Set<String> yaEtiqueta = new HashSet<>();
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT URL, COUNT(*) FROM LOG_ACTIVIDAD WHERE ID_USUARIO = ? AND FECHA_HORA >= SYSDATE - 30 AND ACCION = 'VER' AND URL LIKE '%.jsp' " +
                    "GROUP BY URL ORDER BY 2 DESC")) {
                st.setInt(1, uid);
                try (ResultSet rs = st.executeQuery()) {
                    while (rs.next() && top.size() < 4) {
                        String url = rs.getString(1); if (url == null) continue;
                        String[] seg = url.split("/");
                        if (seg.length < 2) continue;
                        String archivo = seg[seg.length - 1], carpeta = seg[seg.length - 2];
                        String[] info = pag.get(archivo);
                        if (info == null || !yaEtiqueta.add(info[0])) continue;
                        top.add(new String[]{info[0], info[1], ctx + "/" + carpeta + "/" + archivo, String.valueOf(rs.getInt(2))});
                    }
                }
            }
            if (top.isEmpty()) aplica = false;
            else {
                html.append(cabecera("fas fa-star", "warning", "Lo que m&aacute;s usas"));
                html.append("<div class='d-flex flex-wrap gap-1'>");
                for (String[] t : top)
                    html.append("<a href='").append(t[2]).append("' class='btn btn-sm btn-outline-warning mb-1'><i class='").append(t[1]).append(" me-1'></i>").append(t[0]).append("</a>");
                html.append("</div><p class='text-xxs text-secondary mb-0'>seg&uacute;n tus visitas de los &uacute;ltimos 30 d&iacute;as</p>");
                html.append(pie());
            }

        // ---------------------------------------------------------------- PENDIENTES (centro de acciones por rol)
        } else if ("pendientes".equals(b)) {
            List<String[]> items = new ArrayList<>();   // {icono, color, texto, url, boton}
            // Jefe directo: solicitudes de su equipo
            try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM VAC_SOLICITUD WHERE ID_JEFE_DIRECTO = ? AND ESTADO = 'PENDIENTE_JEFE'")) {
                st.setInt(1, uid);
                try (ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-umbrella-beach", "warning", n + (n == 1 ? " solicitud de vacaciones de tu equipo espera tu aprobación" : " solicitudes de vacaciones de tu equipo esperan tu aprobación"), ctx + "/Vacaciones/VAC_AprobacionesJefe.jsp", "Revisar"});
                } }
            } catch (Exception ex) { }
            // Gestor de vacaciones (por grupo)
            if (COMUN.PermisoHelper.tiene(session, "VACACIONES_GESTIONAR")) {
                try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM VAC_SOLICITUD s LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_USUARIO = s.ID_USUARIO " +
                        "WHERE s.ESTADO = 'PENDIENTE_ADMIN' " + VACACIONES.VAC_Alcance.filtroSql(session, cn, "vc.ID_GRUPO"));
                     ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-clipboard-check", "info", n + (n == 1 ? " solicitud de vacaciones por aprobar" : " solicitudes de vacaciones por aprobar"), ctx + "/Vacaciones/VAC_AprobacionesAdmin.jsp", "Aprobar"});
                } } catch (Exception ex) { }
            }
            // Movilizacion por aprobar
            if (COMUN.PermisoHelper.tiene(session, "MOVILIZACION_GESTIONAR")) {
                try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM MOV_SOLICITUD WHERE ESTADO = 'PENDIENTE' AND FECHA >= TRUNC(SYSDATE)");
                     ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-car-side", "info", n + (n == 1 ? " movilización pendiente de aprobar" : " movilizaciones pendientes de aprobar"), ctx + "/Movilizacion/MOV_Calendario.jsp", "Revisar"});
                } } catch (Exception ex) { }
            }
            // Anticipos por pagar (Control y Auditoria)
            if (COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR")) {
                try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM CTRL_ANTICIPOS WHERE ESTADO = 'PENDIENTE' AND TRUNC(FECHA_SOLICITUD,'MM') = TRUNC(SYSDATE,'MM')");
                     ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-hand-holding-dollar", "primary", n + (n == 1 ? " anticipo del mes por pagar" : " anticipos del mes por pagar"), ctx + "/Control/ADM_Dashboard.jsp", "Ver"});
                } } catch (Exception ex) { }
            }
            if (COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR")) {
                try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM AUD_ANTICIPOS WHERE ESTADO = 'PENDIENTE' AND TRUNC(FECHA_SOLICITUD,'MM') = TRUNC(SYSDATE,'MM')");
                     ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-hand-holding-dollar", "primary", n + (n == 1 ? " anticipo de Auditoría por pagar" : " anticipos de Auditoría por pagar"), ctx + "/Auditoria/AUD_Dashboard.jsp", "Ver"});
                } } catch (Exception ex) { }
            }
            // Tecnología: tickets sin tomar y mantenimientos
            if (COMUN.PermisoHelper.tiene(session, "SOPORTES_ATENDER")) {
                try (PreparedStatement st = cn.prepareStatement("SELECT COUNT(*) FROM SOP_SOPORTE_CAB WHERE ESTADO = 'PENDIENTE'");
                     ResultSet rs = st.executeQuery()) { if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    items.add(new String[]{"fas fa-ticket", "danger", n + (n == 1 ? " ticket de soporte sin tomar" : " tickets de soporte sin tomar"), ctx + "/Soportes/SOP_ListaTickets.jsp", "Atender"});
                } } catch (Exception ex) { }
            }
            if (COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_VER") || COMUN.PermisoHelper.tiene(session, "INVENTARIO_MANTENIMIENTO_GESTIONAR")) {
                try {
                    int[] r = INVENTARIO.INV_MantenimientoHelper.resumen(cn);
                    if (r[0] + r[1] > 0)
                        items.add(new String[]{"fas fa-broom", "success", r[0] + " mantenimientos de equipos vencidos y " + r[1] + " próximos", ctx + "/Inventario/INV_Mantenimientos.jsp", "Ver"});
                } catch (Exception ex) { }
            }
            html.append("<div class='card'><div class='card-body p-3'><div class='d-flex align-items-center mb-2'>")
                .append("<h6 class='mb-0'><i class='fas fa-list-check text-primary me-2'></i>").append(items.isEmpty() ? "Estás al día" : "Tienes pendientes").append("</h6>")
                .append(items.isEmpty() ? "" : "<span class='badge bg-gradient-warning ms-2'>" + items.size() + "</span>").append("</div>");
            if (items.isEmpty()) html.append("<p class='text-sm text-secondary mb-0'><i class='fas fa-check-circle text-success me-1'></i>No tienes nada pendiente por resolver en este momento.</p>");
            else {
                html.append("<ul class='list-group list-group-flush'>");
                for (String[] it : items)
                    html.append("<li class='list-group-item border-0 px-0 py-2 d-flex align-items-center justify-content-between'>")
                        .append("<span class='text-sm'><i class='").append(it[0]).append(" text-").append(it[1]).append(" me-2'></i>").append(esc(it[2])).append("</span>")
                        .append("<a href='").append(it[3]).append("' class='btn btn-xs btn-outline-").append(it[1]).append(" py-1 mb-0'>").append(it[4]).append("</a></li>");
                html.append("</ul>");
            }
            html.append("</div></div>");
        } else {
            aplica = false;
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(204);
        return;
    }
    if (!aplica) { response.setStatus(204); return; }
    out.print(html);
%>
