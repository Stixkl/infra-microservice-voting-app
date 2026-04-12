variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_name" {
  type    = string
  default = "votes"
}

variable "db_username" {
  type    = string
  default = "votes_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "16.3"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

