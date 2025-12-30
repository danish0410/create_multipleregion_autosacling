terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25"
    }
  }
}

# Default provider (OPTIONAL – avoid using it)
provider "aws" {
  region = "ap-south-1"
}

# Aliased providers
provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

###########################################
# AP-SOUTH-1 REGION
###########################################
module "ap_south_1" {
  source = "./regions/ap-south-1"

  providers = {
    aws = aws.ap_south_1
  }

  project  = var.project
  vpc_name = "ap-south-1-vpc"
  vpc_cidr = "10.10.0.0/16"

  public_subnets  = ["10.10.1.0/24"]
  private_subnets = ["10.10.11.0/24"]

  instance_type    = "t3.micro"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}

###########################################
# US-EAST-1 REGION
###########################################
module "us_east_1" {
  source = "./regions/us-east-1"

  providers = {
    aws = aws.us_east_1
  }

  project  = var.project
  vpc_name = "us-east-1-vpc"
  vpc_cidr = "10.20.0.0/16"

  public_subnets  = ["10.20.1.0/24"]
  private_subnets = ["10.20.11.0/24"]

  instance_type    = "t3.micro"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}

###########################################
# US-EAST-2 REGION
###########################################
module "us_east_2" {
  source = "./regions/us-east-2"

  providers = {
    aws = aws.us_east_2
  }

  project  = var.project
  vpc_name = "us-east-2-vpc"
  vpc_cidr = "10.30.0.0/16"

  public_subnets  = ["10.30.1.0/24"]
  private_subnets = ["10.30.11.0/24"]

  instance_type    = "t3.micro"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}
