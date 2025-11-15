variable "project" {
  description = "Project Name"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for Autoscaling"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum size of AutoScaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of AutoScaling group"
  type        = number
  default     = 2
}

variable "ssh_key_name" {
  description = "Name of SSH Key Pair"
  type        = string
}

variable "allowed_ips" {
  description = "CIDRs allowed for SSH inbound"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}