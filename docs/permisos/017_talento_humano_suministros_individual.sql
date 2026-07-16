-- =====================================================================
-- Restringir "Talento Humano" e "Inventario Suministros" a solo 2
-- personas (dnaranjo, gnaranjo), en vez de todo el departamento
-- ADMINISTRACIÓN.
--
-- Se crea un permiso nuevo, de concesion PURAMENTE individual (sin
-- fila en APP_ROL_PERMISO ni en APP_DEPARTAMENTO_PERMISO): asi nadie
-- lo tiene "por defecto" y solo se los damos a estas 2 cuentas via
-- APP_USUARIO_PERMISO. El bypass de SUPERADMIN sigue funcionando
-- igual (PermisoHelper.tiene() lo ignora todo si tienes
-- SUPERADMIN_ACCESO_TOTAL).
-- =====================================================================

INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (27, 'TALENTO_HUMANO_SUMINISTROS_ACCESO', 'SISTEMA', 'Acceso a Talento Humano (ADM_Dashboard.jsp) e Inventario Suministros (INV_Dashboard.jsp) -- concesion individual, sin cargo/departamento asociado');
COMMIT;

-- Verificar ANTES de conceder: confirma que 'DNARANJO' y 'GNARANJO'
-- apuntan a las cuentas correctas (revisa NOMBRE/APELLIDOS/ESTADO).
SELECT IDUSUARIO, USUARIO, NOMBRE, APELLIDOS, ESTADO FROM USUARIO
WHERE UPPER(USUARIO) IN ('DNARANJO', 'GNARANJO');

-- Conceder el permiso individual a ambas cuentas:
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 27, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'DNARANJO';
INSERT INTO APP_USUARIO_PERMISO (IDUSUARIO, ID_PERMISO, TIPO)
    SELECT IDUSUARIO, 27, 'G' FROM USUARIO WHERE UPPER(USUARIO) = 'GNARANJO';
COMMIT;

-- Verificar DESPUES:
SELECT u.IDUSUARIO, u.USUARIO, u.NOMBRE, u.APELLIDOS, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
WHERE p.ID_PERMISO = 27;
