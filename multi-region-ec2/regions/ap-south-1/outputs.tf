output "vpc_id" {
  value = module.ec2_vpc_asg.vpc_id
}

output "public_subnet_ids" {
  value = module.ec2_vpc_asg.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.ec2_vpc_asg.private_subnet_ids
}
