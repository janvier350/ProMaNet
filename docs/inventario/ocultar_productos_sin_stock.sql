--------------------------------------------------------------------------
-- Ocultar (soft-delete) productos de inventario sin stock
--------------------------------------------------------------------------
-- Agrega un campo ESTADO a INV_PRODUCTO (A=activo, I=oculto) y marca como
-- ocultos los productos que hoy estan en existencia 0. No borra nada: los
-- productos y su historial se conservan, solo dejan de mostrarse en la
-- pantalla de Existencias (que filtra por ESTADO='A').
--
-- Reversible: para volver a mostrar un producto -> UPDATE ... SET ESTADO='A'.
-- Ejecutar en la base de RRHH. Revisar antes de COMMIT.
--------------------------------------------------------------------------

-- 1. Agregar la columna de estado (por defecto activo).
ALTER TABLE INV_PRODUCTO ADD (ESTADO CHAR(1) DEFAULT 'A');

-- 2. Asegurar que todos los productos existentes queden activos.
UPDATE INV_PRODUCTO SET ESTADO = 'A' WHERE ESTADO IS NULL;

-- 3. Ocultar los productos que hoy estan en existencia 0.
UPDATE INV_PRODUCTO p
SET ESTADO = 'I'
WHERE NVL((SELECT SUM(e.EXISTENCIA) FROM INV_SUMINISTRO_EXISTENCIA e
           WHERE e.ID_PRODUCTO = p.ID_PRODUCTO), 0) = 0;

-- 4. Revisar cuantos quedaron ocultos vs activos antes de confirmar.
SELECT ESTADO, COUNT(*) FROM INV_PRODUCTO GROUP BY ESTADO;

-- Si todo cuadra:
-- COMMIT;
-- Si algo se ve mal:
-- ROLLBACK;
