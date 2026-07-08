<%@page contentType="text/html" pageEncoding="UTF-8"
        import="java.util.Date, java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%
    String cargo     = (String) session.getAttribute("cargo");
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String user      = (String) session.getAttribute("userDB");
    String pass      = (String) session.getAttribute("passDB");
    String ip        = (String) session.getAttribute("ipDB");
    String url       = "" + ip;
    String compania  = (String) session.getAttribute("compania");
    if (compania == null) compania = "EMPRESA";

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    if (!(COMUN.PermisoHelper.tiene(session, "INVENTARIO_DESPACHAR")
            || COMUN.PermisoHelper.tiene(session, "INVENTARIO_IMPRIMIR_COMPROBANTE"))) {
        response.sendRedirect("../sesionInvalida.jsp"); return;
    }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.replaceAll("[^0-9]","").isEmpty()) {
        response.sendRedirect("INV_Lista_Solicitudes_Suministro.jsp"); return;
    }
    int idCab = Integer.parseInt(idParam.replaceAll("[^0-9]",""));
    boolean autoPrint = "true".equals(request.getParameter("imprimir"));

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String fechaHoy   = sdf.format(new Date());
    String fechaSol   = "—", depto = "—", solicitante = "—", autorizador = "—";
    StringBuilder filasProd = new StringBuilder();

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        PreparedStatement stCab = cn.prepareStatement(
            "SELECT e.FECHA_SOLICITUD, d.DEPARTAMENTO, " +
            "       u.NOMBRE||' '||u.APELLIDOS, ua.NOMBRE||' '||ua.APELLIDOS " +
            "FROM INV_SUMINISTRO_EGRESO_CAB e " +
            "LEFT JOIN ADM_DEPARTAMENTO d  ON TO_CHAR(e.ID_DEPARTAMENTO) = d.ID_DEPARTAMENTO " +
            "LEFT JOIN USUARIO u           ON e.ID_USUARIO      = u.IDUSUARIO " +
            "LEFT JOIN USUARIO ua          ON e.ID_USUARIO_AUTO = ua.IDUSUARIO " +
            "WHERE e.ID_SUMINISTRO_EGRESO_CAB = ?");
        stCab.setInt(1, idCab);
        ResultSet rsCab = stCab.executeQuery();
        if (rsCab.next()) {
            fechaSol    = rsCab.getDate(1)    != null ? sdf.format(rsCab.getDate(1)) : "—";
            depto       = rsCab.getString(2)  != null ? rsCab.getString(2) : "—";
            solicitante = rsCab.getString(3)  != null ? rsCab.getString(3) : "—";
            autorizador = rsCab.getString(4)  != null ? rsCab.getString(4) : "—";
        }
        rsCab.close(); stCab.close();

        PreparedStatement stDet = cn.prepareStatement(
            "SELECT p.DESCRIPCION, d.CANTIDAD, u.UNIDAD " +
            "FROM INV_SUMINISTRO_EGRESO_DET d " +
            "JOIN INV_PRODUCTO p ON d.ID_PRODUCTO = p.ID_PRODUCTO " +
            "LEFT JOIN INV_UNIDAD_MEDIDA u ON p.ID_UNIDAD = u.ID_UNIDAD_MEDIDA " +
            "WHERE d.ID_SUMINISTRO_EGRESO_CAB = ? ORDER BY p.DESCRIPCION");
        stDet.setInt(1, idCab);
        ResultSet rsDet = stDet.executeQuery();
        int num = 1;
        while (rsDet.next()) {
            String unidad = rsDet.getString(3) != null ? rsDet.getString(3) : "";
            filasProd.append("<tr>")
                     .append("<td class='tc'>").append(num++).append("</td>")
                     .append("<td>").append(rsDet.getString(1)).append("</td>")
                     .append("<td class='tc fw'>").append(rsDet.getInt(2)).append("</td>")
                     .append("<td class='tc'>").append(unidad).append("</td>")
                     .append("<td class='tc'><div class='chk-box'></div></td>")
                     .append("</tr>");
        }
        if (num == 1) filasProd.append("<tr><td colspan='5' class='tc text-muted'>Sin productos registrados.</td></tr>");
        rsDet.close(); stDet.close();
        cn.close();
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Comprobante de Entrega #<%=String.format("%05d", idCab)%></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        *{box-sizing:border-box;margin:0;padding:0;}
        body{background:#dde3ec;font-family:'Segoe UI',Arial,sans-serif;font-size:13px;}

        /* ---- Barra de acciones (solo pantalla) ---- */
        .action-bar{background:#3d5a99;padding:10px 24px;display:flex;align-items:center;gap:10px;position:sticky;top:0;z-index:100;}
        .action-bar .ab-title{color:#fff;font-weight:700;font-size:.95rem;flex:1;}
        .btn-imp{background:#fff;color:#3d5a99;border:none;padding:7px 18px;border-radius:4px;font-weight:700;cursor:pointer;font-size:.85rem;}
        .btn-imp:hover{background:#e8ecf8;}
        .btn-volver{background:transparent;color:#fff;border:1px solid rgba(255,255,255,.5);padding:7px 16px;border-radius:4px;font-size:.85rem;text-decoration:none;}
        .btn-volver:hover{background:rgba(255,255,255,.15);color:#fff;text-decoration:none;}

        /* ---- Hoja del comprobante ---- */
        .sheet{background:#fff;max-width:800px;margin:28px auto 40px;border-radius:6px;box-shadow:0 6px 24px rgba(0,0,0,.18);overflow:hidden;}

        /* Cabecera empresa */
        .hdr{display:flex;align-items:center;gap:16px;padding:20px 28px 16px;border-bottom:3px solid #3d5a99;}
        .hdr-icon{width:62px;height:62px;border-radius:50%;background:#3d5a99;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
        .hdr-icon i{color:#fff;font-size:1.7rem;}
        .hdr-empresa{flex:1;}
        .hdr-empresa h3{color:#3d5a99;font-size:1.05rem;font-weight:800;margin:0 0 2px;}
        .hdr-empresa p{color:#888;font-size:.75rem;margin:0;}
        .hdr-num{text-align:right;}
        .hdr-num .num{font-size:2rem;font-weight:900;color:#3d5a99;line-height:1;}
        .hdr-num .lbl{font-size:.68rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;}
        .hdr-num .fecha-emision{font-size:.75rem;color:#666;margin-top:3px;}

        /* Banda de título */
        .titulo-banda{background:#3d5a99;color:#fff;text-align:center;padding:9px;font-size:.82rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;}

        /* Grid info */
        .info-grid{display:grid;grid-template-columns:1fr 1fr 1fr;border-bottom:1px solid #e8e8e8;}
        .info-cell{padding:11px 20px;border-right:1px solid #e8e8e8;}
        .info-cell:last-child{border-right:none;}
        .info-cell.full{grid-column:1/-1;border-right:none;border-top:1px solid #e8e8e8;}
        .info-cell .lbl{font-size:.65rem;color:#aaa;text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;}
        .info-cell .val{font-weight:700;font-size:.88rem;color:#1a1a1a;}

        /* Sección productos */
        .sec{padding:16px 24px;}
        .sec-title{font-size:.68rem;color:#3d5a99;font-weight:700;text-transform:uppercase;letter-spacing:1px;margin-bottom:10px;display:flex;align-items:center;gap:6px;}
        .sec-title::after{content:'';flex:1;height:1px;background:#e0e0e0;}

        table.prod{width:100%;border-collapse:collapse;}
        table.prod thead tr{background:#3d5a99;color:#fff;}
        table.prod th{padding:7px 10px;font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;}
        table.prod td{padding:7px 10px;border-bottom:1px solid #f0f0f0;}
        table.prod tbody tr:last-child td{border-bottom:2px solid #3d5a99;}
        table.prod tbody tr:nth-child(even){background:#fafcff;}
        .tc{text-align:center;}
        .fw{font-weight:700;}
        .chk-box{width:20px;height:20px;border:1.5px solid #aaa;border-radius:3px;margin:0 auto;}

        /* Observaciones */
        .obs-box{margin:0 24px 16px;border:1px dashed #ccc;border-radius:4px;padding:10px 14px;min-height:44px;}
        .obs-box .obs-lbl{font-size:.65rem;color:#aaa;text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;}

        /* Firmas */
        .firmas{display:flex;gap:32px;padding:20px 40px 24px;border-top:1px solid #eee;}
        .firma-col{flex:1;text-align:center;}
        .firma-espacio{height:56px;}
        .firma-linea-sig{border-top:1.5px solid #333;padding-top:6px;margin-bottom:12px;}
        .firma-tipo{font-weight:800;font-size:.75rem;text-transform:uppercase;color:#3d5a99;letter-spacing:1px;margin-bottom:10px;}
        .firma-campo{display:flex;align-items:flex-end;margin-bottom:5px;font-size:.72rem;}
        .firma-campo span.f-lbl{color:#888;min-width:52px;text-align:left;}
        .firma-campo span.f-line{flex:1;border-bottom:1px dotted #bbb;margin-left:4px;height:14px;}

        /* Footer */
        .comp-footer{background:#f8f9fb;border-top:1px solid #eee;padding:9px 24px;display:flex;justify-content:space-between;align-items:center;}
        .comp-footer small{color:#bbb;font-size:.68rem;}

        /* IMPRESIÓN */
        @media print {
            body{background:#fff !important;}
            .action-bar{display:none !important;}
            .sheet{margin:0 !important;box-shadow:none !important;border-radius:0 !important;max-width:100% !important;}
            @page{margin:1cm 1.2cm;size:A4;}
        }
    </style>
</head>
<body>

<!-- Barra acciones (no se imprime) -->
<div class="action-bar">
    <span class="ab-title"><i class="fa fa-print mr-2"></i>Comprobante de Entrega de Suministros</span>
    <button class="btn-imp" onclick="window.print()">
        <i class="fa fa-print mr-1"></i> Imprimir / Guardar PDF
    </button>
    <a href="INV_Lista_Solicitudes_Suministro.jsp" class="btn-volver">
        <i class="fa fa-arrow-left mr-1"></i> Volver a la lista
    </a>
</div>

<!-- Comprobante -->
<div class="sheet">

    <!-- Cabecera empresa -->
    <div class="hdr">
        <div class="hdr-icon"><i class="fa fa-building"></i></div>
        <div class="hdr-empresa">
            <h3><%=compania%></h3>
            <p>Sistema de Gesti&oacute;n de Suministros de Oficina &mdash; ProMaNet</p>
        </div>
        <div class="hdr-num">
            <div class="lbl">Comprobante N&deg;</div>
            <div class="num"><%=String.format("%05d", idCab)%></div>
            <div class="fecha-emision">Emitido: <%=fechaHoy%></div>
        </div>
    </div>

    <!-- Banda título -->
    <div class="titulo-banda">
        <i class="fa fa-check-square-o mr-2"></i>
        Comprobante de Entrega de Suministros de Oficina
    </div>

    <!-- Info grid -->
    <div class="info-grid">
        <div class="info-cell">
            <div class="lbl">N&deg; Solicitud</div>
            <div class="val" style="color:#3d5a99;">#<%=idCab%></div>
        </div>
        <div class="info-cell">
            <div class="lbl">Fecha Solicitud</div>
            <div class="val"><%=fechaSol%></div>
        </div>
        <div class="info-cell">
            <div class="lbl">Fecha de Entrega</div>
            <div class="val"><%=fechaHoy%></div>
        </div>
        <div class="info-cell full">
            <div class="lbl">Departamento Solicitante</div>
            <div class="val"><%=depto%></div>
        </div>
        <div class="info-cell">
            <div class="lbl">Solicitante</div>
            <div class="val"><%=solicitante%></div>
        </div>
        <div class="info-cell" style="grid-column:2/-1;border-right:none;">
            <div class="lbl">Autorizado por (Jefe de &Aacute;rea)</div>
            <div class="val"><%=autorizador%></div>
        </div>
    </div>

    <!-- Productos -->
    <div class="sec">
        <div class="sec-title"><i class="fa fa-list"></i>Detalle de suministros entregados</div>
        <table class="prod">
            <thead>
                <tr>
                    <th class="tc" style="width:36px">#</th>
                    <th>Descripci&oacute;n del Producto</th>
                    <th class="tc" style="width:90px">Cantidad</th>
                    <th class="tc" style="width:90px">Unidad</th>
                    <th class="tc" style="width:80px">Conforme</th>
                </tr>
            </thead>
            <tbody>
                <%=filasProd.toString()%>
            </tbody>
        </table>
    </div>

    <!-- Observaciones -->
    <div class="obs-box">
        <div class="obs-lbl">Observaciones</div>
    </div>

    <!-- Firmas -->
    <div class="firmas">
        <div class="firma-col">
            <div class="firma-espacio"></div>
            <div class="firma-linea-sig"></div>
            <div class="firma-tipo">Entrega</div>
            <div class="firma-campo"><span class="f-lbl">Nombre:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">Cargo:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">C.I. / RUC:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">Fecha:</span><span class="f-line"></span></div>
        </div>
        <div class="firma-col">
            <div class="firma-espacio"></div>
            <div class="firma-linea-sig"></div>
            <div class="firma-tipo">Recibe</div>
            <div class="firma-campo"><span class="f-lbl">Nombre:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">Cargo:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">C.I. / RUC:</span><span class="f-line"></span></div>
            <div class="firma-campo"><span class="f-lbl">Fecha:</span><span class="f-line"></span></div>
        </div>
    </div>

    <!-- Footer -->
    <div class="comp-footer">
        <small><i class="fa fa-lock mr-1"></i>Documento generado electr&oacute;nicamente &mdash; ProMaNet v2.0</small>
        <small>Solicitud #<%=idCab%> &nbsp;|&nbsp; <%=fechaHoy%></small>
    </div>

</div>

<script>
    <%if (autoPrint) {%>
    window.addEventListener('load', function() {
        setTimeout(function() { window.print(); }, 700);
    });
    <%}%>
</script>
</body>
</html>
