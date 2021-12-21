output "username" {
  value = local.username
}

output "public_dns" {
  value = aws_instance.server.public_dns
}

output "public_ip" {
  value = aws_instance.server.public_ip
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