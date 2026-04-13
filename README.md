# Infraestructura de microservices-demo

Este repositorio contiene la base de infraestructura para desplegar en AWS la aplicación de `microservices-demo` con Terraform y ejecutar el stack local con Docker.

## Relación con microservices-demo

| Componente original | Infraestructura propuesta |
| --- | --- |
| `vote` | Servicio contenedorizado en ECS |
| `worker` | Servicio contenedorizado en ECS |
| `result` | Servicio contenedorizado en ECS |
| `kafka` | Broker Kafka autogestionado (host configurable) |
| `postgresql` | Amazon RDS PostgreSQL |

## Estructura creada

```text
infra-microservice-voting-app/
├── README.md
├── .gitignore
├── docker/
│   ├── .env.example
│   └── docker-compose.yml
├── terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── ecr/
│   │   ├── ecs-services/
│   │   ├── rds/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.hcl
│   └── terraform.tfvars.example
├── scripts/
│   ├── plan.sh
│   ├── apply.sh
│   └── destroy.sh
└── docs/
    ├── architecture.md
    └── decisions.md
```

## Tecnologías

- Docker
- AWS
- Terraform

## Uso rápido

```bash
cd docker
cp .env.example .env
docker compose up --build
```

Para Terraform:

```bash
./scripts/plan.sh
./scripts/apply.sh
```

Antes de ejecutar Terraform, actualiza `backend.hcl` y `terraform.tfvars` según tu cuenta de AWS.

Kafka se despliega en ECS como servicio interno y se resuelve por DNS privado.

## CI/CD de infraestructura (GitHub Actions)

- `Terraform Validate` (`.github/workflows/terraform-validate.yml`)
  - Se ejecuta en PR hacia `staging` y `main`.
  - Corre `fmt`, `init`, `validate` y `plan`.
  - Publica resumen del plan en el summary del job.

- `Terraform Apply` (`.github/workflows/terraform-apply.yml`)
  - Se ejecuta en push a `staging` y `main`.
  - Aplica cambios de Terraform automáticamente.
  - Usa `environment: staging` y `environment: production` para controles de aprobación.

Secrets requeridos:

- `AWS_ROLE_TO_ASSUME`
- `TF_VAR_DB_PASSWORD`
