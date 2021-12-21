variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "course_path" {
  type    = string
  default = "dev_course"
}

variable "ssh_key" {
  type = string
}

variable "ingr_ssh_ip" {
  type    = string
  default = "0.0.0.0/0"
}
