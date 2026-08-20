package VACACIONES;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

// Motor de calculo de saldo de vacaciones (Fase 2). Un empleado
// acumula un periodo de 15 dias por cada año cumplido de trabajo,
// contado desde su FECHA_INGRESO real (VAC_CONFIG_USUARIO), no desde
// el Aviso de Entrada del IESS si son distintos. El primer periodo
// recien queda disponible al cumplir 1 año -- antes de eso el
// empleado no tiene ningun dia para gozar.
//
// El consumo se resta por periodo especifico (no global) para poder
// mostrar cuantos dias le quedan de CADA año, igual que el reporte de
// vacaciones que ya manejaba la empresa en Excel. Se descuenta tanto
// lo cargado manualmente en VAC_HISTORICO_AJUSTE (el historial previo
// a este modulo) como cualquier VAC_SOLICITUD todavia viva (pendiente
// de jefe/administracion, aprobada o recibida) -- los dias quedan
// reservados desde que se solicitan, no solo cuando ya se aprobaron,
// para que dos solicitudes del mismo periodo no puedan pisarse entre
// si mientras la primera sigue en tramite.
public class VAC_CalculoSaldo {

    public static class Periodo {
        public int numero;
        public Date desde;
        public Date hasta;
        public int diasAcumulados;
        public int diasConsumidos;
        public int diasDisponibles;
    }

    public static class Saldo {
        public Date fechaIngreso;
        public boolean configurado;
        public double antiguedadAnios;
        public List<Periodo> periodos = new ArrayList<>();
        public int totalDisponible;
    }

    public static Saldo calcular(Connection cn, int idUsuario) throws SQLException {
        Saldo saldo = new Saldo();

        Date fechaIngresoSql = null;
        try (PreparedStatement st = cn.prepareStatement(
                "SELECT FECHA_INGRESO FROM VAC_CONFIG_USUARIO WHERE ID_USUARIO = ?")) {
            st.setInt(1, idUsuario);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) fechaIngresoSql = rs.getDate(1);
            }
        }

        if (fechaIngresoSql == null) {
            saldo.configurado = false;
            return saldo;
        }

        saldo.configurado = true;
        saldo.fechaIngreso = fechaIngresoSql;

        LocalDate ingreso = fechaIngresoSql.toLocalDate();
        LocalDate hoy = LocalDate.now();
        saldo.antiguedadAnios = ChronoUnit.DAYS.between(ingreso, hoy) / 365.25;

        int numero = 1;
        while (true) {
            LocalDate finPeriodo = ingreso.plusYears(numero).minusDays(1);
            LocalDate cumpleAnio = ingreso.plusYears(numero); // dia en que el periodo queda disponible
            if (cumpleAnio.isAfter(hoy)) break; // periodo aun no cumplido, no acumula todavia

            Periodo p = new Periodo();
            p.numero = numero;
            p.desde = Date.valueOf(ingreso.plusYears(numero - 1));
            p.hasta = Date.valueOf(finPeriodo);
            // IMPORTANTE: Codigo del Trabajo Ecuador, Art. 69 -- 15 dias por
            // año; "los trabajadores que hubieren prestado servicios por MAS
            // DE CINCO AÑOS" ganan un dia adicional por cada año excedente,
            // es decir el dia extra recien aplica al 6to año (el 5to año
            // completo todavia no supera los cinco años), sin superar los
            // 30 dias totales.
            p.diasAcumulados = numero <= 5 ? 15 : Math.min(30, 15 + (numero - 5));

            int diasHistoricos = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(SUM(DIAS_GOZADOS),0) FROM VAC_HISTORICO_AJUSTE WHERE ID_USUARIO = ? AND NUM_PERIODO = ?")) {
                st.setInt(1, idUsuario);
                st.setInt(2, numero);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) diasHistoricos = rs.getInt(1);
                }
            }

            int diasSolicitudes = 0;
            try (PreparedStatement st = cn.prepareStatement(
                    "SELECT NVL(SUM(CASE WHEN ESTADO IN ('APROBADO','RECIBIDO') THEN NVL(DIAS_APROBADOS,DIAS_SOLICITADOS) " +
                    "ELSE DIAS_SOLICITADOS END),0) FROM VAC_SOLICITUD " +
                    "WHERE ID_USUARIO = ? AND NUM_PERIODO = ? " +
                    "AND ESTADO NOT IN ('RECHAZADO_JEFE','RECHAZADO_ADMIN','CANCELADO')")) {
                st.setInt(1, idUsuario);
                st.setInt(2, numero);
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) diasSolicitudes = rs.getInt(1);
                }
            }

            p.diasConsumidos = diasHistoricos + diasSolicitudes;
            p.diasDisponibles = Math.max(0, p.diasAcumulados - p.diasConsumidos);
            saldo.periodos.add(p);
            saldo.totalDisponible += p.diasDisponibles;

            numero++;
        }

        return saldo;
    }
}
