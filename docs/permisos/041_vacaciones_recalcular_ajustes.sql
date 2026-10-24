-- =====================================================================
-- Vacaciones: recalcular los AJUSTES HISTORICOS ya cargados con el metodo
-- vigente (dias habiles L-V x 15/11 = 1.3636, 2 decimales), igual que las
-- solicitudes. Pedido de la jefatura.
--
-- Solo se tocan los ajustes que tienen FECHA_DESDE y FECHA_HASTA y cuyo
-- rango contiene al menos 1 dia habil. NO se tocan:
--   * ajustes sin fechas (no hay base para calcular);
--   * rangos sin dias habiles (ej. un sabado) -- quedan como estan.
--
-- Contar dias habiles sin depender del idioma de la sesion: se usa la
-- semana ISO (TRUNC(fecha,'IW') = lunes de esa semana). La formula se
-- verifico contra un conteo dia por dia.
--
-- EJECUTAR POR PASOS, revisando cada resultado:
--   PASO 1: vista previa (no modifica nada).
--   PASO 2: respaldo de la tabla.
--   PASO 3: actualizacion (+ COMMIT).
--   PASO 4: verificacion.
--   Si algo no convence: ver "REVERTIR" al final.
--
-- Efecto sobre el saldo: los dias consumidos de cada periodo suben (cada
-- dia habil pasa a descontar 1.36) y los disponibles bajan en consecuencia.
-- =====================================================================

-- PASO 1: VISTA PREVIA ---------------------------------------------------
SELECT a.ID_AJUSTE,
       u.NOMBRE||' '||u.APELLIDOS            AS EMPLEADO,
       a.NUM_PERIODO                          AS PERIODO,
       TO_CHAR(a.FECHA_DESDE,'DD/MM/YYYY')    AS DESDE,
       TO_CHAR(a.FECHA_HASTA,'DD/MM/YYYY')    AS HASTA,
       a.DIAS_GOZADOS                         AS DIAS_ACTUAL,
       h.HABILES,
       ROUND(h.HABILES * 15 / 11, 2)          AS DIAS_NUEVO,
       ROUND(h.HABILES * 15 / 11, 2) - a.DIAS_GOZADOS AS DIFERENCIA,
       CASE WHEN h.HABILES = 0 THEN 'SE OMITE (sin dias habiles)'
            WHEN ROUND(h.HABILES * 15 / 11, 2) = a.DIAS_GOZADOS THEN 'sin cambio'
            ELSE 'SE ACTUALIZA' END           AS ACCION
FROM VAC_HISTORICO_AJUSTE a
JOIN USUARIO u ON u.IDUSUARIO = a.ID_USUARIO
JOIN (SELECT ID_AJUSTE,
             (TRUNC(FECHA_HASTA,'IW') - TRUNC(FECHA_DESDE,'IW')) / 7 * 5
               - LEAST(FECHA_DESDE - TRUNC(FECHA_DESDE,'IW'), 5)
               + LEAST(FECHA_HASTA - TRUNC(FECHA_HASTA,'IW'), 4) + 1 AS HABILES
      FROM VAC_HISTORICO_AJUSTE
      WHERE FECHA_DESDE IS NOT NULL AND FECHA_HASTA IS NOT NULL
        AND FECHA_HASTA >= FECHA_DESDE) h ON h.ID_AJUSTE = a.ID_AJUSTE
ORDER BY u.NOMBRE, a.NUM_PERIODO, a.FECHA_DESDE;

-- Ajustes que NO se tocaran por no tener fechas (informativo):
SELECT a.ID_AJUSTE, u.NOMBRE||' '||u.APELLIDOS AS EMPLEADO, a.NUM_PERIODO, a.DIAS_GOZADOS, a.OBSERVACIONES
FROM VAC_HISTORICO_AJUSTE a JOIN USUARIO u ON u.IDUSUARIO = a.ID_USUARIO
WHERE a.FECHA_DESDE IS NULL OR a.FECHA_HASTA IS NULL
ORDER BY u.NOMBRE, a.NUM_PERIODO;

-- PASO 2: RESPALDO --------------------------------------------------------
CREATE TABLE VAC_HISTORICO_AJUSTE_BKP_041 AS SELECT * FROM VAC_HISTORICO_AJUSTE;

-- PASO 3: ACTUALIZAR ------------------------------------------------------
UPDATE VAC_HISTORICO_AJUSTE a
SET a.DIAS_GOZADOS = ROUND(((TRUNC(a.FECHA_HASTA,'IW') - TRUNC(a.FECHA_DESDE,'IW')) / 7 * 5
                           - LEAST(a.FECHA_DESDE - TRUNC(a.FECHA_DESDE,'IW'), 5)
                           + LEAST(a.FECHA_HASTA - TRUNC(a.FECHA_HASTA,'IW'), 4) + 1) * 15 / 11, 2)
WHERE a.FECHA_DESDE IS NOT NULL AND a.FECHA_HASTA IS NOT NULL
  AND a.FECHA_HASTA >= a.FECHA_DESDE
  -- solo rangos con al menos 1 dia habil
  AND ((TRUNC(a.FECHA_HASTA,'IW') - TRUNC(a.FECHA_DESDE,'IW')) / 7 * 5
        - LEAST(a.FECHA_DESDE - TRUNC(a.FECHA_DESDE,'IW'), 5)
        + LEAST(a.FECHA_HASTA - TRUNC(a.FECHA_HASTA,'IW'), 4) + 1) > 0;
-- Anota cuantas filas se actualizaron; si es lo esperado:
COMMIT;

-- PASO 4: VERIFICACION ----------------------------------------------------
-- Compara contra el respaldo: DIAS_ANTES vs DIAS_AHORA.
SELECT n.ID_AJUSTE, u.NOMBRE||' '||u.APELLIDOS AS EMPLEADO, n.NUM_PERIODO,
       b.DIAS_GOZADOS AS DIAS_ANTES, n.DIAS_GOZADOS AS DIAS_AHORA
FROM VAC_HISTORICO_AJUSTE n
JOIN VAC_HISTORICO_AJUSTE_BKP_041 b ON b.ID_AJUSTE = n.ID_AJUSTE
JOIN USUARIO u ON u.IDUSUARIO = n.ID_USUARIO
WHERE b.DIAS_GOZADOS <> n.DIAS_GOZADOS
ORDER BY u.NOMBRE, n.NUM_PERIODO;

-- REVERTIR (solo si hace falta) -------------------------------------------
-- UPDATE VAC_HISTORICO_AJUSTE a
--    SET a.DIAS_GOZADOS = (SELECT b.DIAS_GOZADOS FROM VAC_HISTORICO_AJUSTE_BKP_041 b WHERE b.ID_AJUSTE = a.ID_AJUSTE)
--  WHERE EXISTS (SELECT 1 FROM VAC_HISTORICO_AJUSTE_BKP_041 b WHERE b.ID_AJUSTE = a.ID_AJUSTE);
-- COMMIT;
