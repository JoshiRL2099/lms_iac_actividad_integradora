# HashiCorp Vault - Gestión de Secretos LMS

## Secretos Almacenados

### 1. Credenciales AWS
- **Ruta:** `secret/aws`
- **Contenido:** 
  - `access_key`: Clave de acceso de AWS
  - `secret_key`: Clave secreta de AWS
- **Uso:** Terraform utiliza estas credenciales para aprovisionar infraestructura

### 2. Credenciales Base de Datos
- **Ruta:** `secret/database`
- **Contenido:**
  - `username`: lms_admin
  - `password`: Contraseña segura
  - `host`: Servidor de base de datos
  - `port`: 5432
- **Uso:** Aplicación LMS se conecta a PostgreSQL/MySQL

### 3. Token API Email
- **Ruta:** `secret/api/email`
- **Contenido:**
  - `token`: Token del servicio de email
- **Uso:** Envío de notificaciones a estudiantes y profesores

## Comandos Básicos

### Leer secreto
```bash
vault kv get secret/aws
```

### Guardar secreto
```bash
vault kv put secret/aws access_key="..." secret_key="..."
```

### Listar secretos
```bash
vault kv list secret/
```
