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
  username    = "ec2-user"
  av_zone     = "${var.region}a"
  device_name = "/dev/xvdf"
  app_port    = 80
  app_name    = "flask-app"
}


resource "aws_iam_instance_profile" "s3_read_access" {
  name = "s3_read_access"
  role = aws_iam_role.s3_read_access.name
}

resource "aws_instance" "server" {
  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD
  ami                    = "ami-04dd4500af104442f"

  instance_type          = "t2.micro"
  availability_zone      = local.av_zone
  key_name               = aws_key_pair.ssh_rsa.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_read_access.name
  user_data = templatefile(
    "${path.module}/files/user_data.sh",
    {
      bucket          = "s3://${aws_s3_bucket.web_app.id}"
      web_app_archive = basename(data.archive_file.web_app.output_path)
      python3_version = "8"
      user            = local.username
      app_name        = local.app_name
      # device          = local.device_name
      # mount_dir       = "shared_volume"
    }
  )

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.username
    private_key = data.local_file.private_key.content
    timeout     = "4m"
  }
}

resource "aws_security_group" "main" {
  egress = [
    {
      description      = ""
      protocol         = "all"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      from_port        = 0
      to_port          = 0
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      description      = "SSH"
      protocol         = "tcp"
      cidr_blocks      = [var.ingr_ssh_ip]
      ipv6_cidr_blocks = []
      from_port        = 22
      to_port          = 22
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTP"
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      from_port        = local.app_port
      to_port          = local.app_port
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTPS"
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      from_port        = 443
      to_port          = 443
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_ebs_volume" "share" {
  type                 = "gp2"
  availability_zone    = local.av_zone
  size                 = 8
}
resource "aws_volume_attachment" "share" {
  device_name = local.device_name
  volume_id   = aws_ebs_volume.share.id
  instance_id = aws_instance.server.id
}


resource "aws_ami_from_instance" "web_site" {
  name               = "web_site"
  source_instance_id = aws_instance.server.id
}
resource "aws_instance" "server_clone" { 
  ami                    = aws_ami_from_instance.web_site.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_rsa.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
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
