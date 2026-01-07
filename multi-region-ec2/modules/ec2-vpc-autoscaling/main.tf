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
# Current AWS Region (MODULE SCOPE)
# --------------------------------------------------
data "aws_region" "current" {}

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
# resource "aws_security_group" "ec2" {
#   name        = "${var.vpc_name}-ec2-sg"
#   description = "EC2 SG for ASG instances"
#   vpc_id      = module.vpc.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "${var.vpc_name}-ec2-sg"
#     Project = var.project
#   }
# }

# --------------------------------------------------
# Security Group - Common Access
# --------------------------------------------------
resource "aws_security_group" "common" {
  name        = "${var.vpc_name}-common-sg"
  description = "Common SG (SSH, HTTP, HTTPS)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name    = "${var.vpc_name}-common-sg"
    Project = var.project
  }
}

# --------------------------------------------------
# Security Group - User (No Inbound)
# --------------------------------------------------
resource "aws_security_group" "user" {
  name        = "${var.vpc_name}-user-sg"
  description = "User SG with no inbound rules"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.vpc_name}-user-sg"
    Project = var.project
  }
}

# --------------------------------------------------
# AMI – Ubuntu 24.04 LTS (Noble) via Canonical SSM
# --------------------------------------------------
data "aws_ssm_parameter" "ubuntu_24_04" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

# # --------------------------------------------------
# # AMI – Ubuntu 20.04 LTS (Canonical)
# # --------------------------------------------------
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# --------------------------------------------------
# Locals – Region Aware SSH Key
# --------------------------------------------------
# locals {
#   ssh_key_map = {
#     ap-south-1 = "dev-classic-ap-south-1"
#     us-east-1  = "dev-classic-us-east-1"
#     us-east-2  = "dev-classic-us-east-2"
#   }

#   ssh_key_name = lookup(
#     local.ssh_key_map,
#     data.aws_region.current.region,
#     # data.aws_region.current.name,
#     null
#   )
# }

# -------------------------------
# SSH public keys per region
# -------------------------------
locals {
  ec2_keypair_map = {
    ap-south-1 = "dev-classic-ap-south-1"
    us-east-1  = "dev-classic-us-east-1"
    us-east-2  = "dev-classic-us-east-2"
  }

  ec2_keypair_name = lookup(
    local.ec2_keypair_map,
    # data.aws_region.current.name,
    data.aws_region.current.region,
    null
  )
}

# --------------------------------------------------
# Validate Key Pair Exists (FAIL FAST)
# --------------------------------------------------
resource "null_resource" "validate_key" {
  lifecycle {
    precondition {
      # condition     = local.ssh_key_name != null
      condition     = local.ec2_keypair_name != null
      error_message = "No EC2 key pair defined for region ${data.aws_region.current.region}"
    }
  }
}

# --------------------------------------------------
# Launch Template
# --------------------------------------------------
resource "aws_launch_template" "this" {
  depends_on = [null_resource.validate_key]

  name_prefix = "${var.vpc_name}-lt-"
  # image_id      = data.aws_ami.amazon_linux_2.id
  # image_id      = data.aws_ami.ubuntu.id
  image_id      = data.aws_ssm_parameter.ubuntu_24_04.value
  instance_type = var.instance_type

  # key_name = local.ssh_key_name
  # key_name = local.ssh_public_key
  key_name = local.ec2_keypair_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
    # name = aws_iam_instance_profile.ssm_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    # security_groups             = [aws_security_group.ec2.id]
    security_groups = [
      aws_security_group.common.id,
      aws_security_group.user.id
    ]
  }

  user_data = base64encode(templatefile(
    "${path.root}/../../dev_classic_userdata.sh",
    {
      # region = data.aws_region.current.name
      region = data.aws_region.current.region
      # ssh_pub_key = local.ssh_public_key
      # ssh_pub_key = local.ec2_keypair_name
    }
  ))


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # user_data = base64encode(
  #   file("${path.root}/../../dev_classic_userdata.sh")
  # )

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
