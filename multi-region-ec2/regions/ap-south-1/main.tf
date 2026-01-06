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

  project = var.project

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  instance_type = var.instance_type

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  iam_instance_profile_name = var.iam_instance_profile_name
}
