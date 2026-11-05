-- =====================================================================
-- Inventario: MANTENIMIENTO PREVENTIVO de equipos (limpieza y revision).
--
-- Aplica a los equipos de INV_EQUIPOS en servicio (estado Asignado,
-- Disponible, Mantenimiento o Infraestructura): portatiles, impresoras,
-- DVR, NVR, servidores, etc. Los perifericos (mouse, teclado) no entran.
--
-- Regla de periodicidad (la calcula el sistema; se puede fijar otra por equipo):
--   * equipos de hasta 2 anos desde la compra: cada 12 meses
--   * equipos de mas de 2 anos:               cada 6 meses
--   Se avisa 15 dias antes ("Proximo") y desde que vence ("Vencido").
--
-- Permisos (los pueden usar tambien companeros de Tecnologia, pasantes incluidos,
-- porque se conceden al DEPARTAMENTO, no solo a personas):
--   INVENTARIO_MANTENIMIENTO_VER        ver el panel de seguimiento
--   INVENTARIO_MANTENIMIENTO_GESTIONAR  registrar/eliminar mantenimientos, ajustar periodicidad
--
-- EJECUTAR ANTES DE DESPLEGAR.
-- =====================================================================

-- 1) Tabla de mantenimientos -------------------------------------------------
CREATE TABLE INV_MANTENIMIENTO (
    ID_MANTENIMIENTO     NUMBER         NOT NULL,
    IDINVEQUIPO          NUMBER         NOT NULL,
    FECHA_MANT           DATE           NOT NULL,
    TIPO                 VARCHAR2(12)   DEFAULT 'PREVENTIVO' NOT NULL,
    ACTIVIDADES          VARCHAR2(400),
    OBSERVACIONES        VARCHAR2(500),
    ID_TECNICO           NUMBER,
    ID_SOPORTE           NUMBER,            -- ticket relacionado (fase 2)
    ID_USUARIO_REGISTRA  NUMBER,
    FECHA_REGISTRO       DATE           DEFAULT SYSDATE NOT NULL,
    ESTADO               CHAR(1)        DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_INV_MANTENIMIENTO PRIMARY KEY (ID_MANTENIMIENTO),
    CONSTRAINT FK_INV_MANT_EQUIPO FOREIGN KEY (IDINVEQUIPO) REFERENCES INV_EQUIPOS(IDINVEQUIPO),
    CONSTRAINT CK_INV_MANT_TIPO CHECK (TIPO IN ('PREVENTIVO','CORRECTIVO')),
    CONSTRAINT CK_INV_MANT_ESTADO CHECK (ESTADO IN ('A','X'))
);
CREATE INDEX IX_INV_MANT_EQUIPO ON INV_MANTENIMIENTO (IDINVEQUIPO, FECHA_MANT);

-- 2) Ajustes por equipo --------------------------------------------------------
--    MANT_PERIODICIDAD_MESES: NULL = automatica (regla de arriba).
--    MANT_APLICA: 'N' excluye al equipo del plan (ej. un monitor o switch).
ALTER TABLE INV_EQUIPOS ADD (MANT_PERIODICIDAD_MESES NUMBER(3), MANT_APLICA CHAR(1) DEFAULT 'S' NOT NULL);
ALTER TABLE INV_EQUIPOS ADD CONSTRAINT CK_INV_EQUIPOS_MANT_APLICA CHECK (MANT_APLICA IN ('S','N'));

-- 3) Permisos ------------------------------------------------------------------
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO)
    SELECT NVL(MAX(ID_PERMISO), 0) + 1, 'INVENTARIO_MANTENIMIENTO_VER', 'INVENTARIO',
           'Ver el seguimiento de mantenimientos de equipos (vencidos, proximos, historial)', 'A'
    FROM APP_PERMISO WHERE NOT EXISTS (SELECT 1 FROM APP_PERMISO WHERE CODIGO = 'INVENTARIO_MANTENIMIENTO_VER');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO)
    SELECT NVL(MAX(ID_PERMISO), 0) + 1, 'INVENTARIO_MANTENIMIENTO_GESTIONAR', 'INVENTARIO',
           'Registrar y eliminar mantenimientos de equipos y ajustar su periodicidad', 'A'
    FROM APP_PERMISO WHERE NOT EXISTS (SELECT 1 FROM APP_PERMISO WHERE CODIGO = 'INVENTARIO_MANTENIMIENTO_GESTIONAR');

-- Todo el departamento TECNOLOGIA (incluye a futuros companeros y pasantes)
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO)
    SELECT 'TECNOLOGÍA', p.ID_PERMISO, 'G' FROM APP_PERMISO p
    WHERE p.CODIGO IN ('INVENTARIO_MANTENIMIENTO_VER', 'INVENTARIO_MANTENIMIENTO_GESTIONAR')
      AND NOT EXISTS (SELECT 1 FROM APP_DEPARTAMENTO_PERMISO d WHERE UPPER(d.DEPARTAMENTO) = 'TECNOLOGÍA' AND d.ID_PERMISO = p.ID_PERMISO);

-- Y a jvaras y cvaras de forma individual (por si su departamento en USUARIO no es TECNOLOGIA)
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) IN ('JVARAS', 'CVARAS')
      AND p.CODIGO IN ('INVENTARIO_MANTENIMIENTO_VER', 'INVENTARIO_MANTENIMIENTO_GESTIONAR')
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;

-- 4) Verificacion ----------------------------------------------------------------
SELECT d.DEPARTAMENTO, p.CODIGO, d.TIPO FROM APP_DEPARTAMENTO_PERMISO d JOIN APP_PERMISO p ON p.ID_PERMISO = d.ID_PERMISO
WHERE p.CODIGO LIKE 'INVENTARIO_MANTENIMIENTO%';
SELECT u.USUARIO, p.CODIGO, up.TIPO FROM APP_USUARIO_PERMISO up JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO LIKE 'INVENTARIO_MANTENIMIENTO%' ORDER BY 1, 2;
