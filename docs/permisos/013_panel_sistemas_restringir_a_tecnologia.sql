-- =====================================================================
-- Restringir el "Panel de Sistemas" (PCN_ListadoUsuario.jsp y todo lo
-- que cuelga de USUARIOS_GESTIONAR: crear/editar/eliminar usuarios,
-- permisos por usuario y permisos por departamento) para que sea
-- realmente el panel del departamento de Sistemas/IT.
--
-- Hoy USUARIOS_GESTIONAR se concede por cargo a ADMINISTRACION,
-- ADMINISTRADOR, CONTRALOR y JEFE de CUALQUIER departamento (asi
-- estaba desde antes de los permisos, via cargo.equals(...) crudo).
-- Este script NO toca esa concesion por cargo (se sigue evaluando
-- normalmente para el personal de TECNOLOGIA), pero AGREGA un "deny"
-- por departamento para el resto: asi, un JEFE/CONTRALOR/ADMINISTRADOR
-- que no sea de TECNOLOGIA deja de ver el panel, aunque su cargo
-- tecnicamente calificaria.
--
-- Quien SI sigue teniendo acceso:
--   - Cualquier ADMINISTRACION/ADMINISTRADOR/CONTRALOR/JEFE del
--     departamento TECNOLOGIA (no se le agrega ningun deny).
--   - SUPERADMIN_ACCESO_TOTAL (jvaras) -- el bypass de PermisoHelper.tiene()
--     ignora cualquier deny.
--   - Cualquier concesion individual ya otorgada (ej. Christian Paul
--     Varas Herrera / cvaras, ver 012_permisos_hermano_asistente.sql),
--     porque la capa individual (APP_USUARIO_PERMISO) siempre se
--     evalua despues y gana sobre el deny de departamento.
-- =====================================================================

INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('ADMINISTRACIÓN', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('ADMINISTRACIÓN NORTE', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('AUDITORÍA', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('CONTABILIDAD', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('IMPUESTOS', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('IMPUESTOS MAGISTERIO', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('IMPUESTOS NORTE', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('LEGAL', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('MARKETING', 15, 'D');
INSERT INTO APP_DEPARTAMENTO_PERMISO (DEPARTAMENTO, ID_PERMISO, TIPO) VALUES ('OUTSOURCING', 15, 'D');
-- TECNOLOGÍA: sin fila -- se queda con el acceso normal por cargo.

COMMIT;

-- Verificar:
SELECT DEPARTAMENTO, ID_PERMISO, TIPO FROM APP_DEPARTAMENTO_PERMISO WHERE ID_PERMISO = 15 ORDER BY DEPARTAMENTO;
