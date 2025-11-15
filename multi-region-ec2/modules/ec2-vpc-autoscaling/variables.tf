variable "region" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "ami" {}
variable "key_name" {}
variable "instance_type" {}
variable "ssh_cidrs" { type = list(string) }
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}