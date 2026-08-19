-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- empresa de afiliacion IESS
--
-- Este campo es DISTINTO de USUARIO.IDCOMPANIA (que ya se usa para
-- Inventario/Movilizacion: representa a que compania esta asignado el
-- empleado operativamente). La empresa patronal del IESS (con la que
-- se hizo el Aviso de Entrada) puede ser otra -- por eso se agrega
-- como un campo propio de VAC_CONFIG_USUARIO y no se toca USUARIO ni
-- la tabla COMPANIA que usa Inventario.
-- =====================================================================

ALTER TABLE VAC_CONFIG_USUARIO ADD EMPRESA_IESS VARCHAR2(150);

COMMIT;
