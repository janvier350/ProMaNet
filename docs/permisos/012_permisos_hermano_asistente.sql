-- =====================================================================
-- Permisos individuales para Christian Paul Varas Herrera
-- (usuario 'cvaras', IDUSUARIO=100) -- asistente Jr. de sistemas.
--
-- Segun lo indicado: acceso total a Inventario de computadoras, crear
-- usuarios, y ver los tickets de soporte (todo lo relacionado a
-- sistemas). NO debe ver sueldos de otros ni las solicitudes de
-- anticipo de otros usuarios.
-- =====================================================================

-- Conceder (TIPO='G'):
--  24 = INVENTARIO_EQUIPOS_VER
--  25 = INVENTARIO_EQUIPOS_GESTIONAR
--  15 = USUARIOS_GESTIONAR (crear/editar/eliminar usuarios)
--  16 = SOPORTES_ACCESO (ver tickets de soporte)
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (100, 24, 'G');
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (100, 25, 'G');
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (100, 15, 'G');
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (100, 16, 'G');

-- Denegar explicitamente (TIPO='D'), sin importar el cargo que tenga
-- hoy o en el futuro:
--  8 = CONTROL_GESTIONAR (ver/asignar sueldo de otros, ver/editar
--      anticipos ajenos). Su propio anticipo lo puede seguir pidiendo
--      via CONTROL_ACCESO (eso no se toca).
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO) VALUES (100, 8, 'D');

COMMIT;

-- Verificar:
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE up.IDUSUARIO = 100
ORDER BY p.CODIGO;
