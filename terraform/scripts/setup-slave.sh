#!/bin/bash

# Update package lists
apt-get update
apt-get upgrade -y

# Install Python and pip
apt-get install -y python3 python3-pip python3-venv

# Install OpenSSH Server
apt-get install -y openssh-server
systemctl start ssh
systemctl enable ssh

# Install Git
apt-get install -y git

# Install Java 17 for Jenkins agent
apt-get install -y openjdk-17-jdk

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create jenkins user with sudo access for the Jenkins agent
useradd -m -s /bin/bash jenkins
echo "jenkins ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins
usermod -aG docker jenkins