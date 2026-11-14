-- =====================================================================
-- SROSERO: pasa a tener los permisos de SMORAN en
--   * Administracion de Vacaciones (configurar + aprobar, y los grupos que gestiona smoran)
--   * Movilizaciones (gestionar)
--   * Suministros de Talento Humano
--   * Registro de Capacitaciones
--
-- Es una COPIA: smoran conserva sus permisos. Si smoran debe dejar de tenerlos, ejecutar el bloque 4 (comentado).
-- Se otorga de forma individual (APP_USUARIO_PERMISO, TIPO 'G'), igual que los scripts 045 y 050, asi no depende del
-- cargo ni del departamento de srosero. Ejecutar DESPUES del 044. Luego srosero debe cerrar sesion y volver a entrar.
-- No se copia VACACIONES_GRUPOS (administrador global): srosero ve solo los grupos que gestiona.
-- =====================================================================

-- 1) Permisos puntuales que se requieren (aunque smoran los tenga por cargo/departamento y no individualmente)
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'SROSERO'
      AND p.CODIGO IN ('VACACIONES_CONFIGURAR', 'VACACIONES_GESTIONAR',
                       'MOVILIZACION_GESTIONAR',
                       'TALENTO_HUMANO_SUMINISTROS_ACCESO',
                       'CAPACITACIONES_ACCESO')
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN MATCHED THEN UPDATE SET up.TIPO = 'G'
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

-- 2) Ademas, cualquier otro permiso INDIVIDUAL que smoran tenga en esos modulos (si hay alguno mas)
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT us.IDUSUARIO, sp.ID_PERMISO
    FROM APP_USUARIO_PERMISO sp
    JOIN USUARIO um ON um.IDUSUARIO = sp.IDUSUARIO AND UPPER(um.USUARIO) = 'SMORAN'
    JOIN APP_PERMISO p ON p.ID_PERMISO = sp.ID_PERMISO
    CROSS JOIN (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SROSERO') us
    WHERE sp.TIPO = 'G'
      AND p.CODIGO <> 'VACACIONES_GRUPOS'
      AND (p.CODIGO LIKE 'VACACIONES%' OR p.CODIGO LIKE 'MOVILIZACION%' OR p.CODIGO LIKE 'CAPACITACIONES%'
           OR p.CODIGO LIKE 'TALENTO_HUMANO_SUMINISTROS%' OR p.CODIGO LIKE '%SUMINISTRO%')
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN MATCHED THEN UPDATE SET up.TIPO = 'G'
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

-- 3) Grupos de vacaciones: srosero tambien gestiona los grupos que gestiona smoran (ademas de los suyos)
INSERT INTO VAC_GRUPO_GESTOR (ID_GRUPO, ID_USUARIO)
    SELECT gg.ID_GRUPO, us.IDUSUARIO
    FROM VAC_GRUPO_GESTOR gg
    JOIN USUARIO um ON um.IDUSUARIO = gg.ID_USUARIO AND UPPER(um.USUARIO) = 'SMORAN'
    CROSS JOIN (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SROSERO') us
    WHERE NOT EXISTS (SELECT 1 FROM VAC_GRUPO_GESTOR x WHERE x.ID_GRUPO = gg.ID_GRUPO AND x.ID_USUARIO = us.IDUSUARIO);

COMMIT;

-- 4) (OPCIONAL) Quitarle esos permisos y grupos a smoran. Descomentar solo si ella ya no debe tenerlos.
-- DELETE FROM APP_USUARIO_PERMISO WHERE IDUSUARIO = (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SMORAN')
--   AND ID_PERMISO IN (SELECT ID_PERMISO FROM APP_PERMISO WHERE CODIGO IN ('VACACIONES_CONFIGURAR', 'VACACIONES_GESTIONAR',
--       'MOVILIZACION_GESTIONAR', 'TALENTO_HUMANO_SUMINISTROS_ACCESO', 'CAPACITACIONES_ACCESO'));
-- DELETE FROM VAC_GRUPO_GESTOR WHERE ID_USUARIO = (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SMORAN');
-- COMMIT;

-- 5) Verificacion -----------------------------------------------------------------
-- Permisos individuales de smoran y srosero en esos modulos (lado a lado)
SELECT u.USUARIO, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) IN ('SMORAN', 'SROSERO')
  AND (p.CODIGO LIKE 'VACACIONES%' OR p.CODIGO LIKE 'MOVILIZACION%' OR p.CODIGO LIKE 'CAPACITACIONES%' OR p.CODIGO LIKE '%SUMINISTRO%')
ORDER BY p.CODIGO, u.USUARIO;
-- Grupos de vacaciones y sus gestores
SELECT g.NOMBRE AS GRUPO, u.USUARIO AS GESTOR
FROM VAC_GRUPO_GESTOR gg JOIN VAC_GRUPO g ON g.ID_GRUPO = gg.ID_GRUPO JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO
ORDER BY g.NOMBRE, u.USUARIO;
-- Todos los permisos individuales de smoran (por si tiene otros que tambien deban pasar, p. ej. suministros)
SELECT p.CODIGO, up.TIPO FROM APP_USUARIO_PERMISO up JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) = 'SMORAN' ORDER BY p.CODIGO;
