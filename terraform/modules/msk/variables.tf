variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "kafka_version" {
  type    = string
  default = "3.7.0"
}

variable "broker_node_count" {
  type    = number
  default = 2
}

