-- =====================================================================
-- Inventario -- campo dedicado para el custodio de un equipo en estado
-- "Backup Oficina" (BK)
--
-- Se habia pensado reutilizar OBSERVACIONES para anotar el nombre del
-- responsable de custodia, pero ese campo ya se usa como bitacora de
-- notas historicas del equipo (traslados, prestamos, etc.) -- mezclar
-- ambas cosas hacia que el Acta de Entrega imprimiera todo el
-- historial como si fuera el nombre de una persona. Se agrega un
-- campo propio, separado de Observaciones.
-- =====================================================================

ALTER TABLE INV_EQUIPOS ADD CUSTODIO_BACKUP VARCHAR2(200);

COMMIT;
