data "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project_name}/${var.environment}/bastion_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ami" "ami_info" {

    most_recent = true
    owners = ["973714476881"]

    filter {
        name   = "name"
        values = ["RHEL-9-DevOps-Practice"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

   
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}locals {
  public_subnet_id = element(split(",", data.aws_ssm_parameter.public_subnet_ids.value), 0)
}# This module creates a bastion host in the public subnet of the VPC.
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-bastion"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  subnet_id              = local.public_subnet_id
  ami                    = data.aws_ami.ubuntu.id  
  key_name               = var.bastion_ssh_key  # Use SSH key for authentication
  user_data              = file("bastion.sh")

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket         = "mtap-remote-state"
    key            = "mtap-dev/bastion"
    region         = "us-east-1"
    dynamodb_table = "mtap-dev-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}variable "project_name" {
  default = "mtap"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "mtap"
    Environment = "dev"
    Terraform = "true"
  }
}
variable "bastion_ssh_key" {
  default = "my-ssh-key"  # Change this to your actual SSH key name in AWS
}
