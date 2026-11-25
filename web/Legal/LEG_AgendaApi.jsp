<%--
    API JSON de la Agenda legal (la usa Legal/LEG_Agenda.jsp). Solo para quien tiene LEGAL_ACCESO.
    GET  a=eventos&start&end[&tipo][&estado][&resp]   a=historial&id   a=tipos
    POST a=crear | editar | estado | reprogramar | tipo
    Responde siempre JSON: {ok:true,...} o {ok:false,error:"..."}.
--%>
<%@page contentType="application/json;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.util.*"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="LEGAL.LEG_Agenda"%>
<%!
    private static Integer entero(String s) { try { return s == null || s.trim().isEmpty() ? null : Integer.valueOf(s.trim()); } catch (Exception e) { return null; } }
    private static String f10(String s) { return s != null && s.length() >= 10 ? s.substring(0, 10) : s; }
%><%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");   // la agenda siempre debe leer datos frescos
    response.setHeader("Pragma", "no-cache");
    if (session.getAttribute("usuario") == null || session.isNew()) { response.setStatus(401); out.print(new JSONObject().put("ok", false).put("error", "Sesión expirada")); return; }
    if (!COMUN.PermisoHelper.tiene(session, "LEGAL_ACCESO")) { response.setStatus(403); out.print(new JSONObject().put("ok", false).put("error", "Sin acceso")); return; }
    int yo = -1;
    try { yo = Integer.parseInt(((String) session.getAttribute("cod")).trim()); } catch (Exception ignore) { }
    if (yo <= 0) { response.setStatus(403); out.print(new JSONObject().put("ok", false).put("error", "Sesión no válida")); return; }

    String a = request.getParameter("a");
    boolean post = "POST".equalsIgnoreCase(request.getMethod());
    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (!post) {
            if ("eventos".equals(a)) {
                LocalDate ini = LocalDate.parse(f10(request.getParameter("start"))), fin = LocalDate.parse(f10(request.getParameter("end")));
                out.print(LEG_Agenda.eventos(cn, ini, fin, entero(request.getParameter("tipo")), request.getParameter("estado"), entero(request.getParameter("resp")), request.getParameter("caso")));
            } else if ("historial".equals(a)) {
                out.print(LEG_Agenda.historial(cn, Integer.parseInt(request.getParameter("id"))));
            } else if ("conflictos".equals(a)) {
                List<Integer> resp = new ArrayList<>();
                String[] rs = request.getParameterValues("resp");
                if (rs != null) for (String r : rs) { Integer v = entero(r); if (v != null) resp.add(v); }
                if (resp.isEmpty()) resp.add(yo);   // sin responsables marcados, el evento quedaria a nombre de quien registra
                LocalDate f = null;
                try { f = LocalDate.parse(request.getParameter("fecha")); } catch (Exception ignore) { }
                out.print(LEG_Agenda.conflictos(cn, f, request.getParameter("ini"), request.getParameter("fin"), resp, entero(request.getParameter("excluir"))));
            } else if ("buscar".equals(a)) {
                out.print(LEG_Agenda.buscar(cn, request.getParameter("q")));
            } else if ("casos".equals(a)) {
                out.print(LEG_Agenda.casos(cn));
            } else if ("tipos".equals(a)) {
                out.print(LEG_Agenda.tipos(cn, !"1".equals(request.getParameter("todos"))));
            } else { out.print(new JSONArray()); }
            return;
        }
        // ---- escrituras
        String msg = "Listo.", fechaIr = null;   // fechaIr: el calendario salta a esa fecha para que se vea lo que se acaba de guardar
        if ("crear".equals(a)) {
            List<String[]> fechas = new ArrayList<>();
            for (int i = 0; i < 40; i++) {
                String f = request.getParameter("fecha_" + i);
                if (f == null || f.trim().isEmpty()) continue;
                fechas.add(new String[]{f.trim(), request.getParameter("ini_" + i), request.getParameter("fin_" + i)});
            }
            List<Integer> resp = new ArrayList<>();
            String[] rs = request.getParameterValues("resp");
            if (rs != null) for (String r : rs) { Integer v = entero(r); if (v != null) resp.add(v); }
            Integer tipo = entero(request.getParameter("tipo"));
            if (tipo == null) throw new IllegalArgumentException("Elige el tipo de evento.");
            List<Integer> ids = LEG_Agenda.crear(cn, yo, tipo, request.getParameter("asunto"), request.getParameter("modalidad"), request.getParameter("lugar"), request.getParameter("comentario"), resp, fechas, request.getParameter("caso"));
            COMUN.LogActividad.registrar(request, "LEGAL", "CREAR", "Agenda legal: registro " + ids.size() + " evento(s) " + ids);
            msg = ids.size() == 1 ? "Evento registrado." : ids.size() + " eventos registrados.";
            fechaIr = fechas.get(0)[0];
        } else if ("editar".equals(a)) {
            List<Integer> resp = new ArrayList<>();
            String[] rs = request.getParameterValues("resp");
            if (rs != null) for (String r : rs) { Integer v = entero(r); if (v != null) resp.add(v); }
            Integer tipo = entero(request.getParameter("tipo")), id = entero(request.getParameter("id"));
            if (tipo == null || id == null) throw new IllegalArgumentException("Datos incompletos.");
            LocalDate fecha;
            try { fecha = LocalDate.parse(request.getParameter("fecha_0")); } catch (Exception e) { throw new IllegalArgumentException("Revisa la fecha."); }
            LEG_Agenda.editar(cn, yo, id, tipo, request.getParameter("asunto"), fecha, request.getParameter("ini_0"), request.getParameter("fin_0"), request.getParameter("modalidad"), request.getParameter("lugar"), request.getParameter("comentario"), resp, request.getParameter("caso"));
            COMUN.LogActividad.registrar(request, "LEGAL", "ACTUALIZAR", "Agenda legal: edito evento #" + id);
            msg = "Evento actualizado.";
            fechaIr = fecha.toString();
        } else if ("estado".equals(a)) {
            Integer id = entero(request.getParameter("id"));
            if (id == null) throw new IllegalArgumentException("Datos incompletos.");
            String nuevo = request.getParameter("estado");
            LEG_Agenda.cambiarEstado(cn, yo, id, nuevo, request.getParameter("justificacion"));
            COMUN.LogActividad.registrar(request, "LEGAL", "ACTUALIZAR", "Agenda legal: evento #" + id + " -> " + nuevo);
            msg = "CANCELADO".equals(nuevo) ? "Evento cancelado." : ("CUMPLIDO".equals(nuevo) ? "Evento marcado como cumplido." : "Evento reabierto.");
        } else if ("reprogramar".equals(a)) {
            Integer id = entero(request.getParameter("id"));
            if (id == null) throw new IllegalArgumentException("Datos incompletos.");
            LocalDate fecha;
            try { fecha = LocalDate.parse(request.getParameter("fecha_0")); } catch (Exception e) { throw new IllegalArgumentException("Indica la nueva fecha."); }
            int nuevo = LEG_Agenda.reprogramar(cn, yo, id, fecha, request.getParameter("ini_0"), request.getParameter("fin_0"), request.getParameter("justificacion"));
            COMUN.LogActividad.registrar(request, "LEGAL", "ACTUALIZAR", "Agenda legal: reprogramo evento #" + id + " -> #" + nuevo);
            msg = "Evento reprogramado.";
            fechaIr = fecha.toString();
        } else if ("tipo".equals(a)) {
            LEG_Agenda.guardarTipo(cn, entero(request.getParameter("id")), request.getParameter("nombre"), request.getParameter("color"), !"0".equals(request.getParameter("activo")));
            msg = "Tipo guardado.";
        } else { throw new IllegalArgumentException("Acción no válida."); }
        out.print(new JSONObject().put("ok", true).put("msg", msg).put("fecha", fechaIr == null ? "" : fechaIr));
    } catch (IllegalArgumentException | java.time.format.DateTimeParseException e) {
        out.print(new JSONObject().put("ok", false).put("error", e instanceof java.time.format.DateTimeParseException ? "Revisa las fechas." : e.getMessage()));
    } catch (Exception e) {
        e.printStackTrace();
        out.print(new JSONObject().put("ok", false).put("error", "No se pudo completar la operación. ¿Se ejecutaron los scripts 003 y 005 de Legal? (" + e.getMessage() + ")"));
    }
%>
