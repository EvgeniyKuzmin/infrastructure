resource "aws_s3_bucket" "web_app" {
  bucket        = "${var.bucket_name}-app"
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
    ".venv",
    "app/__pycache__",
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
  key     = "${local.app_name}.service"
  content = templatefile(
    "${path.module}/files/${local.app_name}.service",
    {
      user     = local.username
      port     = local.app_port
      app_name = local.app_name
    }
  )
}
