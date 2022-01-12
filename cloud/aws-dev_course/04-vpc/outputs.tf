output "nat_gateway_public_ip" {
  value = aws_eip.nat_gateway.public_ip
}