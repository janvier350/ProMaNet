-- =====================================================================
-- Fase 3 (parcial): permisos por departamento
--
-- Tabla nueva APP_DEPARTAMENTO_PERMISO: funciona igual que
-- APP_USUARIO_PERMISO pero a nivel de departamento entero. Se resuelve
-- en COMUN.PermisoHelper.cargarPermisos() en este orden (de mas general
-- a mas especifico, cada capa puede corregir a la anterior):
--   1) permisos por cargo (APP_ROL_PERMISO)
--   2) permisos por departamento (esta tabla)
--   3) permisos individuales por usuario (APP_USUARIO_PERMISO) -- estos
--      siempre ganan al final, incluso sobre una regla de departamento.
--
-- TIPO='D' (denegar) es el uso principal: "aunque el cargo de la
-- persona le daria este permiso, en este departamento se lo quitamos".
-- TIPO='G' (conceder) tambien esta disponible por si a futuro se
-- necesita dar un permiso a todo un departamento sin importar el cargo.
-- =====================================================================

CREATE TABLE APP_DEPARTAMENTO_PERMISO (
    DEPARTAMENTO VARCHAR2(100) NOT NULL,
    ID_PERMISO   NUMBER NOT NULL,
    TIPO         CHAR(1) DEFAULT 'D' NOT NULL,
    CONSTRAINT PK_APP_DEPTO_PERMISO PRIMARY KEY (DEPARTAMENTO, ID_PERMISO),
    CONSTRAINT FK_APP_DEPTO_PERMISO FOREIGN KEY (ID_PERMISO) REFERENCES APP_PERMISO(ID_PERMISO),
    CONSTRAINT CK_APP_DEPTO_PERMISO_TIPO CHECK (TIPO IN ('G','D'))
);

-- =====================================================================
-- Regla 1: el departamento ADMINISTRACIÓN hace el trabajo de sueldos y
-- ve el inventario de suministros, pero NO edita ni crea equipos de
-- computo (si ve el listado, solo no gestiona -- por eso solo se le
-- niega GESTIONAR, no VER).
-- =====================================================================
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO)
    VALUES ('ADMINISTRACIÓN', 25, 'D'); -- INVENTARIO_EQUIPOS_GESTIONAR

-- =====================================================================
-- Regla 2: CONTABILIDAD no debe ver los modulos de Administracion,
-- Legal ni Impuestos. Como hoy no existen permisos separados para
-- "modulo Legal"/"modulo Impuestos" (esos departamentos todavia no
-- tienen pantallas propias -- ver nota sobre el TODO de Legal), esta
-- regla por ahora le niega a Contabilidad el acceso al panel
-- administrativo (Control/ADM_Dashboard y todo lo que cuelga de
-- CONTROL_GESTIONAR). Cuando Legal/Impuestos tengan sus propios
-- permisos, agregamos las filas correspondientes aqui.
-- =====================================================================
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO)
    VALUES ('CONTABILIDAD', 8, 'D'); -- CONTROL_GESTIONAR

-- =====================================================================
-- Regla 3: el departamento MARKETING puede marcar como entregado el
-- kit de bienvenida (hoy era un chequeo por departamento hardcodeado
-- directo en kit_mk_entregado.java -- se mueve aqui).
-- =====================================================================
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO)
    VALUES ('MARKETING', 26, 'G'); -- KIT_BIENVENIDA_ENTREGAR

COMMIT;

-- Verificar:
SELECT DEPARTAMENTO, (SELECT CODIGO FROM APP_PERMISO WHERE ID_PERMISO = dp.ID_PERMISO) AS PERMISO, TIPO
FROM APP_DEPARTAMENTO_PERMISO dp
ORDER BY DEPARTAMENTO;
