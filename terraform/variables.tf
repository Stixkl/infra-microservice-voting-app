variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "voting-app"
}

variable "environment" {
  type    = string
  default = "shared"
}

variable "service_images" {
  type = map(string)
  default = {
    vote   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/voting-app/vote:latest"
    worker = "123456789012.dkr.ecr.us-east-1.amazonaws.com/voting-app/worker:latest"
    result = "123456789012.dkr.ecr.us-east-1.amazonaws.com/voting-app/result:latest"
  }
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password. No default is provided. For local runs, export TF_VAR_db_password before invoking Terraform or the helper scripts (for example: export TF_VAR_db_password='your-password')."

  validation {
    condition     = length(trimspace(var.db_password)) > 0
    error_message = "The db_password variable is required. For local runs, export TF_VAR_db_password before invoking Terraform or the helper scripts."
  }
}

variable "kafka_host" {
  type        = string
  default     = null
  description = "Kafka broker address. Defaults to 'kafka.<project_name>-<environment>.local:9092' if not set."
}

variable "kafka_image" {
  type    = string
  default = "bitnami/kafka:3.7"
}

