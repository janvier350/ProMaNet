-- =====================================================================
-- Bug: en SOP_EditarSolicitudes.jsp, la seccion "Reporte Tecnico"
-- (donde quien atiende el ticket registra su diagnostico) estaba
-- condicionada a SUPERADMIN_ACCESO_TOTAL en vez de un permiso propio.
-- Resultado: nadie que no fuera superadmin (jvaras) podia atender
-- tickets de soporte, ni siquiera Christian Varas (cvaras), que ya
-- tiene SOPORTES_ACCESO justo para eso (ver docs/permisos/012_...sql).
--
-- Se crea SOPORTES_ATENDER y se otorga a cvaras. PermisoHelper.tiene()
-- ya deja pasar automaticamente a SUPERADMIN_ACCESO_TOTAL, asi que
-- jvaras sigue viendo la seccion sin necesidad de un grant adicional.
-- =====================================================================

INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO)
VALUES (30, 'SOPORTES_ATENDER', 'SOPORTES', 'Puede atender solicitudes de soporte (registrar reporte tecnico)', 'A');

INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
SELECT IDUSUARIO, 30, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'CVARAS';

-- Verificar:
SELECT u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.CODIGO = 'SOPORTES_ATENDER';

-- Si todo bien: COMMIT;  Si no: ROLLBACK;
