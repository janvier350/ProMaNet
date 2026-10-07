-- =====================================================================
-- LOG_ACTIVIDAD -- agregar columna USER_AGENT
--
-- La MAC address no es capturable sobre HTTP (vive en capa 2 y no viaja
-- sobre internet). Lo mas cerca que podemos llegar a "identificar la
-- maquina" es el header User-Agent que manda el browser, que trae
-- sistema operativo + navegador + version. Ej:
--
--   Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
--   (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36
--
-- Es mas util que la MAC para evaluar uso del sistema: te dice "fulano
-- entra desde Windows + Chrome" en vez de "entra desde 00:1A:2B:...".
-- Se guarda hasta 300 caracteres (los User-Agent modernos suelen tener
-- unos 120-200).
-- =====================================================================

ALTER TABLE LOG_ACTIVIDAD ADD (USER_AGENT VARCHAR2(300));

COMMIT;

-- Verificar
SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'LOG_ACTIVIDAD' AND column_name = 'USER_AGENT';
