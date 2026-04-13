locals {
  repositories = {
    for service in var.service_names : service => "${var.project_name}/${service}"
  }
}

