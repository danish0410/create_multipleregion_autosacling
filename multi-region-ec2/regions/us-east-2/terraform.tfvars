vpc_name = "dev-classic-us-east-2"
vpc_cidr = "10.10.0.0/16"

public_subnets = [
  "10.10.1.0/24"
]

private_subnets = [
  "10.10.11.0/24"
]

instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1
