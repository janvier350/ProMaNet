-- =====================================================================
-- Normaliza la columna CLIENTE (nombre del cliente) de CLIENTE a
-- mayusculas
--
-- Corre una sola vez para parejar los registros existentes que se
-- cargaron en minuscula/mixto -- de aqui en adelante, si se quiere que
-- todo ingreso nuevo tambien quede en mayusculas, eso hay que forzarlo
-- en la pantalla de alta/edicion de cliente (este script solo arregla
-- lo que ya esta cargado).
-- =====================================================================

UPDATE CLIENTE
SET CLIENTE = UPPER(CLIENTE)
WHERE CLIENTE != UPPER(CLIENTE);

COMMIT;

-- Verificar: no deberia devolver ninguna fila.
SELECT IDCLIENTE, CLIENTE
FROM CLIENTE
WHERE CLIENTE != UPPER(CLIENTE);
