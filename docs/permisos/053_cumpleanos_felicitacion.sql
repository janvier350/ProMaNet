-- =====================================================================
-- Felicitacion de cumpleanos con confeti (dashboard): guarda el ultimo anio en que ya se felicito al usuario, para
-- mostrarla UNA sola vez por cumpleanos (el dia mismo o, si no entro ese dia, la primera vez que entre despues,
-- hasta 15 dias). Ejecutar DESPUES del 051. Sin esta columna la felicitacion se muestra una vez por sesion.
-- =====================================================================
ALTER TABLE USUARIO_CUMPLE ADD (FELICITADO_ANIO NUMBER(4));

-- Para volver a ver la felicitacion de un usuario (pruebas):
-- UPDATE USUARIO_CUMPLE SET FELICITADO_ANIO = NULL WHERE ID_USUARIO = (SELECT IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'JVARAS');
-- COMMIT;
