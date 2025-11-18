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

# -----------------------------------------
# SECURITY GROUP FOR EC2 (SSH + HTTP)
# -----------------------------------------
resource "aws_security_group" "ssh" {
  name        = "${var.vpc_name}-ec2-sg"
  description = "EC2 security group allowing SSH & HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-ec2-sg"
  }
}

# -----------------------------------------
# LAUNCH TEMPLATE
# -----------------------------------------
resource "aws_launch_template" "ec2_lt" {
  provider = aws # <-- FIX REQUIRED

  name_prefix   = "${var.vpc_name}-lt"
  image_id      = var.ami
  instance_type = var.instance_type

  # dynamically passed from tfvars
  key_name = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.ssh.id]

  user_data = base64encode(file("${path.module}/../../dev_classic_userdata.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.vpc_name}-instance"
      Project = var.project
    }
  }
}

# AUTOSCALING GROUP
resource "aws_autoscaling_group" "asg" {
  provider = aws # <-- FIX REQUIRED

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
