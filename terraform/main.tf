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
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment
}

module "msk" {
  source       = "./modules/msk"
  project_name = var.project_name
  environment  = var.environment
}

module "ecs_services" {
  source         = "./modules/ecs-services"
  project_name   = var.project_name
  environment    = var.environment
  service_names  = local.service_names
  service_images = var.service_images
}

