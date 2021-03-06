resource "aws_s3_bucket" "web_app" {
  bucket        = "${var.project_name}-${local.app_name}-web-app"
  force_destroy = true
}
resource "aws_s3_bucket_ownership_controls" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


data "archive_file" "web_app" {
  type        = "zip"
  source_dir  = abspath("${path.module}/${var.web_app_dir}")
  output_path = "${path.module}/.tmp/web_app.zip"

  excludes    = [
    ".env.development",
    ".env.production",
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


resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.web_app.id
  key    = basename(data.archive_file.web_app.output_path)
  source = data.archive_file.web_app.output_path
  etag   = filemd5(data.archive_file.web_app.output_path)
}

resource "aws_s3_bucket_object" "systemd_unit_file" {
  bucket  = aws_s3_bucket.web_app.id
  key     = "app.service"
  content = templatefile(
    "${path.module}/files/app.service",
    {
      user     = local.username
      port     = local.app_port
      app_name = local.app_name
    }
  )
}

locals {
  bucket_storage_prefix = "public"
}

resource "aws_s3_bucket_object" "credentials_dot_env" {
  bucket  = aws_s3_bucket.web_app.id
  key     = ".env.production"
  content = templatefile(
    "${path.module}/files/.env.production",
    {
      db_host       = aws_db_instance.images.address
      db_name       = aws_db_instance.images.name
      db_user       = aws_db_instance.images.username
      db_password   = var.db_password
      flask_secret  = var.flask_secret
      aws_region    = var.region
      bucket_name   = aws_s3_bucket.images.id
      bucket_prefix = "${local.bucket_storage_prefix}/"
    }
  )
}


resource "aws_s3_bucket" "images" {
  bucket        = "${var.project_name}-${local.app_name}-image-storage"
  force_destroy = true
}
resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
data "aws_iam_policy_document" "public_read_images" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images.arn}/${local.bucket_storage_prefix}/*"]
  }
}
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.images.id
  policy = data.aws_iam_policy_document.public_read_images.json
}
