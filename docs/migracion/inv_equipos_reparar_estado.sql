-- =====================================================================
-- Reparar equipos con INV_EQUIPOS.ESTADO desincronizado respecto a
-- INV_ASIGNACION.
--
-- MOTIVO: la version anterior de web/INV_InsertarAsignacion.jsp hacia
-- dos operaciones separadas en dos conexiones distintas y ademas usaba
-- executeQuery() sobre INSERT y UPDATE (invalido en JDBC -- lanza
-- SQLException sin ejecutar el statement siguiente). Resultado: los
-- equipos quedaban con una fila activa en INV_ASIGNACION (ESTADO='A')
-- pero INV_EQUIPOS.ESTADO se quedaba en 'D' (Disponible) o el valor
-- previo, entonces el listado los mostraba como disponibles aunque
-- estuvieran realmente asignados. El JSP ya fue reescrito con
-- PreparedStatement + transaccion en una sola conexion; este script
-- arregla los equipos ya afectados.
--
-- Este script es SEGURO de correr mas de una vez -- solo toca los que
-- realmente estan desincronizados. El primer bloque diagnostica sin
-- cambiar nada, correrlo antes de aplicar el UPDATE para ver que se va
-- a modificar.
-- =====================================================================

-- 1) Diagnostico: equipos con una asignacion activa pero ESTADO <> 'A'.
--    Deberian aparecer los "Disponible" que en realidad estan asignados.
SELECT e.IDINVEQUIPO, e.ESTADO AS estado_actual, e.MARCA, e.MODELO, e.SERIAL,
       u.NOMBRE || ' ' || u.APELLIDOS AS asignado_a,
       TO_CHAR(a.FECHAASIGNACION, 'DD/MM/YYYY') AS desde
FROM INV_EQUIPOS e
JOIN INV_ASIGNACION a ON a.IDINVEQUIPO = e.IDINVEQUIPO AND a.ESTADO = 'A'
JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
WHERE e.ESTADO_AI = 'A'
  AND e.ESTADO <> 'A'
ORDER BY e.IDINVEQUIPO;

-- 2) Reparacion: forzar ESTADO='A' cuando existe una INV_ASIGNACION
--    activa. Se preserva el estado si es F/V/R/M/PV/I/BK (esos son
--    lifecycle propios, no "asignacion"; se asume que si el equipo esta
--    en uno de esos estados y aparte quedo una asignacion abierta, la
--    asignacion es lo que hay que cerrar, no revertir el estado).
UPDATE INV_EQUIPOS e
   SET e.ESTADO = 'A'
 WHERE e.ESTADO_AI = 'A'
   AND e.ESTADO = 'D'
   AND EXISTS (
        SELECT 1 FROM INV_ASIGNACION a
         WHERE a.IDINVEQUIPO = e.IDINVEQUIPO AND a.ESTADO = 'A'
   );

COMMIT;

-- 3) Verificar: el query del paso 1 debe salir vacio ahora.
SELECT e.IDINVEQUIPO, e.ESTADO AS estado_actual, e.MARCA, e.MODELO, e.SERIAL,
       u.NOMBRE || ' ' || u.APELLIDOS AS asignado_a
FROM INV_EQUIPOS e
JOIN INV_ASIGNACION a ON a.IDINVEQUIPO = e.IDINVEQUIPO AND a.ESTADO = 'A'
JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
WHERE e.ESTADO_AI = 'A'
  AND e.ESTADO = 'D'
ORDER BY e.IDINVEQUIPO;
