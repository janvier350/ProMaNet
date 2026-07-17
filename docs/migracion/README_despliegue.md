# Despliegue de ProMaNet en Oracle Cloud (OCI)

Base de datos: Autonomous Database (ATP) "PROMANET", region Chile Central (Santiago).
App: Tomcat en una VM Compute Always Free.

## Paso 5 - Cambios de conexion (YA HECHOS en el codigo)

La conexion vive en 6 archivos Java (el resto de JSPs la leen de la sesion):
- `src/java/Servlets/Ingreso.java`  (ipDB / userDB / passDB de la sesion)
- `src/java/Servlets/Conexion.java`
- `src/java/Servlets/FormulariosServlet.java`
- `src/java/Servlets/generarReporteGastosMes.java`
- `src/java/pdf/NewServlet.java`
- `src/java/pdf/reporteGasto.java`

Valores nuevos:
- URL: `jdbc:oracle:thin:@promanet_low?TNS_ADMIN=/opt/promanet/wallet`
- Usuario: `RRHH`
- Clave: placeholder `__CLAVE_RRHH_NUBE__`  <-- REEMPLAZAR con la clave real de RRHH
  (en NetBeans: Editar > Reemplazar en proyecto > buscar `__CLAVE_RRHH_NUBE__`)

## Paso 6 - Driver y librerias en el WAR

Reemplazar `ojdbc6.jar` por `ojdbc8.jar` y agregar las librerias del wallet:
- ojdbc8.jar
- oraclepki.jar
- osdt_core.jar
- osdt_cert.jar

(Se descargan de Oracle: "ojdbc8-full.tar.gz" / "instantclient ... JDBC".)
Van en la carpeta de librerias del proyecto (donde estaba ojdbc6.jar) y en
`WEB-INF/lib` del WAR.

## Paso 4 - Wallet en la VM

Subir el `Wallet_PROMANET.zip` a la VM y descomprimirlo en:
`/opt/promanet/wallet`
(Debe quedar ahi tnsnames.ora, sqlnet.ora, cwallet.sso, ewallet.p12, etc.)

El `TNS_ADMIN=/opt/promanet/wallet` de la URL apunta a esa carpeta.
El servicio `promanet_low` esta definido dentro del tnsnames.ora del wallet.

## Pasos 1-3 y 7-8

Infra (VM, Java, Tomcat, firewall) y despliegue del WAR: ver la guia paso a paso
de la sesion. Puertos: abrir 8080 (o 80) en la Security List de la VCN y en el
firewall del SO.
