-- =====================================================================
-- Agenda legal, fase 3: vincular un evento a un caso del modulo Legal.
--   CASO_TIPO: 'I' = Investigacion previa (LEGAL_IP)  |  'J' = Juicio (LEGAL_EXPEL)
--   CASO_ID  : id del caso en esa tabla.
-- Opcional por evento. Ejecutar ANTES de desplegar el WAR de la fase 3 (las pantallas leen estas columnas).
-- =====================================================================
ALTER TABLE LEG_AGENDA ADD (CASO_TIPO CHAR(1), CASO_ID NUMBER);
ALTER TABLE LEG_AGENDA ADD CONSTRAINT CK_LEG_AGENDA_CASO CHECK (CASO_TIPO IS NULL OR CASO_TIPO IN ('I','J'));
CREATE INDEX IX_LEG_AGENDA_CASO ON LEG_AGENDA (CASO_TIPO, CASO_ID);
