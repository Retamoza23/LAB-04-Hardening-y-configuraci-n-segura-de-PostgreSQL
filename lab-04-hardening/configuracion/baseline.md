## 1. Red y Exposición
* **`listen_addresses`:** Configurar explícitamente en la IP de la interfaz interna o `localhost`.
* **Puerto:** Mantener puerto estándar `5432` siempre que esté protegido por un Firewall de red.
* **Firewall:** Reglas estrictas `DROP ALL` por defecto, permitiendo únicamente el tráfico proveniente de las subredes autorizadas (ej. Red DBA: `10.10.10.0/24`).

## 2. Autenticación y Credenciales
* **Algoritmo de Hashing:** `password_encryption = scram-sha-256`.
* **Política de Passwords:** Mínimo 16 caracteres, mezcla de mayúsculas, minúsculas, números y símbolos.
* **Manejo de Secretos:** Prohibido almacenar credenciales en repositorios de código. Utilizar gestores de secretos (AWS Secrets Manager / Vault).

## 3. Autorización y Permisos (RBAC)
* **Separación de Funciones:**
  * **DBA:** Unicamente administración del motor.
  * **App:** Unicamente DML (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) en tablas del esquema de producción.
  * **Consulta:** Acceso restringido de solo lectura (`SELECT`) sobre vistas anonimizadas o enmascaradas.
* **Desactivación de Superusuario:** Ningún software o servicio web debe conectarse como `postgres`.

## 4. Configuración del Motor
* **Límite de Conexiones:** `max_connections` ajustado a la capacidad del servidor.
* **Reservas de Administración:** `superuser_reserved_connections = 3`.
* **Timeouts Protegidos:** `statement_timeout = 30000ms`, `idle_in_transaction_session_timeout = 60000ms`.
* **Extensiones:** Revisión periódica de `pg_extension`. Eliminar extensiones no requeridas.

## 5. Permisos del Sistema Operativo
* **Directorio de Datos (`PGDATA`):** Propietario `postgres:postgres`, permisos `0700`.
* **Archivos de Configuración (`postgresql.conf`, `pg_hba.conf`):** Permisos `0600`.

## 6. Cifrado y Comunicaciones
* **TLS Obligatorio:** `ssl = on`, `ssl_min_protocol_version = TLSv1.2` (preferible `TLSv1.3`).
* **Clientes:** Configuración obligatoria con `sslmode=verify-full`.

## 7. Mantenimiento y Auditoría
* **Actualizaciones:** Aplicación regular de parches de seguridad de PostgreSQL.
* **Logs:** Activación de `log_connections`, `log_disconnections` y retención de bitácoras.