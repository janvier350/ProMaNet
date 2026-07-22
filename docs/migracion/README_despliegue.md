# Despliegue de ProMaNet en Oracle Cloud (OCI)

Base de datos: Autonomous Database (ATP) "PROMANET", region Chile Central (Santiago).
App: Tomcat en una VM Compute Always Free.

## Paso 5 - Conexion por configuracion externa (YA HECHO en el codigo)

La conexion ya NO esta quemada en el codigo. Todos los archivos leen los
valores desde `Servlets/Conexion.java`, que funciona asi:
- Por DEFECTO apunta a la base LOCAL de produccion
  (`jdbc:oracle:thin:@181.198.203.205:1521:xe`, usuario/clave RRHH).
- Si existe el archivo externo `/opt/promanet/db.properties` (o la ruta que
  se pase con `-Dpromanet.db.config=...`), sus valores MANDAN.

Ventaja: el mismo codigo/WAR sirve en local y en la nube sin editar nada.
Hacer `git pull` en la maquina local NO cambia a donde apunta (sigue local).

### En la VM de la nube: crear el archivo de config
Ver `db.properties.ejemplo`. Resumen:
```
sudo mkdir -p /opt/promanet
sudo tee /opt/promanet/db.properties >/dev/null <<'EOF'
db.url=jdbc:oracle:thin:@promanet_low?TNS_ADMIN=/opt/promanet/wallet
db.user=RRHH
db.pass=LA_CLAVE_REAL_DE_RRHH
EOF
sudo chown tomcat:tomcat /opt/promanet/db.properties
sudo chmod 640 /opt/promanet/db.properties
sudo systemctl restart tomcat
```
Ya NO hay que reemplazar ningun placeholder en el codigo antes de compilar.

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
