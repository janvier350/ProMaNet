-- =====================================================================
-- Vacaciones: ventana para que los propios usuarios registren vacaciones
-- YA GOZADAS (fechas pasadas).
--
-- Hoy VAC_InsertarSolicitud rechaza cualquier "fecha desde" en el pasado.
-- Para ponerse al dia, Administracion/RRHH abre una VENTANA TEMPORAL
-- (con fecha limite) desde el Panel de Vacaciones; mientras esta vigente
-- los usuarios pueden solicitar rangos completamente pasados. Al cerrarla
-- (boton o por vencimiento de la fecha limite) todo vuelve al modo normal.
--
-- Las solicitudes creadas en la ventana quedan marcadas RETROACTIVA = 'S'
-- y siguen el flujo normal de aprobacion (jefe -> administracion).
--
-- Aditivo: no cambia datos existentes.
-- =====================================================================

CREATE TABLE VAC_RETRO_VENTANA (
    ID_VENTANA        NUMBER        NOT NULL,
    FECHA_APERTURA    DATE          DEFAULT SYSDATE NOT NULL,
    FECHA_LIMITE      DATE          NOT NULL,
    ACTIVA            CHAR(1)       DEFAULT 'S' NOT NULL,
    MOTIVO            VARCHAR2(300),
    ID_USUARIO_ABRE   NUMBER,
    FECHA_CIERRE      DATE,
    ID_USUARIO_CIERRE NUMBER,
    CONSTRAINT PK_VAC_RETRO_VENTANA PRIMARY KEY (ID_VENTANA),
    CONSTRAINT CK_VAC_RETRO_ACTIVA CHECK (ACTIVA IN ('S','N'))
);

ALTER TABLE VAC_SOLICITUD ADD RETROACTIVA CHAR(1) DEFAULT 'N' NOT NULL;
ALTER TABLE VAC_SOLICITUD ADD CONSTRAINT CK_VAC_SOL_RETRO CHECK (RETROACTIVA IN ('S','N'));
