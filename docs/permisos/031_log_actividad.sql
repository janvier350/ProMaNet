-- =====================================================================
-- Log de actividad de usuarios (auditoria de uso del sistema)
--
-- Objetivo: poder responder "quien usa ProMaNet, con que frecuencia y
-- en que modulos" para evaluar que mas conviene desarrollar. Un
-- ServletFilter graba una fila por request bajo /ProMaNet/* (ver
-- COMUN.ActividadFilter) y ademas los servlets de negocio clave llaman
-- a COMUN.LogActividad.registrar() con una descripcion humana cuando
-- hacen una accion de valor (crear ticket, aprobar vacacion, etc.).
--
-- Retencion: 90 dias. Se puede limpiar con la query al final de este
-- archivo o programarla como job de Oracle.
--
-- Permiso: AUDIT_VER_ACTIVIDAD -- concedido SOLO a nivel individual
-- (no por cargo). Se otorga aqui a jvaras y smoran como admin inicial;
-- se puede agregar a mas gente despues desde la pantalla de permisos.
-- =====================================================================


-- 1) Tabla principal --------------------------------------------------
CREATE TABLE LOG_ACTIVIDAD (
    ID_LOG         NUMBER NOT NULL,
    FECHA_HORA     DATE   DEFAULT SYSDATE NOT NULL,
    ID_USUARIO     NUMBER,                      -- null si fue antes de login (ej. intento fallido)
    USUARIO_LOGIN  VARCHAR2(60),                -- snapshot (por si se borra el USUARIO)
    MODULO         VARCHAR2(40) NOT NULL,       -- INVENTARIO, SOPORTES, VACACIONES, ANTICIPOS, AGENDA, MOVILIZACION, PERMISOS, LOGIN, PERIFERICOS, ...
    ACCION         VARCHAR2(30) NOT NULL,       -- VER, CREAR, ACTUALIZAR, APROBAR, RECHAZAR, ELIMINAR, IMPRIMIR, EXPORTAR, LOGIN, LOGOUT
    DESCRIPCION    VARCHAR2(500),               -- texto humano opcional: "Creo ticket #544", "Aprobo vacaciones de Juan Perez"
    URL            VARCHAR2(300),               -- URI relativa, sin query (evita loguear parametros con datos sensibles)
    IP             VARCHAR2(45),                -- IPv4 o IPv6
    CONSTRAINT PK_LOG_ACTIVIDAD PRIMARY KEY (ID_LOG),
    CONSTRAINT CK_LOG_ACTIVIDAD_MODULO CHECK (LENGTH(MODULO) > 0),
    CONSTRAINT CK_LOG_ACTIVIDAD_ACCION CHECK (LENGTH(ACCION) > 0)
);

CREATE INDEX IX_LOG_ACT_FECHA   ON LOG_ACTIVIDAD (FECHA_HORA);
CREATE INDEX IX_LOG_ACT_USUARIO ON LOG_ACTIVIDAD (ID_USUARIO, FECHA_HORA);
CREATE INDEX IX_LOG_ACT_MODULO  ON LOG_ACTIVIDAD (MODULO, FECHA_HORA);


-- 2) Permiso nuevo + concesion inicial a admin ------------------------
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (36, 'AUDIT_VER_ACTIVIDAD', 'SISTEMA', 'Ver el reporte de actividad de usuarios del sistema (quien usa que, cuando)');

-- Concesion individual a jvaras y smoran (admins actuales). No se
-- concede por rol -- es un reporte sensible, se otorga uno por uno.
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) IN ('JVARAS','SMORAN') AND p.CODIGO = 'AUDIT_VER_ACTIVIDAD'
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;


-- 3) Limpieza por retencion (90 dias) --------------------------------
-- Corre esta sentencia manualmente de vez en cuando, o programala
-- como un job de Oracle. Es segura: solo borra registros de LOG_ACTIVIDAD
-- mas viejos que 90 dias.
--
-- DELETE FROM LOG_ACTIVIDAD WHERE FECHA_HORA < SYSDATE - 90;
-- COMMIT;


-- 4) Verificar --------------------------------------------------------
SELECT COUNT(*) AS total_logs FROM LOG_ACTIVIDAD;
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'AUDIT_VER_ACTIVIDAD';
