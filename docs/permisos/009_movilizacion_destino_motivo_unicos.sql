-- =====================================================================
-- Modulo de Movilizacion: evitar destinos/motivos duplicados
--
-- La aplicacion ya valida esto (case-insensitive) antes de insertar,
-- pero se agrega tambien un indice unico funcional como respaldo por
-- si dos personas intentan crear el mismo destino/motivo casi al
-- mismo tiempo.
-- =====================================================================

CREATE UNIQUE INDEX UX_MOV_DESTINO_DESC ON MOV_DESTINO (UPPER(TRIM(DESCRIPCION)));
CREATE UNIQUE INDEX UX_MOV_MOTIVO_DESC ON MOV_MOTIVO (UPPER(TRIM(DESCRIPCION)));

COMMIT;
