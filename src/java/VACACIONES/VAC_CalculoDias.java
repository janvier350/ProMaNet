package VACACIONES;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

// Motor de conteo de dias habiles y aplicacion del factor de
// proporcionalidad para vacaciones -- Art. 69 del Codigo del Trabajo
// del Ecuador.
//
// El codigo garantiza 15 dias CALENDARIO de vacaciones al año. En un
// periodo continuo de 15 dias con semana laboral L-V, se trabajan 11
// dias habiles (2 semanas completas + 1 dia) y se descansan 4 (dos
// fines de semana). Cuando el empleado fracciona sus vacaciones, si
// solo se le descontaran los dias efectivamente pedidos ignorando el
// fin de semana, tomando 15 viernes distintos "gastaria" apenas 15 de
// los 15, lo cual excede la proporcion legal. Y si se le cargaran los
// sabados y domingos aunque no venia a trabajar tampoco, seria un
// castigo injusto.
//
// La solucion adoptada por Nomina/RRHH es aplicar el factor
//   15 calendario / 11 habiles = 1.3636...
// a cada dia habil solicitado. Asi 11 dias habiles = 15.00 dias
// descontados del saldo anual, y las fracciones descuentan lo
// proporcional (1 viernes = 1.36, 5 dias habiles = 6.82, etc).
public class VAC_CalculoDias {

    // Factor de proporcionalidad. Se guarda con 4 decimales para que
    // los redondeos posteriores (2 decimales) sean estables. Se expone
    // como constante publica para que la UI y el reporte puedan
    // mostrar el mismo numero al usuario y no se produzcan diferencias
    // de decimo por redondear en otro lado.
    public static final BigDecimal FACTOR_PROPORCIONALIDAD =
            new BigDecimal("15").divide(new BigDecimal("11"), 4, RoundingMode.HALF_UP);

    // Cuenta dias habiles (lunes a viernes) en el rango [desde, hasta]
    // inclusive. No se descuentan feriados en esta fase -- pendiente
    // para cuando se agregue la tabla de feriados. Si el rango es
    // invalido (hasta < desde) devuelve 0.
    public static int contarDiasHabiles(LocalDate desde, LocalDate hasta) {
        if (desde == null || hasta == null) return 0;
        if (hasta.isBefore(desde)) return 0;
        int habiles = 0;
        LocalDate d = desde;
        while (!d.isAfter(hasta)) {
            DayOfWeek dow = d.getDayOfWeek();
            if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY) habiles++;
            d = d.plusDays(1);
        }
        return habiles;
    }

    // Dias calendario en [desde, hasta] inclusive -- util para el
    // detalle informativo (cuantos dias reales de calendario cubre la
    // solicitud) sin que sea lo que se descuenta del saldo.
    public static int contarDiasCalendario(LocalDate desde, LocalDate hasta) {
        if (desde == null || hasta == null || hasta.isBefore(desde)) return 0;
        return (int) ChronoUnit.DAYS.between(desde, hasta) + 1;
    }

    // Aplica el factor a los dias habiles y redondea a 2 decimales.
    // El redondeo HALF_UP es la convencion contable habitual y calza
    // con la tabla del documento fuente (5 * 1.3636 = 6.818 -> 6.82).
    public static BigDecimal equivalentes(int diasHabiles) {
        return FACTOR_PROPORCIONALIDAD
                .multiply(new BigDecimal(diasHabiles))
                .setScale(2, RoundingMode.HALF_UP);
    }

    // Version de conveniencia para no obligar a los llamadores a
    // manejar BigDecimal cuando lo unico que quieren es un double para
    // sumar/comparar.
    public static double equivalentesDouble(int diasHabiles) {
        return equivalentes(diasHabiles).doubleValue();
    }
}
