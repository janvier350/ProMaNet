-- =====================================================================
-- Modulo de permisos - Fase 1 (piloto: Inventario)
--
-- Este script es unicamente ADITIVO: crea 3 tablas nuevas y las llena
-- con datos semilla que reproducen el comportamiento actual del modulo
-- de Inventario (segun la auditoria de roles). No modifica ninguna
-- tabla existente (USUARIO, ROL, etc.).
--
-- Ejecutar manualmente contra la base de datos, revisando antes cada
-- sentencia. Requiere que existan las tablas USUARIO(IDUSUARIO) y
-- ROL(IDROL, CARGO).
-- =====================================================================

-- 1) Catalogo de permisos --------------------------------------------
CREATE TABLE APP_PERMISO (
    ID_PERMISO   NUMBER PRIMARY KEY,
    CODIGO       VARCHAR2(60)  NOT NULL UNIQUE,
    MODULO       VARCHAR2(40)  NOT NULL,
    DESCRIPCION  VARCHAR2(200),
    ESTADO       CHAR(1) DEFAULT 'A' NOT NULL
);

-- 2) Permisos por rol (comportamiento por defecto) -------------------
CREATE TABLE APP_ROL_PERMISO (
    IDROL      NUMBER NOT NULL,
    ID_PERMISO NUMBER NOT NULL,
    CONSTRAINT PK_APP_ROL_PERMISO PRIMARY KEY (IDROL, ID_PERMISO),
    CONSTRAINT FK_ARP_ROL     FOREIGN KEY (IDROL)      REFERENCES ROL(IDROL),
    CONSTRAINT FK_ARP_PERMISO FOREIGN KEY (ID_PERMISO) REFERENCES APP_PERMISO(ID_PERMISO)
);

-- 3) Excepciones por usuario especifico -------------------------------
--    TIPO = 'G' concede el permiso aunque su rol no lo tenga.
--    TIPO = 'D' se lo quita aunque su rol si lo tenga (gana sobre el rol).
CREATE TABLE APP_USUARIO_PERMISO (
    IDUSUARIO  NUMBER NOT NULL,
    ID_PERMISO NUMBER NOT NULL,
    TIPO       CHAR(1) NOT NULL,
    CONSTRAINT PK_APP_USUARIO_PERMISO PRIMARY KEY (IDUSUARIO, ID_PERMISO),
    CONSTRAINT FK_AUP_USUARIO FOREIGN KEY (IDUSUARIO)  REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_AUP_PERMISO FOREIGN KEY (ID_PERMISO) REFERENCES APP_PERMISO(ID_PERMISO),
    CONSTRAINT CK_AUP_TIPO CHECK (TIPO IN ('G','D'))
);

-- =====================================================================
-- Catalogo de permisos: modulo Inventario
-- =====================================================================
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (1, 'INVENTARIO_SOLICITAR', 'INVENTARIO', 'Solicitar suministros y ver el historial del propio departamento');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (2, 'INVENTARIO_VER_TODAS', 'INVENTARIO', 'Ver la cola de solicitudes de todos los departamentos');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (3, 'INVENTARIO_DESPACHAR', 'INVENTARIO', 'Despachar/confirmar solicitudes (descuenta existencia)');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (4, 'INVENTARIO_INGRESOS', 'INVENTARIO', 'Registrar ingresos de suministros y administrar catalogos (productos, unidades, categorias, proveedores)');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (5, 'INVENTARIO_EXISTENCIAS', 'INVENTARIO', 'Ver dashboard de existencias/alertas y editar producto/unidad');
INSERT INTO APP_PERMISO (ID_PERMISO, CODIGO, MODULO, DESCRIPCION) VALUES
    (6, 'INVENTARIO_IMPRIMIR_COMPROBANTE', 'INVENTARIO', 'Imprimir el comprobante de entrega de una solicitud despachada');

-- =====================================================================
-- Asignacion por rol: reproduce el comportamiento actual (post fixes
-- de seguridad) del modulo de Inventario. Ajustar aqui si en la
-- practica algun rol debe ganar o perder un permiso.
-- =====================================================================
INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 1 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','ASISTENTE','PASANTE','CONTRALOR','JEFE','ANALISTA');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 2 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 3 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 4 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 5 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION','ADMINISTRADOR','CONTRALOR','JEFE');

INSERT INTO APP_ROL_PERMISO (IDROL, ID_PERMISO)
    SELECT IDROL, 6 FROM ROL WHERE CARGO IN
        ('ADMINISTRACION');

COMMIT;

-- =====================================================================
-- Para revertir (si algo sale mal), en orden:
--   DROP TABLE APP_USUARIO_PERMISO;
--   DROP TABLE APP_ROL_PERMISO;
--   DROP TABLE APP_PERMISO;
-- =====================================================================
