<%--
    Document   : Gestion de permisos por departamento (APP_DEPARTAMENTO_PERMISO)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet"%>
<%
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip   = (String) session.getAttribute("ipDB");
    String url  = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    } else if (session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "USUARIOS_GESTIONAR")) {
        response.sendRedirect("sesionInvalida.jsp"); return;
    }

    String departamento = request.getParameter("depto");

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ProMaNet | Permisos por departamento</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>
<body>
<div class="container" style="margin-top:20px;">
    <a href="PCN_ListadoUsuario.jsp" class="btn btn-default"><i class="fa fa-arrow-left mr-1"></i> Volver al listado</a>
    <h3 class="mt-3">Permisos por departamento</h3>
    <p class="text-muted"><small>Estas reglas aplican a todo el departamento sin importar el cargo de cada persona. Se resuelven despues del permiso por rol y antes de la excepcion individual de cada usuario: si el departamento deniega algo, nadie de ese departamento lo tiene aunque su cargo si lo de; una excepcion individual (en "Permisos" del usuario) siempre gana al final sobre esta regla.</small></p>

    <% if (msgExito != null) { %>
    <div class="alert alert-success"><%=msgExito%></div>
    <% } %>
    <% if (msgError != null) { %>
    <div class="alert alert-danger"><%=msgError%></div>
    <% } %>

    <form method="get" action="PCN_GestionPermisosDepartamento.jsp" class="form-inline mb-3">
        <label class="mr-2">Departamento:</label>
        <select name="depto" class="form-control" onchange="this.form.submit()" style="min-width:280px;">
            <option value="">-- Selecciona un departamento --</option>
            <%
                try {
                    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                    Connection cnDep = DriverManager.getConnection(url, user, pass);
                    PreparedStatement stDep = cnDep.prepareStatement(
                        "select * from ADM_DEPARTAMENTO where estado = 'A' order by 2");
                    ResultSet rsDep = stDep.executeQuery();
                    while (rsDep.next()) {
                        String nombreDep = rsDep.getString(2);
            %>
            <option value="<%=nombreDep%>" <%=(nombreDep.equals(departamento)) ? "selected" : ""%>><%=nombreDep%></option>
            <%
                    }
                    rsDep.close(); stDep.close(); cnDep.close();
                } catch (Exception e) { e.printStackTrace(); }
            %>
        </select>
        <noscript><button type="submit" class="btn btn-default ml-2">Ver</button></noscript>
    </form>

    <% if (departamento != null && !departamento.trim().isEmpty()) { %>
    <form method="post" action="PCN_GuardarPermisosDepartamento">
        <input type="hidden" name="departamento" value="<%=departamento%>">
        <%
            try {
                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                Connection cn = DriverManager.getConnection(url, user, pass);

                PreparedStatement stMod = cn.prepareStatement(
                    "SELECT DISTINCT MODULO FROM APP_PERMISO WHERE ESTADO = 'A' ORDER BY MODULO");
                ResultSet rsMod = stMod.executeQuery();
                while (rsMod.next()) {
                    String modulo = rsMod.getString(1);
        %>
        <h4 class="mt-4"><%=modulo%></h4>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Permiso</th>
                    <th>Descripcion</th>
                    <th class="text-center">Regla para <%=departamento%></th>
                </tr>
            </thead>
            <tbody>
            <%
                PreparedStatement stPerm = cn.prepareStatement(
                    "SELECT ID_PERMISO, CODIGO, DESCRIPCION FROM APP_PERMISO WHERE MODULO = ? AND ESTADO = 'A' ORDER BY ID_PERMISO");
                stPerm.setString(1, modulo);
                ResultSet rsPerm = stPerm.executeQuery();
                while (rsPerm.next()) {
                    int idPermiso = rsPerm.getInt(1);
                    String codigo = rsPerm.getString(2);
                    String descripcion = rsPerm.getString(3);

                    PreparedStatement stActual = cn.prepareStatement(
                        "SELECT TIPO FROM APP_DEPARTAMENTO_PERMISO WHERE UPPER(DEPARTAMENTO) = UPPER(?) AND ID_PERMISO = ?");
                    stActual.setString(1, departamento);
                    stActual.setInt(2, idPermiso);
                    ResultSet rsActual = stActual.executeQuery();
                    String tipoActual = rsActual.next() ? rsActual.getString(1) : "NINGUNA";
                    rsActual.close(); stActual.close();
            %>
                <tr>
                    <td><code><%=codigo%></code></td>
                    <td><%=descripcion%></td>
                    <td class="text-center">
                        <select name="permiso_<%=idPermiso%>" class="form-control" style="min-width:260px;width:auto;display:inline-block;">
                            <option value="NINGUNA" <%=("NINGUNA".equals(tipoActual))?"selected":""%>>Sin excepcion (segun el cargo de cada persona)</option>
                            <option value="G" <%=("G".equals(tipoActual))?"selected":""%>>Conceder a todo el departamento</option>
                            <option value="D" <%=("D".equals(tipoActual))?"selected":""%>>Denegar a todo el departamento</option>
                        </select>
                    </td>
                </tr>
            <%
                }
                rsPerm.close(); stPerm.close();
            %>
            </tbody>
        </table>
        <%
                }
                rsMod.close(); stMod.close();
                cn.close();
            } catch (Exception e) { e.printStackTrace();
        %>
            <div class="text-danger">Error: <%=e.getMessage()%></div>
        <%
            }
        %>
        <button type="submit" class="btn btn-primary"><i class="fa fa-save mr-1"></i> Guardar</button>
    </form>
    <% } %>
</div>
</body>
</html>
