<%--
 Document   : LEG_ControlSeguimiento
 Created on : 22 jul 2026
 Author     : Backup
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<!DOCTYPE html>
<%!
    // Escapa texto libre antes de insertarlo en HTML (evita XSS almacenado).
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
String compania = (String) session.getAttribute("compania");
    String cargo = (String) session.getAttribute("cargo");
    String nombre = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    String codigo = (String) session.getAttribute("cod");
    String usuario = (String) session.getAttribute("usuario");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = new String("" + ip);
    String departamento = (String) session.getAttribute("departamento");

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    } else if (session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp");
        return;
    }
    if (!COMUN.PermisoHelper.tiene(session, "LEGAL_ACCESO")) {
        response.sendRedirect("../sesionInvalida.jsp");
        return;
    }

    String msgExito = (String) session.getAttribute("msg_exito");
    String msgError = (String) session.getAttribute("msg_error");
    session.removeAttribute("msg_exito");
    session.removeAttribute("msg_error");

    boolean verEliminados = "1".equals(request.getParameter("eliminados"));
    boolean verEliminadosExpel = "1".equals(request.getParameter("eliminadosExpel"));

    StringBuilder opcionesDelito = new StringBuilder();
    StringBuilder opcionesMateria = new StringBuilder();
    StringBuilder opcionesTipoAccion = new StringBuilder();
    StringBuilder filasIP = new StringBuilder();
    StringBuilder filasExpel = new StringBuilder();
    int totalIP = 0;
    int totalExpel = 0;

    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection cn = DriverManager.getConnection(url, user, pass);

        // Catalogo de delitos activos: <option> para los selects Select2
        // (con busqueda) de los modales Nueva/Editar IP.
        PreparedStatement stDel = cn.prepareStatement(
                "SELECT ID_DELITO, DESCRIPCION FROM LEGAL_DELITO WHERE ESTADO='A' ORDER BY DESCRIPCION");
        ResultSet rsDel = stDel.executeQuery();
        while (rsDel.next()) {
            opcionesDelito.append("<option value=\"").append(rsDel.getInt(1)).append("\">")
                    .append(esc(rsDel.getString(2))).append("</option>");
        }
        rsDel.close();
        stDel.close();

        // Catalogo de materias activas: mismo formato que Delito, para los
        // selects de los modales Nuevo/Editar EXPEL.
        PreparedStatement stMat = cn.prepareStatement(
                "SELECT ID_MATERIA, DESCRIPCION FROM LEGAL_MATERIA WHERE ESTADO='A' ORDER BY DESCRIPCION");
        ResultSet rsMat = stMat.executeQuery();
        while (rsMat.next()) {
            opcionesMateria.append("<option value=\"").append(rsMat.getInt(1)).append("\">")
                    .append(esc(rsMat.getString(2))).append("</option>");
        }
        rsMat.close();
        stMat.close();

        // Catalogo de tipos de accion activos.
        PreparedStatement stTipo = cn.prepareStatement(
                "SELECT ID_TIPO_ACCION, DESCRIPCION FROM LEGAL_TIPO_ACCION WHERE ESTADO='A' ORDER BY DESCRIPCION");
        ResultSet rsTipo = stTipo.executeQuery();
        while (rsTipo.next()) {
            opcionesTipoAccion.append("<option value=\"").append(rsTipo.getInt(1)).append("\">")
                    .append(esc(rsTipo.getString(2))).append("</option>");
        }
        rsTipo.close();
        stTipo.close();

        // Seguimientos, agrupados en memoria por ID_LEGAL_IP para embeber
        // en cada fila (evita una consulta por fila).
        Map<Integer, StringBuilder> mapaSeg = new HashMap<Integer, StringBuilder>();
        Map<Integer, Integer> conteoSeg = new HashMap<Integer, Integer>();
        PreparedStatement stSeg = cn.prepareStatement(
                "SELECT s.ID_LEGAL_IP, s.DESCRIPCION, TO_CHAR(s.FECHA_CREACION,'DD/MM/YYYY HH24:MI'), " +
                "u.NOMBRE||' '||u.APELLIDOS " +
                "FROM LEGAL_IP_SEGUIMIENTO s JOIN USUARIO u ON s.ID_USUARIO_CREA = u.IDUSUARIO " +
                "ORDER BY s.ID_LEGAL_IP, s.FECHA_CREACION");
        ResultSet rsSeg = stSeg.executeQuery();
        while (rsSeg.next()) {
            int idIp = rsSeg.getInt(1);
            String descSeg = rsSeg.getString(2) != null ? rsSeg.getString(2) : "";
            String fechaSeg = rsSeg.getString(3);
            String userSeg = rsSeg.getString(4) != null ? rsSeg.getString(4) : "";

            String descEsc = descSeg.replace("\\", "\\\\").replace("\"", "\\\"")
                    .replace("\n", " ").replace("\r", "");
            String userEsc = userSeg.replace("\\", "\\\\").replace("\"", "\\\"");

            StringBuilder sb = mapaSeg.get(idIp);
            if (sb == null) {
                sb = new StringBuilder();
                mapaSeg.put(idIp, sb);
            }
            if (sb.length() > 0) sb.append(",");
            sb.append("{\"descripcion\":\"").append(descEsc).append("\",\"fecha\":\"")
              .append(fechaSeg).append("\",\"usuario\":\"").append(userEsc).append("\"}");

            Integer c = conteoSeg.get(idIp);
            conteoSeg.put(idIp, c == null ? 1 : c + 1);
        }
        rsSeg.close();
        stSeg.close();

        // Listado principal de Investigaciones Previas.
        PreparedStatement stIP = cn.prepareStatement(
                "SELECT ip.ID_LEGAL_IP, ip.PROCESADO, ip.VICTIMA, ip.PROCESO, d.DESCRIPCION, " +
                "ip.FISCALIA, ip.UBICACION, u.NOMBRE||' '||u.APELLIDOS, " +
                "TO_CHAR(ip.FECHA_CREACION,'DD/MM/YYYY HH24:MI'), ip.ID_DELITO, ip.ESTADO " +
                "FROM LEGAL_IP ip " +
                "LEFT JOIN LEGAL_DELITO d ON ip.ID_DELITO = d.ID_DELITO " +
                "JOIN USUARIO u ON ip.ID_USUARIO_CREA = u.IDUSUARIO " +
                (verEliminados ? "" : "WHERE ip.ESTADO = 'A' ") +
                "ORDER BY ip.FECHA_CREACION DESC");
        ResultSet rsIP = stIP.executeQuery();
        while (rsIP.next()) {
            totalIP++;
            int idIp = rsIP.getInt(1);
            String procesado = rsIP.getString(2) != null ? rsIP.getString(2) : "";
            String victima = rsIP.getString(3) != null ? rsIP.getString(3) : "";
            String proceso = rsIP.getString(4) != null ? rsIP.getString(4) : "";
            String delito = rsIP.getString(5) != null ? rsIP.getString(5) : "—";
            String fiscalia = rsIP.getString(6) != null ? rsIP.getString(6) : "";
            String ubicacion = rsIP.getString(7) != null ? rsIP.getString(7) : "";
            String idDelitoRaw = rsIP.getString(10) != null ? rsIP.getString(10) : "";
            boolean eliminado = "I".equals(rsIP.getString(11));

            StringBuilder segSb = mapaSeg.get(idIp);
            String segJson = "[" + (segSb != null ? segSb.toString() : "") + "]";
            String segAttr = segJson.replace("\"", "&quot;");
            Integer cantSegObj = conteoSeg.get(idIp);
            int cantSeg = cantSegObj != null ? cantSegObj : 0;

            String buscaIdx = (procesado + " " + victima + " " + delito).toLowerCase().replace("'", "");

            String procesadoAttr = esc(procesado).replace("'", "&#39;");
            String victimaAttr = esc(victima).replace("'", "&#39;");
            String procesoAttr = esc(proceso).replace("'", "&#39;");
            String fiscaliaAttr = esc(fiscalia).replace("'", "&#39;");
            String ubicacionAttr = esc(ubicacion).replace("'", "&#39;");

            filasIP.append("<tr data-desc='").append(buscaIdx).append("'>")
                    .append("<td>").append(esc(procesado))
                    .append(eliminado ? " <span class='badge' style='background:#dc3545;color:#fff;'>ELIMINADO</span>" : "")
                    .append("</td>")
                    .append("<td>").append(esc(victima)).append("</td>")
                    .append("<td>").append(esc(proceso)).append("</td>")
                    .append("<td><span class='badge' style='background:#17a2b8;color:#fff;'>").append(esc(delito)).append("</span></td>")
                    .append("<td>").append(esc(fiscalia)).append("</td>")
                    .append("<td>").append(esc(ubicacion)).append("</td>")
                    .append("<td class='text-center'>")
                    .append("<div class='d-flex justify-content-center align-items-center' style='gap:4px;'>")
                    .append("<button type='button' class='btn btn-sm btn-outline-info btn-ver-seg' style='padding:3px 8px;' ")
                    .append("data-id='").append(idIp).append("' data-seg=\"").append(segAttr).append("\">")
                    .append("<i class='fa fa-list-ul'></i> ").append(cantSeg).append("</button>")
                    .append("<button type='button' class='btn btn-sm btn-outline-primary btn-editar-ip' style='padding:3px 8px;' ")
                    .append("data-id='").append(idIp).append("' ")
                    .append("data-procesado='").append(procesadoAttr).append("' ")
                    .append("data-victima='").append(victimaAttr).append("' ")
                    .append("data-proceso='").append(procesoAttr).append("' ")
                    .append("data-iddelito='").append(idDelitoRaw).append("' ")
                    .append("data-fiscalia='").append(fiscaliaAttr).append("' ")
                    .append("data-ubicacion='").append(ubicacionAttr).append("'>")
                    .append("<i class='fa fa-pencil'></i></button>")
                    .append(eliminado
                        ? "<button type='button' class='btn btn-sm btn-outline-success' style='padding:3px 8px;' onclick=\"cambiarEstadoIP(" + idIp + ",'restaurar')\"><i class='fa fa-undo'></i></button>"
                        : "<button type='button' class='btn btn-sm btn-outline-danger' style='padding:3px 8px;' onclick=\"cambiarEstadoIP(" + idIp + ",'eliminar')\"><i class='fa fa-trash'></i></button>")
                    .append("</div></td></tr>\n");
        }
        rsIP.close();
        stIP.close();

        // Seguimientos de EXPEL, agrupados en memoria por ID_LEGAL_EXPEL.
        Map<Integer, StringBuilder> mapaSegExpel = new HashMap<Integer, StringBuilder>();
        Map<Integer, Integer> conteoSegExpel = new HashMap<Integer, Integer>();
        PreparedStatement stSegExpel = cn.prepareStatement(
                "SELECT s.ID_LEGAL_EXPEL, s.DESCRIPCION, TO_CHAR(s.FECHA_CREACION,'DD/MM/YYYY HH24:MI'), " +
                "u.NOMBRE||' '||u.APELLIDOS " +
                "FROM LEGAL_EXPEL_SEGUIMIENTO s JOIN USUARIO u ON s.ID_USUARIO_CREA = u.IDUSUARIO " +
                "ORDER BY s.ID_LEGAL_EXPEL, s.FECHA_CREACION");
        ResultSet rsSegExpel = stSegExpel.executeQuery();
        while (rsSegExpel.next()) {
            int idExpel = rsSegExpel.getInt(1);
            String descSeg = rsSegExpel.getString(2) != null ? rsSegExpel.getString(2) : "";
            String fechaSeg = rsSegExpel.getString(3);
            String userSeg = rsSegExpel.getString(4) != null ? rsSegExpel.getString(4) : "";

            String descEsc = descSeg.replace("\\", "\\\\").replace("\"", "\\\"")
                    .replace("\n", " ").replace("\r", "");
            String userEsc = userSeg.replace("\\", "\\\\").replace("\"", "\\\"");

            StringBuilder sb = mapaSegExpel.get(idExpel);
            if (sb == null) {
                sb = new StringBuilder();
                mapaSegExpel.put(idExpel, sb);
            }
            if (sb.length() > 0) sb.append(",");
            sb.append("{\"descripcion\":\"").append(descEsc).append("\",\"fecha\":\"")
              .append(fechaSeg).append("\",\"usuario\":\"").append(userEsc).append("\"}");

            Integer c = conteoSegExpel.get(idExpel);
            conteoSegExpel.put(idExpel, c == null ? 1 : c + 1);
        }
        rsSegExpel.close();
        stSegExpel.close();

        // Listado principal de EXPEL.
        PreparedStatement stExpel = cn.prepareStatement(
                "SELECT ex.ID_LEGAL_EXPEL, ex.ACTOR, ex.DEMANDADO, ex.JUICIO, m.DESCRIPCION, " +
                "ta.DESCRIPCION, ex.ASUNTO, ex.LUGAR, ex.ID_MATERIA, ex.ID_TIPO_ACCION, ex.ESTADO " +
                "FROM LEGAL_EXPEL ex " +
                "LEFT JOIN LEGAL_MATERIA m ON ex.ID_MATERIA = m.ID_MATERIA " +
                "LEFT JOIN LEGAL_TIPO_ACCION ta ON ex.ID_TIPO_ACCION = ta.ID_TIPO_ACCION " +
                (verEliminadosExpel ? "" : "WHERE ex.ESTADO = 'A' ") +
                "ORDER BY ex.FECHA_CREACION DESC");
        ResultSet rsExpel = stExpel.executeQuery();
        while (rsExpel.next()) {
            totalExpel++;
            int idExpel = rsExpel.getInt(1);
            String actor = rsExpel.getString(2) != null ? rsExpel.getString(2) : "";
            String demandado = rsExpel.getString(3) != null ? rsExpel.getString(3) : "";
            String juicio = rsExpel.getString(4) != null ? rsExpel.getString(4) : "";
            String materia = rsExpel.getString(5) != null ? rsExpel.getString(5) : "—";
            String tipoAccion = rsExpel.getString(6) != null ? rsExpel.getString(6) : "—";
            String asunto = rsExpel.getString(7) != null ? rsExpel.getString(7) : "";
            String lugar = rsExpel.getString(8) != null ? rsExpel.getString(8) : "";
            String idMateriaRaw = rsExpel.getString(9) != null ? rsExpel.getString(9) : "";
            String idTipoAccionRaw = rsExpel.getString(10) != null ? rsExpel.getString(10) : "";
            boolean eliminadoExpel = "I".equals(rsExpel.getString(11));

            StringBuilder segSbExpel = mapaSegExpel.get(idExpel);
            String segJsonExpel = "[" + (segSbExpel != null ? segSbExpel.toString() : "") + "]";
            String segAttrExpel = segJsonExpel.replace("\"", "&quot;");
            Integer cantSegExpelObj = conteoSegExpel.get(idExpel);
            int cantSegExpel = cantSegExpelObj != null ? cantSegExpelObj : 0;

            String buscaIdxExpel = (actor + " " + demandado + " " + juicio + " " + materia)
                    .toLowerCase().replace("'", "");

            String actorAttr = esc(actor).replace("'", "&#39;");
            String demandadoAttr = esc(demandado).replace("'", "&#39;");
            String juicioAttr = esc(juicio).replace("'", "&#39;");
            String asuntoAttr = esc(asunto).replace("'", "&#39;");
            String lugarAttr = esc(lugar).replace("'", "&#39;");

            filasExpel.append("<tr data-desc='").append(buscaIdxExpel).append("'>")
                    .append("<td>").append(esc(actor))
                    .append(eliminadoExpel ? " <span class='badge' style='background:#dc3545;color:#fff;'>ELIMINADO</span>" : "")
                    .append("</td>")
                    .append("<td>").append(esc(demandado)).append("</td>")
                    .append("<td>").append(esc(juicio)).append("</td>")
                    .append("<td><span class='badge' style='background:#17a2b8;color:#fff;'>").append(esc(materia)).append("</span></td>")
                    .append("<td>").append(esc(tipoAccion)).append("</td>")
                    .append("<td>").append(esc(asunto)).append("</td>")
                    .append("<td>").append(esc(lugar)).append("</td>")
                    .append("<td class='text-center'>")
                    .append("<div class='d-flex justify-content-center align-items-center' style='gap:4px;'>")
                    .append("<button type='button' class='btn btn-sm btn-outline-info btn-ver-seg-expel' style='padding:3px 8px;' ")
                    .append("data-id='").append(idExpel).append("' data-seg=\"").append(segAttrExpel).append("\">")
                    .append("<i class='fa fa-list-ul'></i> ").append(cantSegExpel).append("</button>")
                    .append("<button type='button' class='btn btn-sm btn-outline-primary btn-editar-expel' style='padding:3px 8px;' ")
                    .append("data-id='").append(idExpel).append("' ")
                    .append("data-actor='").append(actorAttr).append("' ")
                    .append("data-demandado='").append(demandadoAttr).append("' ")
                    .append("data-juicio='").append(juicioAttr).append("' ")
                    .append("data-idmateria='").append(idMateriaRaw).append("' ")
                    .append("data-idtipoaccion='").append(idTipoAccionRaw).append("' ")
                    .append("data-asunto='").append(asuntoAttr).append("' ")
                    .append("data-lugar='").append(lugarAttr).append("'>")
                    .append("<i class='fa fa-pencil'></i></button>")
                    .append(eliminadoExpel
                        ? "<button type='button' class='btn btn-sm btn-outline-success' style='padding:3px 8px;' onclick=\"cambiarEstadoExpel(" + idExpel + ",'restaurar')\"><i class='fa fa-undo'></i></button>"
                        : "<button type='button' class='btn btn-sm btn-outline-danger' style='padding:3px 8px;' onclick=\"cambiarEstadoExpel(" + idExpel + ",'eliminar')\"><i class='fa fa-trash'></i></button>")
                    .append("</div></td></tr>\n");
        }
        rsExpel.close();
        stExpel.close();

        cn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="apple-touch-icon" sizes="76x76" href="../assets/img/apple-icon.png">
        <link rel="icon" type="image/png" href="../assets/img/favicon.png">
        <title>ProMaNet | Control y Seguimiento Legal</title>
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
        <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
        <link href="../assets/css/nucleo-svg.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet" />
        <link rel="stylesheet" href="../assets/css/custom-sidenav-toggle.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
    </head>
    <body class="g-sidenav-show   bg-gray-100">
        <div class="min-height-300 bg-primary position-absolute w-100"></div>
        <aside class="sidenav bg-white navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-4 " id="sidenav-main">
            <div class="sidenav-header">
                <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
                <a class="navbar-brand m-0" href=" #" target="_blank">
                    <img src="../assets/img/promanetlogo.png" class="navbar-brand-img h-100" alt="main_logo">
                    <span class="ms-1 font-weight-bold">ProMaNet </span>
                </a>
            </div>
            <hr class="horizontal dark mt-0">
            <div class="collapse navbar-collapse  w-auto " id="sidenav-collapse-main">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/PRO_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="../Legal/LEG_Dashboard.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-paper-diploma text-info text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Legal</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../Legal/LEG_ControlSeguimiento.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-collection text-warning text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Control y Seguimiento</span>
                        </a>
                    </li>

                    <li class="nav-item mt-3">
                        <h6 class="ps-4 ms-2 text-uppercase text-xs font-weight-bolder opacity-6">Panel de control</h6>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link " href="../Proyectos/Perfil.jsp">
                            <div class="icon icon-shape icon-sm border-radius-md text-center me-2 d-flex align-items-center justify-content-center">
                                <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
                            </div>
                            <span class="nav-link-text ms-1">Perfil</span>
                        </a>
                    </li>
                </ul>
            </div>
            <div class="sidenav-footer mx-3 ">
                <div class="card card-plain shadow-none" id="sidenavCard">
                    <img class="w-50 mx-auto" src="../assets/img/illustrations/icon-documentation.svg" alt="sidebar_illustration">
                    <div class="card-body text-center p-3 w-100 pt-0">
                        <div class="docs-info">
                            <h6 class="mb-0">Necesitas ayuda?</h6>
                            <p class="text-xs font-weight-bold mb-0">Visita nuestro Tutorial</p>
                        </div>
                    </div>
                </div>
                <a href="../cerrar.jsp"  class="btn btn-dark btn-sm w-100 mb-3">Cerrar Sesión</a>
            </div>
        </aside>
        <main class="main-content position-relative border-radius-lg ">
            <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl " id="navbarBlur" data-scroll="false">
                <div class="container-fluid py-1 px-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                            <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Legal/LEG_Dashboard.jsp">Legal</a></li>
                            <li class="breadcrumb-item text-sm text-white active" aria-current="page">Control y Seguimiento</li>
                        </ol>
                        <h6 class="font-weight-bolder text-white mb-0">Control y Seguimiento</h6>
                    </nav>
                    <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4" id="navbar">
                        <div class="ms-md-auto pe-md-3 d-flex align-items-center">
                            <div class="input-group">
                                <span class=" text-body text-white-50"><i class="fa fa-home" ></i> <%=compania%></span>
                            </div>
                        </div>
                        <ul class="navbar-nav  justify-content-end">
                            <li class="nav-item d-flex align-items-center">
                                <a href="../Proyectos/Perfil.jsp" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-user me-sm-1"></i>
                                    <span class="d-sm-inline d-none"><b> <%=nombre%> <%=apellidos%> </b></span>
                                </a>
                            </li>
                            <li class="nav-item ps-3 d-flex align-items-center">
                                <a href="javascript:;" class="nav-link text-white p-0" id="iconNavbarSidenav">
                                    <div class="sidenav-toggler-inner">
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                        <i class="sidenav-toggler-line bg-white"></i>
                                    </div>
                                </a>
                            </li>
                            <li class="nav-item ps-3 d-flex align-items-center">
                                <a href="../cerrar.jsp" class="nav-link text-white font-weight-bold px-0">
                                    <i class="fa fa-power-off me-sm-1"></i>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="container-fluid py-4">

                <% if (msgExito != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%=msgExito%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>
                <% if (msgError != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%=msgError%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>

                <%-- Tarjeta boton: Investigacion Previa --%>
                <div class="row">
                    <div class="col-xl-3 col-sm-6 mb-4">
                        <div class="card" style="cursor:pointer;" onclick="modalNuevaIP.show()">
                            <div class="card-body p-3">
                                <div class="row">
                                    <div class="col-8">
                                        <div class="numbers">
                                            <p class="text-sm mb-0 text-uppercase font-weight-bold">Registrar</p>
                                            <h5 class="font-weight-bolder">
                                                INVESTIGACION PREVIA
                                            </h5>
                                            <p class="mb-0">
                                                <span class="text-info text-sm font-weight-bolder">Nuevo</span>
                                                <b class="text-info"> registro de IP.</b>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="col-4 text-end">
                                        <div class="icon icon-shape bg-gradient-info shadow-info text-center rounded-circle">
                                            <i class="ni ni-single-copy-04 text-lg opacity-10" aria-hidden="true"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6 mb-4">
                        <div class="card" style="cursor:pointer;" onclick="modalNuevoExpel.show()">
                            <div class="card-body p-3">
                                <div class="row">
                                    <div class="col-8">
                                        <div class="numbers">
                                            <p class="text-sm mb-0 text-uppercase font-weight-bold">Registrar</p>
                                            <h5 class="font-weight-bolder">
                                                EXPEL
                                            </h5>
                                            <p class="mb-0">
                                                <span class="text-warning text-sm font-weight-bolder">Nuevo</span>
                                                <b class="text-warning"> registro de EXPEL.</b>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="col-4 text-end">
                                        <div class="icon icon-shape bg-gradient-warning shadow-warning text-center rounded-circle">
                                            <i class="ni ni-badge text-lg opacity-10" aria-hidden="true"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Tabla de Investigaciones Previas --%>
                <div class="card">
                    <div class="card-header d-flex flex-column flex-md-row justify-content-between align-items-md-center">
                        <span class="mb-2 mb-md-0"><i class="fa fa-table mr-2 text-secondary"></i>Investigaciones Previas
                            <span class="badge ml-2" style="background:#6c757d;color:#fff;"><%=totalIP%> registros</span>
                        </span>
                        <div class="d-flex flex-column flex-sm-row align-items-stretch align-items-sm-center">
                            <a href="LEG_ControlSeguimiento.jsp<%= verEliminados ? "" : "?eliminados=1" %>"
                               class="btn btn-sm <%= verEliminados ? "btn-secondary" : "btn-outline-secondary" %> mb-2 mb-sm-0 mr-sm-2 text-center"
                               style="white-space:nowrap;">
                                <i class="fa fa-eye<%= verEliminados ? "-slash" : "" %> mr-1"></i><%= verEliminados ? "Ocultar eliminados" : "Ver eliminados" %>
                            </a>
                            <input type="text" id="buscarIP" class="form-control form-control-sm"
                                   placeholder="Buscar..." style="width:100%;max-width:220px;">
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0" id="tablaIP">
                                <thead>
                                    <tr>
                                        <th>Procesado</th>
                                        <th>Victima</th>
                                        <th>Proceso</th>
                                        <th>Delito</th>
                                        <th>Fiscalia</th>
                                        <th>Ubicacion</th>
                                        <th class="text-center" style="width:110px;">Seguimiento IP</th>
                                    </tr>
                                </thead>
                                <tbody>
<%=filasIP.length() > 0 ? filasIP.toString() : "<tr><td colspan='7' class='text-center text-muted py-4'><i class='fa fa-inbox fa-2x d-block mb-2'></i>No hay investigaciones previas registradas.</td></tr>"%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <%-- Tabla de EXPEL --%>
                <div class="card">
                    <div class="card-header d-flex flex-column flex-md-row justify-content-between align-items-md-center">
                        <span class="mb-2 mb-md-0"><i class="fa fa-table mr-2 text-secondary"></i>EXPEL
                            <span class="badge ml-2" style="background:#6c757d;color:#fff;"><%=totalExpel%> registros</span>
                        </span>
                        <div class="d-flex flex-column flex-sm-row align-items-stretch align-items-sm-center">
                            <a href="LEG_ControlSeguimiento.jsp<%= verEliminadosExpel ? "" : "?eliminadosExpel=1" %>"
                               class="btn btn-sm <%= verEliminadosExpel ? "btn-secondary" : "btn-outline-secondary" %> mb-2 mb-sm-0 mr-sm-2 text-center"
                               style="white-space:nowrap;">
                                <i class="fa fa-eye<%= verEliminadosExpel ? "-slash" : "" %> mr-1"></i><%= verEliminadosExpel ? "Ocultar eliminados" : "Ver eliminados" %>
                            </a>
                            <input type="text" id="buscarExpel" class="form-control form-control-sm"
                                   placeholder="Buscar..." style="width:100%;max-width:220px;">
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0" id="tablaExpel">
                                <thead>
                                    <tr>
                                        <th>Actor</th>
                                        <th>Demandado</th>
                                        <th>Juicio</th>
                                        <th>Materia</th>
                                        <th>Tipo de Accion</th>
                                        <th>Asunto</th>
                                        <th>Lugar</th>
                                        <th class="text-center" style="width:110px;">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
<%=filasExpel.length() > 0 ? filasExpel.toString() : "<tr><td colspan='8' class='text-center text-muted py-4'><i class='fa fa-inbox fa-2x d-block mb-2'></i>No hay registros de EXPEL.</td></tr>"%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>

            <footer class="footer pt-3  ">
                <div class="container-fluid">
                    <div class="row align-items-center justify-content-lg-between">
                        <div class="col-lg-6 mb-lg-0 mb-4">
                            <div class="copyright text-center text-sm text-muted text-lg-start">
                                © <script>document.write(new Date().getFullYear())</script>,
                                Creado  <i class="fa fa-clock"></i> por
                                <a href="https://www.overclocking.com.ec" class="font-weight-bold" target="_blank">Overclocking</a>
                                for a better web.
                            </div>
                        </div>
                    </div>
                </div>
            </footer>
        </main>

        <%-- Modal: Nueva Investigacion Previa --%>
        <div class="modal fade" id="modalNuevaIP" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="../LEG_InsertarIP" method="post">
                        <div class="modal-header" style="background:#17a2b8;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-search mr-2"></i>Investigacion Previa</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group mb-2">
                                <label>Procesado</label>
                                <input type="text" name="procesado" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Victima</label>
                                <input type="text" name="victima" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Proceso</label>
                                <input type="text" name="proceso" class="form-control" maxlength="500" placeholder="No. de proceso / expediente">
                            </div>
                            <div class="form-group mb-2">
                                <label>Delito</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idDelito" id="selDelito" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesDelito.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selDelito" title="Nuevo delito"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Fiscalia</label>
                                <input type="text" name="fiscalia" class="form-control" maxlength="300">
                            </div>
                            <div class="form-group mb-0">
                                <label>Ubicacion</label>
                                <input type="text" name="ubicacion" class="form-control" maxlength="150">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-info btn-sm text-white"><i class="fa fa-save mr-1"></i>Guardar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Nuevo valor de catalogo (Delito / Materia / Tipo de Accion), quick-add via AJAX --%>
        <div class="modal fade" id="modalNuevoCatalogo" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#6c757d;">
                        <h5 class="modal-title" style="color:#fff;" id="modalNuevoCatalogoTitulo"><i class="fa fa-gavel mr-2"></i>Nuevo Delito</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group mb-0">
                            <label id="modalNuevoCatalogoLabel">Nombre del delito</label>
                            <input type="text" id="nuevoCatalogoDesc" class="form-control" maxlength="200">
                            <small id="nuevoCatalogoMsg" class="text-danger"></small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-dark btn-sm" id="btnGuardarCatalogo"><i class="fa fa-save mr-1"></i>Guardar</button>
                    </div>
                </div>
            </div>
        </div>

        <%-- Modal: Seguimiento IP --%>
        <div class="modal fade" id="modalSeguimiento" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#3d5a99;">
                        <h5 class="modal-title" style="color:#fff;"><i class="fa fa-list-ul mr-2"></i>Seguimiento IP</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                    </div>
                    <div class="modal-body">
                        <div id="listaSeguimientos" style="max-height:260px;overflow-y:auto;" class="mb-3"></div>
                        <form action="../LEG_InsertarSeguimiento" method="post">
                            <input type="hidden" name="idLegalIp" id="segIdLegalIp">
                            <div class="form-group mb-2">
                                <label>Nuevo seguimiento</label>
                                <textarea name="descripcion" class="form-control" rows="3" required maxlength="1000"></textarea>
                            </div>
                            <div class="modal-footer px-0 pb-0">
                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                                <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-plus mr-1"></i>Agregar seguimiento</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <%-- Modal: Editar Investigacion Previa --%>
        <div class="modal fade" id="modalEditarIP" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="../LEG_ActualizarIP" method="post">
                        <input type="hidden" name="idLegalIp" id="editIdLegalIp">
                        <div class="modal-header" style="background:#3d5a99;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-pencil mr-2"></i>Editar Investigacion Previa</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group mb-2">
                                <label>Procesado</label>
                                <input type="text" name="procesado" id="editProcesado" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Victima</label>
                                <input type="text" name="victima" id="editVictima" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Proceso</label>
                                <input type="text" name="proceso" id="editProceso" class="form-control" maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Delito</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idDelito" id="selDelitoEdit" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesDelito.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selDelitoEdit" title="Nuevo delito"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Fiscalia</label>
                                <input type="text" name="fiscalia" id="editFiscalia" class="form-control" maxlength="300">
                            </div>
                            <div class="form-group mb-0">
                                <label>Ubicacion</label>
                                <input type="text" name="ubicacion" id="editUbicacion" class="form-control" maxlength="150">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-save mr-1"></i>Guardar cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <form id="formEstadoIP" method="post" action="../LEG_ActualizarIP" style="display:none;">
            <input type="hidden" name="accion" id="ipAccion">
            <input type="hidden" name="idLegalIp" id="ipAccionId">
        </form>

        <%-- Modal: Nuevo EXPEL --%>
        <div class="modal fade" id="modalNuevoExpel" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="../LEG_InsertarExpel" method="post">
                        <div class="modal-header" style="background:#e6a03d;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-balance-scale mr-2"></i>EXPEL</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group mb-2">
                                <label>Actor</label>
                                <input type="text" name="actor" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Demandado</label>
                                <input type="text" name="demandado" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Juicio</label>
                                <input type="text" name="juicio" class="form-control" maxlength="100" placeholder="No. de juicio">
                            </div>
                            <div class="form-group mb-2">
                                <label>Materia</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idMateria" id="selMateria" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesMateria.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selMateria" title="Nueva materia"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Tipo de Accion</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idTipoAccion" id="selTipoAccion" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesTipoAccion.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selTipoAccion" title="Nuevo tipo de accion"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Asunto</label>
                                <textarea name="asunto" class="form-control" rows="2" maxlength="1000"></textarea>
                            </div>
                            <div class="form-group mb-0">
                                <label>Lugar</label>
                                <input type="text" name="lugar" class="form-control" maxlength="300">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-warning btn-sm text-white"><i class="fa fa-save mr-1"></i>Guardar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Editar EXPEL --%>
        <div class="modal fade" id="modalEditarExpel" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="../LEG_ActualizarExpel" method="post">
                        <input type="hidden" name="idLegalExpel" id="editIdLegalExpel">
                        <div class="modal-header" style="background:#3d5a99;">
                            <h5 class="modal-title" style="color:#fff;"><i class="fa fa-pencil mr-2"></i>Editar EXPEL</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group mb-2">
                                <label>Actor</label>
                                <input type="text" name="actor" id="editActor" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Demandado</label>
                                <input type="text" name="demandado" id="editDemandado" class="form-control" required maxlength="500">
                            </div>
                            <div class="form-group mb-2">
                                <label>Juicio</label>
                                <input type="text" name="juicio" id="editJuicio" class="form-control" maxlength="100">
                            </div>
                            <div class="form-group mb-2">
                                <label>Materia</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idMateria" id="selMateriaEdit" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesMateria.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selMateriaEdit" title="Nueva materia"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Tipo de Accion</label>
                                <div class="d-flex align-items-start" style="gap:6px;">
                                    <div class="flex-grow-1">
                                        <select name="idTipoAccion" id="selTipoAccionEdit" class="form-control select2-modal">
                                            <option value=""></option>
<%=opcionesTipoAccion.toString()%>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-outline-secondary flex-shrink-0 btn-nuevo-catalogo" data-target="selTipoAccionEdit" title="Nuevo tipo de accion"><i class="fa fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="form-group mb-2">
                                <label>Asunto</label>
                                <textarea name="asunto" id="editAsunto" class="form-control" rows="2" maxlength="1000"></textarea>
                            </div>
                            <div class="form-group mb-0">
                                <label>Lugar</label>
                                <input type="text" name="lugar" id="editLugar" class="form-control" maxlength="300">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-save mr-1"></i>Guardar cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal: Seguimiento EXPEL --%>
        <div class="modal fade" id="modalSeguimientoExpel" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header" style="background:#3d5a99;">
                        <h5 class="modal-title" style="color:#fff;"><i class="fa fa-list-ul mr-2"></i>Seguimiento EXPEL</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter:invert(1) brightness(2);"></button>
                    </div>
                    <div class="modal-body">
                        <div id="listaSeguimientosExpel" style="max-height:260px;overflow-y:auto;" class="mb-3"></div>
                        <form action="../LEG_InsertarSeguimientoExpel" method="post">
                            <input type="hidden" name="idLegalExpel" id="segIdLegalExpel">
                            <div class="form-group mb-2">
                                <label>Nuevo seguimiento</label>
                                <textarea name="descripcion" class="form-control" rows="3" required maxlength="1000"></textarea>
                            </div>
                            <div class="modal-footer px-0 pb-0">
                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                                <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-plus mr-1"></i>Agregar seguimiento</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <form id="formEstadoExpel" method="post" action="../LEG_ActualizarExpel" style="display:none;">
            <input type="hidden" name="accion" id="expelAccion">
            <input type="hidden" name="idLegalExpel" id="expelAccionId">
        </form>

        <script src="../assets/js/core/popper.min.js"></script>
        <script src="../assets/js/core/bootstrap.min.js"></script>
        <script src="../assets/js/plugins/perfect-scrollbar.min.js"></script>
        <script src="../assets/js/plugins/smooth-scrollbar.min.js"></script>
        <script src="../assets/js/argon-dashboard.min.js?v=2.0.4"></script>
        <script src="../assets/js/custom-sidenav-toggle.js"></script>
        <script>
            var ctx = '<%=request.getContextPath()%>';

            function escapeHtml(s) {
                return String(s == null ? '' : s)
                    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }

            var modalNuevaIP = new bootstrap.Modal(document.getElementById('modalNuevaIP'));
            var modalNuevoCatalogo = new bootstrap.Modal(document.getElementById('modalNuevoCatalogo'));
            var modalSeguimiento = new bootstrap.Modal(document.getElementById('modalSeguimiento'));
            var modalEditarIP = new bootstrap.Modal(document.getElementById('modalEditarIP'));
            var modalNuevoExpel = new bootstrap.Modal(document.getElementById('modalNuevoExpel'));
            var modalEditarExpel = new bootstrap.Modal(document.getElementById('modalEditarExpel'));
            var modalSeguimientoExpel = new bootstrap.Modal(document.getElementById('modalSeguimientoExpel'));
            var modales = {
                modalNuevaIP: modalNuevaIP,
                modalEditarIP: modalEditarIP,
                modalNuevoExpel: modalNuevoExpel,
                modalEditarExpel: modalEditarExpel
            };

            // Bootstrap 5 no soporta bien modales apilados (uno sobre otro):
            // el modal de alta rapida de catalogo se abre reemplazando
            // temporalmente al modal de origen (Nueva/Editar IP o EXPEL), y
            // al cerrarse vuelve a mostrar ese modal de origen (los campos
            // no se pierden, solo se oculta/muestra el mismo formulario).
            var origenModalCatalogo = null;
            document.getElementById('modalNuevoCatalogo').addEventListener('hidden.bs.modal', function () {
                if (origenModalCatalogo) {
                    origenModalCatalogo.show();
                    origenModalCatalogo = null;
                }
            });

            var buscarIP = document.getElementById('buscarIP');
            if (buscarIP) {
                buscarIP.addEventListener('input', function () {
                    var q = this.value.toLowerCase().trim();
                    document.querySelectorAll('#tablaIP tbody tr').forEach(function (tr) {
                        var d = tr.getAttribute('data-desc') || '';
                        tr.style.display = (!q || d.indexOf(q) !== -1) ? '' : 'none';
                    });
                });
            }

            var buscarExpel = document.getElementById('buscarExpel');
            if (buscarExpel) {
                buscarExpel.addEventListener('input', function () {
                    var q = this.value.toLowerCase().trim();
                    document.querySelectorAll('#tablaExpel tbody tr').forEach(function (tr) {
                        var d = tr.getAttribute('data-desc') || '';
                        tr.style.display = (!q || d.indexOf(q) !== -1) ? '' : 'none';
                    });
                });
            }

            // --- Catalogos (Delito, Materia, Tipo de Accion): select con
            // busqueda rapida (Select2, igual que en Solicitar Movilizacion)
            // y alta rapida via AJAX, con la misma logica para los tres,
            // reutilizables en los modales de Nueva/Editar IP y EXPEL. ---
            document.querySelectorAll('.modal').forEach(function (modalEl) {
                var $modal = $(modalEl);
                var $selects = $modal.find('.select2-modal');
                if ($selects.length) {
                    $selects.select2({theme: 'bootstrap-5', width: '100%', dropdownParent: $modal, allowClear: true, placeholder: ''});
                }
            });

            var catalogosConfig = {
                'delito': {
                    endpoint: 'LEG_InsertarDelito',
                    titulo: '<i class="fa fa-gavel mr-2"></i>Nuevo Delito',
                    label: 'Nombre del delito',
                    selects: ['selDelito', 'selDelitoEdit']
                },
                'materia': {
                    endpoint: 'LEG_InsertarMateria',
                    titulo: '<i class="fa fa-gavel mr-2"></i>Nueva Materia',
                    label: 'Nombre de la materia',
                    selects: ['selMateria', 'selMateriaEdit']
                },
                'tipoAccion': {
                    endpoint: 'LEG_InsertarTipoAccion',
                    titulo: '<i class="fa fa-gavel mr-2"></i>Nuevo Tipo de Accion',
                    label: 'Nombre del tipo de accion',
                    selects: ['selTipoAccion', 'selTipoAccionEdit']
                }
            };

            // Mapea el id de cada <select> con su catalogo y el modal al
            // que pertenece.
            var camposCatalogo = {
                'selDelito': {catalogo: 'delito', modal: 'modalNuevaIP'},
                'selDelitoEdit': {catalogo: 'delito', modal: 'modalEditarIP'},
                'selMateria': {catalogo: 'materia', modal: 'modalNuevoExpel'},
                'selMateriaEdit': {catalogo: 'materia', modal: 'modalEditarExpel'},
                'selTipoAccion': {catalogo: 'tipoAccion', modal: 'modalNuevoExpel'},
                'selTipoAccionEdit': {catalogo: 'tipoAccion', modal: 'modalEditarExpel'}
            };

            function fijarCatalogoSeleccionado(selectId, idValor) {
                $('#' + selectId).val(idValor || '').trigger('change');
            }

            var catalogoActivo = null;
            document.querySelectorAll('.btn-nuevo-catalogo').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    catalogoActivo = this.getAttribute('data-target');
                    var campos = camposCatalogo[catalogoActivo];
                    var cfg = catalogosConfig[campos.catalogo];
                    origenModalCatalogo = modales[campos.modal];
                    document.getElementById('modalNuevoCatalogoTitulo').innerHTML = cfg.titulo;
                    document.getElementById('modalNuevoCatalogoLabel').textContent = cfg.label;
                    document.getElementById('nuevoCatalogoDesc').value = '';
                    document.getElementById('nuevoCatalogoMsg').textContent = '';
                    origenModalCatalogo.hide();
                    modalNuevoCatalogo.show();
                });
            });

            document.getElementById('btnGuardarCatalogo').addEventListener('click', function () {
                var campos = camposCatalogo[catalogoActivo];
                var cfg = catalogosConfig[campos.catalogo];
                var desc = document.getElementById('nuevoCatalogoDesc').value.trim();
                var msgEl = document.getElementById('nuevoCatalogoMsg');
                if (!desc) {
                    msgEl.textContent = 'Escriba el nombre.';
                    return;
                }
                var fd = new FormData();
                fd.append('descripcion', desc);
                fetch(ctx + '/' + cfg.endpoint, {method: 'POST', body: fd})
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (!data.ok) {
                            msgEl.textContent = data.mensaje || 'No se pudo guardar.';
                            return;
                        }
                        // agrega la nueva opcion a los selects de este catalogo
                        // (Crear y Editar) que aun no la tengan.
                        cfg.selects.forEach(function (selId) {
                            var $sel = $('#' + selId);
                            if ($sel.find('option[value="' + data.id + '"]').length === 0) {
                                $sel.append(new Option(data.descripcion, data.id, false, false));
                            }
                        });
                        fijarCatalogoSeleccionado(catalogoActivo, data.id);
                        modalNuevoCatalogo.hide();
                    })
                    .catch(function () {
                        msgEl.textContent = 'Error de conexion.';
                    });
            });

            // --- Editar Investigacion Previa ---
            document.querySelectorAll('.btn-editar-ip').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    document.getElementById('editIdLegalIp').value = this.getAttribute('data-id');
                    document.getElementById('editProcesado').value = this.getAttribute('data-procesado');
                    document.getElementById('editVictima').value = this.getAttribute('data-victima');
                    document.getElementById('editProceso').value = this.getAttribute('data-proceso');
                    document.getElementById('editFiscalia').value = this.getAttribute('data-fiscalia');
                    document.getElementById('editUbicacion').value = this.getAttribute('data-ubicacion');

                    fijarCatalogoSeleccionado('selDelitoEdit', this.getAttribute('data-iddelito'));

                    modalEditarIP.show();
                });
            });

            // --- Editar EXPEL ---
            document.querySelectorAll('.btn-editar-expel').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    document.getElementById('editIdLegalExpel').value = this.getAttribute('data-id');
                    document.getElementById('editActor').value = this.getAttribute('data-actor');
                    document.getElementById('editDemandado').value = this.getAttribute('data-demandado');
                    document.getElementById('editJuicio').value = this.getAttribute('data-juicio');
                    document.getElementById('editAsunto').value = this.getAttribute('data-asunto');
                    document.getElementById('editLugar').value = this.getAttribute('data-lugar');

                    fijarCatalogoSeleccionado('selMateriaEdit', this.getAttribute('data-idmateria'));
                    fijarCatalogoSeleccionado('selTipoAccionEdit', this.getAttribute('data-idtipoaccion'));

                    modalEditarExpel.show();
                });
            });

            // --- Eliminar / Restaurar (soft-delete) ---
            window.cambiarEstadoIP = function (id, accion) {
                var msg = (accion === 'eliminar')
                    ? '¿Eliminar esta Investigacion Previa? Podras restaurarla luego con "Ver eliminados".'
                    : '¿Restaurar esta Investigacion Previa para que vuelva a la lista?';
                if (!confirm(msg)) return;
                document.getElementById('ipAccion').value = accion;
                document.getElementById('ipAccionId').value = id;
                document.getElementById('formEstadoIP').submit();
            };

            window.cambiarEstadoExpel = function (id, accion) {
                var msg = (accion === 'eliminar')
                    ? '¿Eliminar este registro de EXPEL? Podras restaurarlo luego con "Ver eliminados".'
                    : '¿Restaurar este registro de EXPEL para que vuelva a la lista?';
                if (!confirm(msg)) return;
                document.getElementById('expelAccion').value = accion;
                document.getElementById('expelAccionId').value = id;
                document.getElementById('formEstadoExpel').submit();
            };

            document.querySelectorAll('.btn-ver-seg').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var idIp = this.getAttribute('data-id');
                    var seguimientos = [];
                    try {
                        seguimientos = JSON.parse(this.getAttribute('data-seg'));
                    } catch (e) {
                        seguimientos = [];
                    }
                    document.getElementById('segIdLegalIp').value = idIp;
                    var cont = document.getElementById('listaSeguimientos');
                    if (seguimientos.length === 0) {
                        cont.innerHTML = '<p class="text-muted text-center py-3 mb-0"><i class="fa fa-inbox mr-1"></i>Sin seguimientos registrados.</p>';
                    } else {
                        var html = '';
                        seguimientos.forEach(function (s) {
                            html += '<div class="border-bottom pb-2 mb-2">'
                                    + '<div class="small text-muted">' + escapeHtml(s.fecha) + ' &middot; ' + escapeHtml(s.usuario) + '</div>'
                                    + '<div>' + escapeHtml(s.descripcion) + '</div>'
                                    + '</div>';
                        });
                        cont.innerHTML = html;
                    }
                    modalSeguimiento.show();
                });
            });

            document.querySelectorAll('.btn-ver-seg-expel').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var idExpel = this.getAttribute('data-id');
                    var seguimientos = [];
                    try {
                        seguimientos = JSON.parse(this.getAttribute('data-seg'));
                    } catch (e) {
                        seguimientos = [];
                    }
                    document.getElementById('segIdLegalExpel').value = idExpel;
                    var cont = document.getElementById('listaSeguimientosExpel');
                    if (seguimientos.length === 0) {
                        cont.innerHTML = '<p class="text-muted text-center py-3 mb-0"><i class="fa fa-inbox mr-1"></i>Sin seguimientos registrados.</p>';
                    } else {
                        var html = '';
                        seguimientos.forEach(function (s) {
                            html += '<div class="border-bottom pb-2 mb-2">'
                                    + '<div class="small text-muted">' + escapeHtml(s.fecha) + ' &middot; ' + escapeHtml(s.usuario) + '</div>'
                                    + '<div>' + escapeHtml(s.descripcion) + '</div>'
                                    + '</div>';
                        });
                        cont.innerHTML = html;
                    }
                    modalSeguimientoExpel.show();
                });
            });
        </script>
    </body>
</html>
