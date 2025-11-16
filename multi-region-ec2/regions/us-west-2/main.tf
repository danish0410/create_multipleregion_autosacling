module "ec2_vpc_asg" {
  source = "../../modules/ec2-vpc-autoscaling"

  region         = var.region
  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets

  ami              = var.ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  ssh_cidrs        = var.ssh_cidrs
}