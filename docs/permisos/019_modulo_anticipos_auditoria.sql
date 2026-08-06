-- =====================================================================
-- Modulo de Anticipos exclusivo del departamento de AUDITORIA
--
-- Aditivo: NO toca CTRL_ANTICIPOS ni CTRL_FECHA_CORTE_ANTICIPO (el
-- modulo general de Control/RRHH). Crea sus propias tablas, con su
-- propia fecha de corte mensual y su propio tope de anticipo (50% del
-- sueldo, igual regla que Control pero calculada de forma
-- independiente), para no mezclar datos ni arriesgar el modulo
-- existente.
--
-- Acceso (solicitar el propio anticipo): solo el departamento
-- AUDITORIA, via APP_DEPARTAMENTO_PERMISO -- mismo mecanismo que ya
-- usa el modulo LEGAL para restringirse a un solo departamento.
--
-- Gestion (editar/marcar pagado, definir fecha de corte, exportar
-- reporte): concedida puntualmente al usuario srosero via
-- APP_USUARIO_PERMISO -- mismo mecanismo que se uso con smoran en
-- Movilizacion. A proposito SIN mapeo por rol ni departamento: srosero
-- hoy pertenece a Administracion Romeria (no a Auditoria) y aun asi
-- debe poder gestionar este modulo; el dia que cambie el encargado,
-- se reasigna con un solo UPDATE, sin tocar codigo.
-- =====================================================================

-- 1) Tablas -------------------------------------------------------------
CREATE TABLE AUD_ANTICIPOS (
    ID_AUD_ANTICIPO NUMBER NOT NULL,
    ID_USUARIO      NUMBER NOT NULL,
    SUELDO          FLOAT(126) NOT NULL,
    ANTICIPO        FLOAT(126) NOT NULL,
    FECHA_SOLICITUD DATE DEFAULT SYSDATE NOT NULL,
    ESTADO          VARCHAR2(20) DEFAULT 'PENDIENTE' NOT NULL,
    CONSTRAINT PK_AUD_ANTICIPOS PRIMARY KEY (ID_AUD_ANTICIPO),
    CONSTRAINT FK_AUD_ANTICIPOS_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT CK_AUD_ANTICIPOS_ESTADO CHECK (ESTADO IN ('PENDIENTE','PAGADO'))
);

CREATE TABLE AUD_FECHA_CORTE_ANTICIPO (
    ID_FECHA_CORTE NUMBER NOT NULL,
    FECHA_CORTE    DATE NOT NULL,
    ESTADO         CHAR(1) DEFAULT 'A' NOT NULL,
    ID_USUARIO     NUMBER,
    CONSTRAINT PK_AUD_FECHA_CORTE PRIMARY KEY (ID_FECHA_CORTE),
    CONSTRAINT CK_AUD_FECHA_CORTE_ESTADO CHECK (ESTADO IN ('A','I')),
    CONSTRAINT FK_AUD_FECHA_CORTE_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO)
);

-- 2) Permisos -------------------------------------------------------------
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO) VALUES
    (31, 'ANTICIPOS_AUD_ACCESO', 'ANTICIPOS_AUDITORIA', 'Solicitar el propio anticipo y ver el modulo de Anticipos de Auditoria', 'A');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO) VALUES
    (32, 'ANTICIPOS_AUD_GESTIONAR', 'ANTICIPOS_AUDITORIA', 'Editar y marcar como pagados los anticipos de Auditoria, definir la fecha de corte y exportar el reporte', 'A');

-- ANTICIPOS_AUD_ACCESO: todo el departamento AUDITORIA
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('AUDITORÍA', 31, 'G');

-- ANTICIPOS_AUD_GESTIONAR: concesion individual a srosero (Stefania
-- Lisbeth Rosero Chiquito, IDUSUARIO 171).
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 32, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'SROSERO';

COMMIT;

-- Verificar:
SELECT dp.DEPARTAMENTO, p.CODIGO, dp.TIPO
FROM APP_DEPARTAMENTO_PERMISO dp
JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO
WHERE p.MODULO = 'ANTICIPOS_AUDITORIA';

SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.MODULO = 'ANTICIPOS_AUDITORIA';

-- IMPORTANTE: srosero debe cerrar sesion y volver a entrar para que el
-- permiso de gestion surta efecto (los permisos se cargan una sola vez,
-- al hacer login).
