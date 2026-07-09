-- =====================================================================
-- Modulo de Movilizacion: renombrar el estado COMPLETADA -> MOVILIZADO
--
-- COMPLETADA se dejo preparado en el esquema original pero nunca se
-- expuso en pantalla. Ahora se pide explicitamente un estado
-- "Movilizado" que cierre el ciclo de la solicitud (Smoran lo marca
-- una vez que la movilizacion ya ocurrio). Es el mismo concepto, asi
-- que se renombra en vez de agregar un estado nuevo que se solape.
--
-- No hay filas con ESTADO='COMPLETADA' todavia (nunca se uso), asi
-- que el UPDATE de abajo es solo por seguridad si alguna quedo asi
-- manualmente.
-- =====================================================================

ALTER TABLE MOV_SOLICITUD DROP CONSTRAINT CK_MOVSOL_ESTADO;

UPDATE MOV_SOLICITUD SET ESTADO = 'MOVILIZADO' WHERE ESTADO = 'COMPLETADA';

ALTER TABLE MOV_SOLICITUD ADD CONSTRAINT CK_MOVSOL_ESTADO
    CHECK (ESTADO IN ('PENDIENTE','APROBADA','RECHAZADA','CANCELADA','MOVILIZADO'));

COMMIT;
