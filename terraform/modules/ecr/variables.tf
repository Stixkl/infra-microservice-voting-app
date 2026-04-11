variable "project_name" {
  type = string
}

variable "service_names" {
  type    = list(string)
  default = ["vote", "worker", "result"]
}

