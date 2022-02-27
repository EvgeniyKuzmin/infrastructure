output "sqs_url" {
  value = aws_sqs_queue.uploads_notification.id
}

output "sns_arn" {
  value = aws_sns_topic.uploads_notification.id
}

output "s3_url" {
  value = "s3://${aws_s3_bucket.images.id}"
}

output "db_host" {
  value = local.db_host
}
output "db_name" {
  value = local.app_name
}
output "db_user" {
  value = local.db_username
}
output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "my_ip" {
  value = local.my_ip
}

output "app_secret" {
  value     = random_password.app_secret.result
  sensitive = true
}

output "function_name" {
  value = aws_lambda_function.batch_notifier.function_name
}
output "base_url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}