package VACACIONES;

// Catalogo de oficinas de la empresa para Vacaciones (VAC_CONFIG_USUARIO.OFICINA).
// Son las mismas ubicaciones que usa Inventario para los equipos
// (INV_EQUIPOS.UBICACIONOFICINA). Si se abre una oficina nueva, agregarla aqui:
// la usan la pantalla de configuracion y la validacion del servlet.
public class VAC_Oficinas {

    public static final String[] LISTA = {
        "Norte", "Kennedy 401", "Kennedy 403", "Romeria", "Magisterio", "Outsourcing"
    };

    /** Devuelve el nombre canonico de la oficina (sin distinguir mayusculas) o null si no existe. */
    public static String normalizar(String v) {
        if (v == null) return null;
        String t = v.trim();
        for (String o : LISTA) if (o.equalsIgnoreCase(t)) return o;
        return null;
    }
}
