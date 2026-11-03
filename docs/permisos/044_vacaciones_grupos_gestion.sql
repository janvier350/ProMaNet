-- =====================================================================
-- Vacaciones: GRUPOS DE GESTION (cada oficina gestiona sus vacaciones por
-- separado). Hoy: ROMERIA (gestora srosero) y KENNEDY (gestor smoran,
-- oficinas Kennedy 401 y 403). El administrador global (jvaras) ve todo y
-- asigna a los empleados "Sin asignar" a su grupo.
--
-- Modelo: el grupo se asigna POR EMPLEADO (VAC_CONFIG_USUARIO.ID_GRUPO), no por
-- oficina fisica -- asi las excepciones (esta en una oficina, lo gestiona
-- otra) se resuelven cambiando el grupo de la persona. La OFICINA queda
-- como dato informativo y como sugerencia de grupo.
--
-- Un gestor solo ve/modifica/aprueba a los empleados de SUS grupos. Quien
-- tiene el permiso VACACIONES_GRUPOS ve todo y administra los grupos.
-- La ventana de "vacaciones ya gozadas" tambien pasa a ser por grupo.
--
-- EJECUTAR ANTES DE DESPLEGAR (las pantallas leen estas tablas/columnas).
-- =====================================================================

-- 1) Tablas y columnas ---------------------------------------------------
CREATE TABLE VAC_GRUPO (
    ID_GRUPO  NUMBER        NOT NULL,
    NOMBRE    VARCHAR2(60)  NOT NULL,
    ESTADO    CHAR(1)       DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_VAC_GRUPO PRIMARY KEY (ID_GRUPO),
    CONSTRAINT UK_VAC_GRUPO_NOMBRE UNIQUE (NOMBRE),
    CONSTRAINT CK_VAC_GRUPO_ESTADO CHECK (ESTADO IN ('A','I'))
);

CREATE TABLE VAC_GRUPO_GESTOR (
    ID_GRUPO    NUMBER NOT NULL,
    ID_USUARIO  NUMBER NOT NULL,
    CONSTRAINT PK_VAC_GRUPO_GESTOR PRIMARY KEY (ID_GRUPO, ID_USUARIO),
    CONSTRAINT FK_VAC_GG_GRUPO FOREIGN KEY (ID_GRUPO) REFERENCES VAC_GRUPO(ID_GRUPO),
    CONSTRAINT FK_VAC_GG_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(IDUSUARIO)
);

ALTER TABLE VAC_CONFIG_USUARIO ADD ID_GRUPO NUMBER;
ALTER TABLE VAC_CONFIG_USUARIO ADD CONSTRAINT FK_VAC_CONFIG_GRUPO FOREIGN KEY (ID_GRUPO) REFERENCES VAC_GRUPO(ID_GRUPO);

-- Ventana de vacaciones ya gozadas: ahora por grupo (NULL = ventanas anteriores, valen para todos).
ALTER TABLE VAC_RETRO_VENTANA ADD ID_GRUPO NUMBER;

-- 2) Grupos y gestores ---------------------------------------------------
INSERT INTO VAC_GRUPO (ID_GRUPO, NOMBRE) VALUES (1, 'ROMERIA');
INSERT INTO VAC_GRUPO (ID_GRUPO, NOMBRE) VALUES (2, 'KENNEDY');

INSERT INTO VAC_GRUPO_GESTOR (ID_GRUPO, ID_USUARIO)
    SELECT 1, IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SROSERO';
INSERT INTO VAC_GRUPO_GESTOR (ID_GRUPO, ID_USUARIO)
    SELECT 2, IDUSUARIO FROM USUARIO WHERE UPPER(USUARIO) = 'SMORAN';

-- 3) Permisos -------------------------------------------------------------
-- Nuevo: VACACIONES_GRUPOS (administrador global). Los gestores necesitan
-- CONFIGURAR y GESTIONAR para entrar a las pantallas (el alcance lo limita su grupo).
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION, ESTADO)
    SELECT NVL(MAX(ID_PERMISO), 0) + 1, 'VACACIONES_GRUPOS', 'VACACIONES',
           'Administrar los grupos de gestion de Vacaciones y ver/gestionar a todos los empleados, incluidos los sin asignar', 'A'
    FROM APP_PERMISO
    WHERE NOT EXISTS (SELECT 1 FROM APP_PERMISO WHERE CODIGO = 'VACACIONES_GRUPOS');

MERGE INTO APP_USUARIO_PERMISO up
USING (
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) IN ('JVARAS', 'SMORAN', 'SROSERO')
      AND p.CODIGO IN ('VACACIONES_CONFIGURAR', 'VACACIONES_GESTIONAR')
    UNION
    SELECT u.IDUSUARIO, p.ID_PERMISO
    FROM USUARIO u, APP_PERMISO p
    WHERE UPPER(u.USUARIO) = 'JVARAS' AND p.CODIGO = 'VACACIONES_GRUPOS'
) src
ON (up.IDUSUARIO = src.IDUSUARIO AND up.ID_PERMISO = src.ID_PERMISO)
WHEN NOT MATCHED THEN INSERT (IDUSUARIO, ID_PERMISO, TIPO) VALUES (src.IDUSUARIO, src.ID_PERMISO, 'G');

COMMIT;

-- 4) Carga inicial opcional: grupo segun la oficina ya definida -------------
-- Vista previa (no modifica nada):
SELECT u.NOMBRE||' '||u.APELLIDOS AS EMPLEADO, vc.OFICINA,
       CASE WHEN vc.OFICINA = 'Romeria' THEN 'ROMERIA'
            WHEN vc.OFICINA IN ('Kennedy 401','Kennedy 403') THEN 'KENNEDY' END AS GRUPO_SUGERIDO
FROM VAC_CONFIG_USUARIO vc JOIN USUARIO u ON u.IDUSUARIO = vc.ID_USUARIO
WHERE vc.ID_GRUPO IS NULL AND vc.OFICINA IN ('Romeria','Kennedy 401','Kennedy 403')
ORDER BY 3, 1;

-- Aplicar (solo a quienes aun no tienen grupo). Norte, Magisterio y Outsourcing
-- NO se tocan: quedan "Sin asignar" para que el administrador global los ubique.
UPDATE VAC_CONFIG_USUARIO
SET ID_GRUPO = CASE WHEN OFICINA = 'Romeria' THEN 1 ELSE 2 END
WHERE ID_GRUPO IS NULL AND OFICINA IN ('Romeria','Kennedy 401','Kennedy 403');
COMMIT;

-- Verificacion
SELECT g.NOMBRE AS GRUPO, COUNT(vc.ID_USUARIO) AS EMPLEADOS
FROM VAC_GRUPO g LEFT JOIN VAC_CONFIG_USUARIO vc ON vc.ID_GRUPO = g.ID_GRUPO
GROUP BY g.NOMBRE ORDER BY 1;
SELECT g.NOMBRE AS GRUPO, u.USUARIO AS GESTOR
FROM VAC_GRUPO_GESTOR gg JOIN VAC_GRUPO g ON g.ID_GRUPO = gg.ID_GRUPO JOIN USUARIO u ON u.IDUSUARIO = gg.ID_USUARIO;
