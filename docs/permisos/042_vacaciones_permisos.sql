-- =====================================================================
-- Vacaciones: registro de PERMISOS por horas (personal, estudio, salud,
-- otros) con descargo automatico a vacaciones segun reglas.
--
-- Reglas (las aplica VAC_GuardarPermiso):
--   * PERSONAL con 8 horas  -> descarga 1 dia a vacaciones, con el valor
--                              calculado (1 dia habil x 15/11 = 1.36).
--   * PERSONAL de 1 a 7 hs  -> no descarga.
--   * ESTUDIO / SALUD / OTROS (cualquier cantidad de horas) -> no descarga.
--
-- El descargo se registra como un AJUSTE en VAC_HISTORICO_AJUSTE (asi el
-- calculo de saldo no cambia) enlazado al permiso: VAC_PERMISO.ID_AJUSTE y
-- VAC_HISTORICO_AJUSTE.ID_PERMISO. Editar o borrar el permiso actualiza o
-- borra su ajuste; el ajuste enlazado no se puede tocar desde la pantalla de
-- ajustes (se gestiona desde Permisos).
--
-- Aditivo: no cambia datos existentes.
-- =====================================================================

CREATE TABLE VAC_PERMISO (
    ID_PERMISO           NUMBER        NOT NULL,
    ID_USUARIO           NUMBER        NOT NULL,
    FECHA                DATE          NOT NULL,
    HORAS                NUMBER(4,2)   NOT NULL,
    MOTIVO               VARCHAR2(20)  NOT NULL,
    DETALLE              VARCHAR2(300),
    DESCARGA_VACACIONES  CHAR(1)       DEFAULT 'N' NOT NULL,
    DIAS_DESCARGADOS     NUMBER(5,2),
    NUM_PERIODO          NUMBER,
    ID_AJUSTE            NUMBER,
    ID_USUARIO_REGISTRA  NUMBER,
    FECHA_REGISTRO       DATE          DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_VAC_PERMISO PRIMARY KEY (ID_PERMISO),
    CONSTRAINT FK_VAC_PERMISO_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT CK_VAC_PERMISO_HORAS CHECK (HORAS > 0 AND HORAS <= 8),
    CONSTRAINT CK_VAC_PERMISO_MOTIVO CHECK (MOTIVO IN ('PERSONAL','ESTUDIO','SALUD','OTROS')),
    CONSTRAINT CK_VAC_PERMISO_DESC CHECK (DESCARGA_VACACIONES IN ('S','N'))
);

CREATE INDEX IX_VAC_PERMISO_USU ON VAC_PERMISO (ID_USUARIO, FECHA);

ALTER TABLE VAC_HISTORICO_AJUSTE ADD ID_PERMISO NUMBER;
