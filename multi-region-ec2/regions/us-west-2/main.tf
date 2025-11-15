module "ec2" {
  source = "../../modules/ec2-vpc-autoscaling"

  region         = "us-west-2"
  vpc_name       = "classic-us-west-2"
  vpc_cidr       = "10.1.0.0/16"
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  ami            = "ami-0c55b159cbfafe1f0" # change
  key_name       = "dev-classic-us-west-2"
  instance_type  = "t2.micro"

  ssh_cidrs = ["YOUR_IP/32"]

  min_size         = 1
  max_size         = 3
  desired_capacity = 1
}