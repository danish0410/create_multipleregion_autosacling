output "vpc_id" {
  description = "VPC ID for us-west-2 deployment"
  value       = module.ec2_vpc_asg.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for us-west-2"
  value       = module.ec2_vpc_asg.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for us-west-2"
  value       = module.ec2_vpc_asg.private_subnet_ids
}

output "autoscaling_group_name" {
  description = "ASG name for us-west-2"
  value       = module.ec2_vpc_asg.autoscaling_group_name
}

output "alb_dns_name" {
  description = "Load Balancer DNS"
  value       = module.ec2_vpc_asg.alb_dns_name
}
