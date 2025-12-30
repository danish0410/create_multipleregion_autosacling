output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

# output "security_group_id" {
#   value = aws_security_group.ec2.id
# }

# output "autoscaling_group_name" {
#   value = aws_autoscaling_group.asg.name
# }
