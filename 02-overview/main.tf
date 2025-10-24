terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-1"  # Singapore region
  profile = "personal-learning"  # Your custom profile
}

# Safety check - shows which AWS account you're using
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID being used"
}

# Automatically get the latest Ubuntu 22.04 LTS AMI for Singapore
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu's official owner)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 instance with Ubuntu
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id  # Uses Ubuntu AMI
  instance_type = "t2.micro"  # Free tier eligible

  tags = {
    Name        = "My Ubuntu Server"
    Environment = "Learning"
    OS          = "Ubuntu 22.04"
    ManagedBy   = "Terraform"
  }
}

# Output the instance details
output "instance_id" {
  value       = aws_instance.example.id
  description = "EC2 Instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.example.public_ip
  description = "Public IP address of the EC2 instance"
}

output "ami_id_used" {
  value       = data.aws_ami.ubuntu.id
  description = "Ubuntu AMI ID that was used"
}

output "ssh_connection_command" {
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.example.public_ip}"
  description = "SSH command to connect (note: user is 'ubuntu' not 'ec2-user')"
}
