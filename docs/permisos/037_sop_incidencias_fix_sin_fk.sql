-- =====================================================================
-- Fix para 035: crear SOP_SOPORTE_INCIDENCIA sin FK formal
--
-- Al correr el 035 Oracle devolvia ORA-02270 "no matching unique or
-- primary key for this column-list" porque SOP_SOPORTE_CAB.IDSOPORTE
-- NO tiene PRIMARY KEY ni UNIQUE constraint (tabla legacy creada hace
-- años sin PK). La FK no se puede crear contra una columna sin
-- unicidad; como ninguno de los dos errores detuvo la creacion, la
-- tabla SOP_SOPORTE_INCIDENCIA quedo SIN CREAR y los indices tambien
-- fallaron (ORA-00942 "table or view does not exist").
--
-- Este script correctivo:
--   1) Crea la tabla SIN la FK (la integridad la garantiza el codigo:
--      los servlets siempre insertan incidencias contra un ticket
--      que ya existe, verificado al abrirlo).
--   2) Crea los indices por (IDSOPORTE, FECHA_HORA) e (ID_USUARIO,
--      FECHA_HORA) -- es lo que acelera los JOINs y filtros.
--   3) No borra ni toca SOP_SOPORTE_CAB -- queda igual que siempre.
--
-- No ejecutar el 035 despues de este, ya quedo cubierto.
-- =====================================================================


-- Por si quedo basura de un intento anterior.
-- Oracle no tiene "CREATE TABLE IF NOT EXISTS", asi que envolvemos el
-- DROP en PL/SQL para que no rompa si la tabla no existe (-942).
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SOP_SOPORTE_INCIDENCIA PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/


CREATE TABLE SOP_SOPORTE_INCIDENCIA (
    ID_INCIDENCIA  NUMBER NOT NULL,
    IDSOPORTE      NUMBER NOT NULL,
    FECHA_HORA     DATE   DEFAULT SYSDATE NOT NULL,
    ID_USUARIO     NUMBER,
    USUARIO_LOGIN  VARCHAR2(60),
    TIPO           VARCHAR2(30) NOT NULL,
    DESCRIPCION    VARCHAR2(2000) NOT NULL,
    RESULTADO      VARCHAR2(20),
    CONSTRAINT PK_SOP_SOP_INC PRIMARY KEY (ID_INCIDENCIA),
    CONSTRAINT CK_SOP_SOP_INC_TIPO CHECK (TIPO IN (
        'NOTA','DIAGNOSTICO','INTENTO','ESCALAMIENTO','REASIGNACION',
        'CIERRE','CIERRE_SIN_SOLUCION','REAPERTURA'
    )),
    CONSTRAINT CK_SOP_SOP_INC_RES CHECK (RESULTADO IS NULL OR RESULTADO IN ('OK','PARCIAL','FALLO','PENDIENTE'))
);

CREATE INDEX IX_SOP_SOP_INC_SOPORTE ON SOP_SOPORTE_INCIDENCIA (IDSOPORTE, FECHA_HORA);
CREATE INDEX IX_SOP_SOP_INC_USUARIO ON SOP_SOPORTE_INCIDENCIA (ID_USUARIO, FECHA_HORA);

COMMIT;


-- Verificar
SELECT table_name FROM user_tables WHERE table_name = 'SOP_SOPORTE_INCIDENCIA';
SELECT index_name, column_name
FROM user_ind_columns
WHERE table_name = 'SOP_SOPORTE_INCIDENCIA'
ORDER BY index_name, column_position;


-- =====================================================================
-- OPCIONAL (RECOMENDADO, pero NO necesario para que funcione):
-- Agregar PK a SOP_SOPORTE_CAB.IDSOPORTE para que la base tenga
-- integridad real. Solo correrlo si no hay IDSOPORTE duplicados.
-- Para chequear si hay duplicados primero:
--
--   SELECT IDSOPORTE, COUNT(*) FROM SOP_SOPORTE_CAB
--   GROUP BY IDSOPORTE HAVING COUNT(*) > 1;
--
-- Si sale vacio, se puede agregar la PK sin problema:
--
--   ALTER TABLE SOP_SOPORTE_CAB ADD CONSTRAINT PK_SOP_SOPORTE_CAB
--       PRIMARY KEY (IDSOPORTE);
--
-- Y despues, agregar la FK que fallo en el 035:
--
--   ALTER TABLE SOP_SOPORTE_INCIDENCIA ADD CONSTRAINT FK_SOP_SOP_INC_CAB
--       FOREIGN KEY (IDSOPORTE) REFERENCES SOP_SOPORTE_CAB(IDSOPORTE);
-- =====================================================================
