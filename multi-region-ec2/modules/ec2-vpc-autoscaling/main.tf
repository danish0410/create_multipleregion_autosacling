terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25"
    }
  }
}

# --------------------------------------------------
# Availability Zones (Region-aware via provider)
# --------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# --------------------------------------------------
# VPC
# --------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = var.project
  }
}

# --------------------------------------------------
# Security Group (SSM only – no SSH)
# --------------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.vpc_name}-ec2-sg"
  description = "EC2 SG for ASG instances"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.vpc_name}-ec2-sg"
    Project = var.project
  }
}

# --------------------------------------------------
# IAM Role for EC2 (SSM + CloudWatch Agent)
# --------------------------------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.vpc_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.vpc_name}-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# --------------------------------------------------
# Amazon Linux 2 AMI (Region-specific)
# --------------------------------------------------
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --------------------------------------------------
# Launch Template
# --------------------------------------------------
resource "aws_launch_template" "this" {
  name_prefix   = "${var.vpc_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(
    file("${path.root}/../../dev_classic_userdata.sh")
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.vpc_name}-instance"
      Project = var.project
    }
  }
}

# --------------------------------------------------
# Auto Scaling Group
# --------------------------------------------------
resource "aws_autoscaling_group" "this" {
  name                = "${var.vpc_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = module.vpc.public_subnets

  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
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

# --------------------------------------------------
# Auto Scaling Policy (CPU Target 50%)
# --------------------------------------------------
resource "aws_autoscaling_policy" "cpu_50" {
  name                   = "${var.vpc_name}-cpu-50"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

# --------------------------------------------------
# CloudWatch Alarm – CPU High
# --------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.vpc_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "High CPU usage"
}

# --------------------------------------------------
# CloudWatch Alarm – Memory High (CWAgent)
# --------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.vpc_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "High Memory usage"
}
