locals {
  fs_purpose       = "image-storage"
  fs_public_prefix = "public"
  fs_tags          = merge(local.tags, {
    "Purpose" = local.fs_purpose
  })
}


resource "aws_s3_bucket" "images" {
  bucket        = "${var.project_name}-${local.fs_purpose}"
  force_destroy = true

  tags = local.fs_tags
}

resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id
  rule {object_ownership = "BucketOwnerEnforced"}
}

data "aws_iam_policy_document" "public_read_images" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images.arn}/${local.fs_public_prefix}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.images.id
  policy = data.aws_iam_policy_document.public_read_images.json
}
