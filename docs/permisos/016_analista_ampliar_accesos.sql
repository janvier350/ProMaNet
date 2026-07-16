-- =====================================================================
-- Ampliar el rol ANALISTA con los accesos que hoy le faltan:
-- Solicitar Anticipo, Recursos, Lista Soportes, Solicitar soporte,
-- TO-DO, Agenda y Contactos.
--
-- ANALISTA quedo fuera del set "STD6" (todos los cargos de staff
-- menos ANALISTA) al que se le concedieron estos permisos en su
-- momento. Se agrega el rol a cada uno; el resto de cargos no se
-- toca. "Registrar Ejecutivo" no es parte de este script porque no
-- se maneja por permiso, sino por cargo crudo directo en el codigo
-- (ya se agrego ANALISTA ahi por separado).
--
--  7 = CONTROL_ACCESO    (tarjeta "Solicitar Anticipo")
-- 12 = TODO_ACCESO        (tarjeta "TO-DO")
-- 16 = SOPORTES_ACCESO    (tarjeta "Lista Soportes")
-- 17 = AGENDA_ACCESO      (tarjeta "Agenda")
-- 18 = CONTACTOS_ACCESO   (tarjeta "Contactos")
-- 23 = ACCESO_GENERAL     (tarjetas "Recursos" y "Solicitar soporte",
--                          que en realidad enlaza a Perfil.jsp)
-- =====================================================================

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 7 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 7);

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 12 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 12);

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 16 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 16);

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 17 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 17);

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 18 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 18);

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 23 FROM ROL WHERE CARGO = 'ANALISTA'
    AND IDROL NOT IN (SELECT IDROL FROM APP_ROL_PERMISO WHERE ID_PERMISO = 23);

COMMIT;

-- Verificar:
SELECT r.CARGO, p.CODIGO
FROM APP_ROL_PERMISO rp
JOIN ROL r ON rp.IDROL = r.IDROL
JOIN APP_PERMISO p ON rp.ID_PERMISO = p.ID_PERMISO
WHERE r.CARGO = 'ANALISTA' AND p.ID_PERMISO IN (7, 12, 16, 17, 18, 23)
ORDER BY p.CODIGO;
