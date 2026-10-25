## 1. Identificación de la Superficie de Ataque y Configuración

* **Importancia de conocer la ubicación física de los archivos:**  
  Permite auditar los permisos del sistema operativo, verificar que no existan accesos de lectura no autorizados a las credenciales/claves y asegurar la segregación entre ejecutables, archivos de configuración, datos y bitácoras de auditoría.

* **Comparación de Arquitecturas de Red (Directa vs Firewall + Red Privada):**  
  La arquitectura con **Firewall y Red Privada** reduce la superficie de ataque al actuar como una primera capa de defensa perimetral. Impide que escáneres automáticos desde Internet intenten ataques de fuerza bruta o exploten vulnerabilidades directamente sobre el puerto de la base de datos.

---

### Análisis de la Regla: `host all all 0.0.0.0/0 scram-sha-256`
1. **Bases de datos que permite:** Todas (`all`).
2. **Usuarios que permite:** Todos (`all`).
3. **Direcciones de origen:** Cualquiera en el mundo IPv4 (`0.0.0.0/0`).
4. **Método de autenticación:** `scram-sha-256`.
5. **Riesgo:** Representa una exposición excesiva porque permite intentos de conexión desde cualquier IP pública a cualquier base de datos y usuario.
6. **Regla Propuesta de Mínimo Privilegio:**
   ```text
   # TYPE  DATABASE        USER            ADDRESS                 METHOD
   host    basedatos_app   app_user        10.10.10.0/24           scram-sha-256