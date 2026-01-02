terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25"
    }
  }
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

module "ec2_vpc_asg" {
  source    = "../../modules/ec2-vpc-autoscaling"
  providers = { aws = aws.ap_south_1 }

  # pass provider from root via providers = { aws = aws.ap_south_1 } (root main.tf does this)
  #region  = var.region
  project = var.project

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # ami           = var.ami
  # ssh_key_name  = var.ssh_key_name
  instance_type = var.instance_type

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  # key_name         = var.key_name
  iam_instance_profile_name = var.iam_instance_profile_name
  # ssh_cidrs        = var.ssh_cidrs
}
