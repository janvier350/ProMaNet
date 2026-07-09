-- =====================================================================
-- Modulo de Movilizacion (nuevo)
--
-- Aditivo: crea 3 tablas nuevas (catalogos + solicitudes) y agrega
-- 2 permisos al sistema de permisos ya existente. No modifica ninguna
-- tabla existente.
-- =====================================================================

-- 1) Catalogo de movilizadores (quien ejecuta la movilizacion) --------
CREATE TABLE MOV_MOVILIZADOR (
    ID_MOVILIZADOR NUMBER PRIMARY KEY,
    NOMBRE         VARCHAR2(100) NOT NULL,
    ESTADO         CHAR(1) DEFAULT 'A' NOT NULL
);
INSERT INTO MOV_MOVILIZADOR (ID_MOVILIZADOR, NOMBRE) VALUES (1, 'Carlos Briones');
INSERT INTO MOV_MOVILIZADOR (ID_MOVILIZADOR, NOMBRE) VALUES (2, 'Particular');

-- 2) Catalogo de motivos de movilizacion -------------------------------
CREATE TABLE MOV_MOTIVO (
    ID_MOTIVO   NUMBER PRIMARY KEY,
    DESCRIPCION VARCHAR2(100) NOT NULL,
    ESTADO      CHAR(1) DEFAULT 'A' NOT NULL
);
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (1,  'Entrega de documentos');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (2,  'Retiro de documentos');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (3,  'Movilizar personal');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (4,  'Traslado de activos (sillas, laptops)');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (5,  'Outsourcing');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (6,  'Cobros');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (7,  'Pagos');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (8,  'Cambio cheques');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (9,  'Movilizacion Xavier Parrales');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (10, 'Entrega de efectivo');
INSERT INTO MOV_MOTIVO (ID_MOTIVO, DESCRIPCION) VALUES (11, 'Retiro de efectivo');

-- 3) Solicitudes de movilizacion ---------------------------------------
CREATE TABLE MOV_SOLICITUD (
    ID_MOV_SOLICITUD   NUMBER PRIMARY KEY,
    ID_MOVILIZADOR     NUMBER NOT NULL,
    ID_MOTIVO          NUMBER NOT NULL,
    FECHA              DATE NOT NULL,
    HORA_INICIO        VARCHAR2(5) NOT NULL,   -- 'HH24:MI'
    HORA_FIN           VARCHAR2(5) NOT NULL,   -- 'HH24:MI'
    IDUSUARIO          NUMBER NOT NULL,          -- solicitante
    ID_DEPARTAMENTO    NUMBER NOT NULL,
    COMENTARIO         VARCHAR2(500),
    ESTADO             VARCHAR2(15) DEFAULT 'PENDIENTE' NOT NULL,
    FECHA_SOLICITUD    DATE DEFAULT SYSDATE NOT NULL,
    IDUSUARIO_GESTIONA NUMBER,
    FECHA_GESTION      DATE,
    MOTIVO_RECHAZO     VARCHAR2(500),
    CONSTRAINT FK_MOVSOL_MOVILIZADOR FOREIGN KEY (ID_MOVILIZADOR) REFERENCES MOV_MOVILIZADOR(ID_MOVILIZADOR),
    CONSTRAINT FK_MOVSOL_MOTIVO FOREIGN KEY (ID_MOTIVO) REFERENCES MOV_MOTIVO(ID_MOTIVO),
    CONSTRAINT FK_MOVSOL_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_MOVSOL_USUARIO_GEST FOREIGN KEY (IDUSUARIO_GESTIONA) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT CK_MOVSOL_ESTADO CHECK (ESTADO IN ('PENDIENTE','APROBADA','RECHAZADA','CANCELADA','COMPLETADA'))
);

-- =====================================================================
-- Permisos del modulo (usa el mismo sistema APP_PERMISO/APP_ROL_PERMISO/
-- APP_USUARIO_PERMISO ya creado en 001_esquema_permisos.sql)
-- =====================================================================
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (9, 'MOVILIZACION_SOLICITAR', 'MOVILIZACION', 'Solicitar movilizacion y ver el calendario');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (10, 'MOVILIZACION_GESTIONAR', 'MOVILIZACION', 'Aprobar, rechazar y modificar la hora de cualquier solicitud de movilizacion');

-- MOVILIZACION_SOLICITAR: todos los cargos
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 9 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE','ANALISTA');

-- MOVILIZACION_GESTIONAR: a proposito, SIN mapeo por rol. Es pura
-- concesion individual (APP_USUARIO_PERMISO), para que el "encargado"
-- de aprobar movilizaciones se pueda transferir a otra persona sin
-- tocar cargos ni codigo.
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (162, 10, 'G');

COMMIT;

-- Verificar:
SELECT u.USUARIO, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.MODULO = 'MOVILIZACION';
