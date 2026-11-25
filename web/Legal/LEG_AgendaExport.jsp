<%@page contentType="text/csv;charset=UTF-8" pageEncoding="UTF-8"%><%@page import="java.time.LocalDate"%><%@page import="java.sql.Connection"%><%@page import="org.json.JSONArray"%><%@page import="LEGAL.LEG_Agenda"%><%
    // Exporta la agenda legal: fmt=csv (Excel) o fmt=ics (calendario). Params: start, end, tipo, estado, resp, caso. Solo LEGAL_ACCESO.
    // Todo en una sola linea de directivas para que no salgan lineas en blanco antes del archivo.
    response.reset();
    if (session.getAttribute("usuario") == null || session.isNew()) { response.setStatus(401); out.print("Sesion expirada"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "LEGAL_ACCESO")) { response.setStatus(403); out.print("Sin acceso"); return; }
    String fmt = "ics".equals(request.getParameter("fmt")) ? "ics" : "csv";
    try (Connection cn = Servlets.Conexion.getConnection()) {
        LocalDate hoy = LocalDate.now(), ini, fin;
        if ("ics".equals(fmt)) { ini = hoy; fin = hoy.plusDays(400); }   // calendario: lo que viene (pendientes)
        else { ini = LocalDate.parse(request.getParameter("start")); fin = LocalDate.parse(request.getParameter("end")); }
        Integer tipo = null, resp = null;
        try { tipo = Integer.valueOf(request.getParameter("tipo")); } catch (Exception ignore) { }
        try { resp = Integer.valueOf(request.getParameter("resp")); } catch (Exception ignore) { }
        String estado = "ics".equals(fmt) ? "PENDIENTE" : request.getParameter("estado");
        JSONArray ev = LEG_Agenda.eventos(cn, ini, fin, tipo, estado, resp, request.getParameter("caso"));
        String nombre = "agenda_legal_" + hoy;
        if ("ics".equals(fmt)) { response.setContentType("text/calendar;charset=UTF-8"); response.setHeader("Content-Disposition", "attachment; filename=\"" + nombre + ".ics\""); out.print(LEG_Agenda.exportarIcs(ev)); }
        else { response.setContentType("text/csv;charset=UTF-8"); response.setHeader("Content-Disposition", "attachment; filename=\"" + nombre + ".csv\""); out.print(LEG_Agenda.exportarCsv(ev)); }
        COMUN.LogActividad.registrar(request, "LEGAL", "EXPORTAR", "Agenda legal: exporto " + ev.length() + " evento(s) en " + fmt);
    } catch (Exception e) {
        e.printStackTrace();
        response.reset(); response.setStatus(500); response.setContentType("text/plain;charset=UTF-8");
        out.print("No se pudo exportar: " + e.getMessage());
    }
%>
