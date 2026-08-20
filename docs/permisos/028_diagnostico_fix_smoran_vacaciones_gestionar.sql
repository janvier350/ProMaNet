-- =====================================================================
-- Diagnostico + fix: SMORAN no tiene acceso a Vacaciones (Admin.)
--
-- El permiso VACACIONES_GESTIONAR se otorgo en 022_vacaciones_gestionar_
-- smoran.sql con un INSERT INTO ... SELECT que busca el usuario por
-- UPPER(USUARIO) = 'SMORAN'. Si esa fila no coincidio exactamente (por
-- ejemplo el campo USUARIO real tiene un espacio, otro nombre de login,
-- o el script nunca se llego a correr), el INSERT no inserta nada y no
-- avisa error -- SMORAN se queda sin el permiso silenciosamente.
--
-- PASO 1: correr el bloque de abajo y revisar el resultado.
-- =====================================================================

-- 1a) Confirmar el usuario real (por si el login no es literal 'SMORAN')
SELECT IDUSUARIO, USUARIO, NOMBRE, APELLIDOS, ESTADO
FROM USUARIO
WHERE UPPER(USUARIO) LIKE '%MORAN%' OR UPPER(APELLIDOS) LIKE '%MORAN%';

-- 1b) Confirmar si ya tiene el permiso concedido (deberia salir una fila
-- con CODIGO = VACACIONES_GESTIONAR; si sale NULL en CODIGO, no lo tiene)
SELECT u.IDUSUARIO, u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM USUARIO u
LEFT JOIN APP_USUARIO_PERMISO up ON up.IDUSUARIO = u.IDUSUARIO AND up.ID_PERMISO = 35
LEFT JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE UPPER(u.USUARIO) LIKE '%MORAN%';

-- =====================================================================
-- PASO 2: si 1b no mostro el permiso, correr este MERGE (es seguro
-- ejecutarlo mas de una vez -- si ya existe no duplica nada). Si el
-- USUARIO real de 1a NO es literalmente 'SMORAN', cambiar el valor
-- en el WHERE de abajo por el que aparecio en 1a antes de correrlo.
-- =====================================================================

MERGE INTO APP_USUARIO_PERMISO up
USING (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SMORAN') src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = 35)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, 35, 'G');

COMMIT;

-- PASO 3: verificar que ya quedo (debe repetir la fila con CODIGO
-- VACACIONES_GESTIONAR):
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_GESTIONAR';

-- PASO 4 (IMPORTANTE, el paso que mas se olvida): SMORAN debe CERRAR
-- SESION y volver a entrar. Los permisos se cargan a la sesion una
-- sola vez, al hacer login -- si ya tenia sesion abierta cuando se
-- corrio el MERGE, seguira sin ver la opcion hasta que reingrese.
