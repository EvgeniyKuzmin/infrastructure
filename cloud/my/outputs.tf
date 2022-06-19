output "s3_images" {
  value = "s3://${aws_s3_bucket.images.id}"
}