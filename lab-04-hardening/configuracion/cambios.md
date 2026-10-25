| Control | Antes | Después | Justificación |
| :--- | :--- | :--- | :--- |
| **listen_addresses** | `*` (Todas las interfaces) | `localhost` / `10.10.10.20` | Reduce la exposición de red evitando accesos desde interfaces no autorizadas. |
| **pg_hba.conf** | `host all all 0.0.0.0/0 md5` | `host basedatos_app app_user 10.10.10.0/24 scram-sha-256` | Aplica el principio de mínimo privilegio restringiendo BD, usuario y red de origen. |
| **Método de autenticación** | `md5` / `trust` | `scram-sha-256` | Protege contra ataques de retransmisión y descifrado por fuerza bruta. |
| **Usuarios administrativos** | `postgres` usado para la app | `dba_admin` separado | Previene el uso de cuentas con privilegios totales para tareas cotidianas. |
| **Cuentas de aplicación** | Superusuario único | `app_user` (solo DML) y `consulta_user` (Read-only) | Aisla y restringe privilegios operativos en la base de datos. |
| **Puerto** | `5432` expuesto públicamente | `5432` filtrado por Firewall | Evita el escaneo automatizado en redes no seguras. |
| **TLS** | Desactivado o permisivo | `ssl = on` con `TLSv1.3` | Garantiza la confidencialidad de datos y credenciales en tránsito. |
| **Permisos SO** | Archivos con `0644` / `755` | `0600` para configs y `0700` para datos (propietario `postgres`) | Evita la lectura de archivos de configuración o tablas por usuarios no privilegiados del SO. |
| **Extensiones** | Extensiones innecesarias activas | Únicamente `pgcrypto` autorizada | Minimiza la superficie de ataque reduciendo código de terceros no utilizado. |
| **Conexiones y Timeouts** | Sin límites / `timeout = 0` | `statement_timeout = 30s`, `idle_timeout = 60s` | Protege contra denegación de servicio (DoS) y agotamiento de memoria/pool. |