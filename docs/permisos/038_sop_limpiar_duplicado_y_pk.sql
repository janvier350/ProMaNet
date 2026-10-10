-- =====================================================================
-- SOP_SOPORTE_CAB -- limpiar duplicado IDSOPORTE=114 + agregar PK y FK
--
-- Corrida la query de verificacion del 037 aparecio que IDSOPORTE=114
-- se repite 2 veces en SOP_SOPORTE_CAB. Causa historica: condicion de
-- carrera en el calculo "NVL(MAX(IDSOPORTE),0)+1" cuando dos usuarios
-- crearon un ticket casi al mismo tiempo (el COUNT corrio antes del
-- INSERT del primero, asi que los dos obtuvieron el mismo ID).
--
-- Este script:
--   1) DIAGNOSTICO: muestra los 2 registros con IDSOPORTE=114 para
--      que puedas confirmar cual conservar y cual reasignar (el mas
--      nuevo por FECHA_SOLICITUD recibe un ID nuevo).
--   2) REPARACION: le asigna al mas nuevo un ID libre
--      (NVL(MAX)+1), de forma que los 2 registros queden con IDs
--      distintos. Si tenia alguna fila hija (ej. SOP_SOPORTE_DET)
--      hay que arreglarla aparte -- en este modelo no vi tablas
--      hijas nuevas pero chequear antes.
--   3) VERIFICACION: la query del paso 1 debe salir vacia.
--   4) PK + FK: agrega PRIMARY KEY a SOP_SOPORTE_CAB.IDSOPORTE y la
--      FOREIGN KEY que no se pudo crear en el 035.
--
-- CADA PASO ESTA SEPARADO. Correr uno por uno y revisar el resultado
-- antes del siguiente, no todo de corrido.
-- =====================================================================


-- -----------------------------------------------------------------
-- PASO 1 -- DIAGNOSTICO (no modifica nada, solo muestra los 2 registros)
-- -----------------------------------------------------------------
SELECT IDSOPORTE, IDUSUARIO, IDEQUIPO,
       TO_CHAR(FECHA_SOLICITUD,'YYYY-MM-DD HH24:MI:SS') FECHA_SOL,
       SUBSTR(SOPORTE, 1, 60) SOPORTE_INICIO,
       PRIORIDAD, ESTADO, TECNICO
FROM SOP_SOPORTE_CAB
WHERE IDSOPORTE = 114
ORDER BY FECHA_SOLICITUD;

-- Deberia salir 2 filas. La MAS VIEJA (fecha_sol menor) se queda
-- con IDSOPORTE=114; la MAS NUEVA es la que se le reasigna.


-- -----------------------------------------------------------------
-- PASO 2 -- REPARACION automatica
-- -----------------------------------------------------------------
-- Al mas nuevo le damos un IDSOPORTE libre (max actual + 1). Se
-- identifica por ROWID -- es unico siempre, Oracle lo garantiza
-- aunque haya IDSOPORTE duplicados.

UPDATE SOP_SOPORTE_CAB
SET IDSOPORTE = (SELECT NVL(MAX(IDSOPORTE),0) + 1 FROM SOP_SOPORTE_CAB)
WHERE ROWID = (
    SELECT ROWID
    FROM (
        SELECT ROWID, ROW_NUMBER() OVER (
            PARTITION BY IDSOPORTE ORDER BY FECHA_SOLICITUD DESC, ROWID DESC
        ) rn
        FROM SOP_SOPORTE_CAB WHERE IDSOPORTE = 114
    )
    WHERE rn = 1
);

COMMIT;


-- -----------------------------------------------------------------
-- PASO 3 -- VERIFICAR que ya no hay duplicados
-- -----------------------------------------------------------------
SELECT IDSOPORTE, COUNT(*)
FROM SOP_SOPORTE_CAB
GROUP BY IDSOPORTE HAVING COUNT(*) > 1;
-- Debe salir VACIO. Si no, hay mas duplicados y repetir el PASO 2
-- con otro IDSOPORTE, o avisar antes de seguir con el PASO 4.


-- -----------------------------------------------------------------
-- PASO 4 -- Agregar PRIMARY KEY a SOP_SOPORTE_CAB.IDSOPORTE
--           y la FK que no se pudo crear en el 035
-- -----------------------------------------------------------------
-- NO ejecutar si el PASO 3 saco algo. Primero limpiar los otros
-- duplicados.
ALTER TABLE SOP_SOPORTE_CAB
    ADD CONSTRAINT PK_SOP_SOPORTE_CAB PRIMARY KEY (IDSOPORTE);

ALTER TABLE SOP_SOPORTE_INCIDENCIA
    ADD CONSTRAINT FK_SOP_SOP_INC_CAB
    FOREIGN KEY (IDSOPORTE) REFERENCES SOP_SOPORTE_CAB(IDSOPORTE);

COMMIT;


-- -----------------------------------------------------------------
-- Verificacion final
-- -----------------------------------------------------------------
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name IN ('SOP_SOPORTE_CAB','SOP_SOPORTE_INCIDENCIA')
  AND constraint_type IN ('P','R')
ORDER BY table_name, constraint_type;
