variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_names" {
  type    = list(string)
  default = ["vote", "worker", "result"]
}

variable "service_images" {
  type = map(string)
}

variable "kafka_image" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "kafka_host" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

