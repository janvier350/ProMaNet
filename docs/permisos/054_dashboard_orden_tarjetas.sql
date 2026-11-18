-- =====================================================================
-- Orden de las tarjetas del dashboard por usuario (drag & drop). Guarda la lista de tarjetas en el orden elegido
-- (texto "pendientes,novedades,..."), para que siga al usuario en cualquier equipo. Sin esta tabla el orden se guarda
-- solo en el navegador de cada equipo. Ejecutar en el esquema de la aplicacion.
-- =====================================================================
CREATE TABLE APP_USUARIO_DASH (
    ID_USUARIO NUMBER NOT NULL,
    ORDEN      VARCHAR2(500),
    FECHA_ACT  DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_APP_USUARIO_DASH PRIMARY KEY (ID_USUARIO)
);
