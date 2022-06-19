variable "aws_region" {
  description = "AWS region"
  default = {
    "dev"   = "eu-north-1"    # Stockholm
    "stage" = "eu-west-1"     # Ireland
    "prod"  = "eu-central-1"  # Frankfurt
  }
}
variable "project_name" {
  description = "Prefix for resources naming"
  type        = string
}
variable "email" {
  description = "Email to send budget notifications"
  type        = string
}