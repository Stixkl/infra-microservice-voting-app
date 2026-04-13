# Infraestructura de microservices-demo

Este repositorio contiene la base de infraestructura para desplegar en AWS la aplicación de `microservices-demo` con Terraform y ejecutar el stack local con Docker.

## Relación con microservices-demo

| Componente original | Infraestructura propuesta |
| --- | --- |
| `vote` | Servicio contenedorizado en ECS |
| `worker` | Servicio contenedorizado en ECS |
| `result` | Servicio contenedorizado en ECS |
| `kafka` | Amazon MSK |
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
│   │   └── msk/
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
