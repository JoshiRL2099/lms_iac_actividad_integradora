# Learning Management System (LMS) - Infraestructura como Código

## Descripción del proyecto

Este repositorio contiene el bosquejo y la preparación de infraestructura para un Learning Management System (LMS), desarrollado como actividad integradora de Infraestructura como Código y seguridad.

El proyecto utiliza herramientas DevOps para preparar un entorno de desarrollo en AWS. Terraform se usa para aprovisionar la infraestructura, Ansible para configurar el servidor EC2 y HashiCorp Vault para gestionar secretos y credenciales sensibles.

## Objetivo

Implementar una infraestructura base para un LMS aplicando prácticas de DevOps, principalmente:

- Aprovisionamiento de infraestructura mediante Terraform.
- Gestión de configuración mediante Ansible.
- Gestión segura de secretos mediante HashiCorp Vault.
- Versionamiento y trabajo colaborativo mediante GitHub.

## Alcance del proyecto

El objetivo principal de esta actividad no es desarrollar la aplicación LMS completa, sino preparar la infraestructura necesaria para que posteriormente pueda desplegarse una aplicación educativa.

La infraestructura está pensada para un entorno de desarrollo y pruebas. En una versión productiva se podrían agregar más instancias EC2, base de datos administrada, HTTPS, monitoreo, políticas de seguridad más estrictas y alta disponibilidad completa.

## Herramientas utilizadas

| Herramienta | Uso dentro del proyecto |
|---|---|
| AWS | Proveedor de nube para crear la infraestructura |
| Terraform | Aprovisionamiento de recursos como VPC, EC2, S3 y ALB |
| Ansible | Configuración automática del servidor EC2 |
| HashiCorp Vault | Gestión centralizada de secretos |
| Docker | Preparación del servidor para aplicaciones en contenedores |
| GitHub | Control de versiones y colaboración del equipo |

## Requerimientos principales

El LMS requiere una infraestructura que permita:

- Soportar usuarios como estudiantes y profesores.
- Almacenar archivos multimedia como documentos, imágenes y videos.
- Permitir escalabilidad mediante balanceo de carga.
- Mantener credenciales y secretos fuera del código fuente.
- Automatizar la creación y configuración del entorno.

## Arquitectura general

La infraestructura se organiza en tres capas principales.

### Capa de red

- VPC con rango `10.0.0.0/16`.
- Subred pública 1: `10.0.1.0/24` en `us-east-1a`.
- Subred pública 2: `10.0.2.0/24` en `us-east-1b`.
- Internet Gateway para permitir comunicación con Internet.
- Route Table pública con salida hacia `0.0.0.0/0` por medio del Internet Gateway.

### Capa de aplicación

- Instancia EC2 tipo `t2.micro`.
- Sistema operativo Ubuntu 22.04.
- Docker y Docker Compose instalados con Ansible.
- Application Load Balancer para distribuir tráfico HTTP/HTTPS.

### Capa de seguridad

- Security Group con reglas para SSH y HTTP.
- Llave SSH para acceso al servidor EC2.
- HashiCorp Vault para almacenar secretos como credenciales de AWS, base de datos y tokens de API.

## Recursos principales en AWS

| Recurso | Descripción |
|---|---|
| VPC | Red principal del proyecto con CIDR `10.0.0.0/16` |
| Public Subnet 1 | Subred pública `10.0.1.0/24` en `us-east-1a` |
| Public Subnet 2 | Subred pública `10.0.2.0/24` en `us-east-1b` |
| Internet Gateway | Permite comunicación entre la VPC e Internet |
| Route Table | Define la ruta pública hacia el Internet Gateway |
| Security Group | Controla el tráfico permitido hacia la instancia EC2 |
| EC2 | Servidor base del LMS con Ubuntu 22.04 |
| S3 Bucket | Almacenamiento para archivos multimedia, estáticos o respaldos |
| Application Load Balancer | Balanceador para distribuir tráfico web |

## Estructura del repositorio

```text
lms_iac_actividad_integradora/
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── site.yml
│   └── vault-demo.yml
│
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── vault.tf
│
├── vault/
│   └── vault-usage.md
│
├── .gitignore
└── README.md
```

## Aprovisionamiento con Terraform

Terraform se utiliza para definir y crear la infraestructura en AWS a partir de archivos de configuración.

### Recursos aprovisionados

- VPC.
- Subredes públicas.
- Internet Gateway.
- Route Table.
- Security Group.
- Instancia EC2.
- S3 Bucket.
- Application Load Balancer.

### Comandos principales

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Nota sobre Vault y Terraform

Se agregó el archivo `terraform/vault.tf` para integrar Terraform con HashiCorp Vault. La finalidad es que Terraform pueda obtener credenciales desde Vault, específicamente desde la ruta `secret/aws`, en lugar de tener claves escritas directamente en el código.

Ejemplo de ejecución con token de Vault:

```bash
terraform plan -var="vault_token=TOKEN_GENERADO_POR_VAULT"
```

## Gestión de configuración con Ansible

Ansible se utiliza para configurar la instancia EC2 después de que Terraform crea la infraestructura.

### Archivos principales

| Archivo | Función |
|---|---|
| `ansible/inventory.ini` | Define el servidor EC2 que será configurado |
| `ansible/ansible.cfg` | Configuración general de Ansible |
| `ansible/site.yml` | Playbook principal para configurar el servidor |
| `ansible/vault-demo.yml` | Prueba de concepto para consultar secretos desde Vault |

### Tareas realizadas con Ansible

- Actualización del sistema operativo.
- Instalación de dependencias base.
- Instalación de Docker.
- Instalación de Docker Compose.
- Configuración de permisos para el usuario `ubuntu`.
- Verificación de servicios.

### Comandos principales

```bash
cd ansible
ansible lms_servers -m ping
ansible-playbook site.yml
```

## Seguridad con HashiCorp Vault

Vault se utiliza para centralizar la gestión de secretos del proyecto y evitar que credenciales sensibles queden expuestas en archivos del repositorio.

### Secretos considerados

| Ruta en Vault | Uso |
|---|---|
| `secret/aws` | Credenciales para que Terraform pueda autenticarse en AWS |
| `secret/database` | Datos de conexión para la base de datos del LMS |
| `secret/api/email` | Token para servicio de correo o notificaciones |

La documentación específica de Vault se encuentra en:

```text
vault/vault-usage.md
```

## Flujo general de trabajo DevOps

El flujo general del proyecto es el siguiente:

```text
1. Terraform crea la infraestructura en AWS.
2. Ansible configura la instancia EC2 creada por Terraform.
3. Vault almacena y entrega secretos de forma controlada.
4. GitHub permite versionar y compartir los archivos del proyecto.
```

## Integrantes y responsabilidades

| Integrante | Responsabilidad principal |
|---|---|
| Evelyn Betzabeth Sotelo Pichardo | Gestión de configuración con Ansible |
| Joshua Reyes León | Aprovisionamiento de infraestructura con Terraform y AWS |
| Estrella Ximena Zarate Delgado | Seguridad con HashiCorp Vault e integración con Terraform/Ansible |

## Buenas prácticas de seguridad

No se deben subir credenciales reales al repositorio.

Antes de hacer commit, se recomienda revisar que no existan tokens, contraseñas, llaves privadas o access keys dentro de los archivos:

```bash
grep -R "hvs\|AKIA\|secret_key\|access_key\|password\|token" .
```

Se recomienda mantener en `.gitignore` archivos sensibles o innecesarios:

```gitignore
.DS_Store
.env
*.pem
*.tfstate
*.tfstate.backup
.terraform/
.vault-token
```

## Limitaciones del entorno

Esta infraestructura corresponde a un entorno de desarrollo. Por esa razón:

- Se utiliza una sola instancia EC2.
- El balanceador queda preparado para escalar, pero no representa alta disponibilidad completa si solo existe una instancia.
- Vault se ejecuta en modo desarrollo para fines académicos.
- Las reglas de seguridad deben endurecerse antes de un uso en producción.
- En producción, SSH no debería estar abierto a cualquier IP.

## Mejoras futuras

Para una versión productiva, se recomienda agregar:

- Más instancias EC2 en diferentes zonas de disponibilidad.
- Base de datos administrada con Amazon RDS.
- HTTPS con certificado SSL/TLS.
- Políticas IAM con privilegios mínimos.
- Monitoreo y alertas.
- Backups automáticos.
- Configuración productiva de Vault con auditoría y almacenamiento persistente.

## Referencias oficiales

- Terraform Documentation: https://developer.hashicorp.com/terraform/docs
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Ansible Documentation: https://docs.ansible.com/
- HashiCorp Vault Documentation: https://developer.hashicorp.com/vault/docs
- AWS Documentation: https://docs.aws.amazon.com/
