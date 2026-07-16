-- =====================================================================
-- Quitar a PASANTE el acceso a Solicitar Suministros, Movilizacion y
-- Anticipo (los demas cargos conservan estos permisos, no se tocan).
--
-- Los 3 permisos hoy se conceden por rol a todos los cargos del staff
-- (incluido PASANTE). Se elimina unicamente la fila de
-- APP_ROL_PERMISO para los roles con CARGO = 'PASANTE'.
--
--  1 = INVENTARIO_SOLICITAR   (tarjeta "Solicitar Suministros")
--  7 = CONTROL_ACCESO         (tarjeta "Solicitar Anticipo")
--  9 = MOVILIZACION_SOLICITAR (tarjeta "Solicitar Movilizacion")
-- =====================================================================

-- Verificar ANTES (para confirmar que hoy PASANTE tiene los 3):
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON rp.IDROL = r.IDROL
JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO
WHERE r.CARGO = 'PASANTE' AND p.ID_PERMISO IN (1, 7, 9);

DELETE FROM APP_ROL_PERMISO
WHERE ID_PERMISO IN (1, 7, 9)
AND IDROL IN (SELECT IDROL FROM ROL WHERE CARGO = 'PASANTE');

COMMIT;

-- Verificar DESPUES: no debe devolver ninguna fila.
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON rp.IDROL = r.IDROL
JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO
WHERE r.CARGO = 'PASANTE' AND p.ID_PERMISO IN (1, 7, 9);

-- Confirmar que los demas cargos SI conservan estos 3 permisos:
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON rp.IDROL = r.IDROL
JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO
WHERE p.ID_PERMISO IN (1, 7, 9)
ORDER BY p.CODIGO, r.CARGO;
