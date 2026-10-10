-- =====================================================================
-- SOP_SOPORTE_CAB.ESTADO: expandir longitud
--
-- La columna ESTADO era chica (en la base vieja estaba definida como
-- VARCHAR2(10) o similar) y acepta sin problema 'PENDIENTE' (9) y
-- 'ATENDIDO' (8), pero los estados nuevos no entran:
--   'EN_PROGRESO'          -> 11 caracteres
--   'REASIGNADO'           -> 10
--   'CERRADO_SIN_SOLUCION' -> 20
--   'CANCELADO_USR'        -> 13
--
-- Al intentar un UPDATE con 'EN_PROGRESO' Oracle devuelve
-- "ORA-12899: valor demasiado grande para columna" y el servlet
-- SOP_AgregarIncidencia hace rollback, mostrando "Error al registrar
-- incidencia" en el UI.
--
-- Se expande a VARCHAR2(25) -- holgado para los estados actuales y
-- futuros, sin perdida de datos (los valores viejos entran igual).
-- =====================================================================

ALTER TABLE SOP_SOPORTE_CAB MODIFY (ESTADO VARCHAR2(25));

COMMIT;

-- Verificar
SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'SOP_SOPORTE_CAB' AND column_name = 'ESTADO';
