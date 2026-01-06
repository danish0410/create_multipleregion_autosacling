variable "project" {
  type    = string
  default = "multi-region-demo"
}

variable "enable_ap_south_1" {
  type    = bool
  default = false
}

variable "enable_us_east_1" {
  type    = bool
  default = true
}

variable "enable_us_east_2" {
  type    = bool
  default = false
}

variable "iam_instance_profile_name" {
  type    = string
  default = "dev-ssm-profile"
}
