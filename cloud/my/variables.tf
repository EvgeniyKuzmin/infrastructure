variable "region" {
  description = "AWS region"
  type        = string
}
variable "environment" {
  description = "Label for environment: DEV, STAGE or PROD"
  type        = string
}
variable "project_name" {
  description = "Prefix for resources naming"
  type        = string
}
variable "email" {
  description = "Email to send budget notifications"
  type        = string
}