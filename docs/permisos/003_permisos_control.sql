-- =====================================================================
-- Modulo de permisos - Fase 2: Control/RRHH (sueldos y anticipos)
--
-- Aditivo: agrega 2 permisos nuevos al catalogo ya creado por
-- 001_esquema_permisos.sql (no repetir ese script, este es incremental).
--
-- IMPORTANTE - esto SI cambia comportamiento actual, a proposito:
-- Hoy, ADM_Asignar_Sueldo.jsp (ver/asignar el sueldo de CUALQUIER
-- empleado), ADM_Asignar_Fecha_Corte_Anticipos.jsp (fecha de corte
-- de anticipos), y los servlets que procesan pagos masivos de
-- anticipos y exportan el reporte de sueldos de toda la compania,
-- estan abiertos a TODOS los cargos (incluidos ASISTENTE y PASANTE).
-- Este script los reclasifica como CONTROL_GESTIONAR, que solo
-- ADMINISTRACION/ADMINISTRADOR/CONTRALOR/JEFE tienen por defecto.
-- Si algun ASISTENTE o PASANTE necesita seguir teniendo esa capacidad
-- puntualmente, se le puede conceder despues desde
-- PCN_GestionPermisosUsuario.jsp sin devolverle el cargo mas alto.
-- =====================================================================

INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (7, 'CONTROL_ACCESO', 'CONTROL', 'Entrar al modulo de Control: ver el dashboard y solicitar el propio anticipo de sueldo');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (8, 'CONTROL_GESTIONAR', 'CONTROL', 'Ver y asignar el sueldo de otros empleados, editar/procesar anticipos ajenos, definir fecha de corte y exportar el reporte de sueldos de toda la compania');

-- CONTROL_ACCESO: mismo alcance que hoy (entrada al modulo + autoservicio)
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 7 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE');

-- CONTROL_GESTIONAR: solo los cargos que ya podian ver/aprobar informacion de otros
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 8 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

COMMIT;
