terraform {

  required_providers {
    aws    = ">= 4.2.0"
    local  = ">= 2.1.0"
    random = ">= 3.1.0"
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}


resource "random_password" "db_password" {
  length  = 16
  special = false
}
resource "random_password" "app_secret" {
  length  = 64
  special = false
}


locals {
  app_name = "imager"
  app_path = "${path.module}/../web_app/"

  # NOW: a local docker host; TODO: switch to RDS
  db_host     = "db"
  db_username = var.db_username

  tags = {
    "Project" = var.project_name
  }
}
