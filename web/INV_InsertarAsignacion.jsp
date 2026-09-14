<%--
    Document   : Insertar ASIGNACION
    Created on : 26-Febrero-2019, 10:43:59
    Author     : Jquinde
--%>

<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Types"%>
<%Class.forName("oracle.jdbc.driver.OracleDriver");%>
<%
    String idInvEquipo = request.getParameter("idEquipo");
    String IDUSUARIO = request.getParameter("idUsuario");
    String cargo = (String) session.getAttribute("cargo");
    String user = (String) session.getAttribute("userDB");
    String pass = (String) session.getAttribute("passDB");
    String ip = (String) session.getAttribute("ipDB");
    String url = "" + ip;

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect("sesionExpirada.jsp");
        return;
    } else if (session.isNew()) {
        response.sendRedirect("sesionExpirada.jsp");
        return;
    }
    if (!(cargo.equals("JEFE") || cargo.equals("ASISTENTE"))) {
        response.sendRedirect("sesionInvalida.jsp");
        return;
    }

    if (idInvEquipo == null || idInvEquipo.trim().isEmpty()
            || IDUSUARIO == null || IDUSUARIO.trim().isEmpty()) {
        response.sendRedirect("Inventario/INV_Equipos.jsp?error=Datos incompletos");
        return;
    }

    // Insertar la asignacion Y marcar el equipo como Asignado dentro de
    // una MISMA transaccion. Antes eran dos operaciones separadas en dos
    // conexiones distintas y ademas se usaba executeQuery() sobre INSERT/
    // UPDATE (invalido en JDBC -- lanza excepcion sin ejecutar el
    // siguiente statement, dejando INV_ASIGNACION con la nueva fila pero
    // INV_EQUIPOS.ESTADO todavia en 'D'). Ver INV_EQUIPOS reparacion
    // masiva en docs/migracion/inv_equipos_reparar_estado.sql.
    Connection cn = null;
    try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        cn = DriverManager.getConnection(url, user, pass);
        cn.setAutoCommit(false);

        int idAsignacion = 1;
        try (PreparedStatement stSec = cn.prepareStatement(
                "SELECT NVL(MAX(IDINV_ASIGNACION),0)+1 FROM INV_ASIGNACION");
             ResultSet rsSec = stSec.executeQuery()) {
            if (rsSec.next()) idAsignacion = rsSec.getInt(1);
        }

        try (PreparedStatement st = cn.prepareStatement(
                "INSERT INTO INV_ASIGNACION (IDINV_ASIGNACION, IDINVEQUIPO, " +
                "FECHAASIGNACION, IDUSUARIO, ESTADO) VALUES (?, ?, SYSDATE, ?, 'A')")) {
            st.setInt(1, idAsignacion);
            st.setInt(2, Integer.parseInt(idInvEquipo.trim()));
            st.setInt(3, Integer.parseInt(IDUSUARIO.trim()));
            st.executeUpdate();
        }

        try (PreparedStatement st = cn.prepareStatement(
                "UPDATE INV_EQUIPOS SET ESTADO = 'A' WHERE IDINVEQUIPO = ?")) {
            st.setInt(1, Integer.parseInt(idInvEquipo.trim()));
            st.executeUpdate();
        }

        cn.commit();
    } catch (Exception e) {
        if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
        e.printStackTrace();
        response.sendRedirect("Inventario/INV_Equipos.jsp?error=Error al asignar el equipo");
        return;
    } finally {
        try { if (cn != null) cn.close(); } catch (Exception ignore) {}
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Insertar Asignacion</title>
    </head>
    <body>
        <script type="text/javascript">
            alert("Equipo Asignado Correctamente!!");
            location.href = 'Inventario/INV_Equipos.jsp';
        </script>
    </body>
</html>
