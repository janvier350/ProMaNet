-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- VACACIONES_CONFIGURAR pasa a ser
-- SOLO de SMORAN, igual que VACACIONES_GESTIONAR
--
-- 020_modulo_vacaciones_fase1.sql lo habia concedido por CARGO
-- (ADMINISTRACION/ADMINISTRADOR/CONTRALOR) -- eso significaba que
-- cualquiera con esos cargos veia "Vacaciones - Config.", no solo la
-- persona encargada del modulo. Se quita esa concesion por rol y se
-- deja como concesion individual (APP_USUARIO_PERMISO), igual patron
-- que VACACIONES_GESTIONAR: mas facil de transferir despues con un
-- solo UPDATE, sin tocar cargos ni codigo.
-- =====================================================================

-- 1) Quitar la concesion por cargo.
DELETE FROM APP_ROL_PERMISO
WHERE ID_PERMISO = (SELECT ID_PERMISO FROM APP_PERMISO WHERE CODIGO = 'VACACIONES_CONFIGURAR');

-- 2) Conceder individualmente a SMORAN (MERGE: seguro de correr mas de
-- una vez, no duplica si ya existe).
MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'SMORAN' AND p.CODIGO = 'VACACIONES_CONFIGURAR'
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO)
    VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;

-- Verificar: debe salir SOLO SMORAN (mas quien tenga
-- SUPERADMIN_ACCESO_TOTAL, que pasa cualquier chequeo sin necesitar
-- este grant puntual -- eso es normal, no es un problema).
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_CONFIGURAR';

-- Y esto debe salir vacio (0 filas) -- confirma que ya nadie lo tiene
-- por cargo:
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON r.IDROL = rp.IDROL
JOIN APP_PERMISO p ON p.ID_PERMISO = rp.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_CONFIGURAR';

-- IMPORTANTE: cualquiera que antes veia "Vacaciones - Config." por su
-- cargo (Administracion/Administrador/Contralor) y NO sea SMORAN debe
-- cerrar sesion y volver a entrar para que deje de aparecerle -- los
-- permisos se cargan una sola vez, al hacer login.
