module "ec2" {
  source = "../../modules/ec2-vpc-autoscaling"

  region         = "ap-south-1"
  vpc_name       = "classic-ap-south-1"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  ami            = "ami-00305d2fa3c93abfc"
  key_name       = "dev-classic-ap-south-1"
  instance_type  = "t2.micro"

  ssh_cidrs = ["YOUR_IP/32"]

  min_size         = 1
  max_size         = 3
  desired_capacity = 1
}