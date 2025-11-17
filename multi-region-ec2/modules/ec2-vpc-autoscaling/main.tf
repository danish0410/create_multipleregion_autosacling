# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC MODULE
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# SECURITY GROUP FOR SSH
resource "aws_security_group" "ssh" {
  name        = "${var.vpc_name}-ssh"
  description = "Allow SSH inbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# LAUNCH TEMPLATE (CORRECT)
resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.vpc_name}-lt"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.ssh.id]

  user_data = base64encode(file("${path.module}/../../dev_classic_userdata.sh"))
}

# AUTOSCALING GROUP
resource "aws_autoscaling_group" "asg" {
  name                = "${var.vpc_name}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = module.vpc.public_subnets

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.vpc_name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}
