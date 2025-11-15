output "vpc_id" {
  description = "ID of the VPC created"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "Security group created for EC2/ASG"
  value       = aws_security_group.ec2_sg.id
}

output "launch_template_id" {
  description = "Launch template ID created for Autoscaling"
  value       = aws_launch_template.ec2_lt.id
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_autoscaling_group.ec2_asg.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}