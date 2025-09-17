#!/bin/bash

# Update package lists
apt-get update
apt-get upgrade -y

# Install Java 17
apt-get install -y software-properties-common
apt-get update
apt-get install -y openjdk-17-jdk

# Install Jenkins - updated method using proper key management
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins

# Fix permissions explicitly
mkdir -p /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins
mkdir -p /var/cache/jenkins
chown -R jenkins:jenkins /var/cache/jenkins
mkdir -p /var/log/jenkins
chown -R jenkins:jenkins /var/log/jenkins

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Git
apt-get install -y git

# Install Ansible
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add Jenkins user to docker group
usermod -aG docker jenkins

# Restart Jenkins
systemctl restart jenkins