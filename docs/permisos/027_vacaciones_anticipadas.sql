-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- solicitudes anticipadas
--
-- Un empleado puede, de mutuo acuerdo con la empresa, adelantar dias
-- de vacaciones de un periodo que TODAVIA no ha cumplido (ej. antes
-- de llegar al año, o antes de que empiece su siguiente periodo).
-- Como esto genera una obligacion que la empresa podria tener que
-- recuperar si el empleado sale antes de ganarse esos dias, no se deja
-- como una opcion libre: el empleado la marca al solicitar (con una
-- justificacion obligatoria), pero sigue pasando por jefe directo y
-- Administracion -- es Administracion (SMORAN) quien tiene la ultima
-- palabra para aprobarla o rechazarla si el adelanto no fue realmente
-- acordado.
-- =====================================================================

ALTER TABLE VAC_SOLICITUD ADD ANTICIPADA CHAR(1) DEFAULT 'N' NOT NULL;
ALTER TABLE VAC_SOLICITUD ADD CONSTRAINT CK_VAC_SOL_ANTICIPADA CHECK (ANTICIPADA IN ('S','N'));
ALTER TABLE VAC_SOLICITUD ADD JUSTIFICACION_ANTICIPO VARCHAR2(500);

COMMIT;
