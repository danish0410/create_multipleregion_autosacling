variable "project" {
  description = "Project name"
  type        = string
  default     = "multi-region-demo"
}

# variable "aws_region" {
#   type = string
# }

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
