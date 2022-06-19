resource "aws_s3_bucket" "images" {
  bucket        = "${local.prefix}-images"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
