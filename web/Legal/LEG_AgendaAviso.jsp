<%--
    Document   : LEG_AgendaAviso
    Estado y prueba de los recordatorios por correo de la agenda legal (solo administradores). Muestra la configuracion del servidor,
    a quien se avisaria ahora (vista previa) y permite ejecutar el envio manualmente (respeta legal.aviso.prueba).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="LEGAL.LEG_AgendaAviso"%>
<%!
    private static String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!COMUN.PermisoHelper.tiene(session, "SUPERADMIN_ACCESO_TOTAL")) { response.sendRedirect("../sesionInvalida.jsp"); return; }
    boolean ejecutar = "POST".equalsIgnoreCase(request.getMethod()) && "enviar".equals(request.getParameter("accion"));
    LEG_AgendaAviso.Resultado res = null; String err = null;
    try { res = LEG_AgendaAviso.ejecutar(ejecutar); } catch (Throwable t) { err = String.valueOf(t.getMessage() == null ? t : t.getMessage()); t.printStackTrace(); }
    DateTimeFormatter f = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String prueba = Servlets.MailConfig.LEGAL_AVISO_PRUEBA;
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Recordatorios de agenda legal</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<a href="LEG_Agenda.jsp" class="small">&larr; Volver a la agenda</a>
<h4 class="mt-2">Recordatorios por correo de la agenda legal</h4>
<p class="text-muted">A cada responsable le llega un correo con sus eventos pendientes del pr&oacute;ximo d&iacute;a h&aacute;bil (los viernes, s&aacute;bado a lunes). No se repiten.</p>

<div class="card mb-3"><div class="card-body"><h6>Configuraci&oacute;n de este servidor</h6><ul class="mb-0">
  <li>Correo (SMTP): <b class="<%= Servlets.MailConfig.SMTP_HABILITADO ? "text-success" : "text-danger" %>"><%= Servlets.MailConfig.SMTP_HABILITADO ? "habilitado" : "DESHABILITADO" %></b></li>
  <li>Env&iacute;o autom&aacute;tico (<code>legal.recordatorio</code>): <b class="<%= Servlets.MailConfig.LEGAL_RECORDATORIO ? "text-success" : "text-secondary" %>"><%= Servlets.MailConfig.LEGAL_RECORDATORIO ? "ENCENDIDO desde las " + Servlets.MailConfig.LEGAL_RECORDATORIO_HORA + ":00, lunes a viernes" : "apagado" %></b></li>
  <li>Modo prueba (<code>legal.aviso.prueba</code>): <%= prueba.isEmpty() ? "<b class='text-success'>apagado</b> (los correos van a cada responsable)" : "<b class='text-danger'>ENCENDIDO</b>: todo va solo a " + esc(prueba) + " y no se marca como enviado" %></li>
</ul></div></div>

<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %> &iquest;Se ejecut&oacute; el script docs/legal/004_agenda_avisos.sql?</div><% } %>
<% if (res != null) { %>
<div class="card mb-3"><div class="card-body">
  <h6><%= ejecutar ? "Resultado del env&iacute;o" : "Vista previa" %>: eventos del <%= f.format(res.desde) %><%= res.hasta.equals(res.desde) ? "" : " al " + f.format(res.hasta) %></h6>
  <p class="mb-2"><%= res.usuarios %> responsable(s) con <%= res.eventos %> evento(s) por avisar<%= ejecutar ? "; correos enviados: <b>" + res.enviados + "</b>" : "" %>.</p>
  <% if (res.detalle.isEmpty()) { %><p class="text-muted mb-2">No hay nada pendiente de avisar.</p><% } else { %><ul class="small"><% for (String d : res.detalle) { %><li><%= esc(d) %></li><% } %></ul><% } %>
  <% for (String e : res.errores) { %><div class="alert alert-danger py-2 small"><%= esc(e) %></div><% } %>
  <% if (!ejecutar) { %><form method="post"><input type="hidden" name="accion" value="enviar"><button class="btn btn-primary" onclick="return confirm('¿Enviar ahora los recordatorios<%= prueba.isEmpty() ? " a los responsables" : " (solo a la dirección de prueba)" %>?');">Enviar ahora</button></form><% } %>
</div></div>
<% } %>
</div></body></html>
