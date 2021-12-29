locals {
  web_site = abspath("${path.module}/${var.web_site_dir}")
  web_app  = abspath("${path.module}/${var.web_app_dir}")
}


resource "aws_s3_bucket" "web_site" {
  bucket        = "${var.bucket_name}-site"
  force_destroy = true
}
resource "aws_s3_bucket_ownership_controls" "web_site" {
  bucket = aws_s3_bucket.web_site.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_object" "web_site_html" {
  for_each     = fileset("${local.web_site}/", "*.html")

  bucket       = aws_s3_bucket.web_site.id
  key          = each.value
  source       = "${var.web_site_dir}/${each.value}"
  etag         = filemd5("${local.web_site}/${each.value}")
  content_type = "text/html"
}
resource "aws_s3_bucket_object" "web_site_css" {
  for_each     = fileset("${local.web_site}/", "*.css")

  bucket       = aws_s3_bucket.web_site.id
  key          = each.value
  source       = "${var.web_site_dir}/${each.value}"
  etag         = filemd5("${local.web_site}/${each.value}")
  content_type = "text/css"
}


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
  source_dir  = local.web_app
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