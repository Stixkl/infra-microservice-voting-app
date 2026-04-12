output "ecs_service_names" {
  value = local.ecs_service_names
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "kafka_service_name" {
  value = aws_ecs_service.kafka.name
}

