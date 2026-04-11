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

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

