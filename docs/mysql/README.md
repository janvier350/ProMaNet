# ProMaNet en MySQL (para MySQL Workbench)

Scripts generados a partir de la estructura Oracle vigente del proyecto
(`docs/migracion/atp_01_estructura.sql`, `atp_02_llaves_foraneas.sql` y los
scripts de modulos: permisos 001-042, capacitaciones, legal, perifericos,
ajuste de stock).

| Archivo | Contenido |
|---|---|
| `promanet_mysql_01_estructura.sql` | Esquema `promanet`: 79 tablas, indices, checks y llaves foraneas declaradas en el proyecto |
| `promanet_mysql_02_relaciones_logicas.sql` | (Opcional) 46 relaciones adicionales implicitas en el modelo, para un diagrama E-R completo |

Requiere **MySQL 8.0.16+** (CHECK, indices funcionales). Ambos archivos se probaron
contra MySQL 8.0.46 sin errores.

## Uso
1. Workbench: *File > Open SQL Script...* > `promanet_mysql_01_estructura.sql` > ejecutar todo.
2. (Opcional) ejecutar `promanet_mysql_02_relaciones_logicas.sql`.
3. Diagrama: *Database > Reverse Engineer...* y elegir el esquema `promanet`.

Para recrear desde cero: `DROP DATABASE IF EXISTS promanet;` y volver a ejecutar.

## Notas de la conversion
- `NUMBER` -> `INT` (ids) / `DECIMAL` (dias, montos); `DATE` -> `DATETIME`; `FLOAT(126)` de dinero -> `DECIMAL(12,2)`.
- Las llaves numericas son `AUTO_INCREMENT` y aceptan ids explicitos (la app usa `MAX+1`).
- Tablas Oracle sin PK reciben una sobre su primera columna (lista al final del script 01).
- Solo estructura: no incluye datos ni el catalogo de permisos (`APP_PERMISO`).
- El esquema no incluye las tablas antiguas del diagrama de mayo 2025 que ya no existen en la base vigente.
