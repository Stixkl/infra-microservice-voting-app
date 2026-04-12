terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  service_names = ["vote", "worker", "result"]
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source        = "./modules/ecr"
  project_name  = var.project_name
  service_names = local.service_names
}

module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  environment           = var.environment
  db_password           = var.db_password
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
}

module "ecs_services" {
  source                = "./modules/ecs-services"
  project_name          = var.project_name
  environment           = var.environment
  service_names         = local.service_names
  service_images        = var.service_images
  kafka_image           = var.kafka_image
  subnet_ids            = module.networking.public_subnet_ids
  vpc_id                = module.networking.vpc_id
  ecs_security_group_id = module.networking.ecs_security_group_id
  kafka_host            = var.kafka_host
  db_host               = module.rds.db_endpoint
  db_name               = module.rds.db_name
  db_username           = module.rds.db_username
  db_password           = var.db_password
}

