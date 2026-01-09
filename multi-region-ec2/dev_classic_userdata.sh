#!/bin/bash
set -e

LOG=/var/log/dev-classic-userdata.log
exec > >(tee -a $LOG) 2>&1

REGION="${region}"

echo "===== Userdata started | Region: $REGION ====="

# Base tools
apt-get update -y
apt-get install -y software-properties-common apt-transport-https \
                   ca-certificates curl git gnupg lsb-release

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible
ansible --version

# Clone repo
git clone git@github.com:danish0410/create-user.git /opt/create-user || \
git clone https://github.com/danish0410/create-user.git /opt/create-user

# Run Ansible locally
cd /opt/create-user/ansible
ansible-playbook create-user.yml

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker

echo "===== Userdata completed successfully ====="
