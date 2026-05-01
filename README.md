# 🎓 Learning Management System - Infraestructura como Código

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-EE0000?logo=ansible)](https://www.ansible.com/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Vault](https://img.shields.io/badge/HashiCorp-Vault-000000?logo=vault)](https://www.vaultproject.io/)

> Proyecto de Infraestructura como Código (IaC) para un Learning Management System desplegado en AWS utilizando Terraform, Ansible y HashiCorp Vault.

## 🎯 Descripción del Proyecto

Este proyecto implementa la infraestructura completa para un Learning Management System (LMS) utilizando las mejores prácticas de DevOps:

- **Infraestructura como Código (IaC)** con Terraform
- **Automatización de Configuración** con Ansible
- **Gestión de Secretos** con HashiCorp Vault
- **Despliegue en AWS** (EC2, VPC, S3, ALB)

## 🏗️ Arquitectura

```
Internet → Internet Gateway → Route Table → VPC (10.0.0.0/16)
                                              │
                                              └─→ Public Subnet (10.0.1.0/24)
                                                   ├─ EC2 (t2.micro + Docker)
                                                   ├─ Security Group (SSH, HTTP)
                                                   └─ Application Load Balancer

S3 Bucket (archivos estáticos)
HashiCorp Vault (gestión de secretos)
```

### Componentes Principales

| Componente | Especificación |
|------------|----------------|
| **VPC** | CIDR: 10.0.0.0/16 |
| **Subred** | 10.0.1.0/24 (us-east-1a) |
| **EC2** | t2.micro, Ubuntu 22.04 LTS |
| **ALB** | Application Load Balancer |
| **S3** | lms-bucket-joshua-548161 |
| **Security Group** | SSH (22), HTTP (80) |

## 📁 Estructura del Proyecto

```
lms_iac_actividad_integradora/
├── terraform/          # Infraestructura como código
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/           # Automatización de configuración
│   ├── ansible.cfg
│   ├── inventory.ini
│   └── site.yml
├── vault/            # Documentación de Vault
│   └── vault-usage.md
└── README.md
```

## 🚀 Guía de Despliegue

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/JoshiRL2099/lms_iac_actividad_integradora.git
cd lms_iac_actividad_integradora
```

### Paso 2: Desplegar con Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Paso 3: Configurar con Ansible

```bash
cd ../ansible
ansible lms_servers -m ping
ansible-playbook site.yml
```

### Paso 4: Verificar Instalación

```bash
ssh -i ~/.ssh/lms-key.pem ubuntu@[IP_DEL_EC2]
docker --version
docker-compose --version
```

## 🔐 Seguridad con Vault

HashiCorp Vault gestiona secretos de forma centralizada:

### Secretos Almacenados

| Secreto | Ruta en Vault |
|---------|---------------|
| **AWS Credentials** | `secret/aws` |
| **Database Password** | `secret/database` |
| **API Tokens** | `secret/api/email` |

### Comandos Básicos

```bash
# Iniciar Vault (desarrollo)
vault server -dev

# Guardar secreto
vault kv put secret/aws access_key="..." secret_key="..."

# Leer secreto
vault kv get secret/aws

# Listar secretos
vault kv list secret/
```

## 🧩 Componentes del Equipo

### Terraform (Infraestructura)
**Responsable:** Integrante 1
- Creación de VPC, subredes, EC2, S3, ALB
- Configuración de Security Groups

### Ansible (Configuración)
**Responsable:** Integrante 2
- Instalación de Docker y Docker Compose
- Configuración de servidores
- Automatización de tareas

### Vault (Seguridad)
**Responsable:** Integrante 3
- Gestión de secretos
- Documentación del proyecto
- Evidencias y diagramas

## 👥 Equipo

- **Integrante 1:** Terraform / AWS
- **Integrante 2:** Ansible / Configuración
- **Integrante 3:** Vault / Documentación / Evidencias

## 📚 Referencias

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [HashiCorp Vault Docs](https://www.vaultproject.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)

---

**Última actualización:** Mayo 2026  
**Repositorio:** https://github.com/JoshiRL2099/lms_iac_actividad_integradora
