<%@page contentType="text/html" pageEncoding="UTF-8" import="java.util.Date, java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%
    String cargo=(String)session.getAttribute("cargo"); String nombre=(String)session.getAttribute("nombre");
    String apellidos=(String)session.getAttribute("apellidos"); String user=(String)session.getAttribute("userDB");
    String pass=(String)session.getAttribute("passDB"); String ip=(String)session.getAttribute("ipDB"); String url=""+ip;
    if(session.getAttribute("usuario")==null){response.sendRedirect("../sesionExpirada.jsp");return;}
    else if(session.isNew()){response.sendRedirect("../sesionExpirada.jsp");return;}
    if(!(cargo.equals("ADMINISTRACION")||cargo.equals("ADMINISTRADOR")||cargo.equals("CONTRALOR")||cargo.equals("JEFE"))){response.sendRedirect("../sesionInvalida.jsp");return;}
    String idParam=request.getParameter("id");
    if(idParam==null||idParam.replaceAll("[^0-9]","").isEmpty()){response.sendRedirect("INV_Lista_Solicitudes_Suministro.jsp");return;}
    int idCab=Integer.parseInt(idParam.replaceAll("[^0-9]",""));
    String fechaSol="—",depto="—",solicitante="—",autorizador="—",estadoSol="",compania="";
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn=DriverManager.getConnection(url,user,pass);
        String sqlCab="SELECT e.FECHA_SOLICITUD,e.ESTADO_SOLICITUD,d.DEPARTAMENTO,u.NOMBRE||' '||u.APELLIDOS,ua.NOMBRE||' '||ua.APELLIDOS "+
            "FROM INV_SUMINISTRO_EGRESO_CAB e "+
            "LEFT JOIN ADM_DEPARTAMENTO d ON TO_CHAR(e.ID_DEPARTAMENTO)=d.ID_DEPARTAMENTO "+
            "LEFT JOIN USUARIO u ON e.ID_USUARIO=u.IDUSUARIO "+
            "LEFT JOIN USUARIO ua ON e.ID_USUARIO_AUTO=ua.IDUSUARIO "+
            "WHERE e.ID_SUMINISTRO_EGRESO_CAB="+idCab;
        PreparedStatement stCab=cn.prepareStatement(sqlCab); ResultSet rsCab=stCab.executeQuery();
        SimpleDateFormat sdf=new SimpleDateFormat("dd/MM/yyyy");
        if(rsCab.next()){
            fechaSol=rsCab.getDate(1)!=null?sdf.format(rsCab.getDate(1)):"—";
            estadoSol=rsCab.getString(2)!=null?rsCab.getString(2):"";
            depto=rsCab.getString(3)!=null?rsCab.getString(3):"Sin departamento";
            solicitante=rsCab.getString(4)!=null?rsCab.getString(4):"—";
            autorizador=rsCab.getString(5)!=null?rsCab.getString(5):"—";
        }
        rsCab.close(); stCab.close();
        PreparedStatement stC=cn.prepareStatement("SELECT COMPANIA FROM COMPANIA WHERE ESTADO='a' AND ROWNUM=1");
        ResultSet rsC=stC.executeQuery(); if(rsC.next())compania=rsC.getString(1); rsC.close(); stC.close(); cn.close();
    }catch(Exception ex){ex.printStackTrace();}
    if("ENTREGADO".equals(estadoSol)){response.sendRedirect("INV_Lista_Solicitudes_Suministro.jsp?estado=ENTREGADO");return;}
    String msgExito=(String)session.getAttribute("msg_exito"); String msgError=(String)session.getAttribute("msg_error");
    session.removeAttribute("msg_exito"); session.removeAttribute("msg_error");
    boolean todoOk=true; StringBuilder filas=new StringBuilder(); int totalItems=0;
    String sqlDet="SELECT p.ID_PRODUCTO,p.DESCRIPCION,p.UNIDAD,d.CANTIDAD,"+
        "NVL((SELECT ex.EXISTENCIA FROM INV_SUMINISTRO_EXISTENCIA ex WHERE ex.ID_PRODUCTO=p.ID_PRODUCTO AND ROWNUM=1),0) AS STOCK "+
        "FROM INV_SUMINISTRO_EGRESO_DET d JOIN INV_PRODUCTO p ON d.ID_PRODUCTO=p.ID_PRODUCTO "+
        "WHERE d.ID_SUMINISTRO_EGRESO_CAB="+idCab+" ORDER BY p.DESCRIPCION";
    try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn2=DriverManager.getConnection(url,user,pass);
        PreparedStatement st2=cn2.prepareStatement(sqlDet); ResultSet rs2=st2.executeQuery();
        while(rs2.next()){
            totalItems++; int idProd=rs2.getInt(1); String desc=rs2.getString(2);
            String unidad=rs2.getString(3)!=null?rs2.getString(3):""; int cantSol=rs2.getInt(4); int stock=rs2.getInt(5);
            boolean ok=stock>=cantSol; if(!ok)todoOk=false;
            filas.append("<tr><td>").append(desc).append(" <small class='text-muted'>(").append(unidad).append(")</small></td>")
                 .append("<td class='text-center font-weight-bold'>").append(cantSol).append("</td>")
                 .append("<td class='text-center ").append(ok?"stock-ok":"stock-fail").append("'>").append(stock).append("</td>")
                 .append("<td class='text-center'><span class='badge ").append(ok?"badge-success":"badge-danger").append("'>").append(ok?"Suficiente":"Insuficiente").append("</span></td></tr>");
        }
        rs2.close(); st2.close(); cn2.close();
    }catch(Exception ex2){ex2.printStackTrace();todoOk=false;}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>ProMaNet - Despachar Suministros</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        body{background:#f4f6f9;font-family:'Segoe UI',Arial,sans-serif;margin:0;}
        .topbar{background:#3d5a99;color:#fff;padding:10px 20px;display:flex;justify-content:space-between;align-items:center;}
        .topbar .brand{font-size:1.1rem;font-weight:700;}
        .topbar .user-info{font-size:0.85rem;text-align:right;}
        .sidebar{width:220px;min-height:100vh;background:#fff;border-right:1px solid #e0e0e0;position:fixed;top:44px;left:0;}
        .sidebar .nav-link{color:#444;padding:10px 20px;font-size:0.88rem;}
        .sidebar .nav-link:hover,.sidebar .nav-link.active{background:#eef2fb;color:#3d5a99;font-weight:600;}
        .sidebar .nav-section{padding:10px 20px 4px;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;}
        .main-content{margin-left:220px;}
        .page-header{background:linear-gradient(135deg,#3d5a99,#5b7fc4);color:#fff;padding:18px 28px 14px;}
        .page-header .breadcrumb{background:transparent;padding:0;margin:0 0 4px;font-size:.8rem;}
        .page-header .breadcrumb-item a{color:rgba(255,255,255,0.75);} .page-header .breadcrumb-item.active{color:#fff;}
        .page-header h4{margin:0;font-weight:600;} .content-area{padding:24px;}
        .card{border:none;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.08);margin-bottom:20px;}
        .card-header{background:#fff;border-bottom:1px solid #eee;padding:14px 20px;}
        .card-header.azul{background:#3d5a99;color:#fff;border-radius:8px 8px 0 0;}
        .table th{background:#f8f9fb;font-size:.78rem;text-transform:uppercase;color:#666;}
        .table td{vertical-align:middle;font-size:.88rem;}
        .stock-ok{color:#198754;font-weight:600;} .stock-fail{color:#dc3545;font-weight:600;}
        .resumen-item label{font-size:.75rem;color:#999;margin:0;} .resumen-item .valor{font-weight:600;font-size:.95rem;}
        .footer{margin-left:220px;padding:12px 24px;font-size:.78rem;color:#aaa;border-top:1px solid #eee;}
    </style>
</head>
<body>
<div class="topbar"><span class="brand"><i class="fa fa-th-large mr-2"></i>INVENTARIOS</span>
<span class="user-info"><%=compania%><br><strong><%=nombre%> <%=apellidos%></strong></span></div>
<div class="sidebar"><nav class="nav flex-column pt-3">
    <a class="nav-link" href="INV_Dashboard_Suministro.jsp"><i class="fa fa-home mr-2"></i>Dashboard</a>
    <a class="nav-link active" href="INV_Lista_Solicitudes_Suministro.jsp"><i class="fa fa-list mr-2"></i>Lista de solicitudes</a>
    <div class="nav-section">Ingresos</div>
    <a class="nav-link" href="INV_Ingreso_Suministro2.jsp"><i class="fa fa-plus-circle mr-2"></i>Registrar ingreso</a>
    <div class="nav-section">Panel de control</div>
    <a class="nav-link" href="../Proyectos/Perfil.jsp"><i class="fa fa-user mr-2"></i>Perfil</a>
    <a class="nav-link" href="../cerrar.jsp"><i class="fa fa-sign-out mr-2"></i>Cerrar Sesi&oacute;n</a>
</nav></div>
<div class="main-content">
    <div class="page-header">
        <ol class="breadcrumb"><li class="breadcrumb-item"><a href="#">Menu</a></li><li class="breadcrumb-item"><a href="INV_Lista_Solicitudes_Suministro.jsp">Solicitudes</a></li><li class="breadcrumb-item active">Despachar #<%=idCab%></li></ol>
        <h4><i class="fa fa-check-square-o mr-2"></i>Despachar Solicitud #<%=idCab%></h4>
    </div>
    <div class="content-area">
        <% if(msgExito!=null){ %><div class="alert alert-success alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button><i class="fa fa-check-circle mr-1"></i><%=msgExito%></div><% } %>
        <% if(msgError!=null){ %><div class="alert alert-danger alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button><i class="fa fa-exclamation-triangle mr-1"></i><%=msgError%></div><% } %>
        <div class="card">
            <div class="card-header azul"><i class="fa fa-clipboard mr-2"></i><strong>Resumen de la solicitud</strong></div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3 resumen-item"><label>N&deg; Solicitud</label><div class="valor text-primary">#<%=idCab%></div></div>
                    <div class="col-md-3 resumen-item"><label>Fecha solicitud</label><div class="valor"><%=fechaSol%></div></div>
                    <div class="col-md-3 resumen-item"><label>Departamento</label><div class="valor"><%=depto%></div></div>
                    <div class="col-md-3 resumen-item"><label>Solicitante</label><div class="valor"><%=solicitante%></div></div>
                </div>
                <div class="row mt-3">
                    <div class="col-md-3 resumen-item"><label>Autorizado por</label><div class="valor"><%=autorizador%></div></div>
                    <div class="col-md-3 resumen-item"><label>Estado</label><div class="valor"><span style="background:#fff3cd;color:#856404;padding:3px 10px;border-radius:10px;font-size:.8rem;"><i class="fa fa-clock-o mr-1"></i>PENDIENTE</span></div></div>
                </div>
            </div>
        </div>
        <div class="card">
            <div class="card-header"><strong><i class="fa fa-list mr-1"></i>Productos solicitados</strong> <span class="ml-2 badge badge-secondary"><%=totalItems%> &iacute;tems</span></div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead><tr><th class="pl-3">Producto</th><th class="text-center">Cant. solicitada</th><th class="text-center">Stock actual</th><th class="text-center">Disponibilidad</th></tr></thead>
                        <tbody><%=filas.toString()%></tbody>
                    </table>
                </div>
            </div>
        </div>
        <% if(!todoOk){ %>
        <div class="alert alert-warning"><i class="fa fa-exclamation-triangle mr-2"></i><strong>Advertencia:</strong> Uno o m&aacute;s productos no tienen stock suficiente. Marque la casilla para forzar el despacho.</div>
        <% }else{ %>
        <div class="alert alert-success"><i class="fa fa-check-circle mr-2"></i><strong>Stock disponible.</strong> Todos los productos tienen existencia suficiente.</div>
        <% } %>
        <div class="card"><div class="card-body">
            <form action="../INV_Confirmar_Despacho" method="post" onsubmit="return confirmarDespacho()">
                <input type="hidden" name="idCab" value="<%=idCab%>">
                <% if(!todoOk){ %>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="chkForzar" name="forzar" value="true">
                    <label class="form-check-label text-danger" for="chkForzar"><strong>Entiendo que el stock es insuficiente y deseo despachar de todas formas.</strong></label>
                </div>
                <% } %>
                <div class="d-flex">
                    <button type="submit" class="btn btn-success mr-2"><i class="fa fa-check mr-1"></i>Confirmar Despacho</button>
                    <a href="INV_Lista_Solicitudes_Suministro.jsp" class="btn btn-secondary"><i class="fa fa-arrow-left mr-1"></i>Cancelar</a>
                </div>
            </form>
        </div></div>
    </div>
</div>
<footer class="footer">&copy; 2026 Overclocking &mdash; ProMaNet versi&oacute;n 2.0</footer>
<script>
function confirmarDespacho(){
    var chk=document.getElementById('chkForzar');
    if(chk&&!chk.checked){alert('Debe marcar la casilla para confirmar el despacho con stock insuficiente.');return false;}
    return confirm('¿Confirma el despacho? Esta acción descontará el stock.');
}
</script>
</body></html>
