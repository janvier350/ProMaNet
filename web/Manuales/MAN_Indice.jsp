<%--
    Document   : MAN_Indice
    Indice de manuales de usuario. Cada manual aparece solo si el usuario
    tiene permiso sobre el modulo correspondiente. Para agregar un manual
    nuevo: crear MAN_Xxx.jsp en esta carpeta y sumar una entrada al
    arreglo de abajo (titulo, descripcion, archivo, icono, permiso).
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%
    if (session.getAttribute("usuario") == null || session.isNew()) {
        response.sendRedirect("../sesionExpirada.jsp"); return;
    }
    String nombre    = (String) session.getAttribute("nombre");
    String apellidos = (String) session.getAttribute("apellidos");
    request.setAttribute("sidenav_active", "manuales");

    // { titulo, descripcion, archivo, icono FA, color, permiso1|permiso2 (basta uno; vacio = todos) }
    String[][] manuales = {
        {"Anticipos de Auditoria", "Del sueldo al anticipo pagado: asignar sueldo, fecha de corte, solicitud, pago y comprobante.",
         "MAN_AnticiposAuditoria.jsp", "fa-hand-holding-usd", "info", "ANTICIPOS_AUD_ACCESO|ANTICIPOS_AUD_GESTIONAR"},
        {"Solicitud de vacaciones", "Para quien solicita: entender el saldo, pedir vacaciones, seguir la aprobacion, anticipadas y ya gozadas.",
         "MAN_Vacaciones.jsp", "fa-umbrella-beach", "warning", "VACACIONES_SOLICITAR"},
    };
    List<String[]> visibles = new ArrayList<>();
    for (String[] m : manuales) {
        boolean ok = m[5].isEmpty();
        for (String p : m[5].split("\\|")) {
            if (!p.isEmpty() && COMUN.PermisoHelper.tiene(session, p)) ok = true;
        }
        if (ok) visibles.add(m);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manuales de usuario</title>
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
<link href="../assets/css/nucleo-icons.css" rel="stylesheet">
<link href="../assets/css/nucleo-svg.css" rel="stylesheet">
<script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link id="pagestyle" href="../assets/css/argon-dashboard.css?v=2.0.4" rel="stylesheet">
</head>
<body class="g-sidenav-show bg-gray-100">
<%@ include file="/_sidenav.jspf" %>
<div class="min-height-300 bg-primary position-absolute w-100"></div>
<main class="main-content position-relative border-radius-lg">
    <nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl">
        <div class="container-fluid py-1 px-3">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0">
                    <li class="breadcrumb-item text-sm"><a class="opacity-5 text-white" href="../Proyectos/PRO_Dashboard.jsp">Menu</a></li>
                    <li class="breadcrumb-item text-sm text-white active">Manuales</li>
                </ol>
                <h6 class="font-weight-bolder text-white mb-0">Manuales de usuario</h6>
            </nav>
            <div class="ms-auto">
                <span class="nav-link text-white font-weight-bold px-0">
                    <i class="fa fa-user me-1"></i> <%=nombre%> <%=apellidos%>
                </span>
            </div>
        </div>
    </nav>
    <div class="container-fluid py-4">
        <p class="text-white text-sm mb-4">Guias cortas, paso a paso, de los modulos a los que tienes acceso.</p>
        <div class="row">
            <% for (String[] m : visibles) { %>
            <div class="col-xl-4 col-md-6 mb-4">
                <a href="<%=m[2]%>" class="text-decoration-none">
                    <div class="card h-100">
                        <div class="card-body">
                            <div class="d-flex align-items-start">
                                <div class="icon icon-shape bg-gradient-<%=m[4]%> shadow text-center rounded-circle me-3" style="min-width:3rem;">
                                    <i class="fas <%=m[3]%> text-lg opacity-10 text-white"></i>
                                </div>
                                <div>
                                    <h6 class="mb-1"><%=m[0]%></h6>
                                    <p class="text-sm text-secondary mb-0"><%=m[1]%></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </a>
            </div>
            <% } %>
            <% if (visibles.isEmpty()) { %>
            <div class="col-12"><div class="card"><div class="card-body text-center text-secondary">Aun no hay manuales disponibles para tu perfil.</div></div></div>
            <% } %>
        </div>
    </div>
</main>
</body>
</html>
