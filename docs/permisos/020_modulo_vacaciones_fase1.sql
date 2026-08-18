-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- Fase 1: datos base
--
-- Antes de poder calcular saldos ni tramitar solicitudes, el sistema
-- necesita dos datos que hoy no existen en ningun lado:
--   1) La fecha real de ingreso de cada empleado (no la fecha del
--      Aviso de Entrada del IESS, que puede ser distinta -- ver
--      PATRONAL_AE.xlsx, columna "Fecha de Ingreso").
--   2) Quien es el jefe directo de cada empleado (no existe ninguna
--      relacion de este tipo en el sistema hoy).
--
-- Esta fase crea SOLO eso: una tabla de configuracion por usuario y
-- el permiso para mantenerla desde una pantalla nueva. No crea
-- todavia solicitudes, saldos ni aprobaciones (eso es la Fase 2/3).
-- =====================================================================

-- 1) Tabla ---------------------------------------------------------------
CREATE TABLE VAC_CONFIG_USUARIO (
    ID_USUARIO         NUMBER NOT NULL,
    FECHA_INGRESO       DATE,
    ID_JEFE_DIRECTO      NUMBER,
    ID_USUARIO_ACTUALIZA NUMBER,
    FECHA_ACTUALIZACION  DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_VAC_CONFIG_USUARIO PRIMARY KEY (ID_USUARIO),
    CONSTRAINT FK_VAC_CONFIG_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_VAC_CONFIG_JEFE FOREIGN KEY (ID_JEFE_DIRECTO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT CK_VAC_CONFIG_NO_AUTOJEFE CHECK (ID_JEFE_DIRECTO IS NULL OR ID_JEFE_DIRECTO <> ID_USUARIO)
);

-- 2) Permiso ---------------------------------------------------------------
-- Mantener fecha de ingreso y jefe directo de cualquier empleado: solo
-- RRHH/Administracion (mismo grupo que ya administra sueldos en
-- Control), no por departamento -- este dato es transversal a toda la
-- compania.
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO) VALUES
    (33, 'VACACIONES_CONFIGURAR', 'VACACIONES', 'Mantener fecha de ingreso y jefe directo de los empleados (base para el calculo de vacaciones)', 'A');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 33 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR');

COMMIT;

-- Verificar:
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON r.IDROL = rp.IDROL
JOIN APP_PERMISO p ON p.ID_PERMISO = rp.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_CONFIGURAR';
