-- =====================================================================
-- Vacaciones -- factor de proporcionalidad 1.3636 (Art. 69 CT Ecuador)
--
-- Pasa los conteos de dias de INTEGER a NUMBER(5,2) para poder guardar
-- fracciones como 1.36, 2.73, 6.82 y 15.00. El factor viene de la
-- proporcion legal 15 dias calendario = 11 dias habiles por periodo,
-- entonces cada dia habil solicitado equivale a 15/11 = 1.3636... del
-- saldo anual.
--
-- La conversion INT -> NUMBER(5,2) es SIN PERDIDA: cualquier valor
-- entero existente queda igual (ej. 10 pasa a ser 10.00) y sigue
-- descontando lo mismo del saldo del periodo. Los datos historicos
-- cargados a mano en VAC_HISTORICO_AJUSTE no se tocan -- representan
-- lo que la empresa ya conto como consumido; las cargas nuevas si
-- podran ser decimales.
--
-- No hay solicitudes en tramite en el momento de este cambio
-- (confirmado con Administracion) asi que no hay riesgo de que un
-- estado a medio camino quede inconsistente entre los tipos.
-- =====================================================================


-- 1) VAC_SOLICITUD.DIAS_SOLICITADOS -----------------------------------
ALTER TABLE VAC_SOLICITUD ADD (DIAS_SOLICITADOS_NEW NUMBER(5,2));
UPDATE VAC_SOLICITUD SET DIAS_SOLICITADOS_NEW = DIAS_SOLICITADOS;
ALTER TABLE VAC_SOLICITUD DROP COLUMN DIAS_SOLICITADOS;
ALTER TABLE VAC_SOLICITUD RENAME COLUMN DIAS_SOLICITADOS_NEW TO DIAS_SOLICITADOS;


-- 2) VAC_SOLICITUD.DIAS_APROBADOS -------------------------------------
ALTER TABLE VAC_SOLICITUD ADD (DIAS_APROBADOS_NEW NUMBER(5,2));
UPDATE VAC_SOLICITUD SET DIAS_APROBADOS_NEW = DIAS_APROBADOS;
ALTER TABLE VAC_SOLICITUD DROP COLUMN DIAS_APROBADOS;
ALTER TABLE VAC_SOLICITUD RENAME COLUMN DIAS_APROBADOS_NEW TO DIAS_APROBADOS;


-- 3) VAC_HISTORICO_AJUSTE.DIAS_GOZADOS --------------------------------
ALTER TABLE VAC_HISTORICO_AJUSTE ADD (DIAS_GOZADOS_NEW NUMBER(5,2));
UPDATE VAC_HISTORICO_AJUSTE SET DIAS_GOZADOS_NEW = DIAS_GOZADOS;
ALTER TABLE VAC_HISTORICO_AJUSTE DROP COLUMN DIAS_GOZADOS;
ALTER TABLE VAC_HISTORICO_AJUSTE RENAME COLUMN DIAS_GOZADOS_NEW TO DIAS_GOZADOS;


-- 4) Columnas nuevas en VAC_SOLICITUD para dejar constancia del calculo
--    de proporcionalidad -- asi si mañana alguien reclama "por que se me
--    descontaron 6.82 dias?", el registro tiene el desglose y no hay que
--    reconstruirlo.
--    DIAS_HABILES_SOLICITADOS  -> conteo bruto de L-V en el rango pedido
--    DIAS_HABILES_APROBADOS    -> mismo conteo pero de lo aprobado
--    FACTOR_PROPORCIONALIDAD   -> factor efectivamente aplicado
--                                 (por defecto 1.3636; se guarda por si
--                                 el ministerio cambia el numero)
ALTER TABLE VAC_SOLICITUD ADD (
    DIAS_HABILES_SOLICITADOS NUMBER(5,2),
    DIAS_HABILES_APROBADOS   NUMBER(5,2),
    FACTOR_PROPORCIONALIDAD  NUMBER(6,4)
);

COMMIT;


-- Verificar: las columnas deben aparecer como NUMBER(5,2) / NUMBER(6,4)
SELECT column_name, data_type, data_precision, data_scale
FROM   user_tab_columns
WHERE  table_name IN ('VAC_SOLICITUD', 'VAC_HISTORICO_AJUSTE')
   AND column_name IN (
       'DIAS_SOLICITADOS', 'DIAS_APROBADOS', 'DIAS_GOZADOS',
       'DIAS_HABILES_SOLICITADOS', 'DIAS_HABILES_APROBADOS',
       'FACTOR_PROPORCIONALIDAD'
   )
ORDER BY table_name, column_name;
