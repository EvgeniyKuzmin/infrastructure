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
  name          = "${var.project_name}-stack"
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    ProjectName = var.project_name
    VPCCidr     = "10.0.0.0/16"
    SubnetACidr = "10.0.11.0/24"
    SubnetBCidr = "10.0.21.0/24"
  }

  template_body = file("${path.module}/template.yaml")

  tags = {
    Name = "${var.project_name}-CloudFormation"
  }
}
