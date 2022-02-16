output "sqs_url" {
  value = aws_sqs_queue.uploads_notification.id
}

output "sns_arn" {
  value = aws_sns_topic.uploads_notification.id
}

output "s3_url" {
  value = "s3://${aws_s3_bucket.images.id}"
}
