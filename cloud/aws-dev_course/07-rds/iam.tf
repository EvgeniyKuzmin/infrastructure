data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_access" {
  statement {
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.web_app.arn,
      aws_s3_bucket.images.arn
    ]
  }
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_app.arn}/*"]
  }
  statement {
    actions = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/*",
      # "${aws_s3_bucket.images.arn}/${local.bucket_storage_prefix}/*",
    ]
  }
}
resource "aws_iam_role_policy" "s3_read_access" {
  name = "s3_read_access"
  role = aws_iam_role.s3_read_access.id
  policy = data.aws_iam_policy_document.s3_read_access.json
}
resource "aws_iam_role" "s3_read_access" {
  name = "ReadAccessRoleS3"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}
