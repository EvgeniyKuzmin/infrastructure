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
  region  = var.region
}


locals {
  prefix = "${var.project_name}-${var.environment}"
  tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}