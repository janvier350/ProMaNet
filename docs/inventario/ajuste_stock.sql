-- =====================================================================
-- Inventario de suministros: AJUSTES de stock.
--
-- Permite cargar existencia a un producto (ej. el que esta en 0 porque
-- llego en cajas y solo falta ingresar la cantidad) SIN pasar por un
-- ingreso de compra completo, dejando registrado como AJUSTE: que
-- producto, cuanto, existencia antes/despues, motivo, quien y cuando.
--
-- Aditivo: no modifica tablas existentes.
-- =====================================================================
CREATE TABLE INV_SUMINISTRO_AJUSTE (
    ID_AJUSTE            NUMBER         NOT NULL,
    ID_PRODUCTO          NUMBER         NOT NULL,
    CANTIDAD             NUMBER         NOT NULL,
    EXISTENCIA_ANTERIOR  NUMBER,
    EXISTENCIA_NUEVA     NUMBER,
    MOTIVO               VARCHAR2(100)  NOT NULL,
    OBSERVACION          VARCHAR2(300),
    ID_USUARIO           NUMBER,
    FECHA                DATE           DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_INV_SUM_AJUSTE PRIMARY KEY (ID_AJUSTE)
);

CREATE INDEX IX_INV_SUM_AJUSTE_PROD ON INV_SUMINISTRO_AJUSTE (ID_PRODUCTO, FECHA);
