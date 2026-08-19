-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- agregar cedula
--
-- USUARIO no tiene columna de cedula, asi que el documento impreso la
-- dejaba en blanco. Se agrega a VAC_CONFIG_USUARIO (junto a fecha de
-- ingreso y jefe directo) en vez de tocar la tabla USUARIO existente.
-- =====================================================================

ALTER TABLE VAC_CONFIG_USUARIO ADD CEDULA VARCHAR2(20);

COMMIT;
