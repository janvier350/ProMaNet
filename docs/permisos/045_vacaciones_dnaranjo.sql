-- =====================================================================
-- DNARANJO (administradora): mismos permisos que SMORAN en Vacaciones.
--
-- SMORAN es gestor del grupo KENNEDY (044) y tiene CONFIGURAR y GESTIONAR.
-- Con los grupos, DNARANJO ve el Panel de Vacaciones pero NO veria empleados
-- hasta ser gestora de un grupo. Este script la agrega como gestora de
-- KENNEDY (junto a smoran) y asegura sus permisos de configurar y aprobar.
--
-- Ejecutar DESPUES del 044. Luego DNARANJO debe cerrar sesion y volver a
-- entrar (los permisos se cargan al iniciar sesion).
-- =====================================================================

-- 1) Gestora del grupo KENNEDY ------------------------------------------------
INSERT INTO VAC_GRUPO_GESTOR (ID_GRUPO, ID_USUARIO)
    SELECT g.ID_GRUPO, u.IDUSUARIO
    FROM VAC_GRUPO g, USUARIO u
    WHERE g.NOMBRE = 'KENNEDY' AND UPPER(u.USUARIO) = 'DNARANJO'
      AND NOT EXISTS (SELECT 1 FROM VAC_GRUPO_GESTOR x WHERE x.ID_GRUPO = g.ID_GRUPO AND x.ID_USUARIO = u.IDUSUARIO);

-- 2) Permisos de Vacaciones (igual que smoran) ------------------------------
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'DNARANJO'
      AND p.CODIGO IN ('VACACIONES_CONFIGURAR', 'VACACIONES_GESTIONAR')
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN MATCHED THEN UPDATE SET up.TIPO = 'G'
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;

-- 3) Verificacion -----------------------------------------------------------------
SELECT g.NOMBRE AS GRUPO, u.USUARIO AS GESTOR
FROM VAC_GRUPO_GESTOR gg JOIN VAC_GRUPO g ON g.ID_GRUPO = gg.ID_GRUPO JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO
ORDER BY g.NOMBRE, u.USUARIO;

SELECT u.USUARIO, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) IN ('SMORAN', 'DNARANJO') AND p.CODIGO LIKE 'VACACIONES%'
ORDER BY p.CODIGO, u.USUARIO;

-- 4) OPCIONAL: ¿"los mismos permisos" en TODO el sistema? ---------------------
-- Permisos individuales que tiene SMORAN y DNARANJO no (revisar antes de copiar):
SELECT p.CODIGO, p.MODULO, p.DESCRIPCION
FROM APP_USUARIO_PERMISO s
JOIN USUARIO us ON us.IDUSUARIO = s.IDUSUARIO AND UPPER(us.USUARIO) = 'SMORAN'
JOIN APP_PERMISO p ON p.ID_PERMISO = s.ID_PERMISO
WHERE s.TIPO = 'G'
  AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO d JOIN USUARIO ud ON ud.IDUSUARIO = d.IDUSUARIO
                  WHERE UPPER(ud.USUARIO) = 'DNARANJO' AND d.ID_PERMISO = s.ID_PERMISO AND d.TIPO = 'G')
ORDER BY p.MODULO, p.CODIGO;

-- Si se quieren TODOS, descomentar y ejecutar (solo copia los que faltan):
-- INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
--     SELECT ud.IDUSUARIO, s.ID_PERMISO, 'G'
--     FROM APP_USUARIO_PERMISO s
--     JOIN USUARIO us ON us.IDUSUARIO = s.IDUSUARIO AND UPPER(us.USUARIO) = 'SMORAN'
--     JOIN USUARIO ud ON UPPER(ud.USUARIO) = 'DNARANJO'
--     WHERE s.TIPO = 'G'
--       AND NOT EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO d WHERE d.IDUSUARIO = ud.IDUSUARIO AND d.ID_PERMISO = s.ID_PERMISO);
-- COMMIT;
-- Nota: los permisos que vienen del CARGO o del DEPARTAMENTO no se copian (dependen de su rol).
