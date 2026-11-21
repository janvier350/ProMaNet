-- =====================================================================
-- Novedades dirigidas + ventana emergente (modal).
--
--  * APP_NOVEDAD.AUDIENCIA : T = todos, D = departamentos elegidos, U = usuarios elegidos.
--  * APP_NOVEDAD_DEST      : los departamentos (TIPO 'D', VALOR = ID_DEPARTAMENTO) o usuarios (TIPO 'U', VALOR = IDUSUARIO).
--  * APP_NOVEDAD.EN_MODAL  : 'S' = ademas de la tarjeta, aparece como ventana emergente al abrir el dashboard,
--                            una sola vez por persona (se registra en APP_NOVEDAD_VISTA).
-- Las novedades ya publicadas quedan como "para todos" y sin ventana emergente. Ejecutar DESPUES del 051.
-- =====================================================================
ALTER TABLE APP_NOVEDAD ADD (AUDIENCIA CHAR(1) DEFAULT 'T' NOT NULL, EN_MODAL CHAR(1) DEFAULT 'N' NOT NULL);

CREATE TABLE APP_NOVEDAD_DEST (
    ID_NOVEDAD NUMBER NOT NULL,
    TIPO       CHAR(1) NOT NULL,        -- D departamento, U usuario
    VALOR      VARCHAR2(40) NOT NULL,
    CONSTRAINT PK_APP_NOVEDAD_DEST PRIMARY KEY (ID_NOVEDAD, TIPO, VALOR)
);

CREATE TABLE APP_NOVEDAD_VISTA (
    ID_NOVEDAD NUMBER NOT NULL,
    ID_USUARIO NUMBER NOT NULL,
    FECHA      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_APP_NOVEDAD_VISTA PRIMARY KEY (ID_NOVEDAD, ID_USUARIO)
);
