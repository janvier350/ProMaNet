<%--
    Document   : Gestion de permisos individuales por usuario (modulo Inventario)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet"%>
<%
    String cargo     = (String) session.getAttribute("cargo");
    String apellidos = (String) session.getAttribute("apellidos");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    }
    if (!(cargo.equals("CONTRALOR") || cargo.equals("JEFE") || cargo.equals("ADMINISTRACION")
            || cargo.equals("ADMINISTRADOR") || apellidos.equals("Varas Herrera"))) {
        response.sendRedirect("sesionInvalida.jsp"); return;
    }

    String idUserParam = request.getParameter("idUser");
    if (idUserParam == null || idUserParam.replaceAll("[^0-9]", "").isEmpty()) {
        response.sendRedirect("PCN_ListadoUsuario.jsp"); return;
    }
    int idUser = Integer.parseInt(idUserParam.replaceAll("[^0-9]", ""));

    String nombreUsuario = "", apellidosUsuario = "", cargoUsuario = "";
    int idRolUsuario = 0;

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ProMaNet | Permisos de Inventario</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>
<body>
<div class="container" style="margin-top:20px;">
    <a href="PCN_ListadoUsuario.jsp" class="btn btn-default"><i class="fa fa-arrow-left mr-1"></i> Volver al listado</a>
    <h3 class="mt-3">Permisos de Inventario</h3>

    <% if (msgExito != null) { %>
    <div class="alert alert-success"><%=msgExito%></div>
    <% } %>
    <% if (msgError != null) { %>
    <div class="alert alert-danger"><%=msgError%></div>
    <% } %>

    <%
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            Connection cn = DriverManager.getConnection(url, user, pass);

            PreparedStatement stUser = cn.prepareStatement(
                "SELECT u.NOMBRE, u.APELLIDOS, r.CARGO, u.IDROL " +
                "FROM USUARIO u, ROL r WHERE u.IDUSUARIO = ? AND u.IDROL = r.IDROL");
            stUser.setInt(1, idUser);
            ResultSet rsUser = stUser.executeQuery();
            if (rsUser.next()) {
                nombreUsuario   = rsUser.getString(1);
                apellidosUsuario= rsUser.getString(2);
                cargoUsuario    = rsUser.getString(3);
                idRolUsuario    = rsUser.getInt(4);
            }
            rsUser.close(); stUser.close();
    %>

    <p><strong><%=nombreUsuario%> <%=apellidosUsuario%></strong> &mdash; cargo actual: <span class="label label-info"><%=cargoUsuario%></span></p>
    <p class="text-muted"><small>Los permisos aqui asignados son excepciones puntuales para esta persona: se suman o se restan de lo que su cargo ya permite, sin tener que cambiarle el cargo. El cambio se aplica la proxima vez que esta persona inicie sesion.</small></p>

    <form method="post" action="PCN_GuardarPermisosUsuario">
        <input type="hidden" name="idUser" value="<%=idUser%>">
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Permiso</th>
                    <th>Descripcion</th>
                    <th class="text-center">Por su cargo</th>
                    <th class="text-center">Asignacion para esta persona</th>
                </tr>
            </thead>
            <tbody>
            <%
                PreparedStatement stPerm = cn.prepareStatement(
                    "SELECT ID_PERMISO, CODIGO, DESCRIPCION FROM APP_PERMISO WHERE MODULO = 'INVENTARIO' AND ESTADO = 'A' ORDER BY ID_PERMISO");
                ResultSet rsPerm = stPerm.executeQuery();
                while (rsPerm.next()) {
                    int idPermiso = rsPerm.getInt(1);
                    String codigo = rsPerm.getString(2);
                    String descripcion = rsPerm.getString(3);

                    PreparedStatement stRolTiene = cn.prepareStatement(
                        "SELECT COUNT(*) FROM APP_ROL_PERMISO WHERE IDROL = ? AND ID_PERMISO = ?");
                    stRolTiene.setInt(1, idRolUsuario);
                    stRolTiene.setInt(2, idPermiso);
                    ResultSet rsRolTiene = stRolTiene.executeQuery();
                    boolean porRol = rsRolTiene.next() && rsRolTiene.getInt(1) > 0;
                    rsRolTiene.close(); stRolTiene.close();

                    PreparedStatement stOverride = cn.prepareStatement(
                        "SELECT TIPO FROM APP_USUARIO_PERMISO WHERE IDUSUARIO = ? AND ID_PERMISO = ?");
                    stOverride.setInt(1, idUser);
                    stOverride.setInt(2, idPermiso);
                    ResultSet rsOverride = stOverride.executeQuery();
                    String tipoActual = rsOverride.next() ? rsOverride.getString(1) : "ROL";
                    rsOverride.close(); stOverride.close();
            %>
                <tr>
                    <td><code><%=codigo%></code></td>
                    <td><%=descripcion%></td>
                    <td class="text-center"><%=porRol ? "Si" : "No"%></td>
                    <td class="text-center">
                        <select name="permiso_<%=idPermiso%>" class="form-control" style="min-width:220px;width:auto;display:inline-block;">
                            <option value="ROL" <%=("ROL".equals(tipoActual))?"selected":""%>>Segun su cargo (<%=porRol?"tiene":"no tiene"%>)</option>
                            <option value="G" <%=("G".equals(tipoActual))?"selected":""%>>Conceder siempre</option>
                            <option value="D" <%=("D".equals(tipoActual))?"selected":""%>>Denegar siempre</option>
                        </select>
                    </td>
                </tr>
            <%
                }
                rsPerm.close(); stPerm.close();
                cn.close();
            }catch(Exception e){ e.printStackTrace();
            %>
                <tr><td colspan="4" class="text-danger">Error: <%=e.getMessage()%></td></tr>
            <%
            }
            %>
            </tbody>
        </table>
        <button type="submit" class="btn btn-primary"><i class="fa fa-save mr-1"></i> Guardar</button>
    </form>
</div>
</body>
</html>
