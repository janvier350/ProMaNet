-- =====================================================================
-- Vacaciones: OFICINA de cada empleado (para separar los datos por sede).
--
-- El campo se edita en Vacaciones > Configuracion (lista de oficinas en
-- VACACIONES/VAC_Oficinas.java: Norte, Kennedy 401, Kennedy 403, Romeria,
-- Magisterio, Outsourcing -- las mismas ubicaciones que usa Inventario).
--
-- EJECUTAR ANTES DE DESPLEGAR: la pantalla de configuracion y su servlet
-- ahora leen/escriben VAC_CONFIG_USUARIO.OFICINA.
-- =====================================================================

-- PASO 1: crear la columna ----------------------------------------------
ALTER TABLE VAC_CONFIG_USUARIO ADD OFICINA VARCHAR2(50);

-- PASO 2 (opcional): vista previa de la carga inicial a partir del equipo
-- asignado (el mas reciente de cada usuario). Solo para quienes aun no
-- tienen oficina. Revisar antes de ejecutar el paso 3.
SELECT u.IDUSUARIO, u.NOMBRE||' '||u.APELLIDOS AS EMPLEADO, x.UBICACIONOFICINA AS OFICINA_SUGERIDA
FROM VAC_CONFIG_USUARIO vc
JOIN USUARIO u ON u.IDUSUARIO = vc.ID_USUARIO
JOIN (SELECT IDUSUARIO, UBICACIONOFICINA FROM (
          SELECT a.IDUSUARIO, e.UBICACIONOFICINA,
                 ROW_NUMBER() OVER (PARTITION BY a.IDUSUARIO ORDER BY a.FECHAASIGNACION DESC, a.IDINV_ASIGNACION DESC) RN
          FROM INV_ASIGNACION a JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDINVEQUIPO
          WHERE a.ESTADO = 'A' AND e.UBICACIONOFICINA IN ('Norte','Kennedy 401','Kennedy 403','Romeria','Magisterio','Outsourcing'))
      WHERE RN = 1) x ON x.IDUSUARIO = vc.ID_USUARIO
WHERE vc.OFICINA IS NULL AND u.ESTADO = 'a'
ORDER BY u.NOMBRE;

-- PASO 3 (opcional): aplicar la carga inicial -----------------------------
UPDATE VAC_CONFIG_USUARIO vc
SET vc.OFICINA = (
    SELECT x.UBICACIONOFICINA FROM (
        SELECT IDUSUARIO, UBICACIONOFICINA FROM (
            SELECT a.IDUSUARIO, e.UBICACIONOFICINA,
                   ROW_NUMBER() OVER (PARTITION BY a.IDUSUARIO ORDER BY a.FECHAASIGNACION DESC, a.IDINV_ASIGNACION DESC) RN
            FROM INV_ASIGNACION a JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDINVEQUIPO
            WHERE a.ESTADO = 'A' AND e.UBICACIONOFICINA IN ('Norte','Kennedy 401','Kennedy 403','Romeria','Magisterio','Outsourcing'))
        WHERE RN = 1) x
    WHERE x.IDUSUARIO = vc.ID_USUARIO)
WHERE vc.OFICINA IS NULL
  AND EXISTS (SELECT 1 FROM INV_ASIGNACION a JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = a.IDINVEQUIPO
              WHERE a.IDUSUARIO = vc.ID_USUARIO AND a.ESTADO = 'A'
                AND e.UBICACIONOFICINA IN ('Norte','Kennedy 401','Kennedy 403','Romeria','Magisterio','Outsourcing'));
COMMIT;

-- Los empleados sin equipo (ej. recepcion, agentes externos) quedan sin
-- oficina: se asignan a mano desde Vacaciones > Configuracion > Editar.
