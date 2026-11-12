<%--
    Document   : ADM_ProbarAvisoAnticipos
    Diagnostico del correo automatico de apertura de anticipos: muestra si el SMTP esta habilitado en el servidor,
    quienes recibirian el aviso en cada modulo y permite enviar una prueba SOLO a una direccion elegida
    (mostrando el error real si falla). No envia a los usuarios y no crea ninguna fecha de corte.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) { response.sendRedirect("../sesionExpirada.jsp"); return; }
    if (!(COMUN.PermisoHelper.tiene(session, "CONTROL_GESTIONAR") || COMUN.PermisoHelper.tiene(session, "ANTICIPOS_AUD_GESTIONAR"))) { response.sendRedirect("../sesionInvalida.jsp"); return; }

    String destino = request.getParameter("destino");
    String resultado = null, errorTxt = null;
    if ("POST".equalsIgnoreCase(request.getMethod()) && destino != null && destino.trim().matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) {
        try {
            int n = COMUN.AnticiposAviso.enviarA(Collections.singletonList(destino.trim()), java.time.LocalDate.now().plusDays(1),
                    COMUN.AnticiposAviso.firmante(session), application.getRealPath("/assets/img/promanet/firma_correo.png"));
            resultado = n > 0 ? "Correo de prueba enviado a " + destino.trim() + ". Revisa la bandeja (y spam)." : "No se envio: el SMTP esta deshabilitado en este servidor (falta la clave smtp.pass).";
        } catch (Throwable t) {
            java.io.StringWriter sw = new java.io.StringWriter(); t.printStackTrace(new java.io.PrintWriter(sw));
            errorTxt = sw.toString();
        }
    }
    List<String> rAud = new ArrayList<>(), rCtrl = new ArrayList<>(); String errDest = null;
    try { rAud = COMUN.AnticiposAviso.destinatarios("ANTICIPOS_AUD_ACCESO"); rCtrl = COMUN.AnticiposAviso.destinatarios("CONTROL_ACCESO", "ANTICIPOS_AUD_ACCESO"); }
    catch (Throwable t) { errDest = String.valueOf(t); }
    String firmaPath = application.getRealPath("/assets/img/promanet/firma_correo.png");
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Probar aviso de anticipos</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light"><div class="container py-4" style="max-width:900px">
<h4>Prueba del correo de apertura de anticipos</h4>
<p class="text-muted">Diagn&oacute;stico del aviso autom&aacute;tico al registrar la fecha de corte. Esta p&aacute;gina no crea fechas de corte ni escribe a los usuarios.</p>

<div class="card mb-3"><div class="card-body">
<h6>1. Configuraci&oacute;n de correo del servidor</h6>
<ul class="mb-0">
  <li>SMTP habilitado: <b class="<%= Servlets.MailConfig.SMTP_HABILITADO ? "text-success" : "text-danger" %>"><%= Servlets.MailConfig.SMTP_HABILITADO ? "SI" : "NO" %></b></li>
  <li>Servidor: <%= Servlets.MailConfig.SMTP_HOST %>:<%= Servlets.MailConfig.SMTP_PORT %> &middot; cuenta: <%= Servlets.MailConfig.SMTP_USER %></li>
  <li>Imagen de firma: <%= firmaPath != null && new java.io.File(firmaPath).exists() ? "encontrada" : "<b class='text-danger'>no encontrada</b>" %></li>
</ul>
<% if (!Servlets.MailConfig.SMTP_HABILITADO) { %>
<div class="alert alert-warning mt-2 mb-0">El SMTP est&aacute; deshabilitado: este servidor no tiene la clave de correo. Se lee del archivo indicado por la propiedad
<code>promanet.db.config</code> (por defecto <code>/opt/promanet/db.properties</code>) con la l&iacute;nea <code>smtp.pass=...</code>. En un Tomcat de Windows hay que crear ese archivo o apuntar la propiedad a &eacute;l y reiniciar Tomcat. Mientras tanto el aviso no se env&iacute;a (solo queda una l&iacute;nea en el log).</div>
<% } %>
</div></div>

<div class="card mb-3"><div class="card-body">
<h6>2. Qui&eacute;nes recibir&iacute;an el aviso</h6>
<% if (errDest != null) { %><div class="alert alert-danger"><%= errDest %></div><% } %>
<p class="mb-1"><b>Auditor&iacute;a</b> (permiso ANTICIPOS_AUD_ACCESO): <%= rAud.size() %> usuarios con correo v&aacute;lido</p>
<small class="text-muted d-block mb-2"><%= String.join(", ", rAud) %></small>
<p class="mb-1"><b>Control</b> (permiso CONTROL_ACCESO, sin quienes usan Auditor&iacute;a): <%= rCtrl.size() %> usuarios con correo v&aacute;lido</p>
<small class="text-muted"><%= String.join(", ", rCtrl) %></small>
</div></div>

<div class="card mb-3"><div class="card-body">
<h6>3. Enviar un correo de prueba</h6>
<form method="post" class="row g-2">
  <div class="col-sm-8"><input type="email" name="destino" class="form-control" placeholder="tu correo" required value="<%= destino == null ? "" : destino.replace("\"","&quot;").replace("<","&lt;") %>"></div>
  <div class="col-sm-4"><button class="btn btn-primary w-100">Enviar solo a esta direcci&oacute;n</button></div>
</form>
<% if (resultado != null) { %><div class="alert alert-info mt-3 mb-0"><%= resultado %></div><% } %>
<% if (errorTxt != null) { %><div class="alert alert-danger mt-3 mb-0"><b>Error al enviar:</b><pre class="mb-0 small" style="white-space:pre-wrap"><%= errorTxt.replace("<","&lt;") %></pre></div><% } %>
</div></div>
</div></body></html>
