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
  type      = string
  sensitive = true
}

variable "kafka_host" {
  type    = string
  default = "kafka.voting-app-dev.local:9092"
}

variable "kafka_image" {
  type    = string
  default = "bitnami/kafka:3.7"
}

