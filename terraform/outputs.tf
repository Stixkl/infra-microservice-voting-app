output "network_name_prefix" {
  value = module.networking.name_prefix
}

output "ecr_repositories" {
  value = module.ecr.repositories
}

output "db_identifier" {
  value = module.rds.db_identifier
}

output "kafka_host" {
  value = local.kafka_host
}

output "kafka_service_name" {
  value = module.ecs_services.kafka_service_name
}

