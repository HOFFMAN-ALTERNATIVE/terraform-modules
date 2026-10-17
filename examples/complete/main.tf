terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "dev | staging | prod."
  type        = string
  default     = "dev"
}

module "naming" {
  source      = "../../modules/naming"
  namespace   = "acme"
  environment = var.environment
  component   = "platform"
}

module "network" {
  source   = "../../modules/network"
  name     = module.naming.name
  az_count = 3
  # HA NAT only where it pays for itself
  nat_mode = module.naming.is_production ? "per_az" : "single"
  tags     = module.naming.tags
}

module "artifacts" {
  source        = "../../modules/secure-bucket"
  name          = "${module.naming.name}-artifacts"
  force_destroy = !module.naming.is_production
  tags          = module.naming.tags
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets for workloads."
  value       = module.network.private_subnet_ids
}

output "artifacts_bucket" {
  description = "Artifacts bucket name."
  value       = module.artifacts.bucket_id
}
