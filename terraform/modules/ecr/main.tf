locals {
  repositories = {
    for service in var.service_names : service => "${var.project_name}/${service}"
  }
}

resource "aws_ecr_repository" "service" {
  for_each = local.repositories

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

