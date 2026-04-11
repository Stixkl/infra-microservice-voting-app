# Decisiones iniciales

1. AWS como nube principal.
2. Terraform modular por dominio (`networking`, `ecr`, `ecs-services`, `rds`, `msk`).
3. Configuración Terraform en una sola capa (`terraform/`) sin separación por ambientes.
4. Docker Compose para validar el flujo local antes de despliegues cloud.
