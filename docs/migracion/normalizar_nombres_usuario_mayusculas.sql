-- =====================================================================
-- Normaliza NOMBRE y APELLIDOS de USUARIO a mayusculas
--
-- Corre una sola vez para parejar los registros existentes que se
-- cargaron en minuscula/mixto -- de aqui en adelante, si se quiere que
-- todo ingreso nuevo tambien quede en mayusculas, eso hay que forzarlo
-- en las pantallas de alta/edicion de usuario (este script solo arregla
-- lo que ya esta cargado).
-- =====================================================================

UPDATE USUARIO
SET NOMBRE = UPPER(NOMBRE),
    APELLIDOS = UPPER(APELLIDOS)
WHERE NOMBRE != UPPER(NOMBRE)
   OR APELLIDOS != UPPER(APELLIDOS);

COMMIT;

-- Verificar: no deberia devolver ninguna fila.
SELECT IDUSUARIO, NOMBRE, APELLIDOS
FROM USUARIO
WHERE NOMBRE != UPPER(NOMBRE) OR APELLIDOS != UPPER(APELLIDOS);
