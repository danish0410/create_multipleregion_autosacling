variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Autoscaling minimum size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Autoscaling maximum size"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Autoscaling desired capacity"
  type        = number
  default     = 1
}

variable "project" {
  # description = "Project name for resource tagging"
  type = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name"
  type        = string
}
