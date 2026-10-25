## Objetivo
Implementar un proceso integral de endurecimiento (*hardening*) e inspección sobre una instancia de motor de base de datos PostgreSQL 16. El propósito es reducir su superficie de ataque, eliminar configuraciones inseguras de fábrica, aplicar el principio de menor privilegio mediante el control de acceso basado en roles (RBAC), forzar comunicaciones cifradas y establecer una línea base (*baseline*) de seguridad alineada con las mejores prácticas internacionales para entornos de producción.

## Entorno
* **Sistema Operativo:** Windows Environment
* **Motor de Base de Datos:** PostgreSQL 16.x
* **Herramientas de Administración:** `psql` (CLI), Visual Studio Code, Git
* **Protocolo de Red y Puerto:** TCP/5432, TLS v1.3
* **Directorio del Proyecto:** `lab-04-hardening/`

## Superficie de ataque inicial
En la inspección inicial mediante el script `sql/01-inspeccion.sql`, se identificaron los siguientes puntos de vulnerabilidad y exposición:
1. **Interfaces de Red:** Parámetro `listen_addresses = '*'` escuchando en todas las interfaces de red de la máquina hosting.
2. **Control de Acceso Perimetral (`pg_hba.conf`):** Presencia de reglas globales permisivas tipo `host all all 0.0.0.0/0 md5`, exponiendo el motor a cualquier origen IPv4.
3. **Mecanismo de Autenticación:** Uso de algoritmos de cifrado heredados (`md5`) o configuraciones permisivas (`trust`) en segmentos locales.
4. **Separación de Roles Inexistente:** Aplicación conectándose directamente utilizando el superusuario `postgres` (`SUPERUSER`), otorgando control absoluto sobre el motor de base de datos en caso de vulnerabilidades como SQL Injection.
5. **Cifrado en Tránsito:** Conexiones SSL/TLS desactivadas o laxas (`ssl = off`).
6. **Límites de Conexión:** Parámetros de timeout inactivos (`statement_timeout = 0`, `idle_in_transaction_session_timeout = 0`), lo que permite ataques de denegación de servicio (DoS) por agotamiento de conexiones.

## Hallazgos
* **Sobreexposición de red:** El puerto `5432` se encontraba expuesto a redes públicas sin filtrado previo de firewall.
* **Falta de segregación de funciones:** Ausencia de roles dedicados para administración (DBA), servicios de aplicación (DML) y lectura analítica (Read-Only).
* **Ausencia de límites de tiempo de sesión:** Sesiones inactivas o transacciones colgadas no eran terminadas por el motor, acumulando consumo innecesario de memoria y sockets.
* **Permisos del Sistema Operativo:** Permisos de carpetas de datos y archivos de configuración sin aislamiento suficiente a nivel del usuario `postgres` del SO.

## Cambios realizados
1. **Reducción de Interfaces:** Ajuste del parámetro `listen_addresses` a la dirección de red privada específica o `localhost`.
2. **Reconfiguración de `pg_hba.conf`:** Eliminación de reglas `0.0.0.0/0` y sustitución por segmentos de red CIDR específicos por usuario y base de datos (ej. `10.10.10.0/24`).
3. **Estandarización de Hashing:** Configuración obligatoria de `password_encryption = 'scram-sha-256'`.
4. **Implementación de Roles Segregados (RBAC):**
   * `dba_admin`: Rol administrativo con login exclusivo.
   * `app_user`: Rol operativo para la aplicación web con privilegios reducidos a DML (`SELECT`, `INSERT`, `UPDATE`, `DELETE`).
   * `consulta_user`: Rol de solo lectura (`SELECT`) sobre vistas anonimizadas para tareas de analítica.
5. **Ajuste de Timeouts y Conexiones:**
   * `max_connections = 100`
   * `superuser_reserved_connections = 3`
   * `statement_timeout = 30000` (30 segundos)
   * `idle_in_transaction_session_timeout = 60000` (60 segundos)
6. **Cifrado en Tránsito:** Activación forzada de TLS/SSL (`ssl = on`) en PostgreSQL.

## Justificación de los cambios
* **Estrategia de Defensa en Profundidad:** Al restringir IP, base de datos y usuario en `pg_hba.conf`, se imponen múltiples barreras antes de llegar a la fase de autenticación.
* **Principio de Menor Privilegio:** Evita que el compromiso de una cuenta de aplicación permita al atacante modificar esquemas, leer datos de otras bases o ejecutar funciones del sistema operativo.
* **Resiliencia ante Ataques DoS:** Los timeouts automáticos liberan recursos y evitan la saturación del pool de conexiones ante tráfico malicioso o fugas de conexiones en la aplicación.
* **Protección contra Sniffing y Retransmisión:** `SCRAM-SHA-256` y TLS v1.3 impiden que las credenciales o el tráfico con datos personales sean capturados mediante ataques man-in-the-middle (MitM).

## Verificación
La validación post-hardening se ejecutó mediante `sql/04-verificacion.sql` obteniendo los siguientes resultados:
* Confirmación de `password_encryption = scram-sha-256`.
* Confirmación de `ssl = on` y presencia del cipher en `pg_stat_ssl`.
* Ausencia de cuentas de aplicación con privilegios `SUPERUSER` en `pg_roles`.
* Confirmación de la aplicación de los parámetros `statement_timeout` e `idle_in_transaction_session_timeout`.

## Checklist de hardening

| # | Control | Estado | Evidencia |
| :-: | :--- | :-: | :--- |
| **1** | Puerto predeterminado protegido/filtrado por firewall | Aplicado | Configuración de red y Firewall |
| **2** | `listen_addresses` limitado a la red interna | Aplicado | `SHOW listen_addresses;` |
| **3** | `pg_hba.conf` revisado sin reglas `0.0.0.0/0` | Aplicado | `SELECT * FROM pg_hba_file_rules;` |
| **4** | Redes de origen restringidas por CIDR específico | Aplicado | Archivo `pg_hba.conf` |
| **5** | Autenticación mediante `scram-sha-256` activa | Aplicado | `SHOW password_encryption;` |
| **6** | Cuentas de superusuario restringidas e identificadas | Aplicado | Consulta sobre `pg_roles` |
| **7** | Separación formal entre roles DBA, App y Consulta | Aplicado | Script `sql/02-roles.sql` |
| **8** | Aplicación limitada a permisos DML indispensables | Aplicado | Sentencias `GRANT` acotadas |
| **9** | Inventario y revisión de extensiones (`pg_extension`) | Aplicado | `SELECT * FROM pg_extension;` |
| **10**| Conexiones cifradas en tránsito forzadas (TLS/SSL) | Aplicado | Consulta sobre `pg_stat_ssl` |
| **11**| Permisos de `postgresql.conf` en modo `0600` | Aplicado | Inspección en SO (`ls -l`) |
| **12**| Directorio de datos con permisos restrictivos `0700` | Aplicado | Inspección en SO (`ls -ld`) |
| **13**| Límite de tiempo en ejecuciones (`statement_timeout`)| Aplicado | `SHOW statement_timeout;` |
| **14**| Cierre de transacciones inactivas (`idle_timeout`) | Aplicado | `SHOW idle_in_transaction_session_timeout;` |
| **15**| Desactivación de cuentas y bases de datos de prueba | Aplicado | Auditoría de `pg_roles` |

## Conclusiones
El hardening de un motor de bases de datos como PostgreSQL no es un evento único, sino un proceso continuo de administración de configuraciones y gobernanza de accesos. La seguridad por defecto no viene garantizada en las instalaciones estándar, por lo que es responsabilidad técnica del administrador configurar explícitamente barreras en la capa de red, autenticación, autorización y sistema operativo. La implementación de un *baseline* de seguridad formalizado minimiza el riesgo operativo y garantiza el cumplimiento normativo en la protección de activos de información.