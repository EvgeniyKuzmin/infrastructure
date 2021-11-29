# output "username" {
#   value = var.username
# }

# output "public_dns" {
#   value = aws_instance.app_server.public_dns
# }

# output "private_key" {
#   value = data.local_file.private_key.filename
# }

output "connect_str" {
  value = "ssh -i ${data.local_file.private_key.filename} ${var.username}@${aws_instance.app_server.public_dns}"
}