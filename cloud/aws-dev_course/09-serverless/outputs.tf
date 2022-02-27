output "my_ip" {
  value = local.my_ip
}

output "sqs_url" {
  value = aws_sqs_queue.uploads_notification.id
}
output "sns_arn" {
  value = aws_sns_topic.uploads_notification.id
}
output "s3_url" {
  value = "s3://${aws_s3_bucket.images.id}"
}

output "app_dns" {
  value = aws_instance.server.public_dns
}
output "app_ip" {
  value = aws_instance.server.public_ip
}
output "app_ssh_connect" {
  value = "ssh -i ${data.local_file.private_key.filename} ${local.srv_username}@${aws_instance.server.public_ip}"
}
output "app_private_key" {
  value = data.local_file.private_key.filename
}
output "app_av_zone" {
  value = aws_instance.server.availability_zone
}
output "app_secret" {
  value     = random_password.app_secret.result
  sensitive = true
}
output "app_code_s3_url" {
  value = "s3://${aws_s3_bucket.app_code.id}"
}

output "db_host" {
  value = aws_db_instance.metadata.address
}
output "db_port" {
  value = aws_db_instance.metadata.port
}
output "db_name" {
  value = aws_db_instance.metadata.name
}
output "db_user" {
  value = aws_db_instance.metadata.username
}
output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "function_name" {
  value = aws_lambda_function.batch_notifier.function_name
}
output "function_url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}