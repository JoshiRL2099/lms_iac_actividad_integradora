# Seguridad con HashiCorp Vault

## Descripción

Este archivo documenta el uso de HashiCorp Vault dentro del proyecto LMS. Vault se utilizó para gestionar secretos de forma centralizada y evitar que credenciales sensibles quedaran escritas directamente en el código fuente o en archivos del repositorio.

La implementación se realizó en modo desarrollo, con fines académicos y de prueba. En un entorno productivo, Vault debe configurarse con almacenamiento persistente, políticas de acceso, auditoría, respaldos y alta disponibilidad.

## Objetivo de Vault en el proyecto

El objetivo principal fue reforzar la seguridad del proyecto mediante la separación entre código y secretos.

En lugar de escribir credenciales dentro de archivos de Terraform, Ansible o configuración de la aplicación, Vault funciona como un almacén centralizado donde se guardan y consultan los secretos cuando son necesarios.

## Secretos considerados

Dentro del proyecto LMS se consideraron los siguientes secretos:

| Ruta en Vault | Contenido | Uso dentro del proyecto |
|---|---|---|
| `secret/aws` | `access_key`, `secret_key` | Terraform consulta estas credenciales para crear recursos en AWS |
| `secret/database` | `username`, `password`, `host`, `port` | Ansible o la aplicación LMS pueden usar estos datos para conectarse a la base de datos |
| `secret/api/email` | `token` | La aplicación LMS puede usarlo para enviar notificaciones por correo |

## Configuración inicial de Vault

Primero se verificó que Vault estuviera instalado:

```bash
vault version
```

Después se inició Vault en modo desarrollo:

```bash
vault server -dev
```

Este modo inicia Vault localmente, desbloqueado y con un token root generado automáticamente. Se usó únicamente para práctica y demostración.

En otra terminal se configuraron las variables de entorno:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='TOKEN_GENERADO_POR_VAULT'
```

Luego se verificó el estado de Vault:

```bash
vault status
```

El resultado esperado debe mostrar:

```text
Initialized: true
Sealed: false
```

Esto significa que Vault está iniciado y listo para recibir comandos.

## Estructura de secretos

Los secretos se organizaron dentro del mount point `secret/`, usando una estructura por categorías:

```text
secret/
├── aws
├── database
└── api/
    └── email
```

Esta organización permite separar los secretos según su uso y facilita agregar nuevas rutas en el futuro, por ejemplo:

```text
secret/api/sms
secret/api/payment
secret/ssh
```

## Creación de secretos

### Credenciales de AWS

Ruta:

```text
secret/aws
```

Comando de ejemplo:

```bash
vault kv put secret/aws access_key="XXXX" secret_key="XXXX"
```

Uso:

Terraform puede consultar esta ruta para obtener las credenciales necesarias para crear recursos en AWS, como VPC, EC2, S3 y Application Load Balancer.

### Credenciales de base de datos

Ruta:

```text
secret/database
```

Comando de ejemplo:

```bash
vault kv put secret/database username="lms_admin" password="XXXX" host="lms-database" port=5432
```

Uso:

Estas credenciales pueden ser utilizadas por Ansible durante la configuración del servidor o por la aplicación LMS cuando necesite conectarse a una base de datos.

### Token para servicio de correo

Ruta:

```text
secret/api/email
```

Comando de ejemplo:

```bash
vault kv put secret/api/email token="XXXX"
```

Uso:

Este token se usaría para que la aplicación LMS pueda enviar correos de notificación, como avisos de tareas, inscripciones o recordatorios.

## Verificación de secretos

Para listar los secretos creados:

```bash
vault kv list secret/
```

Resultado esperado:

```text
Keys
----
api/
aws
database
```

Para consultar un secreto específico:

```bash
vault kv get secret/aws
```

Este comando permite verificar que el secreto existe y que Vault puede entregar la información cuando se utiliza un token válido.

## Integración con Terraform

Se agregó el archivo:

```text
terraform/vault.tf
```

Este archivo define la conexión con Vault y permite que Terraform lea secretos desde la ruta `secret/aws`.

También se modificó el archivo:

```text
terraform/variables.tf
```

para agregar una variable sensible:

```hcl
variable "vault_token" {
  description = "Token de Vault para leer secretos"
  type        = string
  sensitive   = true
}
```

Además, el provider de AWS puede obtener las credenciales desde Vault, en lugar de tenerlas escritas directamente en `provider.tf`.

Flujo general:

```text
Terraform -> Vault -> secret/aws -> AWS
```

Comandos usados para probar la integración:

```bash
cd terraform
terraform init
terraform plan -var="vault_token=TOKEN_GENERADO_POR_VAULT"
```

Con esta integración, Terraform puede consultar Vault y usar las credenciales necesarias para comunicarse con AWS.

## Integración con Ansible

Se agregó el archivo:

```text
ansible/vault-demo.yml
```

Este archivo funciona como una prueba de concepto para mostrar cómo Ansible puede consultar secretos desde Vault.

También se verificó la colección necesaria:

```bash
ansible-galaxy collection install community.hashi_vault
```

El playbook consulta rutas como:

```text
secret/aws
secret/database
```

Comando usado:

```bash
cd ansible
ansible-playbook vault-demo.yml
```

Durante la prueba local se presentó el siguiente error:

```text
A worker was found in a dead state
```

Este error apareció al ejecutar el playbook en el entorno local de macOS. Por esta razón, `vault-demo.yml` se mantiene como prueba de concepto y no reemplaza al playbook principal `site.yml`.

## Propuesta de uso con el playbook principal

En una siguiente etapa, la lógica de Vault podría integrarse directamente en `site.yml`. Por ejemplo, Ansible podría consultar `secret/database` y usar esos valores para crear un archivo de configuración de la aplicación LMS.

Ejemplo conceptual:

```yaml
- name: Obtener credenciales de base de datos desde Vault
  set_fact:
    db_user: "{{ lookup('community.hashi_vault.vault_kv2_get', 'secret/database', url=vault_addr, token=vault_token).secret.username }}"
    db_pass: "{{ lookup('community.hashi_vault.vault_kv2_get', 'secret/database', url=vault_addr, token=vault_token).secret.password }}"
```

Con esto, las credenciales de base de datos no se escribirían directamente dentro del playbook.

## Beneficios para el proyecto

El uso de Vault aporta varias ventajas al LMS:

- Evita guardar credenciales en archivos de código.
- Centraliza los secretos en un solo lugar.
- Permite separar permisos por servicio o herramienta.
- Facilita cambiar credenciales sin modificar todo el repositorio.
- Mejora la seguridad del flujo DevOps.
- Prepara el proyecto para prácticas más cercanas a un entorno real.

## Limitaciones

Esta implementación fue realizada en modo desarrollo, por lo que no debe usarse tal cual en producción.

Limitaciones principales:

- `vault server -dev` guarda la información en memoria.
- El token root no debe usarse para operaciones diarias en producción.
- No se configuraron políticas avanzadas de acceso.
- No se habilitó auditoría persistente.
- No se configuró alta disponibilidad.
- No se configuraron respaldos.

## Recomendaciones para producción

Para un entorno productivo se recomienda:

- No usar modo desarrollo.
- Configurar almacenamiento persistente.
- Habilitar auditoría.
- Crear políticas de acceso con privilegios mínimos.
- Usar autenticación segura.
- Rotar credenciales periódicamente.
- Configurar respaldos.
- Configurar alta disponibilidad.

## Archivos relacionados

```text
terraform/vault.tf
terraform/variables.tf
terraform/provider.tf
ansible/vault-demo.yml
vault/vault-usage.md
```

## Comandos principales utilizados

```bash
vault version
vault server -dev
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='TOKEN_GENERADO_POR_VAULT'
vault status

vault kv put secret/aws access_key="XXXX" secret_key="XXXX"
vault kv put secret/database username="lms_admin" password="XXXX" host="lms-database" port=5432
vault kv put secret/api/email token="XXXX"

vault kv list secret/
vault kv get secret/aws

cd terraform
terraform init
terraform plan -var="vault_token=TOKEN_GENERADO_POR_VAULT"

cd ../ansible
ansible-playbook vault-demo.yml
```

## Buenas prácticas de seguridad

Antes de subir cambios al repositorio, revisar que no existan credenciales reales:

```bash
grep -R "hvs\|AKIA\|secret_key\|access_key\|password\|token" .
```

También se recomienda mantener en `.gitignore`:

```gitignore
.DS_Store
.env
*.pem
*.tfstate
*.tfstate.backup
.terraform/
.vault-token
```

## Conclusión

Vault permitió reforzar la seguridad del proyecto LMS al separar las credenciales del código fuente. Aunque se trabajó en modo desarrollo, la práctica demuestra cómo Vault puede integrarse con Terraform y Ansible para manejar secretos de forma más segura, ordenada y reutilizable.
