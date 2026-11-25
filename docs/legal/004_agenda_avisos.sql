-- =====================================================================
-- Agenda legal: control de recordatorios enviados por correo (para no repetirlos).
-- Un recordatorio = un evento + su fecha + un responsable. Si el evento cambia de fecha, se avisa de nuevo.
-- Ejecutar DESPUES de docs/legal/003_agenda_legal.sql. El envio se enciende en db.properties del servidor de produccion:
--     legal.recordatorio=S          (por defecto apagado)
--     legal.recordatorio.hora=16    (hora del dia en que se envian los de "el proximo dia habil"; por defecto 16)
--     legal.aviso.prueba=correo@dominio   (opcional: todo va solo a esa direccion y no se marca como enviado)
-- =====================================================================
CREATE TABLE LEG_AGENDA_AVISO (
    ID_EVENTO    NUMBER NOT NULL,
    FECHA_EVENTO DATE   NOT NULL,
    ID_USUARIO   NUMBER NOT NULL,
    FECHA_ENVIO  DATE   DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_LEG_AGENDA_AVISO PRIMARY KEY (ID_EVENTO, FECHA_EVENTO, ID_USUARIO)
);
