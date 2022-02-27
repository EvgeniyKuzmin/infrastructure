locals {
  srv_purpose = "${local.app_name}-server"
  srv_name    = "${var.project_name}-${local.srv_purpose}"
  srv_tags    = merge(local.tags, {
    "Purpose" = local.srv_purpose
  })

  srv_app_port = 80
  srv_username = "ec2-user"
}


## APP CODE BUCKET ############################################################

resource "aws_s3_bucket" "app_code" {
  bucket        = "${local.srv_name}-app-code"
  force_destroy = true
  tags          = local.srv_tags
}
resource "aws_s3_bucket_ownership_controls" "app_code" {
  bucket = aws_s3_bucket.app_code.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "archive_file" "app_code" {
  type        = "zip"
  source_dir  = local.app_path
  output_path = "${local.code_path}/app_code.zip"

  excludes    = [
    local.credential_file,
    local.credentials_db_file,
    ".python-version",
    ".venv",
    "Dockerfile",
    "README.md",
    # "app",
    "docker-compose.yml",
    # "migrations",
    "postman_collection.json",
    "requirements-dev.txt",
    # "requirements.txt",
    "scripts",
    "tox.ini",
    "uploads"
  ]
}

resource "aws_s3_object" "app_code" {
  bucket = aws_s3_bucket.app_code.id
  key    = basename(data.archive_file.app_code.output_path)
  source = data.archive_file.app_code.output_path
  etag   = filemd5(data.archive_file.app_code.output_path)
}

resource "aws_s3_object" "systemd_unit_file" {
  bucket  = aws_s3_bucket.app_code.id
  key     = "app.service"
  content = templatefile(
    "${local.templates_path}/app.service",
    {
      user     = local.srv_username
      port     = local.srv_app_port
      app_name = local.app_name
    }
  )
}

resource "aws_s3_object" "credentials_env" {
  bucket  = aws_s3_bucket.app_code.id
  key     = local.credential_file
  content = local_file.credentials_env.content
}


## SERVER POLICY ##############################################################

resource "aws_iam_role" "server" {
  name               = local.srv_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.srv_tags
}
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "read_app_code" {
  name   = "${local.srv_name}-read-app-code-bucket"
  role   = aws_iam_role.server.id
  policy = data.aws_iam_policy_document.read_app_code.json
}
data "aws_iam_policy_document" "read_app_code" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app_code.arn]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.app_code.arn}/*"]
  }
}

resource "aws_iam_role_policy" "rw_filestorage" {
  name   = "${local.srv_name}-rw-filestorage"
  role   = aws_iam_role.server.id
  policy = data.aws_iam_policy_document.rw_filestorage.json
}
data "aws_iam_policy_document" "rw_filestorage" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.images.arn]
  }
  statement {
    actions   = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
}

resource "aws_iam_role_policy" "server_sqs" {
  name   = data.aws_iam_policy_document.server_sqs.policy_id
  role   = aws_iam_role.server.id
  policy = data.aws_iam_policy_document.server_sqs.json
}
data "aws_iam_policy_document" "server_sqs" {
  policy_id = "sqs"
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    resources = [aws_sqs_queue.uploads_notification.arn]
  }
}

resource "aws_iam_role_policy" "server_sns" {
  name   = data.aws_iam_policy_document.server_sns.policy_id
  role   = aws_iam_role.server.id
  policy = data.aws_iam_policy_document.server_sns.json
}
data "aws_iam_policy_document" "server_sns" {
  policy_id = "sns"
  statement {
    actions = [
      "sns:Publish",
      "sns:Subscribe",
      "sns:GetSubscriptionAttributes",
    ]
    resources = [aws_sns_topic.uploads_notification.arn]
  }
}

## SERVER INSTANCE ############################################################

resource "aws_instance" "server" {
  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD
  ami                    = "ami-04dd4500af104442f"

  instance_type          = "t2.micro"
  availability_zone      = data.aws_availability_zones.available.names[0]
  subnet_id              = aws_subnet.public_a.id
  key_name               = aws_key_pair.ssh_rsa.key_name
  vpc_security_group_ids = [aws_security_group.server.id]
  iam_instance_profile   = aws_iam_instance_profile.server.name
  user_data              = templatefile(
    "${local.templates_path}/user_data.sh",
    {
      bucket          = "s3://${aws_s3_bucket.app_code.id}"
      web_app_archive = basename(data.archive_file.app_code.output_path)
      python3_version = "8"
      user            = local.srv_username
      credential_file = local.credential_file
    }
  )

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.srv_username
    private_key = data.local_file.private_key.content
    timeout     = "4m"
  }

  depends_on = [
    aws_s3_bucket.app_code,
    aws_db_instance.metadata,
  ]
}

resource "aws_iam_instance_profile" "server" {
  name = local.srv_name
  role = aws_iam_role.server.name
}

resource "aws_security_group" "server" {
  name   = local.srv_name
  vpc_id = aws_vpc.this.id
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
      cidr_blocks      = ["${local.my_ip}/32"]
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
      from_port        = local.srv_app_port
      to_port          = local.srv_app_port
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
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
