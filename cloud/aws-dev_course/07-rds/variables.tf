variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "ssh_key" {
  type = string
}

variable "ingr_ssh_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "bucket_name" {
  type = string
  default = "evgenii-kuzmin-web"
}

variable "web_app_dir" {
  type    = string
  default = "../web_app"
}

variable "project_name" {
  type    = string
  default = "task7"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "flask_secret" {
  type      = string
  sensitive = true
}