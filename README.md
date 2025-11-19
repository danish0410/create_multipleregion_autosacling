generate_ed25519_key
***before delete all the keys in AWS console***
chmod +x scripts/generate_ed25519_key.sh 
./scripts/generate_ed25519_key.sh dev-classic-ap-south-1 ap-south-1
./scripts/generate_ed25519_key.sh dev-classic-us-east-1 us-east-1
./scripts/generate_ed25519_key.sh dev-classic-us-east-2 us-east-2


nano update-all-bastion-ip.sh
Press Ctrl + O → hit Enter to save
Press Ctrl + X to exit
chmod +x update-all-bastion-ip.sh
./update-all-bastion-ip.sh


Region 1
cd regions/ap-south-1
terraform init -reconfigure
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform destroy

Region 2
cd regions/us-east-1
terraform init -reconfigure
terraform fmt -recursive
terraform validate
terraform plan
terraform init
terraform apply
terraform destroy

Region 3
cd regions/us-east-2
terraform init -reconfigure
terraform fmt -recursive
terraform validate
terraform plan
terraform init
terraform apply
terraform destroy
