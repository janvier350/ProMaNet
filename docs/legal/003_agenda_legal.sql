-- =====================================================================
-- AGENDA LEGAL: calendario de audiencias, mediaciones, reuniones, tramites, etc. del departamento Legal.
--
--  * LEG_AGENDA_TIPO  : tipos de evento con color (editable por Legal desde la pantalla "Tipos").
--  * LEG_AGENDA       : eventos. Estados: PENDIENTE | CUMPLIDO | CANCELADO (con justificacion) | REPROGRAMADO (apunta al evento nuevo).
--                       ID_GRUPO agrupa las fechas de una misma causa registradas juntas (ej. 5 audiencias del mismo caso).
--  * LEG_AGENDA_RESP  : abogados responsables de cada evento.
--  * LEG_AGENDA_HIST  : historial de cambios (quien, cuando, que, justificacion).
-- Acceso: permiso LEGAL_ACCESO (el mismo del modulo Legal): todos los de Legal ven, registran, editan y cancelan.
-- Ejecutar en el esquema de la aplicacion.
-- =====================================================================
CREATE TABLE LEG_AGENDA_TIPO (
    ID_TIPO  NUMBER        NOT NULL,
    NOMBRE   VARCHAR2(60)  NOT NULL,
    COLOR    VARCHAR2(7)   NOT NULL,        -- #RRGGBB
    ESTADO   CHAR(1)       DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_LEG_AGENDA_TIPO PRIMARY KEY (ID_TIPO),
    CONSTRAINT UK_LEG_AGENDA_TIPO_NOM UNIQUE (NOMBRE)
);

CREATE TABLE LEG_AGENDA (
    ID_EVENTO        NUMBER         NOT NULL,
    ID_GRUPO         NUMBER,
    ID_TIPO          NUMBER         NOT NULL,
    ASUNTO           VARCHAR2(200)  NOT NULL,
    FECHA            DATE           NOT NULL,
    HORA_INI         VARCHAR2(5)    NOT NULL,       -- HH:MM
    HORA_FIN         VARCHAR2(5),
    MODALIDAD        CHAR(1)        DEFAULT 'P' NOT NULL,   -- P presencial, V virtual
    LUGAR            VARCHAR2(300),                 -- direccion o enlace (Zoom, etc.)
    COMENTARIO       VARCHAR2(1000),
    ESTADO           VARCHAR2(12)   DEFAULT 'PENDIENTE' NOT NULL,
    JUSTIFICACION    VARCHAR2(500),
    ID_REPROG_A      NUMBER,                        -- si fue reprogramado: id del evento nuevo
    ID_CREA          NUMBER,
    FECHA_CREA       DATE           DEFAULT SYSDATE NOT NULL,
    ID_MODIFICA      NUMBER,
    FECHA_MODIFICA   DATE,
    CONSTRAINT PK_LEG_AGENDA PRIMARY KEY (ID_EVENTO),
    CONSTRAINT FK_LEG_AGENDA_TIPO FOREIGN KEY (ID_TIPO) REFERENCES LEG_AGENDA_TIPO (ID_TIPO),
    CONSTRAINT CK_LEG_AGENDA_ESTADO CHECK (ESTADO IN ('PENDIENTE','CUMPLIDO','CANCELADO','REPROGRAMADO')),
    CONSTRAINT CK_LEG_AGENDA_MOD CHECK (MODALIDAD IN ('P','V'))
);
CREATE INDEX IX_LEG_AGENDA_FECHA ON LEG_AGENDA (FECHA);
CREATE INDEX IX_LEG_AGENDA_GRUPO ON LEG_AGENDA (ID_GRUPO);

CREATE TABLE LEG_AGENDA_RESP (
    ID_EVENTO  NUMBER NOT NULL,
    ID_USUARIO NUMBER NOT NULL,
    CONSTRAINT PK_LEG_AGENDA_RESP PRIMARY KEY (ID_EVENTO, ID_USUARIO)
);
CREATE INDEX IX_LEG_AGENDA_RESP_USU ON LEG_AGENDA_RESP (ID_USUARIO);

CREATE TABLE LEG_AGENDA_HIST (
    ID_HIST    NUMBER        NOT NULL,
    ID_EVENTO  NUMBER        NOT NULL,
    FECHA_HORA DATE          DEFAULT SYSDATE NOT NULL,
    ID_USUARIO NUMBER,
    ACCION     VARCHAR2(20)  NOT NULL,     -- CREADO | EDITADO | CUMPLIDO | CANCELADO | REPROGRAMADO | REABIERTO
    DETALLE    VARCHAR2(800),
    CONSTRAINT PK_LEG_AGENDA_HIST PRIMARY KEY (ID_HIST)
);
CREATE INDEX IX_LEG_AGENDA_HIST_EV ON LEG_AGENDA_HIST (ID_EVENTO);

-- Tipos iniciales (Legal puede agregar, renombrar, cambiar color o desactivar)
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (1, 'Audiencia', '#5e72e4');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (2, 'Mediación', '#2dce89');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (3, 'Reunión', '#fb6340');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (4, 'Trámite', '#11cdef');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (5, 'Diligencia', '#8965e0');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (6, 'Pericia', '#e91e8c');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (7, 'Plazo / término', '#d4a017');
INSERT INTO LEG_AGENDA_TIPO (ID_TIPO, NOMBRE, COLOR) VALUES (8, 'Otro', '#8392ab');
COMMIT;
