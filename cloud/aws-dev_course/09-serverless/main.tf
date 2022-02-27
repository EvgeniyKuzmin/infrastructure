terraform {

  required_providers {
    archive = ">= 2.2.0"
    aws     = ">= 4.2.0"
    local   = ">= 2.1.0"
    random  = ">= 3.1.0"
    http    = ">= 2.1.0"
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}


resource "random_password" "db_password" {
  length  = 16
  special = false
}
resource "random_password" "app_secret" {
  length  = 64
  special = false
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}


locals {
  app_name = "imager"
  app_path = "${path.module}/../web_app/"

  my_ip = chomp(data.http.my_ip.body)

  tags = {
    "Project" = var.project_name
  }
}
