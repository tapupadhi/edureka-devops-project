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
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  default     = "10.0.1.0/24"
}