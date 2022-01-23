output "username" {
  value = local.username
}

output "public_dns_server" {
  value = aws_instance.server.public_dns
}

output "public_ip_server" {
  value = aws_instance.server.public_ip
}

output "public_dns_server_clone" {
  value = aws_instance.server_clone.public_dns
}

output "private_key" {
  value = data.local_file.private_key.filename
}

output "av_zone" {
  value = aws_instance.server.availability_zone
}

output "connect_str" {
  value = "ssh -i ${data.local_file.private_key.filename} ${local.username}@${aws_instance.server.public_ip}"
}

output "s3_uri" {
  value = "s3://${aws_s3_bucket.web_site.id}"
}

