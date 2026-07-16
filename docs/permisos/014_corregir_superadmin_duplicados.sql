-- =====================================================================
-- Corregir un error del script 010: la concesion de SUPERADMIN se hizo
-- con "WHERE UPPER(USUARIO) = 'JVARAS'", que no distingue mayusculas/
-- minusculas. Eso alcanzo, ademas de la cuenta real de Javier, a otras
-- cuentas (de prueba/duplicadas) cuyo USUARIO tambien coincide en
-- mayusculas: confirmado por la verificacion del propio script 010,
-- que mostro SUPERADMIN_ACCESO_TOTAL concedido a 3 filas:
--   JVARAS  / Santiago (Prueba) / Varas Herrera  <- cuenta de prueba, NO debe tenerlo
--   jvaras  / Javier            / Varas Herrera  <- la cuenta real, SI debe tenerlo
--   jvaras  / papa              / (sin apellido) <- otra cuenta de prueba, NO debe tenerlo
--
-- Esto explica por que una cuenta de prueba con cargo PASANTE
-- (Santiago Prueba, departamento Tecnologia) veia TODO sin
-- restriccion: el bypass de SUPERADMIN en PermisoHelper.tiene()
-- ignora cualquier chequeo de cargo/departamento/permiso.
--
-- Este script quita el permiso de cualquier cuenta que calzo por el
-- match case-insensitive, EXCEPTO la que realmente es Javier Varas
-- Herrera (se identifica por NOMBRE + APELLIDOS, no solo por USUARIO,
-- ya que hay mas de una fila con USUARIO='jvaras' en minusculas).
-- =====================================================================

-- Verificar ANTES de borrar (para confirmar que la fila de Javier real
-- no se va a tocar):
SELECT u.IDUSUARIO, u.USUARIO, u.NOMBRE, u.APELLIDOS
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
WHERE up.ID_PERMISO = 11;

DELETE FROM APP_USUARIO_PERMISO
WHERE ID_PERMISO = 11
AND IDUSUARIO IN (
    SELECT IDUSUARIO FROM USUARIO
    WHERE UPPER(USUARIO) = 'JVARAS'
    AND NOT (UPPER(NOMBRE) = 'JAVIER' AND UPPER(APELLIDOS) = 'VARAS HERRERA')
);

COMMIT;

-- Verificar DESPUES: debe quedar UNA sola fila (Javier).
SELECT u.IDUSUARIO, u.USUARIO, u.NOMBRE, u.APELLIDOS
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
WHERE up.ID_PERMISO = 11;
