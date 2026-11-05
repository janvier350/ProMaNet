-- =====================================================================
-- Inventario / Mantenimiento - FASE 2: avisos al usuario + solicitud por ticket.
--
-- Interruptor global de los avisos a usuarios. Nace APAGADO a proposito: al
-- lanzar el seguimiento casi todos los equipos figuran como vencidos (no hay
-- historial) y asi no se avisa a todos los usuarios a la vez. Tecnologia lo
-- enciende desde Inventario > Mantenimientos cuando este lista la primera ronda.
--
-- EJECUTAR ANTES DE DESPLEGAR (requiere el 046).
-- =====================================================================
CREATE TABLE INV_MANT_CONFIG (
    CLAVE       VARCHAR2(40)   NOT NULL,
    VALOR       VARCHAR2(100),
    ID_USUARIO  NUMBER,
    FECHA       DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_INV_MANT_CONFIG PRIMARY KEY (CLAVE)
);

INSERT INTO INV_MANT_CONFIG (CLAVE, VALOR) VALUES ('AVISOS_USUARIO', 'N');
COMMIT;
