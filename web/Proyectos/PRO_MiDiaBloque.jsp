<%--
    Document   : PRO_MiDiaBloque
    Bloques del panel "Hoy para ti" del dashboard (PRO_Dashboard.jsp). Cada bloque es un fragmento HTML
    independiente que el dashboard pide por fetch (?b=nombre) despues de cargar la pagina: asi el dashboard abre
    rapido y un bloque que falle no afecta a los demas. Si un bloque no aplica al usuario responde 204 y el
    dashboard lo quita.

    Bloques: pendientes | movilizacion | tickets | vacaciones | anticipos | equipo
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
