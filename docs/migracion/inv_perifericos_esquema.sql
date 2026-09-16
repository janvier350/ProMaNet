-- =====================================================================
-- Modulo de Perifericos -- esquema y catalogos semilla
--
-- Se maneja como un modulo paralelo a INV_EQUIPOS: un periferico tiene
-- identidad propia (marca, modelo, serial, foto, garantia) y se puede
-- entregar/devolver/reemplazar como cualquier otro activo. Se asigna a
-- un USUARIO (no a un equipo) -- si el usuario cambia de laptop, sus
-- perifericos siguen con el, que es lo mas fiel a como funciona en la
-- realidad (el mouse es del empleado, no de la maquina).
--
-- Cada movimiento de entrega registra su MOTIVO (primera asignacion,
-- reemplazo por daño, prestamo temporal, etc.) para tener trazabilidad
-- de por que se entrego cada unidad -- clave para el acta.
--
-- Cuatro tablas:
--   1) INV_PERIFERICO_TIPO      -- catalogo (mouse, teclado, cargador, ...)
--   2) INV_PERIFERICO_MOTIVO    -- catalogo (primera, daño, prestamo, ...)
--   3) INV_PERIFERICO           -- una fila por unidad fisica
--   4) INV_PERIFERICO_ASIGNACION-- historico de entregas/devoluciones
-- =====================================================================


-- 1) Catalogo de tipos ---------------------------------------------------
CREATE TABLE INV_PERIFERICO_TIPO (
    ID_TIPO       NUMBER NOT NULL,
    CODIGO        VARCHAR2(30) NOT NULL,   -- p.ej. MOUSE, TECLADO, CARGADOR
    DESCRIPCION   VARCHAR2(100) NOT NULL,  -- lo que se muestra en pantalla
    ESTADO        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_INV_PERIF_TIPO PRIMARY KEY (ID_TIPO),
    CONSTRAINT UK_INV_PERIF_TIPO_CODIGO UNIQUE (CODIGO),
    CONSTRAINT CK_INV_PERIF_TIPO_ESTADO CHECK (ESTADO IN ('A','I'))
);

INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (1,  'MOUSE',           'Mouse');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (2,  'TECLADO',         'Teclado');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (3,  'TECLADO_NUM',     'Teclado numerico');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (4,  'CARGADOR',        'Cargador');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (5,  'LECTOR_DVD',      'Lector DVD externo');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (6,  'AURICULARES',     'Auriculares / diadema');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (7,  'DOCKING',         'Docking station');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (8,  'ADAPTADOR_VIDEO', 'Adaptador de video (HDMI/VGA)');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (9,  'WEBCAM',          'Webcam');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (10, 'HUB_USB',         'Hub USB');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (11, 'PARLANTES',       'Parlantes');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (12, 'MONITOR_EXTRA',   'Monitor adicional');
INSERT INTO INV_PERIFERICO_TIPO (ID_TIPO, CODIGO, DESCRIPCION) VALUES (13, 'OTRO',            'Otro');


-- 2) Catalogo de motivos de entrega -------------------------------------
CREATE TABLE INV_PERIFERICO_MOTIVO (
    ID_MOTIVO     NUMBER NOT NULL,
    CODIGO        VARCHAR2(30) NOT NULL,
    DESCRIPCION   VARCHAR2(100) NOT NULL,
    ESTADO        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_INV_PERIF_MOTIVO PRIMARY KEY (ID_MOTIVO),
    CONSTRAINT UK_INV_PERIF_MOTIVO_CODIGO UNIQUE (CODIGO),
    CONSTRAINT CK_INV_PERIF_MOTIVO_ESTADO CHECK (ESTADO IN ('A','I'))
);

INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (1, 'PRIMERA_ASIGNACION', 'Primera asignacion');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (2, 'REEMPLAZO_DANO',     'Reemplazo por daño');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (3, 'REEMPLAZO_PERDIDA',  'Reemplazo por perdida');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (4, 'REEMPLAZO_ROBO',     'Reemplazo por robo');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (5, 'REEMPLAZO_DESGASTE', 'Reemplazo por desgaste / fin de vida util');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (6, 'UPGRADE',            'Upgrade de equipo');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (7, 'AJUSTE_DE_PUESTO',   'Ajuste de puesto de trabajo');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (8, 'PRESTAMO_TEMPORAL',  'Prestamo temporal');
INSERT INTO INV_PERIFERICO_MOTIVO (ID_MOTIVO, CODIGO, DESCRIPCION) VALUES (9, 'OTRO',               'Otro (especificar en observaciones)');


-- 3) Perifericos ---------------------------------------------------------
CREATE TABLE INV_PERIFERICO (
    ID_PERIFERICO     NUMBER NOT NULL,
    ID_TIPO           NUMBER NOT NULL,
    MARCA             VARCHAR2(100),
    MODELO            VARCHAR2(100),
    SERIAL            VARCHAR2(100),          -- opcional: hay perifericos sin serial (mouses baratos, cables)
    FECHACOMPRA       DATE,
    UBICACIONOFICINA  VARCHAR2(50),
    EMPRESA           VARCHAR2(100),
    OBSERVACIONES     VARCHAR2(1000),
    FICHERO           VARCHAR2(300),          -- ruta/nombre de la foto (mismo patron que INV_EQUIPOS.FICHERO)
    -- D=Disponible A=Asignado B=Backup F=Fuera de servicio V=Vendido R=Robado X=Baja
    ESTADO            VARCHAR2(2) DEFAULT 'D' NOT NULL,
    -- Soft delete (mismo patron que INV_EQUIPOS.ESTADO_AI)
    ESTADO_AI         CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_INV_PERIFERICO PRIMARY KEY (ID_PERIFERICO),
    CONSTRAINT FK_INV_PERIF_TIPO FOREIGN KEY (ID_TIPO) REFERENCES INV_PERIFERICO_TIPO(ID_TIPO),
    CONSTRAINT CK_INV_PERIF_ESTADO_AI CHECK (ESTADO_AI IN ('A','I'))
);


-- 4) Historico de asignaciones ------------------------------------------
CREATE TABLE INV_PERIFERICO_ASIGNACION (
    ID_ASIGNACION           NUMBER NOT NULL,
    ID_PERIFERICO           NUMBER NOT NULL,
    IDUSUARIO               NUMBER NOT NULL,   -- FK a USUARIO.IDUSUARIO
    ID_MOTIVO               NUMBER NOT NULL,
    OBSERVACION_MOTIVO      VARCHAR2(500),     -- obligatorio si el motivo es OTRO (validado en el servlet)
    -- Trazabilidad de reemplazos: si esta entrega reemplaza un periferico
    -- que se dio de baja, apunta al ID del anterior. Null para primera
    -- asignacion o entregas sueltas.
    ID_PERIFERICO_REEMPLAZA NUMBER,
    FECHAASIGNACION         DATE DEFAULT SYSDATE NOT NULL,
    FECHADEVOLUCION         DATE,              -- null mientras la asignacion sigue viva
    -- A=Activa (el periferico esta con esa persona hoy)
    -- I=Inactiva (ya se devolvio o se reemplazo)
    ESTADO                  CHAR(1) DEFAULT 'A' NOT NULL,
    ID_USUARIO_REGISTRA     NUMBER,            -- quien registro la entrega (para el acta / auditoria)
    CONSTRAINT PK_INV_PERIF_ASIG PRIMARY KEY (ID_ASIGNACION),
    CONSTRAINT FK_INV_PERIF_ASIG_PERIF FOREIGN KEY (ID_PERIFERICO) REFERENCES INV_PERIFERICO(ID_PERIFERICO),
    CONSTRAINT FK_INV_PERIF_ASIG_MOTIVO FOREIGN KEY (ID_MOTIVO) REFERENCES INV_PERIFERICO_MOTIVO(ID_MOTIVO),
    CONSTRAINT FK_INV_PERIF_ASIG_REEMP FOREIGN KEY (ID_PERIFERICO_REEMPLAZA) REFERENCES INV_PERIFERICO(ID_PERIFERICO),
    CONSTRAINT CK_INV_PERIF_ASIG_ESTADO CHECK (ESTADO IN ('A','I'))
);

CREATE INDEX IX_INV_PERIF_ASIG_USUARIO  ON INV_PERIFERICO_ASIGNACION (IDUSUARIO, ESTADO);
CREATE INDEX IX_INV_PERIF_ASIG_PERIF    ON INV_PERIFERICO_ASIGNACION (ID_PERIFERICO, ESTADO);

COMMIT;

-- Verificar (deben salir los conteos > 0):
SELECT 'Tipos'   AS tabla, COUNT(*) AS filas FROM INV_PERIFERICO_TIPO   UNION ALL
SELECT 'Motivos' AS tabla, COUNT(*) AS filas FROM INV_PERIFERICO_MOTIVO;
