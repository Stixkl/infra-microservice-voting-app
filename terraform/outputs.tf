output "network_name_prefix" {
  value = module.networking.name_prefix
}

output "ecr_repositories" {
  value = module.ecr.repositories
}

output "db_identifier" {
  value = module.rds.db_identifier
}

output "kafka_cluster_name" {
  value = module.msk.cluster_name
}

