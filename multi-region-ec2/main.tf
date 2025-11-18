terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Providers for each region
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
  source    = "./modules/ec2-vpc-autoscaling"
  providers = { aws = aws.ap_south_1 }

  region   = "ap-south-1"
  project  = "multi-region-demo"
  vpc_name = "ap-south-1-vpc"
  vpc_cidr = "10.10.0.0/16"

  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]

  ami           = "ami-00305d2fa3c93abfc" # Amazon Linux 2 (Mumbai)
  ssh_key_name  = "my-key-ap-south-1"
  instance_type = "t3.micro"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}

###########################################
# US-EAST-1 REGION
###########################################
module "us_east_1" {
  source    = "./modules/ec2-vpc-autoscaling"
  providers = { aws = aws.us_east_1 }

  region   = "us-east-1"
  project  = "multi-region-demo"
  vpc_name = "us-east-1-vpc"
  vpc_cidr = "10.20.0.0/16"

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

  ami           = "ami-07fd08aad95a03016" # Amazon Linux 2 (US-East-1)
  ssh_key_name  = "my-key-us-east-1"
  instance_type = "t3.micro"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}

###########################################
# US-EAST-2 REGION
###########################################
module "us_east_2" {
  source    = "./modules/ec2-vpc-autoscaling"
  providers = { aws = aws.us_east_2 }

  region   = "us-east-2"
  project  = "multi-region-demo"
  vpc_name = "us-east-2-vpc"
  vpc_cidr = "10.30.0.0/16"

  public_subnets  = ["10.30.1.0/24", "10.30.2.0/24"]
  private_subnets = ["10.30.11.0/24", "10.30.12.0/24"]

  ami           = "ami-0fb653ca2d3203ac1" # Amazon Linux 2 (US-East-2)
  ssh_key_name  = "my-key-us-east-2"
  instance_type = "t3.micro"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
}
