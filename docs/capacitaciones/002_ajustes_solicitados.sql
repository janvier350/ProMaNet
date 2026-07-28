--------------------------------------------------------------------------
-- Modulo CAPACITACIONES: ajustes pedidos por SMORAN tras la primera
-- prueba (28 jul 2026):
--   1) "Compania que Factura" pasa de texto libre a un select contra el
--      catalogo real COMPANIA (la misma tabla que usa el resto del
--      sistema), via ID_COMPANIA_FACTURA.
--   2) El Estado de pago en la practica solo es "PAGADO" (se quita
--      "POR COBRAR").
--   3) La forma de pago "CHEQUE" pasa a llamarse "CHEQUE/DEPOSITO".
-- Ejecutar en la base de RRHH, DESPUES de 001_modulo_capacitaciones.sql.
-- Revisar y hacer COMMIT al final.
--------------------------------------------------------------------------

-- 1. Compania que factura -> FK real a COMPANIA -----------------------
ALTER TABLE CAPACITACIONES_SEMINARIO ADD ID_COMPANIA_FACTURA NUMBER;

-- Migracion best-effort de lo ya capturado como texto libre, buscando
-- una coincidencia exacta (sin distinguir mayus/minus) en COMPANIA.
UPDATE CAPACITACIONES_SEMINARIO s
   SET s.ID_COMPANIA_FACTURA = (
        SELECT c.IDCOMPANIA FROM COMPANIA c
         WHERE UPPER(c.COMPANIA) = UPPER(s.COMPANIA_FACTURA)
           AND ROWNUM = 1)
 WHERE s.COMPANIA_FACTURA IS NOT NULL;

-- Revisar antes de continuar: si algun registro no encontro coincidencia
-- (quedo con ID_COMPANIA_FACTURA NULL pero COMPANIA_FACTURA no era nulo),
-- asignarlo a mano antes de eliminar la columna vieja.
SELECT ID_SEMINARIO, COMPANIA_FACTURA, ID_COMPANIA_FACTURA
  FROM CAPACITACIONES_SEMINARIO
 WHERE COMPANIA_FACTURA IS NOT NULL AND ID_COMPANIA_FACTURA IS NULL;

ALTER TABLE CAPACITACIONES_SEMINARIO
    ADD CONSTRAINT FK_CAPAC_SEM_COMPFACT FOREIGN KEY (ID_COMPANIA_FACTURA) REFERENCES COMPANIA(IDCOMPANIA);

ALTER TABLE CAPACITACIONES_SEMINARIO DROP COLUMN COMPANIA_FACTURA;

-- 2. Estado de pago: solo "PAGADO" -------------------------------------
UPDATE CAPACITACIONES_SEMINARIO SET ESTADO_PAGO = 'PAGADO' WHERE ESTADO_PAGO = 'POR COBRAR';

ALTER TABLE CAPACITACIONES_SEMINARIO DROP CONSTRAINT CK_CAPAC_SEM_ESTADOPAGO;
ALTER TABLE CAPACITACIONES_SEMINARIO
    ADD CONSTRAINT CK_CAPAC_SEM_ESTADOPAGO CHECK (ESTADO_PAGO = 'PAGADO');

-- 3. Forma de pago: "CHEQUE" -> "CHEQUE/DEPOSITO" ----------------------
UPDATE CAPACITACIONES_SEMINARIO SET FORMA_PAGO = 'CHEQUE/DEPOSITO' WHERE FORMA_PAGO = 'CHEQUE';

ALTER TABLE CAPACITACIONES_SEMINARIO DROP CONSTRAINT CK_CAPAC_SEM_FORMAPAGO;
ALTER TABLE CAPACITACIONES_SEMINARIO
    ADD CONSTRAINT CK_CAPAC_SEM_FORMAPAGO CHECK (FORMA_PAGO IN ('EFECTIVO','TRANSFERENCIA','CHEQUE/DEPOSITO','CANJE'));

-- 4. Verificacion --------------------------------------------------------
SELECT s.ID_SEMINARIO, s.NOMBRE_SEMINARIO, s.ESTADO_PAGO, s.FORMA_PAGO,
       s.ID_COMPANIA_FACTURA, c.COMPANIA
  FROM CAPACITACIONES_SEMINARIO s
  LEFT JOIN COMPANIA c ON c.IDCOMPANIA = s.ID_COMPANIA_FACTURA;

-- Si todo bien: COMMIT;  Si no: ROLLBACK;
