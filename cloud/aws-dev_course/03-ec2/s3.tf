resource "aws_s3_bucket" "static_website" {
  bucket        = "${var.bucket_name}"
  force_destroy = true
}
resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_object" "static_website_html" {
  for_each     = fileset("${path.module}/${var.website_dir}/", "*.html")

  bucket       = aws_s3_bucket.static_website.id
  key          = each.value
  source       = "${var.website_dir}/${each.value}"
  etag         = filemd5("${path.module}/${var.website_dir}/${each.value}")
  content_type = "text/html"
}
resource "aws_s3_bucket_object" "static_website_css" {
  for_each     = fileset("${path.module}/${var.website_dir}/", "*.css")

  bucket       = aws_s3_bucket.static_website.id
  key          = each.value
  source       = "${var.website_dir}/${each.value}"
  etag         = filemd5("${path.module}/${var.website_dir}/${each.value}")
  content_type = "text/css"
}