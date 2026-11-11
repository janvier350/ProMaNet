-- =====================================================================
-- Mantenimiento de equipos: cerrar los tickets [MANTENIMIENTO] que quedaron ABIERTOS aunque el
-- mantenimiento ya se registro desde Inventario (antes de que el registro cerrara el ticket solo).
--
-- Un ticket [MANTENIMIENTO] abierto se considera atendido si su equipo tiene un mantenimiento PREVENTIVO
-- registrado en la fecha del ticket o despues. Ejecutar por pasos y revisar la vista previa.
-- =====================================================================

-- PASO 1: vista previa (no modifica nada) -------------------------------------
SELECT t.IDSOPORTE, TO_CHAR(t.FECHA_SOLICITUD,'DD/MM/YYYY') AS TICKET_DEL, t.ESTADO,
       e.MARCA || ' ' || e.MODELO AS EQUIPO, TO_CHAR(m.FECHA_MANT,'DD/MM/YYYY') AS MANTENIMIENTO, m.ID_MANTENIMIENTO
FROM SOP_SOPORTE_CAB t
JOIN INV_EQUIPOS e ON e.IDINVEQUIPO = t.IDEQUIPO
JOIN INV_MANTENIMIENTO m ON m.IDINVEQUIPO = t.IDEQUIPO AND m.ESTADO = 'A' AND m.TIPO = 'PREVENTIVO'
                        AND m.FECHA_MANT >= TRUNC(t.FECHA_SOLICITUD)
WHERE t.SOPORTE LIKE '[MANTENIMIENTO]%' AND t.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO')
ORDER BY t.IDSOPORTE;

-- PASO 2: cerrar esos tickets y vincular el mantenimiento -----------------------
UPDATE SOP_SOPORTE_CAB t
SET t.ESTADO = 'ATENDIDO',
    t.FECHA_REPORTE = SYSDATE,
    t.FECHA_PRIMERA_ATENCION = NVL(t.FECHA_PRIMERA_ATENCION, SYSDATE),
    t.TECNICO = NVL((SELECT u.USUARIO FROM INV_MANTENIMIENTO m JOIN USUARIO u ON u.IDUSUARIO = m.ID_TECNICO
                     WHERE m.IDINVEQUIPO = t.IDEQUIPO AND m.ESTADO = 'A' AND m.TIPO = 'PREVENTIVO'
                       AND m.FECHA_MANT >= TRUNC(t.FECHA_SOLICITUD) AND ROWNUM = 1), t.TECNICO),
    t.REPORTE = 'Mantenimiento preventivo ya registrado en Inventario (cierre automatico de ticket pendiente).'
WHERE t.SOPORTE LIKE '[MANTENIMIENTO]%' AND t.ESTADO IN ('PENDIENTE','EN_PROGRESO','REASIGNADO')
  AND EXISTS (SELECT 1 FROM INV_MANTENIMIENTO m WHERE m.IDINVEQUIPO = t.IDEQUIPO AND m.ESTADO = 'A'
                AND m.TIPO = 'PREVENTIVO' AND m.FECHA_MANT >= TRUNC(t.FECHA_SOLICITUD));

UPDATE INV_MANTENIMIENTO m
SET m.ID_SOPORTE = (SELECT MAX(t.IDSOPORTE) FROM SOP_SOPORTE_CAB t
                    WHERE t.IDEQUIPO = m.IDINVEQUIPO AND t.SOPORTE LIKE '[MANTENIMIENTO]%' AND t.ESTADO = 'ATENDIDO'
                      AND t.REPORTE LIKE 'Mantenimiento preventivo ya registrado%' AND m.FECHA_MANT >= TRUNC(t.FECHA_SOLICITUD))
WHERE m.ID_SOPORTE IS NULL AND m.TIPO = 'PREVENTIVO' AND m.ESTADO = 'A';
COMMIT;
