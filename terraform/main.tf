provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-vpc"
  }
}

# Create subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "jenkins-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-igw"
  }
}

# Create route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "jenkins-route-table"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security group for Jenkins master
resource "aws_security_group" "jenkins_master" {
  name        = "jenkins-master-sg"
  description = "Security group for Jenkins master"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Jenkins web interface
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins web interface"
  }
  
  # FastAPI test environment
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "FastAPI test environment"
  }
  
  # FastAPI production environment (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "FastAPI production environment"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-master-sg"
  }
}

# Security group for Jenkins slave
resource "aws_security_group" "jenkins_slave" {
  name        = "jenkins-slave-sg"
  description = "Security group for Jenkins slave"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access for production environment
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for production environment"
  }
  
  # Port for test environment
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port for test environment"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-slave-sg"
  }
}

# Jenkins master instance
resource "aws_instance" "jenkins_master" {
  ami                         = "ami-0360c520857e3138f" # Ubuntu 24.04 LTS
  instance_type               = var.master_instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/setup-master.sh")

  tags = {
    Name = "jenkins-master"
  }
}

# Jenkins slave instances
resource "aws_instance" "jenkins_slave_test" {
  ami                         = "ami-0360c520857e3138f" # Ubuntu 24.04 LTS
  instance_type               = var.slave_instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.jenkins_slave.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/setup-slave.sh")

  tags = {
    Name = "jenkins-slave-test"
  }
}

resource "aws_instance" "jenkins_slave_prod" {
  ami                         = "ami-0360c520857e3138f" # Ubuntu 24.04 LTS
  instance_type               = var.slave_instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.jenkins_slave.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/setup-slave.sh")

  tags = {
    Name = "jenkins-slave-prod"
  }
}