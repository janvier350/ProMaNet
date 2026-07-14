-- =====================================================================
-- Modulo de Movilizacion: catalogo de Destinos
--
-- Se agrega un catalogo MOV_DESTINO (igual patron que MOV_MOTIVO /
-- MOV_MOVILIZADOR) y la columna ID_DESTINO en MOV_SOLICITUD.
--
-- OJO: no se agrega ningun destino de ejemplo (a diferencia de los
-- motivos, aqui no nos dieron una lista). El catalogo arranca vacio;
-- se llena desde la pantalla con el boton "+ Nuevo Destino" la primera
-- vez que alguien lo necesite.
--
-- ID_DESTINO es NULLABLE a proposito: las solicitudes que ya existen
-- (creadas antes de este cambio) se quedan sin destino, no hace falta
-- backfill.
-- =====================================================================

CREATE TABLE MOV_DESTINO (
    ID_DESTINO  NUMBER PRIMARY KEY,
    DESCRIPCION VARCHAR2(150) NOT NULL,
    ESTADO      CHAR(1) DEFAULT 'A' NOT NULL
);

ALTER TABLE MOV_SOLICITUD ADD ID_DESTINO NUMBER;
ALTER TABLE MOV_SOLICITUD ADD CONSTRAINT FK_MOVSOL_DESTINO
    FOREIGN KEY (ID_DESTINO) REFERENCES MOV_DESTINO(ID_DESTINO);

COMMIT;
