<%--
    Document   : Insertar USUARIO
    Created on : 15-Agosto-2019, 11:43:59
    Author     : Jquinde
--%>

<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import=" java.util.Date"
        import=" java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private Integer aEnteroONulo(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.valueOf(s.trim()); } catch (Exception e) { return null; }
    }
%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%
    String nombre = (String) session.getAttribute("nombre");
    String nombreUsuario = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String telefono = request.getParameter("telefono");
    String email = request.getParameter("email");
    String usuario = request.getParameter("usuario");
    String passUsuario = request.getParameter("pass");
    String idRol = request.getParameter("idRol");
    String idCia = request.getParameter("idCia");
    String idRolTodo = request.getParameter("idRolTodo");
    String departamento = request.getParameter("departamento");
    String sueldo = request.getParameter("sueldo");

    String cargo = (String) session.getAttribute("cargo");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    //String url = new String("jdbc:oracle:thin:@"+ip);
    String url = new String(""+ip);
    if(session.getAttribute("usuario")==null){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }else if (session.isNew()){
             response.sendRedirect("sesionExpirada.jsp");
             return;
             }
        if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

        // Link fijo de la aplicacion para el correo de bienvenida -- si
        // cambia el dominio/puerto publico, se actualiza aqui nomas.
        final String LINK_APP = "http://respaldos3.duckdns.org:8088/ProMaNet";

        boolean exito = false;
        String errorMsg = null;

        Connection cn = null;
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cn = DriverManager.getConnection(url, user, pass);

            int idUser = 0;
            try (PreparedStatement stSec = cn.prepareStatement("SELECT NVL(MAX(IDUSUARIO),0)+1 FROM USUARIO");
                 ResultSet rsSec = stSec.executeQuery()) {
                if (rsSec.next()) idUser = rsSec.getInt(1);
            }

            try (PreparedStatement st = cn.prepareStatement(
                    "INSERT INTO USUARIO (IDUSUARIO, NOMBRE, APELLIDOS, TELEFONO, EMAIL, USUARIO, CONTRASENA, " +
                    "IDCOMPANIA, IDROL, ESTADO, IDROLTODO, ID_ADM_DEPARTAMENTO, SUELDO) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'a', ?, ?, ?)")) {
                st.setInt(1, idUser);
                st.setString(2, nombreUsuario);
                st.setString(3, apellido);
                st.setString(4, telefono);
                st.setString(5, email);
                st.setString(6, usuario);
                st.setString(7, passUsuario);
                Integer idCiaNum = aEnteroONulo(idCia);
                if (idCiaNum != null) st.setInt(8, idCiaNum); else st.setNull(8, Types.NUMERIC);
                Integer idRolNum = aEnteroONulo(idRol);
                if (idRolNum != null) st.setInt(9, idRolNum); else st.setNull(9, Types.NUMERIC);
                Integer idRolTodoNum = aEnteroONulo(idRolTodo);
                if (idRolTodoNum != null) st.setInt(10, idRolTodoNum); else st.setNull(10, Types.NUMERIC);
                Integer deptoNum = aEnteroONulo(departamento);
                if (deptoNum != null) st.setInt(11, deptoNum); else st.setNull(11, Types.NUMERIC);
                Integer sueldoNum = aEnteroONulo(sueldo);
                if (sueldoNum != null) st.setInt(12, sueldoNum); else st.setNull(12, Types.NUMERIC);
                st.executeUpdate();
            }
            exito = true;
        } catch (Exception e) {
            e.printStackTrace();
            errorMsg = e.getMessage();
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception e2) {}
        }

        String textoBienvenida = "";
        boolean correoEnviado = false;
        String correoError = null;
        boolean emailValido = email != null && email.trim().contains("@");

        if (exito) {
            textoBienvenida =
                "Estimado " + (nombreUsuario != null ? nombreUsuario : "") + ",\n" +
                "Bienvenido a la empresa. A continuación te comparto tus accesos a las plataformas internas que utilizarás en tus actividades diarias:\n" +
                "🔹 Sistema ProMaNet (para generación de tickets de soporte, consulta de contactos, hojas membretadas, etc.)\n" +
                "\n" +
                "* Link: " + LINK_APP + "\n" +
                "* Usuario: " + (usuario != null ? usuario : "") + "\n" +
                "* Clave: " + (passUsuario != null ? passUsuario : "") + "\n" +
                "\n" +
                "Por favor confirma la recepción de este correo y, si tienes algún inconveniente en el primer acceso, comunícate con el área de Soporte.\n" +
                "Saludos cordiales,";

            // Envio automatico si hay SMTP configurado en el servidor y el
            // usuario trae un email real. Si algo falla (SMTP caido, clave
            // mal puesta, etc.) NO se revierte la creacion del usuario --
            // solo se avisa en pantalla y queda el texto de siempre para
            // copiar y pegar a mano.
            if (Servlets.MailConfig.SMTP_HABILITADO && emailValido) {
                try {
                    correoEnviado = Servlets.Correo.enviar(
                            email.trim(),
                            "Bienvenido a la empresa - Accesos ProMaNet",
                            textoBienvenida);
                } catch (Exception eMail) {
                    eMail.printStackTrace();
                    correoError = eMail.getMessage();
                }
            }
        }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - <%=exito ? "Usuario creado" : "Error"%></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link id="pagestyle" href="assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        body{min-height:100vh;display:flex;align-items:center;justify-content:center;background:#f8f9fa;}
        .card-resultado{max-width:640px;width:100%;margin:24px;}
        #txtBienvenida{font-family:'Courier New',monospace;font-size:.85rem;white-space:pre;}
    </style>
</head>
<body>
<div class="card card-resultado shadow">
    <div class="card-body p-4">
        <% if (exito) { %>
        <div class="text-center mb-3">
            <i class="fa fa-check-circle text-success" style="font-size:2.5rem;"></i>
            <h5 class="mt-2 mb-0">Usuario creado correctamente</h5>
            <% if (correoEnviado) { %>
            <p class="text-sm text-success mb-0"><i class="fa fa-paper-plane me-1"></i>Correo de bienvenida enviado a <%=esc(email)%>.</p>
            <% } else if (!Servlets.MailConfig.SMTP_HABILITADO) { %>
            <p class="text-sm text-secondary mb-0">Copia el siguiente texto y peg&aacute;lo en el correo de bienvenida.</p>
            <% } else if (!emailValido) { %>
            <p class="text-sm text-warning mb-0"><i class="fa fa-exclamation-triangle me-1"></i>Este usuario no tiene un email valido -- copia el texto y env&iacute;alo a mano.</p>
            <% } else { %>
            <p class="text-sm text-danger mb-0"><i class="fa fa-exclamation-triangle me-1"></i>No se pudo enviar el correo automaticamente<%=correoError != null ? " (" + esc(correoError) + ")" : ""%>. Copia el texto y env&iacute;alo a mano.</p>
            <% } %>
        </div>
        <div class="form-group mb-3">
            <textarea id="txtBienvenida" class="form-control" rows="13" readonly><%=esc(textoBienvenida)%></textarea>
        </div>
        <div class="d-flex justify-content-between flex-wrap" style="gap:10px;">
            <a href="PCN_ListadoUsuario.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                <i class="fa fa-arrow-left me-1"></i>Volver al listado
            </a>
            <button type="button" class="btn bg-gradient-primary btn-sm mb-0" id="btnCopiar" onclick="copiarTexto()">
                <i class="fa fa-copy me-1"></i>Copiar texto
            </button>
        </div>
        <% } else { %>
        <div class="text-center mb-3">
            <i class="fa fa-exclamation-triangle text-danger" style="font-size:2.5rem;"></i>
            <h5 class="mt-2 mb-0">No se pudo crear el usuario</h5>
            <p class="text-sm text-secondary mb-0"><%=esc(errorMsg != null ? errorMsg : "Error desconocido")%></p>
        </div>
        <div class="text-center">
            <a href="PCN_ListadoUsuario.jsp" class="btn btn-outline-secondary btn-sm mb-0">
                <i class="fa fa-arrow-left me-1"></i>Volver al listado
            </a>
        </div>
        <% } %>
    </div>
</div>
<% if (exito) { %>
<script>
    function copiarTexto() {
        var ta = document.getElementById('txtBienvenida');
        ta.focus();
        ta.select();
        ta.setSelectionRange(0, 999999);
        var ok = false;
        try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
        if (!ok && navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(ta.value);
            ok = true;
        }
        var btn = document.getElementById('btnCopiar');
        if (ok) {
            btn.innerHTML = '<i class="fa fa-check me-1"></i>Copiado!';
            setTimeout(function () { btn.innerHTML = '<i class="fa fa-copy me-1"></i>Copiar texto'; }, 2000);
        }
    }
</script>
<% } %>
</body>
</html>
