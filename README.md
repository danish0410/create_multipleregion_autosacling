Region -> ap-south-1
aws s3api create-bucket \
  --bucket tfstatebackup-16102025-south \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws dynamodb create-table \
  --table-name terraformsouth-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
***before delete all the keys in AWS console***
chmod +x scripts/generate_ed25519_key.sh 
./scripts/generate_ed25519_key.sh dev-classic-ap-south-1 ap-south-1

nano update-bastion-ip.sh
Press Ctrl + O → hit Enter to save
Press Ctrl + X to exit
chmod +x update-bastion-ip.sh
./update-bastion-ip.sh

mv backend-ap-southeast-1.hcl backend-ap-southeast-1.hcl.disabled
mv backend-ap-south-1.hcl.disabled backend-ap-south-1.hcl
rm -rf .terraform terraform.tfstate terraform.tfstate.backup
terraform init -reconfigure -backend-config="backend-ap-south-1.hcl"
terraform init -upgrade
terraform fmt -recursive
terraform validate
terraform plan -var-file="terraform-ap-south-1.tfvars"
terraform apply -target=module.ap-south-1
terraform apply -var-file="terraform-ap-south-1.tfvars"
terraform state list
scp -i /home/thani/.ssh/dev-classic-ap-south-1.pem ~/.ssh/dev-classic-ap-south-1.pem ~/.ssh/dev-classic-ap-south-1 ~/.ssh/dev-classic-ap-south-1.pub ubuntu@13.235.50.20:/home/ubuntu/.ssh
terraform destroy -var-file="terraform-ap-south-1.tfvars"
*****ubuntu*****
sudo apt update -y
sudo apt install -y stress-ng
stress-ng --cpu 2 --timeout 600
*****linux*****
sudo amazon-linux-extras install epel -y
sudo yum install stress-ng -y
stress-ng --cpu 2 --timeout 600
yum install -y amazon-cloudwatch-agent


sudo apt install -y stress
stress --cpu 2 --timeout 600

###rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=dev_classic-instance-*" \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name,Placement.AvailabilityZone]' \
  --output table \
  --region ap-south-1

ssh -i ./dev_classic-ap-south-1.pem ubuntu@<PUBLIC_IP>
terraform destroy -var-file="terraform-ap-south-1.tfvars"
****************************************************************************************************************
****************************************************************************************************************

Region -> us-east-1
aws s3api create-bucket \
  --bucket tfstatebackup-16102025-east \
  --region us-east-1

aws dynamodb create-table \
  --table-name terraformeast-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
***before delete all the keys in AWS console***
chmod +x scripts/generate_ed25519_key.sh 
./scripts/generate_ed25519_key.sh dev-classic-us-east-1 us-east-1

nano update-bastion-ip.sh
Press Ctrl + O → hit Enter to save
Press Ctrl + X to exit
chmod +x update-bastion-ip.sh
./update-bastion-ip.sh

mv backend-us-east-1.hcl backend-us-east-1.hcl.disabled
mv backend-us-east-1.hcl.disabled backend-us-east-1.hcl
rm -rf .terraform terraform.tfstate terraform.tfstate.backup
terraform init -reconfigure -backend-config="backend-us-east-1.hcl"
terraform init -upgrade
terraform fmt -recursive
terraform validate
terraform plan -var-file="terraform-us-east-1.tfvars"
terraform apply -target=module.us-east-1
terraform apply -var-file="terraform-us-east-1.tfvars"
terraform state list
scp -i /home/thani/.ssh/dev-classic-us-east-1.pem ~/.ssh/dev-classic-us-east-1.pem ~/.ssh/dev-classic-us-east-1 ~/.ssh/dev-classic-us-east-1.pub ubuntu@13.235.50.20:/home/ubuntu/.ssh
terraform destroy -var-file="terraform-us-east-1.tfvars"
sudo apt install -y stress
stress --cpu 2 --timeout 600

###rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=dev_classic-instance-*" \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name,Placement.AvailabilityZone]' \
  --output table \
  --region us-east-1

ssh -i ./dev_classic-us-east-1.pem ubuntu@<PUBLIC_IP>
terraform destroy -var-file="terraform-us-east-1.tfvars"
****************************************************************************************************************
****************************************************************************************************************

Region -> us-east-2
aws s3api create-bucket \
  --bucket tfstatebackup-16102025-east2 \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2

aws dynamodb create-table \
  --table-name terraformeast-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-2
***before delete all the keys in AWS console***
chmod +x scripts/generate_ed25519_key.sh 
./scripts/generate_ed25519_key.sh dev-classic-us-east-2 us-east-2

nano update-bastion-ip.sh
Press Ctrl + O → hit Enter to save
Press Ctrl + X to exit
chmod +x update-bastion-ip.sh
./update-bastion-ip.sh

mv backend-us-east-2.hcl backend-us-east-2.hcl.disabled
mv backend-us-east-2.hcl.disabled backend-us-east-2.hcl
rm -rf .terraform terraform.tfstate terraform.tfstate.backup
terraform init -reconfigure -backend-config="backend-us-east-2.hcl"
terraform init -upgrade
terraform fmt -recursive
terraform validate
terraform plan -var-file="terraform-us-east-2.tfvars"
terraform apply -target=module.us-east-2
terraform apply -var-file="terraform-us-east-2.tfvars"
terraform state list
scp -i /home/thani/.ssh/dev-classic-us-east-2.pem ~/.ssh/dev-classic-us-east-2.pem ~/.ssh/dev-classic-us-east-2 ~/.ssh/dev-classic-us-east-2.pub ubuntu@13.235.50.20:/home/ubuntu/.ssh
terraform destroy -var-file="terraform-us-east-2.tfvars"
sudo apt install -y stress
stress --cpu 2 --timeout 600

###rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=dev_classic-instance-*" \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name,Placement.AvailabilityZone]' \
  --output table \
  --region us-east-2

ssh -i ./dev_classic-us-east-2.pem ubuntu@<PUBLIC_IP>
terraform destroy -var-file="terraform-us-east-2.tfvars"
