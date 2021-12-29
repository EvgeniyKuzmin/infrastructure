terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}


locals {
  web_app = abspath("${path.module}/../web_app")
}

data "archive_file" "web_app" {
  type        = "zip"
  source_dir  = local.web_app
  output_path = "${path.module}/.tmp/web_app.zip"

  excludes    = [
    ".venv",
    "app/__pycache__",
  ]
}