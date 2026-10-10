-- =====================================================================
-- Soportes -- tabla SOP_SOPORTE_INCIDENCIA (fase 4)
--
-- Hasta ahora un ticket solo tenia un REPORTE unico (texto final al
-- cerrarlo) y un ESTADO. No habia como registrar los pasos
-- intermedios: "el 02/10 probe reinstalar el driver, no funciono",
-- "el 04/10 escale al proveedor", etc. Con esta tabla hija el ticket
-- se vuelve una secuencia de incidencias con fecha, tecnico y
-- resultado, y la pantalla de Atender muestra un timeline.
--
-- El REPORTE del CAB se mantiene para no romper nada; al cerrar un
-- ticket ademas de llenarlo se crea una incidencia TIPO='CIERRE' con
-- la misma descripcion, asi el historial completo queda en un solo
-- lugar.
-- =====================================================================


CREATE TABLE SOP_SOPORTE_INCIDENCIA (
    ID_INCIDENCIA  NUMBER NOT NULL,
    IDSOPORTE      NUMBER NOT NULL,
    FECHA_HORA     DATE   DEFAULT SYSDATE NOT NULL,
    ID_USUARIO     NUMBER,                        -- quien registra (tecnico/supervisor)
    USUARIO_LOGIN  VARCHAR2(60),                  -- snapshot
    TIPO           VARCHAR2(30) NOT NULL,         -- ver abajo
    DESCRIPCION    VARCHAR2(2000) NOT NULL,
    RESULTADO      VARCHAR2(20),                  -- OK | PARCIAL | FALLO | PENDIENTE (opcional)
    CONSTRAINT PK_SOP_SOP_INC PRIMARY KEY (ID_INCIDENCIA),
    CONSTRAINT FK_SOP_SOP_INC_CAB FOREIGN KEY (IDSOPORTE) REFERENCES SOP_SOPORTE_CAB(IDSOPORTE),
    CONSTRAINT CK_SOP_SOP_INC_TIPO CHECK (TIPO IN (
        'NOTA',             -- comentario informativo
        'DIAGNOSTICO',      -- "lo revise, el problema es X"
        'INTENTO',          -- "probe hacer Y"
        'ESCALAMIENTO',     -- "lo escale al proveedor / nivel 2"
        'REASIGNACION',     -- cambio de tecnico asignado
        'CIERRE',           -- cierre con solucion
        'CIERRE_SIN_SOLUCION', -- cierre sin resolver
        'REAPERTURA'        -- se reabrio para seguir trabajando
    )),
    CONSTRAINT CK_SOP_SOP_INC_RES CHECK (RESULTADO IS NULL OR RESULTADO IN ('OK','PARCIAL','FALLO','PENDIENTE'))
);

CREATE INDEX IX_SOP_SOP_INC_SOPORTE ON SOP_SOPORTE_INCIDENCIA (IDSOPORTE, FECHA_HORA);
CREATE INDEX IX_SOP_SOP_INC_USUARIO ON SOP_SOPORTE_INCIDENCIA (ID_USUARIO, FECHA_HORA);

COMMIT;


-- Verificar
SELECT column_name, data_type, nullable FROM user_tab_columns
WHERE table_name = 'SOP_SOPORTE_INCIDENCIA' ORDER BY column_id;
