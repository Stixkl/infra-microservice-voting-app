# Arquitectura objetivo

La infraestructura está alineada a `microservices-demo`:

- `vote`, `worker`, `result` como contenedores Docker.
- Kafka autogestionado en ECS como cola de eventos.
- PostgreSQL como base de datos.
- AWS como plataforma cloud.
- Terraform como IaC en una sola configuración base.
