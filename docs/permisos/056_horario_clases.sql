-- =====================================================================
-- HORARIO DE CLASES (usuarios que estudian): dias y horas de la semana en que NO estan disponibles en la oficina.
--
-- Cada usuario registra una solicitud con la vigencia (inicio y fin del semestre) y uno o varios bloques
-- (dia de la semana + hora de inicio + hora de fin + materia opcional). La aprueba su jefe directo o la administracion
-- (gestores de vacaciones de su grupo): el primero que lo haga. El jefe/administracion tambien puede registrarlo por el
-- usuario, y en ese caso queda aprobado de inmediato.
-- Al aprobarse una solicitud nueva, las anteriores aprobadas del mismo usuario cuya vigencia se cruce quedan REEMPLAZADAS.
-- No hay permisos nuevos: cualquier usuario registra el suyo; aprueban jefe directo y gestores de Vacaciones.
-- Ejecutar en el esquema de la aplicacion.
-- =====================================================================
CREATE TABLE HOR_CLASE_SOL (
    ID_SOL         NUMBER        NOT NULL,
    ID_USUARIO     NUMBER        NOT NULL,
    FECHA_DESDE    DATE          NOT NULL,
    FECHA_HASTA    DATE          NOT NULL,
    ESTADO         VARCHAR2(12)  DEFAULT 'PENDIENTE' NOT NULL,   -- PENDIENTE | APROBADO | RECHAZADO | CANCELADO | REEMPLAZADO
    OBSERVACION    VARCHAR2(500),
    ID_REGISTRA    NUMBER,                                        -- quien lo registro (el usuario o su jefe/administracion)
    FECHA_REG      DATE          DEFAULT SYSDATE NOT NULL,
    ID_APRUEBA     NUMBER,
    FECHA_APRUEBA  DATE,
    MOTIVO_RECHAZO VARCHAR2(500),
    CONSTRAINT PK_HOR_CLASE_SOL PRIMARY KEY (ID_SOL),
    CONSTRAINT CK_HOR_CLASE_SOL_ESTADO CHECK (ESTADO IN ('PENDIENTE','APROBADO','RECHAZADO','CANCELADO','REEMPLAZADO')),
    CONSTRAINT CK_HOR_CLASE_SOL_FECHAS CHECK (FECHA_HASTA >= FECHA_DESDE)
);
CREATE INDEX IX_HOR_CLASE_SOL_USU ON HOR_CLASE_SOL (ID_USUARIO, ESTADO);

CREATE TABLE HOR_CLASE_BLOQUE (
    ID_SOL    NUMBER       NOT NULL,
    DIA       NUMBER(1)    NOT NULL,       -- 1 lunes ... 7 domingo
    HORA_INI  VARCHAR2(5)  NOT NULL,       -- HH:MM
    HORA_FIN  VARCHAR2(5)  NOT NULL,
    MATERIA   VARCHAR2(100),
    CONSTRAINT CK_HOR_CLASE_BLOQUE_DIA CHECK (DIA BETWEEN 1 AND 7)
);
CREATE INDEX IX_HOR_CLASE_BLOQUE_SOL ON HOR_CLASE_BLOQUE (ID_SOL);
