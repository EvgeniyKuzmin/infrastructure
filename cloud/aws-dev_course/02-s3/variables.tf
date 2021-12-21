variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "region_replication" {
  type = string
  default = "eu-central-1"
}

variable "course_path" {
  type    = string
  default = "dev_course"
}

variable "bucket_name" {
  type = string
  default = "evgenii-kuzmin-static-website"
}

variable "website_dir" {
  type    = string
  default = "../website_static"
}