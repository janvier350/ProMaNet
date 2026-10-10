-- =====================================================================
-- Mover los permisos de Soportes de SMORAN -> CVARAS (asistente).
--
-- En 033_soportes_refactor.sql se le habian otorgado los 6 permisos
-- nuevos de SOPORTES a smoran por default (admin), pero no los
-- necesita en la practica. Cvaras es quien gestiona Soportes dia a
-- dia como asistente.
--
-- Mantenemos los permisos de jvaras (admin principal). smoran pierde
-- SOLO los 6 nuevos, el resto de permisos que ya tenia queda intacto.
-- =====================================================================


-- 1) Quitar los 6 permisos nuevos a smoran -----------------------------
DELETE FROM APP_USUARIO_PERMISO up
WHERE up.IDUSUARIO = (SELECT u.IDUSUARIO FROM USUARIO u WHERE UPPER(u.USUARIO) = 'SMORAN')
  AND up.ID_PERMISO IN (
      SELECT ID_PERMISO FROM APP_PERMISO
      WHERE CODIGO IN (
          'SOPORTES_VER_PENDIENTES','SOPORTES_VER_ATENDIDOS',
          'SOPORTES_VER_HISTORIAL','SOPORTES_VER_METRICAS',
          'SOPORTES_REASIGNAR','SOPORTES_ELIMINAR'
      )
  );


-- 2) Darselos a cvaras -------------------------------------------------
-- Tambien SOPORTES_ACCESO + SOPORTES_ATENDER por si no los tenia
-- (cvaras necesita atender tickets como el flujo normal).
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'CVARAS'
      AND p.CODIGO IN (
          'SOPORTES_ACCESO','SOPORTES_ATENDER',
          'SOPORTES_VER_PENDIENTES','SOPORTES_VER_ATENDIDOS',
          'SOPORTES_VER_HISTORIAL','SOPORTES_VER_METRICAS',
          'SOPORTES_REASIGNAR','SOPORTES_ELIMINAR'
      )
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;


-- 3) Verificar ---------------------------------------------------------
SELECT u.USUARIO, p.CODIGO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) IN ('JVARAS','SMORAN','CVARAS','DNARANJO') AND p.MODULO = 'SOPORTES'
ORDER BY u.USUARIO, p.CODIGO;
