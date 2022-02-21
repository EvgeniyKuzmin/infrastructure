locals {
  m_purpose = "uploads-notification"
  m_tags    = merge(local.tags, {
    "Purpose" = local.m_purpose
  })
}

resource "aws_sqs_queue" "uploads_notification" {
  name = "${var.project_name}-${local.m_purpose}-queue"
  tags = local.m_tags
}

resource "aws_sns_topic" "uploads_notification" {
  name = "${var.project_name}-${local.m_purpose}-topic"
  tags = local.m_tags
}
