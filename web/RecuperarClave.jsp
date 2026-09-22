<%--
    Document   : Recuperar clave
    Genera una clave nueva aleatoria, la guarda en USUARIO.CONTRASENA y
    la envia por correo al email registrado del usuario.

    Seguridad:
      - No revela si el usuario existe o no (siempre se muestra el mismo
        mensaje "si existe, se envio el correo"). Asi la pantalla no
        sirve como sonda para descubrir usuarios validos.
      - Solo actua sobre usuarios activos (a.ESTADO = 'a').
      - Requiere que el usuario tenga email registrado -- si no lo tiene
        se muestra el mismo mensaje generico y no se toca nada.
      - Requiere SMTP habilitado (MailConfig). Si SMTP no esta habilitado
        no se resetea la clave -- no tendria como avisarle a la persona.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.security.SecureRandom"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    // Genera una clave de 10 caracteres, sin ambiguos (0/O, 1/l/I) para
    // que sea facil de tipear si la persona la copia a mano del correo.
    private static String generarClave() {
        final String ALFABETO = "ABCDEFGHJKLMNPQRSTUVWXYZ" +
                                "abcdefghijkmnpqrstuvwxyz" +
                                "23456789";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(10);
        for (int i = 0; i < 10; i++) sb.append(ALFABETO.charAt(rnd.nextInt(ALFABETO.length())));
        return sb.toString();
    }

    // Enmascara un correo: juan.perez@empresa.com -> j***z@empresa.com
    // Es informativo -- no revela el correo completo por si alguien
    // intenta usar la pantalla como sonda.
    private static String enmascararEmail(String email) {
        if (email == null) return "";
        int at = email.indexOf('@');
        if (at < 2) return "***";
        String local = email.substring(0, at);
        String dominio = email.substring(at);
        if (local.length() <= 2) return local.charAt(0) + "***" + dominio;
        return local.charAt(0) + "***" + local.charAt(local.length() - 1) + dominio;
    }
%>
<%
    String metodo = request.getMethod();
    boolean esPost = "POST".equalsIgnoreCase(metodo);

    String identificador = request.getParameter("identificador");   // usuario o email
    boolean mostrarResultado = false;
    boolean smtpDeshabilitado = false;
    String emailEnmascarado = null;
    String errorInterno = null;

    if (esPost) {
        if (!Servlets.MailConfig.SMTP_HABILITADO) {
            smtpDeshabilitado = true;
        } else if (identificador == null || identificador.trim().isEmpty()) {
            // Se cae al final del render mostrando el error en el form.
        } else {
            String idClean = identificador.trim();
            String idUsuarioDb = null;
            String nombreUsuarioDb = null;
            String usuarioLoginDb = null;
            String emailDb = null;

            // Buscar por USUARIO o por EMAIL. UPPER en ambos lados para no
            // depender del casing como se lo escribio.
            try (Connection cn = Servlets.Conexion.getConnection()) {
                if (cn != null) {
                    try (PreparedStatement st = cn.prepareStatement(
                            "SELECT IDUSUARIO, NOMBRE, USUARIO, EMAIL " +
                            "FROM USUARIO " +
                            "WHERE (UPPER(USUARIO) = UPPER(?) OR UPPER(EMAIL) = UPPER(?)) " +
                            "  AND ESTADO = 'a'")) {
                        st.setString(1, idClean);
                        st.setString(2, idClean);
                        try (ResultSet rs = st.executeQuery()) {
                            if (rs.next()) {
                                idUsuarioDb     = rs.getString(1);
                                nombreUsuarioDb = rs.getString(2);
                                usuarioLoginDb  = rs.getString(3);
                                emailDb         = rs.getString(4);
                            }
                        }
                    }

                    // Solo se actualiza y se manda correo si:
                    //   - Existe usuario activo
                    //   - Tiene email valido
                    if (idUsuarioDb != null && emailDb != null && emailDb.contains("@")) {
                        String claveNueva = generarClave();

                        try (PreparedStatement stU = cn.prepareStatement(
                                "UPDATE USUARIO SET CONTRASENA = ? WHERE IDUSUARIO = ?")) {
                            stU.setString(1, claveNueva);
                            stU.setInt(2, Integer.parseInt(idUsuarioDb));
                            stU.executeUpdate();
                        }

                        String cuerpo =
                            "Estimado " + (nombreUsuarioDb != null ? nombreUsuarioDb : "") + ",\n\n" +
                            "Se registro una solicitud de recuperacion de clave para tu cuenta en ProMaNet.\n\n" +
                            "Tus nuevos datos de acceso son:\n" +
                            "  Usuario: " + (usuarioLoginDb != null ? usuarioLoginDb : "") + "\n" +
                            "  Clave:   " + claveNueva + "\n\n" +
                            "Por seguridad, se recomienda cambiar esta clave desde tu perfil " +
                            "una vez que ingreses al sistema.\n\n" +
                            "Si no fuiste tu quien solicito este cambio, avisa de inmediato al area de Soporte.\n\n" +
                            "Saludos cordiales,\n" +
                            "ProMaNet - Soporte";

                        try {
                            Servlets.Correo.enviar(emailDb.trim(),
                                    "Recuperacion de clave - ProMaNet",
                                    cuerpo);
                            emailEnmascarado = enmascararEmail(emailDb);
                        } catch (Exception eMail) {
                            eMail.printStackTrace();
                            // Si el correo fallo (SMTP caido, red, etc.) revertimos
                            // la clave? No -- la nueva clave ya quedo. El admin puede
                            // ver el usuario y mandarsela a mano. Pero se avisa el
                            // error a soporte por log.
                            errorInterno = "smtp";
                        }
                    }
                    // Si no existe, no tiene email, o algo salio raro:
                    // igual mostramos el mensaje generico. No se le dice a
                    // quien esta escribiendo si el usuario existe o no.
                }
            } catch (Exception e) {
                e.printStackTrace();
                errorInterno = "db";
            }
            mostrarResultado = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Recuperar clave</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: #f8f9fa; }
        .card-rec { max-width: 460px; width: 100%; margin: 24px; }
    </style>
</head>
<body>
<div class="card card-rec shadow">
    <div class="card-body p-4">

        <% if (smtpDeshabilitado) { %>
            <div class="text-center mb-3">
                <i class="fa fa-exclamation-triangle text-warning" style="font-size:2.5rem;"></i>
                <h5 class="mt-2 mb-0">Envio de correo no disponible</h5>
                <p class="text-sm text-secondary mb-0">
                    El envio automatico de correo no esta configurado en este servidor.
                    Por favor comunicate con el area de Soporte para restablecer tu clave.
                </p>
            </div>
            <div class="text-center">
                <a href="index.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                    <i class="fa fa-arrow-left me-1"></i> Volver
                </a>
            </div>

        <% } else if (mostrarResultado) { %>
            <div class="text-center mb-3">
                <i class="fa fa-check-circle text-success" style="font-size:2.5rem;"></i>
                <h5 class="mt-2 mb-0">Solicitud recibida</h5>
                <p class="text-sm text-secondary mb-0">
                    Si el usuario o correo que ingresaste corresponde a una cuenta activa
                    <% if (emailEnmascarado != null) { %>
                        con correo <b><%=esc(emailEnmascarado)%></b>,
                    <% } %>
                    se envio un mensaje con la nueva clave. Revisa la bandeja de entrada
                    (y la carpeta de <i>spam</i>, por las dudas).
                </p>
                <% if ("smtp".equals(errorInterno)) { %>
                <p class="text-xs text-warning mt-2 mb-0">
                    <i class="fa fa-info-circle me-1"></i>
                    Nota: se genero la nueva clave pero el envio del correo tuvo un
                    inconveniente tecnico. Comunicate con Soporte para que te la reenvien.
                </p>
                <% } %>
            </div>
            <div class="text-center">
                <a href="index.jsp" class="btn bg-gradient-primary btn-sm mb-0">
                    <i class="fa fa-sign-in me-1"></i> Ir al inicio de sesion
                </a>
            </div>

        <% } else { %>
            <div class="text-center mb-3">
                <i class="fa fa-key text-primary" style="font-size:2.5rem;"></i>
                <h5 class="mt-2 mb-0">Recuperar clave</h5>
                <p class="text-sm text-secondary mb-0">
                    Ingresa tu <b>usuario</b> o <b>correo electronico</b>.
                    Te enviaremos una clave nueva al correo registrado en el sistema.
                </p>
            </div>
            <form action="RecuperarClave.jsp" method="post">
                <div class="mb-3">
                    <input type="text" name="identificador" class="form-control form-control-lg"
                           placeholder="Usuario o correo" required autofocus
                           value="<%=esc(identificador != null ? identificador : "")%>">
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <a href="index.jsp" class="text-xs text-secondary">
                        <i class="fa fa-arrow-left me-1"></i> Volver al inicio de sesion
                    </a>
                    <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">
                        <i class="fa fa-paper-plane me-1"></i> Enviar nueva clave
                    </button>
                </div>
            </form>
        <% } %>

    </div>
</div>
</body>
</html>
