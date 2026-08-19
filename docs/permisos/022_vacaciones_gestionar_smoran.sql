-- =====================================================================
-- Modulo de Solicitud de Vacaciones -- permiso de Administracion/Recepcion
--
-- Cuando exista el flujo de solicitudes (Fase 3), alguien tiene que
-- aprobar a nivel Administracion/RRHH y marcar como recibido el
-- documento firmado. Esa persona es SMORAN.
--
-- A proposito SIN mapeo por rol ni departamento: es pura concesion
-- individual (APP_USUARIO_PERMISO), igual que se hizo con
-- MOVILIZACION_GESTIONAR -- para poder transferir el modulo a otra
-- persona despues con un solo UPDATE, sin tocar cargos ni codigo.
-- (El usuario ya avisa que pronto habra que hacer este mismo cambio
-- de titular en Movilizacion, de SMORAN a SROSERO -- ver ese modulo
-- cuando toque, esto de aqui es solo Vacaciones.)
-- =====================================================================

INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO) VALUES
    (35, 'VACACIONES_GESTIONAR', 'VACACIONES', 'Aprobar a nivel Administracion/RRHH y marcar como recibido el documento firmado de una solicitud de vacaciones', 'A');

INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 35, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'SMORAN';

COMMIT;

-- Verificar:
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'VACACIONES_GESTIONAR';

-- IMPORTANTE: SMORAN debe cerrar sesion y volver a entrar para que el
-- permiso surta efecto (los permisos se cargan una sola vez, al hacer
-- login). Este permiso ya queda visible en el panel "Permisos por
-- Usuario" (PCN_GestionPermisosUsuario.jsp) para cuando toque
-- transferirlo a otra persona -- esa pantalla lee el catalogo
-- APP_PERMISO directamente, no requiere cambios de codigo.
