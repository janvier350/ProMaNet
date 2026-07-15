-- =====================================================================
-- Fase 1 + Fase 2: mecanismo SUPERADMIN y nuevos permisos por modulo
--
-- Este script agrega los permisos necesarios para reemplazar:
--  - Los ~32 chequeos hardcodeados de apellidos.equals("Varas Herrera")
--    y el chequeo usuario.equals("jvaras") -> reemplazados por un solo
--    mecanismo SUPERADMIN_ACCESO_TOTAL (ver COMUN.PermisoHelper.tiene()).
--  - Los 16 chequeos de nombre.equals("Jonathan") (ya no trabaja en la
--    empresa) -> se quita esa condicion del codigo; el resto del
--    chequeo (por cargo) pasa a los permisos de abajo.
--  - Los ~140 archivos que usaban cargo.equals(...) "crudo" en vez del
--    sistema de permisos.
--
-- Todos los cargos/listas de abajo preservan EXACTAMENTE el acceso que
-- ya existia hoy en cada grupo de archivos (confirmado por la
-- auditoria completa del codigo), salvo donde se indica lo contrario.
-- =====================================================================

-- 11: acceso total, sin importar el permiso pedido. Solo por concesion
-- individual (APP_USUARIO_PERMISO), nunca por cargo.
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (11, 'SUPERADMIN_ACCESO_TOTAL', 'SISTEMA', 'Acceso total a todo el sistema, sin excepciones. Reemplaza los hardcodes de "Varas Herrera"/"jvaras".');

-- 12: modulo TODO (tareas/trabajos)
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (12, 'TODO_ACCESO', 'TODO', 'Acceso al modulo de TODO (tareas y trabajos)');

-- 13: gestion de grupos de trabajo (GTR_*)
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (13, 'GESTION_GRUPOS_TRABAJO', 'TODO', 'Crear/editar/eliminar grupos de trabajo y sus asignados');

-- 14: reportes de gastos de asignados/hijos (RGA_*)
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (14, 'REPORTES_GASTOS_ASIGNADOS', 'REPORTE_GASTOS', 'Ver y gestionar reportes de gastos de personal asignado');

-- 15: administracion de usuarios (PCN_*)
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (15, 'USUARIOS_GESTIONAR', 'SISTEMA', 'Crear, editar, eliminar usuarios y administrar sus permisos');

-- 16: Soportes (SOP_*)
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (16, 'SOPORTES_ACCESO', 'SOPORTES', 'Acceso al modulo de soportes tecnicos');

-- 17: Agenda
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (17, 'AGENDA_ACCESO', 'AGENDA', 'Acceso al modulo de agenda');

-- 18: Contactos
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (18, 'CONTACTOS_ACCESO', 'CONTACTOS', 'Acceso al directorio de contactos');

-- 19: gestion de clientes
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (19, 'CLIENTES_GESTIONAR', 'CLIENTES', 'Crear, editar y eliminar clientes');

-- 20-22: reporte de gastos individual
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (20, 'REPORTE_GASTOS_ACCESO', 'REPORTE_GASTOS', 'Registrar y consultar el propio reporte de gastos diario');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (21, 'REPORTE_GASTOS_APROBAR', 'REPORTE_GASTOS', 'Aprobar reportes de gastos');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (22, 'REPORTE_GASTOS_DESAPROBAR', 'REPORTE_GASTOS', 'Desaprobar/revertir reportes de gastos ya aprobados');

-- 23: catch-all general para pantallas misceláneas de Proyectos/raiz
-- que hoy solo exigian "cualquier cargo del staff" sin logica propia.
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (23, 'ACCESO_GENERAL', 'SISTEMA', 'Acceso a pantallas generales del sistema (perfil, notificaciones, etc.)');

-- 24-25: inventario de EQUIPOS DE COMPUTO (distinto del inventario de
-- suministros de oficina, que ya tiene sus propios permisos INVENTARIO_*).
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (24, 'INVENTARIO_EQUIPOS_VER', 'INVENTARIO_EQUIPOS', 'Ver el listado e historial de equipos de computo');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (25, 'INVENTARIO_EQUIPOS_GESTIONAR', 'INVENTARIO_EQUIPOS', 'Crear, editar, eliminar y asignar equipos de computo');

-- 26: marcar como entregado el kit de bienvenida de un nuevo ejecutivo
-- (hoy: kit_mk_entregado.java + el panel "Atender notificaciones" de
-- ADM_Dashboard.jsp). Jamine Navarrete, jefe de Marketing, es quien
-- hace click aqui hoy -- se concede por rol CONTRALOR y por
-- departamento MARKETING (ver 011_fase3_departamentos.sql), no por
-- nombre de persona.
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (26, 'KIT_BIENVENIDA_ENTREGAR', 'PROYECTOS', 'Marcar como entregado el kit de bienvenida de un nuevo ejecutivo');

COMMIT;

-- =====================================================================
-- Concesiones por cargo (APP_ROL_PERMISO) -- preservan el acceso actual
-- =====================================================================

-- TODO_ACCESO: hoy la mayoria de pantallas TODO_* dejan entrar a
-- cualquier cargo del staff (ADM/ADR/AST/PAS/CTR/JEF), no a ANALISTA.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 12 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- GESTION_GRUPOS_TRABAJO: hoy ADMINISTRADOR/CONTRALOR/JEFE (+ Jonathan,
-- que ya no trabaja aqui -- se quita esa excepcion).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 13 FROM ROL WHERE CARGO IN ('ADMINISTRADOR','CONTRALOR','JEFE');

-- REPORTES_GASTOS_ASIGNADOS: hoy CONTRALOR/JEFE (+ Jonathan, se quita).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 14 FROM ROL WHERE CARGO IN ('CONTRALOR','JEFE');

-- USUARIOS_GESTIONAR: hoy ADMINISTRACION/ADMINISTRADOR/CONTRALOR/JEFE
-- (+ Varas Herrera/Jonathan en algunos archivos, se quitan esas
-- excepciones -- Varas Herrera ya cubierto por SUPERADMIN).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 15 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

-- SOPORTES_ACCESO: hoy cualquier cargo del staff.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 16 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- AGENDA_ACCESO: hoy cualquier cargo del staff (unificamos: 3 archivos
-- excluian ADMINISTRACION sin razon aparente, se las incluye por
-- consistencia -- ADMINISTRACION ya es el cargo mas amplio del sistema).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 17 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- CONTACTOS_ACCESO: hoy cualquier cargo del staff.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 18 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- CLIENTES_GESTIONAR: hoy ADMINISTRACION/ADMINISTRADOR/CONTRALOR/JEFE.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 19 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

-- REPORTE_GASTOS_ACCESO: hoy cualquier cargo del staff.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 20 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- REPORTE_GASTOS_APROBAR: igual que REPORTE_GASTOS_ACCESO hoy.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 21 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- REPORTE_GASTOS_DESAPROBAR: hoy SOLO ADMINISTRACION (es el unico caso
-- angosto del grupo -- se preserva tal cual, puede ser intencional).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 22 FROM ROL WHERE CARGO IN ('ADMINISTRACION');

-- ACCESO_GENERAL: hoy cualquier cargo del staff.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 23 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- INVENTARIO_EQUIPOS_VER: hoy ADMINISTRACION/ADMINISTRADOR/JEFE.
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 24 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','JEFE');

-- INVENTARIO_EQUIPOS_GESTIONAR: hoy ADMINISTRACION/ADMINISTRADOR/JEFE
-- (el departamento ADMINISTRACIÓN pierde este permiso especificamente
-- via APP_DEPARTAMENTO_PERMISO -- ver 011_fase3_departamentos.sql).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 25 FROM ROL WHERE CARGO IN ('ADMINISTRACION','ADMINISTRADOR','JEFE');

-- KIT_BIENVENIDA_ENTREGAR: hoy CONTRALOR (el departamento MARKETING se
-- concede aparte, en 011_fase3_departamentos.sql).
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 26 FROM ROL WHERE CARGO IN ('CONTRALOR');

COMMIT;

-- =====================================================================
-- Concesiones individuales (APP_USUARIO_PERMISO)
-- =====================================================================

-- SUPERADMIN para Javier Varas Herrera (usuario jvaras). Reemplaza los
-- ~32 chequeos de apellidos.equals("Varas Herrera") y el chequeo
-- usuario.equals("jvaras") esparcidos por el codigo.
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 11, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'JVARAS';

-- La excepcion de "Bravo" en INV_Inventarios.jsp / INV_Ingreso_Suministro.jsp
-- controlaba un panel de catalogo de inventario -- se une a
-- INVENTARIO_INGRESOS (mismo permiso que ya usan las demas pantallas de
-- catalogo). Si su cargo ya se lo daba por rol esto no hace nada
-- (INSERT redundante e inofensivo); si no, se lo concede explicito.
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 4, 'G' FROM USUARIO WHERE UPPER(APELLIDOS) LIKE 'BRAVO%'
    AND IDUSUARIO NOT IN (SELECT IDUSUARIO FROM APP_USUARIO_PERMISO WHERE ID_PERMISO = 4);

COMMIT;

-- Verificar:
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.ID_PERMISO IN (11, 4)
ORDER BY p.CODIGO, u.USUARIO;
