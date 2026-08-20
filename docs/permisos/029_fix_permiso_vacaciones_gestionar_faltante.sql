-- =====================================================================
-- Fix: el permiso VACACIONES_GESTIONAR nunca se creo en APP_PERMISO
--
-- El intento de otorgarselo a SMORAN (028) fallo con ORA-02291 (parent
-- key not found): el MERGE trataba de insertar en APP_USUARIO_PERMISO
-- una fila con ID_PERMISO = 35, pero ese ID no existe en APP_PERMISO.
-- Esto confirma que 022_vacaciones_gestionar_smoran.sql nunca llego a
-- correr (o fallo) en esta base -- Javier ve la pantalla de todos
-- modos porque su acceso viene de otro lado (superadmin), no de este
-- permiso puntual.
--
-- Este script es seguro de correr aunque el 022 SI se haya corrido a
-- medias: no asume que el ID 35 esta libre, lo busca por CODIGO primero
-- y solo crea la fila si de verdad no existe.
-- =====================================================================

-- PASO 1: diagnostico -- ¿existe ya el permiso, con cualquier ID?
SELECT ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO
FROM APP_PERMISO
WHERE CODIGO = 'VACACIONES_GESTIONAR';

-- PASO 2: si el paso 1 no devolvio ninguna fila, crear el permiso
-- (usa el siguiente ID libre en vez de forzar el 35, por si ese numero
-- ya lo tomo otro permiso mientras tanto).
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO)
SELECT NVL(MAX(ID_PERMISO), 0) + 1, 'VACACIONES_GESTIONAR', 'VACACIONES',
       'Aprobar a nivel Administracion/RRHH y marcar como recibido el documento firmado de una solicitud de vacaciones', 'A'
FROM APP_PERMISO
WHERE NOT EXISTS (SELECT 1 FROM APP_PERMISO WHERE CODIGO = 'VACACIONES_GESTIONAR');

COMMIT;

-- PASO 3: ahora si, otorgar el permiso a SMORAN (busca el ID_PERMISO
-- por CODIGO, no por numero fijo, para que funcione sin importar que
-- ID haya quedado en el paso 2).
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'SMORAN' AND p.CODIGO = 'VACACIONES_GESTIONAR'
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;

-- PASO 4: verificar que ya quedo todo en orden.
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.ID_PERMISO, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_GESTIONAR';

-- PASO 5 (no te lo saltes): SMORAN debe cerrar sesion y volver a
-- entrar para que el permiso surta efecto.
