-- =====================================================================
-- Quitar a un usuario del modulo Anticipos Auditoria (caso: MARIA
-- MAGDALENA MAXIMI CHANCAY, que paso a CONTABILIDAD y sigue apareciendo
-- en Auditoria, por lo que el sistema la manda a Auditoria y no la deja
-- usar el flujo de anticipos de Control).
--
-- Por que pasa: el acceso a Anticipos Auditoria (ANTICIPOS_AUD_ACCESO) se
-- concede por DEPARTAMENTO (APP_DEPARTAMENTO_PERMISO) o de forma
-- INDIVIDUAL (APP_USUARIO_PERMISO). Al cambiar a alguien de departamento
-- solo deja de aplicar la concesion por departamento: una concesion
-- individual (o una anterior) se queda para siempre. Esa es la causa
-- mas probable.
--
-- Ejecutar por pasos y revisar el resultado de cada SELECT.
-- Despues del paso 3 la usuaria debe CERRAR SESION y volver a entrar:
-- los permisos se cargan al iniciar sesion.
-- =====================================================================

-- PASO 1: ¿de donde le viene el acceso? ---------------------------------
-- 1a) Concesion/denegacion individual (la causa probable).
SELECT up.IDUSUARIO, u.USUARIO, u.NOMBRE||' '||u.APELLIDOS AS NOMBRE, p.CODIGO, up.TIPO
FROM APP_USUARIO_PERMISO up
JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
JOIN USUARIO u ON u.IDUSUARIO = up.IDUSUARIO
WHERE p.CODIGO IN ('ANTICIPOS_AUD_ACCESO','ANTICIPOS_AUD_GESTIONAR')
  AND UPPER(u.NOMBRE||' '||u.APELLIDOS) LIKE '%MAXIMI%CHANCAY%';

-- 1b) Su departamento actual y si ese departamento tiene el acceso.
SELECT u.IDUSUARIO, u.USUARIO, d.DEPARTAMENTO,
       (SELECT COUNT(*) FROM APP_DEPARTAMENTO_PERMISO dp JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO
         WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G'
           AND UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO)) AS DEPTO_TIENE_ACCESO
FROM USUARIO u
LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO
WHERE UPPER(u.NOMBRE||' '||u.APELLIDOS) LIKE '%MAXIMI%CHANCAY%';
--   DEPTO_TIENE_ACCESO = 0  -> el acceso es individual (1a lo muestra).
--   DEPTO_TIENE_ACCESO > 0  -> su departamento en USUARIO sigue siendo
--                              Auditoria: hay que corregir el departamento.

-- PASO 2: quitar la concesion individual ---------------------------------
DELETE FROM APP_USUARIO_PERMISO
WHERE TIPO = 'G'
  AND ID_PERMISO IN (SELECT ID_PERMISO FROM APP_PERMISO WHERE CODIGO = 'ANTICIPOS_AUD_ACCESO')
  AND IDUSUARIO IN (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(NOMBRE||' '||APELLIDOS) LIKE '%MAXIMI%CHANCAY%');
-- Debe decir "1 fila eliminada". Si dice 0, el acceso no era individual: revisar el paso 1b.

COMMIT;

-- PASO 3: verificacion ----------------------------------------------------
-- No debe devolver filas para ella (si devuelve algo, sigue con acceso).
SELECT u.IDUSUARIO, u.NOMBRE||' '||u.APELLIDOS
FROM USUARIO u
LEFT JOIN ADM_DEPARTAMENTO d ON u.ID_ADM_DEPARTAMENTO = d.ID_DEPARTAMENTO
WHERE UPPER(u.NOMBRE||' '||u.APELLIDOS) LIKE '%MAXIMI%CHANCAY%'
  AND (
    EXISTS (SELECT 1 FROM APP_DEPARTAMENTO_PERMISO dp JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO
             WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G' AND UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO))
    OR EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
                WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up.TIPO = 'G' AND up.IDUSUARIO = u.IDUSUARIO));

-- AUDITORIA PREVENTIVA: todos los que hoy tienen Anticipos Auditoria por
-- concesion individual pero NO pertenecen al departamento Auditoria.
-- Cada uno es un caso a revisar (ej. STEFANIA ROSERO, gestora, es
-- legitima; los demas probablemente no).
SELECT u.IDUSUARIO, u.NOMBRE||' '||u.APELLIDOS AS NOMBRE, d.DEPARTAMENTO
FROM USUARIO u
LEFT JOIN ADM_DEPARTAMENTO d ON d.ID_DEPARTAMENTO = u.ID_ADM_DEPARTAMENTO
WHERE u.ESTADO = 'a'
  AND EXISTS (SELECT 1 FROM APP_USUARIO_PERMISO up JOIN APP_PERMISO p ON p.ID_PERMISO = up.ID_PERMISO
               WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND up.TIPO = 'G' AND up.IDUSUARIO = u.IDUSUARIO)
  AND NOT EXISTS (SELECT 1 FROM APP_DEPARTAMENTO_PERMISO dp JOIN APP_PERMISO p ON p.ID_PERMISO = dp.ID_PERMISO
                   WHERE p.CODIGO = 'ANTICIPOS_AUD_ACCESO' AND dp.TIPO = 'G' AND UPPER(dp.DEPARTAMENTO) = UPPER(d.DEPARTAMENTO))
ORDER BY u.NOMBRE;

-- NOTA: sus solicitudes ANTERIORES en AUD_ANTICIPOS (historial) quedan
-- intactas; solo se le quita el acceso al modulo hacia adelante. Si tiene
-- una solicitud PENDIENTE de Auditoria del mes en curso, resolverla antes
-- (el gestor puede marcarla como pagada) para que no quede huerfana.
