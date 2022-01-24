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


resource "aws_cloudformation_stack" "stack" {
  name          = "hui-pizda-kartoshka"
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/template.yaml")

  tags = {
    Name = "${var.project_name}-CloudFormation"
  }
}
