-- =====================================================================
-- Soportes -- refactor del modulo (fase 1 de 4)
--
-- Objetivos:
--   1) Permisos granulares para poder dar "solo ver pendientes" (ej.
--      a DNARANJO) sin dar atender/cerrar.
--   2) Estados ampliados: ademas de PENDIENTE y ATENDIDO, agregar
--      EN_PROGRESO, REASIGNADO, CERRADO_SIN_SOLUCION.
--   3) Columnas nuevas opcionales para trazabilidad de atencion:
--      ID_TECNICO_ASIGNADO (FK USUARIO), FECHA_PRIMERA_ATENCION.
--
-- Nota: la columna TECNICO (texto libre) existente se MANTIENE para
-- no romper historico; las pantallas nuevas van a preferir
-- ID_TECNICO_ASIGNADO cuando este cargado.
--
-- La tabla hija SOP_SOPORTE_INCIDENCIA (para registrar MULTIPLES
-- incidencias por ticket y que EN_PROGRESO tenga sentido real) queda
-- para una fase 2 cuando se este listo para rediseñar el flujo de
-- "atender". Por ahora el estado EN_PROGRESO se puede setear a mano y
-- las notas se concatenan en REPORTE con fecha.
-- =====================================================================


-- 1) Permisos nuevos --------------------------------------------------
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (37, 'SOPORTES_VER_PENDIENTES', 'SOPORTES', 'Ver la lista de tickets pendientes y en progreso');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (38, 'SOPORTES_VER_ATENDIDOS', 'SOPORTES', 'Ver la lista de tickets ya atendidos / cerrados');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (39, 'SOPORTES_VER_HISTORIAL', 'SOPORTES', 'Ver el historial completo de tickets con filtros avanzados');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (40, 'SOPORTES_VER_METRICAS', 'SOPORTES', 'Ver dashboard de metricas: tickets con mucha espera, promedio de atencion, top equipos problematicos');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (41, 'SOPORTES_REASIGNAR', 'SOPORTES', 'Reasignar un ticket a otro tecnico');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (42, 'SOPORTES_ELIMINAR', 'SOPORTES', 'Eliminar un ticket (operacion destructiva, usar con precaucion)');


-- 2) Columnas nuevas en SOP_SOPORTE_CAB -------------------------------
--    ID_TECNICO_ASIGNADO: a diferencia del campo TECNICO (texto libre
--    heredado), apunta a USUARIO.IDUSUARIO. Permite reasignar y hacer
--    reporte "tickets por tecnico" con nombre consistente.
--    FECHA_PRIMERA_ATENCION: para calcular tiempo de respuesta promedio.
ALTER TABLE SOP_SOPORTE_CAB ADD (
    ID_TECNICO_ASIGNADO    NUMBER,
    FECHA_PRIMERA_ATENCION DATE
);


-- 3) Concesiones iniciales de permisos --------------------------------
--    Admins (jvaras, smoran): todos los nuevos (y los existentes que
--    ya tengan quedan intactos).
--    DNARANJO: ACCESO + VER_PENDIENTES + VER_ATENDIDOS + VER_METRICAS
--    (puede evaluar y supervisar, NO puede atender ni cerrar).
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) IN ('JVARAS','SMORAN')
      AND p.CODIGO IN (
          'SOPORTES_VER_PENDIENTES','SOPORTES_VER_ATENDIDOS',
          'SOPORTES_VER_HISTORIAL','SOPORTES_VER_METRICAS',
          'SOPORTES_REASIGNAR','SOPORTES_ELIMINAR'
      )
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'DNARANJO'
      AND p.CODIGO IN (
          'SOPORTES_ACCESO',
          'SOPORTES_VER_PENDIENTES','SOPORTES_VER_ATENDIDOS',
          'SOPORTES_VER_METRICAS'
      )
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;


-- 4) Verificar --------------------------------------------------------
SELECT ID_PERMISO, CODIGO FROM APP_PERMISO WHERE MODULO = 'SOPORTES' ORDER BY ID_PERMISO;

SELECT u.USUARIO, p.CODIGO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) IN ('JVARAS','SMORAN','DNARANJO') AND p.MODULO = 'SOPORTES'
ORDER BY u.USUARIO, p.CODIGO;

SELECT column_name, data_type FROM user_tab_columns
WHERE table_name = 'SOP_SOPORTE_CAB'
  AND column_name IN ('ID_TECNICO_ASIGNADO','FECHA_PRIMERA_ATENCION');
