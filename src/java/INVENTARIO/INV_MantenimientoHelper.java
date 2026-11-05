package INVENTARIO;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

// Calculo del plan de mantenimiento preventivo de los equipos de inventario.
//
// Aplica a INV_EQUIPOS en servicio (estado A asignado, D disponible, M mantenimiento, I infraestructura),
// con registro activo (ESTADO_AI = 'A') y MANT_APLICA = 'S'.
//
// Periodicidad: la fijada en el equipo (MANT_PERIODICIDAD_MESES) o, si es automatica, 12 meses para equipos
// de hasta 2 anos desde la compra (medido a la fecha base) y 6 meses para los mas antiguos.
// Fecha base: ultimo mantenimiento PREVENTIVO; si nunca tuvo, la fecha de compra.
// Estado: VENCIDO (proxima < hoy), PROXIMO (faltan <= DIAS_AVISO) o AL_DIA.
public class INV_MantenimientoHelper {

    public static final int DIAS_AVISO = 15;
    public static final int MESES_EQUIPO_NUEVO = 24;
    public static final int PERIODO_NUEVO = 12;
    public static final int PERIODO_ANTIGUO = 6;

    public static class Fila {
        public int idEquipo;
        public String dispositivo, marca, modelo, serial, oficina, departamento, estadoEquipo, usuario;
        public Integer idUsuario;
        public LocalDate fechaCompra, ultimo, proxima;
        public int totalMant;
        public Integer periodoFijo;       // null = automatica
        public int periodo;               // meses efectivos
        public boolean aplica = true;
        public boolean nunca;             // nunca tuvo mantenimiento preventivo registrado
        public String estado;             // VENCIDO | PROXIMO | AL_DIA
        public long dias;                 // dias hasta/desde la proxima (negativo = vencido)
    }

    public static List<Fila> cargar(Connection cn, boolean soloQueAplican) throws SQLException {
        List<Fila> r = new ArrayList<>();
        LocalDate hoy = LocalDate.now();
        String sql =
            "SELECT e.IDINVEQUIPO, e.DISPOSITIVO, e.MARCA, e.MODELO, e.SERIAL, e.UBICACIONOFICINA, e.DEPARTAMENTO, e.ESTADO, " +
            "       e.FECHACOMPRA, e.MANT_PERIODICIDAD_MESES, e.MANT_APLICA, " +
            "       (SELECT MAX(m.FECHA_MANT) FROM INV_MANTENIMIENTO m WHERE m.IDINVEQUIPO = e.IDINVEQUIPO AND m.ESTADO = 'A' AND m.TIPO = 'PREVENTIVO'), " +
            "       (SELECT COUNT(*) FROM INV_MANTENIMIENTO m WHERE m.IDINVEQUIPO = e.IDINVEQUIPO AND m.ESTADO = 'A'), " +
            "       (SELECT u.IDUSUARIO FROM (SELECT a.IDINVEQUIPO, a.IDUSUARIO FROM INV_ASIGNACION a WHERE a.ESTADO = 'A' ORDER BY a.FECHAASIGNACION DESC) x " +
            "          JOIN USUARIO u ON u.IDUSUARIO = x.IDUSUARIO WHERE x.IDINVEQUIPO = e.IDINVEQUIPO AND ROWNUM = 1), " +
            "       (SELECT u.NOMBRE || ' ' || u.APELLIDOS FROM (SELECT a.IDINVEQUIPO, a.IDUSUARIO FROM INV_ASIGNACION a WHERE a.ESTADO = 'A' ORDER BY a.FECHAASIGNACION DESC) x " +
            "          JOIN USUARIO u ON u.IDUSUARIO = x.IDUSUARIO WHERE x.IDINVEQUIPO = e.IDINVEQUIPO AND ROWNUM = 1) " +
            "FROM INV_EQUIPOS e " +
            "WHERE e.ESTADO_AI = 'A' AND e.ESTADO IN ('A','D','M','I') " +
            (soloQueAplican ? "AND NVL(e.MANT_APLICA,'S') = 'S' " : "") +
            "ORDER BY e.UBICACIONOFICINA, e.DISPOSITIVO, e.MARCA, e.MODELO";
        try (PreparedStatement st = cn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Fila f = new Fila();
                f.idEquipo = rs.getInt(1);
                f.dispositivo = nz(rs.getString(2)); f.marca = nz(rs.getString(3)); f.modelo = nz(rs.getString(4));
                f.serial = nz(rs.getString(5)); f.oficina = nz(rs.getString(6)); f.departamento = nz(rs.getString(7));
                f.estadoEquipo = nz(rs.getString(8));
                Date dc = rs.getDate(9); f.fechaCompra = dc == null ? null : dc.toLocalDate();
                int per = rs.getInt(10); f.periodoFijo = rs.wasNull() ? null : per;
                f.aplica = !"N".equals(rs.getString(11));
                Date du = rs.getDate(12); f.ultimo = du == null ? null : du.toLocalDate();
                f.totalMant = rs.getInt(13);
                int iu = rs.getInt(14); f.idUsuario = rs.wasNull() ? null : iu;
                f.usuario = rs.getString(15);
                calcular(f, hoy);
                r.add(f);
            }
        }
        return r;
    }

    public static void calcular(Fila f, LocalDate hoy) {
        f.nunca = f.ultimo == null;
        LocalDate base = f.ultimo != null ? f.ultimo : f.fechaCompra;
        if (f.periodoFijo != null && f.periodoFijo > 0) {
            f.periodo = f.periodoFijo;
        } else if (f.fechaCompra != null && base != null
                && ChronoUnit.MONTHS.between(f.fechaCompra, base) <= MESES_EQUIPO_NUEVO) {
            f.periodo = PERIODO_NUEVO;
        } else {
            f.periodo = PERIODO_ANTIGUO;
        }
        if (base == null) {           // sin fecha de compra ni mantenimientos: no hay base de calculo
            f.proxima = null; f.estado = "VENCIDO"; f.dias = Long.MIN_VALUE; return;
        }
        f.proxima = base.plusMonths(f.periodo);
        f.dias = ChronoUnit.DAYS.between(hoy, f.proxima);
        f.estado = f.dias < 0 ? "VENCIDO" : (f.dias <= DIAS_AVISO ? "PROXIMO" : "AL_DIA");
    }

    /** Conteos {vencidos, proximos, alDia, nuncaMantenidos} de los equipos que aplican. */
    public static int[] resumen(Connection cn) throws SQLException {
        int v = 0, p = 0, a = 0, n = 0;
        for (Fila f : cargar(cn, true)) {
            if ("VENCIDO".equals(f.estado)) v++; else if ("PROXIMO".equals(f.estado)) p++; else a++;
            if (f.nunca) n++;
        }
        return new int[]{v, p, a, n};
    }

    private static String nz(String s) { return s == null ? "" : s.trim(); }
}
