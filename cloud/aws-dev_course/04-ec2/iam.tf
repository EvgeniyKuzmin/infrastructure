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
      aws_s3_bucket.web_site.arn,
      aws_s3_bucket.web_app.arn,
    ]
  }
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.web_site.arn}/*",
      "${aws_s3_bucket.web_app.arn}/*",
    ]
  }
  statement {
    actions = ["ec2:*"]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "s3_read_access" {
  name = "s3_read_access"
  role = aws_iam_role.s3_read_access.id
  policy = data.aws_iam_policy_document.s3_read_access.json
}
resource "aws_iam_role" "s3_read_access" {
  name = "ReadAccessRoleS3"
  path = "/${var.course_path}/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}
