-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- Fase 2: motor de calculo de saldo
--
-- Con la fecha de ingreso ya cargada (Fase 1), esta fase agrega:
--   1) Una tabla para cargar el consumo HISTORICO de vacaciones (el
--      que ya paso antes de que existiera este modulo -- ej. lo que
--      muestra el "Reporte de Vacaciones" de cada empleado). Sin esto
--      el sistema creeria que todos tienen sus 15 dias completos
--      disponibles por cada periodo cumplido, lo cual seria falso
--      para casi todos.
--   2) El permiso para que cualquier empleado vea su propio saldo
--      (todavia de solo lectura -- la solicitud en si es la Fase 3).
-- =====================================================================

-- 1) Tabla de ajustes historicos -----------------------------------------
CREATE TABLE VAC_HISTORICO_AJUSTE (
    ID_AJUSTE            NUMBER NOT NULL,
    ID_USUARIO           NUMBER NOT NULL,
    NUM_PERIODO          NUMBER NOT NULL,
    DIAS_GOZADOS         NUMBER NOT NULL,
    FECHA_DESDE          DATE,
    FECHA_HASTA          DATE,
    OBSERVACIONES        VARCHAR2(500),
    ID_USUARIO_REGISTRA  NUMBER,
    FECHA_REGISTRO       DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_VAC_HISTORICO_AJUSTE PRIMARY KEY (ID_AJUSTE),
    CONSTRAINT FK_VAC_HIST_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT CK_VAC_HIST_DIAS CHECK (DIAS_GOZADOS > 0)
);

-- 2) Permiso: ver el propio saldo -----------------------------------------
-- Mismo alcance amplio que ya usan otros modulos de autoservicio
-- (CONTROL_ACCESO, MOVILIZACION_SOLICITAR): todos los cargos que
-- trabajan de forma regular.
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO) VALUES
    (34, 'VACACIONES_SOLICITAR', 'VACACIONES', 'Ver el propio saldo de vacaciones y (en fases siguientes) solicitarlas', 'A');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 34 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE','ANALISTA');

COMMIT;

-- Verificar:
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON r.IDROL = rp.IDROL
JOIN APP_PERMISO p ON p.ID_PERMISO = rp.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_SOLICITAR';
