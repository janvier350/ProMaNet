<%--
    Document   : Acta de entrega de periferico
    Se abre en ventana nueva (target=_blank) desde el listado. Recibe
    idPeriferico (obligatorio). Opcional: idAsignacion (para reimprimir un
    acta especifica del historial). Si no se envia idAsignacion o se envia
    "ultima", se toma la asignacion mas reciente (activa o cerrada) de ese
    periferico.
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private static String nz(String s) { return s == null ? "" : s; }
%>
<%
    String nombreOp    = (String) session.getAttribute("nombre");
    String apellidosOp = (String) session.getAttribute("apellidos");

    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "INVENTARIO_EQUIPOS_VER")) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String idPeriferico = request.getParameter("idPeriferico");
    String idAsignacionParam = request.getParameter("idAsignacion");
    if (idPeriferico == null || idPeriferico.trim().isEmpty()) {
        out.println("<p>Falta idPeriferico.</p>"); return;
    }

    String tipoDesc="", marca="", modelo="", serial="", fcompra="", oficina="", empresa="";
    String usuarioNombre="", usuarioCedula="", usuarioDepto="";
    String motivoDesc="", motivoCodigo="", obsMotivo="";
    String fechaAsig="", operador="";
    int idAsignacion = 0;

    try (Connection cn = Servlets.Conexion.getConnection()) {
        if (cn != null) {
            // 1) Datos del periferico
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT t.DESCRIPCION, p.MARCA, p.MODELO, p.SERIAL, " +
                    " TO_CHAR(p.FECHACOMPRA,'DD/MM/YYYY'), p.UBICACIONOFICINA, p.EMPRESA " +
                    "FROM INV_PERIFERICO p JOIN INV_PERIFERICO_TIPO t ON t.ID_TIPO = p.ID_TIPO " +
                    "WHERE p.ID_PERIFERICO = ? AND p.ESTADO_AI = 'A'")) {
                st.setString(1, idPeriferico);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        tipoDesc = nz(rs.getString(1)); marca = nz(rs.getString(2));
                        modelo = nz(rs.getString(3)); serial = nz(rs.getString(4));
                        fcompra = nz(rs.getString(5)); oficina = nz(rs.getString(6));
                        empresa = nz(rs.getString(7));
                    } else {
                        out.println("<p>Periferico no encontrado.</p>"); return;
                    }
                }
            }

            // 2) Datos de la asignacion (por id, o la mas reciente)
            String sqlAsig;
            boolean porId = idAsignacionParam != null && !idAsignacionParam.trim().isEmpty()
                            && !"ultima".equalsIgnoreCase(idAsignacionParam.trim());
            if (porId) {
                sqlAsig =
                    "SELECT a.ID_ASIGNACION, TO_CHAR(a.FECHAASIGNACION,'DD/MM/YYYY'), " +
                    " u.NOMBRE || ' ' || u.APELLIDOS, u.CEDULA, u.DEPARTAMENTO, " +
                    " m.DESCRIPCION, m.CODIGO, a.OBSERVACION_MOTIVO, " +
                    " (SELECT ur.NOMBRE || ' ' || ur.APELLIDOS FROM USUARIO ur WHERE ur.IDUSUARIO = a.ID_USUARIO_REGISTRA) " +
                    "FROM INV_PERIFERICO_ASIGNACION a " +
                    " JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
                    " JOIN INV_PERIFERICO_MOTIVO m ON m.ID_MOTIVO = a.ID_MOTIVO " +
                    "WHERE a.ID_ASIGNACION = ? AND a.ID_PERIFERICO = ?";
            } else {
                sqlAsig =
                    "SELECT * FROM ( " +
                    "  SELECT a.ID_ASIGNACION, TO_CHAR(a.FECHAASIGNACION,'DD/MM/YYYY'), " +
                    "   u.NOMBRE || ' ' || u.APELLIDOS, u.CEDULA, u.DEPARTAMENTO, " +
                    "   m.DESCRIPCION, m.CODIGO, a.OBSERVACION_MOTIVO, " +
                    "   (SELECT ur.NOMBRE || ' ' || ur.APELLIDOS FROM USUARIO ur WHERE ur.IDUSUARIO = a.ID_USUARIO_REGISTRA) OPERADOR " +
                    "  FROM INV_PERIFERICO_ASIGNACION a " +
                    "   JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO " +
                    "   JOIN INV_PERIFERICO_MOTIVO m ON m.ID_MOTIVO = a.ID_MOTIVO " +
                    "  WHERE a.ID_PERIFERICO = ? " +
                    "  ORDER BY a.FECHAASIGNACION DESC, a.ID_ASIGNACION DESC " +
                    ") WHERE ROWNUM = 1";
            }
            try (PreparedStatement st = cn.prepareStatement(sqlAsig)) {
                if (porId) {
                    st.setInt(1, Integer.parseInt(idAsignacionParam.trim()));
                    st.setInt(2, Integer.parseInt(idPeriferico.trim()));
                } else {
                    st.setInt(1, Integer.parseInt(idPeriferico.trim()));
                }
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        idAsignacion  = rs.getInt(1);
                        fechaAsig     = nz(rs.getString(2));
                        usuarioNombre = nz(rs.getString(3));
                        usuarioCedula = nz(rs.getString(4));
                        usuarioDepto  = nz(rs.getString(5));
                        motivoDesc    = nz(rs.getString(6));
                        motivoCodigo  = nz(rs.getString(7));
                        obsMotivo     = nz(rs.getString(8));
                        operador      = nz(rs.getString(9));
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Si no hay asignacion, usar operador de sesion.
    if (operador.isEmpty()) operador = nz(nombreOp) + " " + nz(apellidosOp);
    if (fechaAsig.isEmpty()) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
        fechaAsig = sdf.format(new java.util.Date());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Acta de entrega de periferico - <%=esc(usuarioNombre)%></title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
    <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
    <style>
        body { background: #f8f9fe; padding: 50px; font-family: "Open Sans", sans-serif; color: #333; }
        .hoja-acta { background: white; padding: 60px; box-shadow: 0 0 20px rgba(0,0,0,0.1); border-radius: 8px; min-height: 842px; position: relative; }
        .logo-buadnet { height: 75px; float: right; }
        .texto-verde { color: #2dce89 !important; font-weight: 600; }
        .firma-linea { border-top: 1px solid #adb5bd; width: 180px; margin-top: 80px; margin-bottom: 10px; }
        .text-justify { text-align: justify; text-justify: inter-word; line-height: 1.6; }
        @media print { body { background: white; padding: 0; } .hoja-acta { box-shadow: none; border: none; padding: 20px; } .btn-imprimir { display: none; } }
    </style>
</head>
<body>
    <div class="text-center mb-4 btn-imprimir">
        <button onclick="window.print();" class="btn btn-success px-5">
            <i class="fa fa-print me-2"></i> CONFIRMAR E IMPRIMIR
        </button>
    </div>

    <div class="hoja-acta">
        <img src="../assets/img/promanetlogo.png" class="logo-buadnet">
        <div style="clear: both;"></div>

        <p class="mt-4"><strong>Guayaquil, <%=esc(fechaAsig)%></strong></p>
        <h2 class="text-center mt-5 mb-4" style="color: #5e72e4; letter-spacing: 1px;">
            Acta de Entrega de Periferico
        </h2>
        <p class="text-center text-muted mb-5">
            Acta #<%=idAsignacion%> &middot; Motivo: <b><%=esc(motivoDesc)%></b>
        </p>

        <% if ("PRESTAMO_TEMPORAL".equals(motivoCodigo)) { %>
            <p class="text-justify">
                Yo, <strong class="text-uppercase"><%=esc(usuarioNombre)%></strong>
                <% if (!usuarioCedula.isEmpty()) { %>, con identificación: <strong><%=esc(usuarioCedula)%></strong><% } %>,
                declaro haber recibido de la empresa, en calidad de <strong>préstamo temporal</strong>,
                el periférico detallado a continuación, para el desempeño exclusivo de mis funciones laborales
                <% if (!usuarioDepto.isEmpty()) { %> en el área de <strong><%=esc(usuarioDepto)%></strong><% } %>.
            </p>
            <p class="text-justify mt-3">
                Me comprometo a devolver el bien en las mismas condiciones en que se me entrega
                una vez cumplido el motivo del préstamo, y a informar de inmediato al Departamento
                de Sistemas cualquier daño, pérdida o inconveniente durante el uso.
            </p>
        <% } else { %>
            <p class="text-justify">
                Yo, <strong class="text-uppercase"><%=esc(usuarioNombre)%></strong>
                <% if (!usuarioCedula.isEmpty()) { %>, con identificación: <strong><%=esc(usuarioCedula)%></strong><% } %>,
                declaro haber recibido de la empresa, en calidad de <strong>herramienta de trabajo</strong>,
                el periférico detallado a continuación, para el desempeño exclusivo de mis funciones laborales
                <% if (!usuarioDepto.isEmpty()) { %> en el área de <strong><%=esc(usuarioDepto)%></strong><% } %>.
            </p>
            <p class="text-justify mt-3">
                Hago constar que el bien se me entrega en <strong>perfectas condiciones físicas, operativo y
                totalmente funcional</strong>, libre de desperfectos que impidan su uso. El periférico queda
                bajo mi custodia para <strong>uso exclusivo de las actividades de la empresa</strong>, asumiendo
                la responsabilidad total de su correcto uso, cuidado y conservación.
            </p>
        <% } %>

        <div class="mt-4 d-flex align-items-start" style="gap:20px;">
            <div class="ps-4" style="flex:1;">
                <ul style="list-style: disc;">
                    <li class="mb-1"><span class="texto-verde">Tipo:</span> <strong class="text-dark"><%=esc(tipoDesc)%></strong></li>
                    <li class="mb-1"><span class="texto-verde">Marca:</span> <strong class="text-dark"><%=esc(marca)%></strong></li>
                    <li class="mb-1"><span class="texto-verde">Modelo:</span> <%=esc(modelo)%></li>
                    <% if (!serial.isEmpty()) { %>
                    <li class="mb-1"><span class="texto-verde">Serial:</span> <%=esc(serial)%></li>
                    <% } %>
                    <% if (!fcompra.isEmpty()) { %>
                    <li class="mb-1"><span class="texto-verde">Fecha de compra:</span> <%=esc(fcompra)%></li>
                    <% } %>
                    <% if (!oficina.isEmpty()) { %>
                    <li class="mb-1"><span class="texto-verde">Ubicación:</span> <%=esc(oficina)%></li>
                    <% } %>
                    <% if (!empresa.isEmpty()) { %>
                    <li class="mb-1"><span class="texto-verde">Empresa:</span> <%=esc(empresa)%></li>
                    <% } %>
                    <li class="mb-1"><span class="texto-verde">Motivo de entrega:</span> <%=esc(motivoDesc)%></li>
                    <% if (!obsMotivo.isEmpty()) { %>
                    <li class="mb-1"><span class="texto-verde">Observación:</span> <%=esc(obsMotivo)%></li>
                    <% } %>
                </ul>
            </div>
            <div style="flex:0 0 200px;text-align:center;">
                <img src="../INV_MostrarImagenPeriferico?nombre=perif_<%=esc(idPeriferico)%>"
                     style="max-width:200px;max-height:150px;object-fit:cover;border-radius:8px;border:1px solid #dee2e6;"
                     onerror="this.parentElement.style.display='none';">
                <p class="text-xs text-muted mt-1 mb-0">Foto del periférico</p>
            </div>
        </div>

        <p class="mt-5 text-justify">
            Me comprometo a velar por el adecuado mantenimiento del activo asignado, garantizando su integridad
            física y operativa. En caso de daño por negligencia, pérdida o uso indebido fuera del ámbito laboral,
            acepto las políticas de reposición establecidas por la organización.
        </p>

        <div class="d-flex justify-content-between mt-8 text-center">
            <div style="flex: 1;">
                <div class="firma-linea mx-auto"></div>
                <p class="text-xs">Entregado por:<br><strong><%=esc(operador)%></strong></p>
            </div>
            <div style="flex: 1;">
                <div class="firma-linea mx-auto"></div>
                <p class="text-xs">Recibí Conforme:<br><strong class="text-uppercase"><%=esc(usuarioNombre)%></strong></p>
            </div>
            <div style="flex: 1;">
                <div class="firma-linea mx-auto"></div>
                <p class="text-xs">Jefe de Departamento<br><strong>Responsable</strong></p>
            </div>
        </div>
    </div>
</body>
</html>
