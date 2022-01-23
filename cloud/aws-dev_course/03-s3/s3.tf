data "aws_iam_policy_document" "website_policy_src" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["arn:aws:s3:::${var.bucket_name}-task1/*"]
  }
}
data "aws_iam_policy_document" "website_policy_dst" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["arn:aws:s3:::${var.bucket_name}-task1-replica/*"]
  }
}

data "aws_iam_policy_document" "s3_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "replication" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
    ]
    resources = [
      aws_s3_bucket.static_website_1.arn,
    ]
  }
  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = [
      "${aws_s3_bucket.static_website_1.arn}/*",
    ]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = [
      "${aws_s3_bucket.static_website_1_repl.arn}/*",
    ]
  }
}


resource "aws_s3_bucket" "static_website_1" {
  bucket        = "${var.bucket_name}-task1"
  acl           = "public-read"
  policy        = data.aws_iam_policy_document.website_policy_src.json
  force_destroy = true

  website    {index_document = "index.html"}
  versioning {enabled = true}
  lifecycle  {ignore_changes = [replication_configuration]}
}
resource "aws_s3_bucket_object" "static_website_html" {
  for_each     = fileset("${path.module}/${var.website_dir}/", "*.html")

  bucket       = aws_s3_bucket.static_website_1.id
  key          = each.value
  source       = "${var.website_dir}/${each.value}"
  etag         = filemd5("${path.module}/${var.website_dir}/${each.value}")
  content_type = "text/html"
}
resource "aws_s3_bucket_object" "static_website_css" {
  for_each     = fileset("${path.module}/${var.website_dir}/", "*.css")

  bucket       = aws_s3_bucket.static_website_1.id
  key          = each.value
  source       = "${var.website_dir}/${each.value}"
  etag         = filemd5("${path.module}/${var.website_dir}/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_bucket" "static_website_1_repl" {
  provider      = aws.another
  bucket        = "${var.bucket_name}-task1-replica"
  acl           = "public-read"
  policy        = data.aws_iam_policy_document.website_policy_dst.json
  force_destroy = true

  website    {index_document = "index.html"}
  versioning {enabled = true}
}
resource "aws_s3_bucket_replication_configuration" "static_website_1" {
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.static_website_1.id

  rule {
    status = "Enabled"
    destination {bucket = aws_s3_bucket.static_website_1_repl.arn}
  }
}
resource "aws_iam_role" "replication" {
  name               = "replication"
  assume_role_policy = data.aws_iam_policy_document.s3_assume.json
  path = "/${var.course_path}/"
}
resource "aws_iam_role_policy" "replication" {
  name   = "replication"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication.json
}


output "static_website_endpoint" {
  value = aws_s3_bucket.static_website_1.website_endpoint
}
output "static_website_endpoint_replica" {
  value = aws_s3_bucket.static_website_1_repl.website_endpoint
}


### Task 2 ####################################################################
resource "aws_s3_bucket" "static_website_2" {
  bucket        = "${var.bucket_name}-task2"
  acl           = "private"
  force_destroy = true

  versioning {enabled = true}
}