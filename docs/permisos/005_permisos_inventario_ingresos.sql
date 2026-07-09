-- =====================================================================
-- Modulo de permisos - Fase 3: unificar el flujo de "Ingresos" de
-- Inventario (registrar factura, catalogos de producto/unidad/
-- categoria/proveedor) bajo INVENTARIO_INGRESOS (ID_PERMISO=4).
--
-- Hoy ese flujo esta repartido en checks de cargo inconsistentes:
--   - INV_Ingreso_Suministro2.jsp / INV_Ingreso_Suministro_Detalle.jsp:
--       solo ADMINISTRACION/ADMINISTRADOR
--   - Crear/terminar factura (INV_Insert_Ingreso_Suministro_Cab.java,
--     INV_Terminar_Ingreso.java): ADMINISTRACION/ADMINISTRADOR/
--     CONTRALOR/JEFE
--   - Eliminar factura (INV_Delete_Suministro_Cab.java): JEFE/
--     ADMINISTRACION/ADMINISTRADOR
--   - Catalogos (producto/categoria/proveedor/unidad de medida) y
--     agregar producto a factura: JEFE/ASISTENTE (a veces +CONTRALOR)
--
-- Este script agrega a INVENTARIO_INGRESOS (que 001_esquema_permisos.sql
-- ya le dio a ADMINISTRACION/ADMINISTRADOR) los cargos CONTRALOR, JEFE
-- y ASISTENTE, para que nadie pierda lo que ya puede hacer hoy al
-- unificar todos estos archivos bajo un solo permiso.
-- =====================================================================

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 4 FROM ROL WHERE CARGO IN ('CONTRALOR','JEFE','ASISTENTE')
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 4);

COMMIT;

-- Verificar:
SELECT r.CARGO FROM APP_ROL_PERMISO rp JOIN ROL r ON rp.IDROL = r.IDROL
WHERE rp.ID_PERMISO = 4 ORDER BY r.CARGO;
