-- =====================================================================
-- Reasignar el manejo de Inventario de Suministros de GNARANJO a SMORAN
-- SIN cambiarles el cargo/rol (que afectaria otros modulos).
--
-- Esto es un FALLBACK por SQL directo. Una vez desplegado el esquema
-- de permisos (001_esquema_permisos.sql) y el codigo actualizado, lo
-- normal es hacerlo desde la pantalla nueva:
--   PCN_ListadoUsuario.jsp -> boton "Permisos" (icono candado) en la
--   fila de cada usuario -> seleccionar "Denegar siempre" / "Conceder
--   siempre" para los permisos de INVENTARIO que correspondan.
--
-- Ajustar la lista de ID_PERMISO segun lo que realmente haga GNARANJO
-- hoy (ver 001_esquema_permisos.sql para el catalogo):
--   3 = INVENTARIO_DESPACHAR
--   4 = INVENTARIO_INGRESOS   (no migrado todavia, ver nota al final)
--   5 = INVENTARIO_EXISTENCIAS
--   6 = INVENTARIO_IMPRIMIR_COMPROBANTE
-- =====================================================================

-- Quitarle a GNARANJO la gestion de inventario (denegar aunque su cargo la incluya)
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 3, 'D' FROM USUARIO WHERE USUARIO = 'GNARANJO';
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 5, 'D' FROM USUARIO WHERE USUARIO = 'GNARANJO';
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 6, 'D' FROM USUARIO WHERE USUARIO = 'GNARANJO';

-- Dársela a SMORAN (conceder aunque su cargo no la incluya)
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 3, 'G' FROM USUARIO WHERE USUARIO = 'SMORAN';
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 5, 'G' FROM USUARIO WHERE USUARIO = 'SMORAN';
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 6, 'G' FROM USUARIO WHERE USUARIO = 'SMORAN';

COMMIT;

-- Ambas personas deben volver a iniciar sesion para que el cambio
-- tenga efecto (los permisos se cargan una vez, al hacer login).

-- NOTA: el "Ingreso de suministros" (registrar factura de compra,
-- catalogos de producto/unidad/categoria/proveedor) todavia usa los
-- chequeos de cargo antiguos, no este sistema de permisos, porque al
-- revisarlo encontramos inconsistencias propias (paginas que solo
-- dejan entrar a ADMINISTRACION/ADMINISTRADOR pero servlets que ademas
-- aceptan CONTRALOR/JEFE, y el CRUD de catalogos que solo acepta
-- JEFE/ASISTENTE). Si GNARANJO/SMORAN tambien necesitan ese cambio ahi,
-- hay que decidir primero cual es el comportamiento correcto antes de
-- migrarlo.
