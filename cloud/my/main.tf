terraform {
  required_version = ">= 1.2.3"

  required_providers {
    aws = ">= 4.19.0"
  }

  backend "s3" {
    region  = "eu-north-1"
    bucket  = "my-backend-terraform"
    key     = "global.tfstate"
    encrypt = true
  }
}

provider "aws" {
  profile = "default"
  region  = local.aws_region
}


locals {
  env        = terraform.workspace
  aws_region = var.aws_region[local.env]
  prefix     = "${var.project_name}-${local.env}"
  tags = {
    "Project"     = var.project_name
    "Environment" = local.env
    "Region"      = local.aws_region
  }
}