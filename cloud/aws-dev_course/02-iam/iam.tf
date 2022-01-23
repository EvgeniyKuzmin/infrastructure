resource "aws_iam_group" "coordinators" {
  name = "CoordinatorsGroup"
  path = "/${var.course-path}/"
}

resource "aws_iam_group" "mentors" {
  name = "MentorsGroup"
  path = "/${var.course-path}/"
}

resource "aws_iam_group" "mentees" {
  name = "MenteesGroup"
  path = "/${var.course-path}/"
}
###############################################################################
data "aws_iam_policy_document" "ec2-assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

variable "course-path" {
  default = "dev_course"
}

### FullAccessEC2 #############################################################
data "aws_iam_policy_document" "ec2-full-access" {
  statement {
    actions = ["ec2:*"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "ec2-full-access" {
  name = "FullAccessPolicyEC2"
  path = "/${var.course-path}/"
  policy = data.aws_iam_policy_document.ec2-full-access.json
}
resource "aws_iam_role" "ec2-full-access" {
  name = "FullAccessRoleEC2"
  path = "/${var.course-path}/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume.json
}
resource "aws_iam_role_policy_attachment" "ec2-full-access" {
  role       = aws_iam_role.ec2-full-access.name
  policy_arn = aws_iam_policy.ec2-full-access.arn
}
resource "aws_iam_group" "ec2-full-access" {
  name = "FullAccessGroupEC2"
  path = "/${var.course-path}/"
}
resource "aws_iam_group_policy_attachment" "ec2-full-access" {
  group      = aws_iam_group.ec2-full-access.name
  policy_arn = aws_iam_policy.ec2-full-access.arn
}
resource "aws_iam_user" "ec2-full-access" {
  name = "FullAccessUserEC2"
  path = "/${var.course-path}/"
}
resource "aws_iam_access_key" "ec2-full-access" {
  user = aws_iam_user.ec2-full-access.name
}
resource "aws_iam_user_group_membership" "ec2-full-access" {
  user = aws_iam_user.ec2-full-access.name
  groups = [aws_iam_group.ec2-full-access.name]
}
output "access_key_id_ec2-full-access-user" {
  value = aws_iam_access_key.ec2-full-access.id
}
output "access_key_secret_ec2-full-access-user" {
  value     = aws_iam_access_key.ec2-full-access.secret
  sensitive = true
}


### FullAccessS3 ##############################################################
data "aws_iam_policy_document" "s3-full-access" {
  statement {
    actions = ["s3:*"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "s3-full-access" {
  name = "FullAccessPolicyS3"
  path = "/${var.course-path}/"
  policy = data.aws_iam_policy_document.s3-full-access.json
}
resource "aws_iam_role" "s3-full-access" {
  name = "FullAccessRoleS3"
  path = "/${var.course-path}/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume.json
}
resource "aws_iam_role_policy_attachment" "s3-full-access" {
  role       = aws_iam_role.s3-full-access.name
  policy_arn = aws_iam_policy.s3-full-access.arn
}
resource "aws_iam_group" "s3-full-access" {
  name = "FullAccessGroupS3"
  path = "/${var.course-path}/"
}
resource "aws_iam_group_policy_attachment" "s3-full-access" {
  group      = aws_iam_group.s3-full-access.name
  policy_arn = aws_iam_policy.s3-full-access.arn
}
resource "aws_iam_user" "s3-full-access" {
  name = "FullAccessUserS3"
  path = "/${var.course-path}/"
}
resource "aws_iam_access_key" "s3-full-access" {
  user = aws_iam_user.s3-full-access.name
}
resource "aws_iam_user_group_membership" "s3-full-access" {
  user = aws_iam_user.s3-full-access.name
  groups = [aws_iam_group.s3-full-access.name]
}
output "access_key_id_s3-full-access-user" {
  value = aws_iam_access_key.s3-full-access.id
}
output "access_key_secret_s3-full-access-user" {
  value     = aws_iam_access_key.s3-full-access.secret
  sensitive = true
}


### ReadAccessS3 ##############################################################
data "aws_iam_policy_document" "s3-read-access" {
  statement {
    actions = ["s3:Get*", "s3:List*"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "s3-read-access" {
  name = "ReadAccessPolicyS3"
  path = "/${var.course-path}/"
  policy = data.aws_iam_policy_document.s3-read-access.json
}
resource "aws_iam_role" "s3-read-access" {
  name = "ReadAccessRoleS3"
  path = "/${var.course-path}/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume.json
}
resource "aws_iam_role_policy_attachment" "s3-read-access" {
  role       = aws_iam_role.s3-read-access.name
  policy_arn = aws_iam_policy.s3-read-access.arn
}
resource "aws_iam_group" "s3-read-access" {
  name = "ReadAccessGroupS3"
  path = "/${var.course-path}/"
}
resource "aws_iam_group_policy_attachment" "s3-read-access" {
  group      = aws_iam_group.s3-read-access.name
  policy_arn = aws_iam_policy.s3-read-access.arn
}
resource "aws_iam_user" "s3-read-access" {
  name = "ReadAccessUserS3"
  path = "/${var.course-path}/"
}
resource "aws_iam_access_key" "s3-read-access" {
  user = aws_iam_user.s3-read-access.name
}
resource "aws_iam_user_group_membership" "s3-read-access" {
  user = aws_iam_user.s3-read-access.name
  groups = [aws_iam_group.s3-read-access.name]
}
output "access_key_id_s3-read-access-user" {
  value = aws_iam_access_key.s3-read-access.id
}
output "access_key_secret_s3-read-access-user" {
  value     = aws_iam_access_key.s3-read-access.secret
  sensitive = true
}