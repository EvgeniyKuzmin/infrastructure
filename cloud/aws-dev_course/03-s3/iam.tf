### FullAccessS3 ##############################################################
data "aws_iam_policy_document" "s3_full_access" {
  statement {
    actions = ["s3:*"]
    resources = ["*"]
  }
}
resource "aws_iam_group" "s3_full_access" {
  name = "S3FullAccessGroup"
  path = "/${var.course_path}/"
}
resource "aws_iam_group_policy" "s3_full_access" {
  name   = "S3FullAccessPolicy"
  group  = aws_iam_group.s3_full_access.name
  policy = data.aws_iam_policy_document.s3_full_access.json
}
resource "aws_iam_user" "s3_full_access" {
  name = "S3FullAccessUser"
  path = "/${var.course_path}/"
}
resource "aws_iam_access_key" "s3_full_access" {
  user = aws_iam_user.s3_full_access.name
}
resource "aws_iam_user_group_membership" "s3_full_access" {
  user   = aws_iam_user.s3_full_access.name
  groups = [aws_iam_group.s3_full_access.name]
}

output "access_key_id_s3_full_access_user" {
  value = aws_iam_access_key.s3_full_access.id
}
output "access_key_secret_s3_full_access_user" {
  value     = aws_iam_access_key.s3_full_access.secret
  sensitive = true
}


### ReadAccessS3 ##############################################################
data "aws_iam_policy_document" "s3_read_access" {
  statement {
    actions = ["s3:Get*", "s3:List*"]
    resources = ["*"]
  }
}
resource "aws_iam_group" "s3_read_access" {
  name = "S3ReadAccessGroup"
  path = "/${var.course_path}/"
}
resource "aws_iam_group_policy" "s3_read_access" {
  name   = "S3ReadAccessPolicy"
  group  = aws_iam_group.s3_read_access.name
  policy = data.aws_iam_policy_document.s3_read_access.json
}
resource "aws_iam_user" "s3_read_access" {
  name = "S3ReadAccessUser"
  path = "/${var.course_path}/"
}
resource "aws_iam_access_key" "s3_read_access" {
  user = aws_iam_user.s3_read_access.name
}
resource "aws_iam_user_group_membership" "s3_read_access" {
  user   = aws_iam_user.s3_read_access.name
  groups = [aws_iam_group.s3_read_access.name]
}

output "access_key_id_s3_read_access_user" {
  value = aws_iam_access_key.s3_read_access.id
}
output "access_key_secret_s3_read_access_user" {
  value     = aws_iam_access_key.s3_read_access.secret
  sensitive = true
}
