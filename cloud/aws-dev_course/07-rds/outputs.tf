output "connect_str" {
  value = "ssh -i ${data.local_file.private_key.filename} ${local.username}@${aws_instance.server.public_ip}"
}

output "username" {
  value = local.username
}

output "public_dns_server" {
  value = aws_instance.server.public_dns
}

output "public_ip_server" {
  value = aws_instance.server.public_ip
}

output "private_key" {
  value = data.local_file.private_key.filename
}

output "av_zone" {
  value = aws_instance.server.availability_zone
}

output "s3_uri" {
  value = "s3://${aws_s3_bucket.web_app.id}"
}

output "rds_hostname" {
  value = aws_db_instance.images.address
}
output "rds_port" {
  value = aws_db_instance.images.port
}
output "rds_name" {
  value = aws_db_instance.images.name
}
output "rds_username" {
  value = aws_db_instance.images.username
}
output "db_password" {
  value     = var.db_password
  sensitive = true
}
