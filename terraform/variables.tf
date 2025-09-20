variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "master_instance_type" {
  description = "Instance type for Jenkins master"
  default     = "t2.medium"
}

variable "slave_instance_type" {
  description = "Instance type for Jenkins slave"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of SSH key pair to use"
  type        = string
  # Remove default to force users to specify their own SSH key
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default is open, but users should restrict this in their own tfvars
}

variable "allowed_jenkins_cidr" {
  description = "CIDR blocks allowed for Jenkins web interface access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default is open, but users should restrict this in their own tfvars
}

variable "allowed_app_cidr" {
  description = "CIDR blocks allowed for application access (ports 80 and 8000)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default is open, but users should restrict this in their own tfvars
}