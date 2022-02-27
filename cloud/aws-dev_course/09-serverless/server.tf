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
  tags = local.srv_tags
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
