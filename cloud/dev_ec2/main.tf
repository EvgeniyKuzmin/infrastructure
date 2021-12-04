terraform {

  # backend "remote" {
  #   organization = "Evgeniy"
  #   workspaces {
  #     name = "Example-Workspace"
  #   }
  # }

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


resource "aws_instance" "app_server" {
  ami                    = "ami-0a8e758f5e873d1c1"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_rsa.key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.username
    private_key = data.local_file.private_key.content
    timeout     = "4m"
  }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}


resource "aws_key_pair" "ssh_rsa" {
  key_name   = basename(var.ssh_key)
  public_key = data.local_file.public_key.content
}

data "local_file" "private_key" {
  filename = var.ssh_key
}

data "local_file" "public_key" {
  filename = "${var.ssh_key}.pub"
}
