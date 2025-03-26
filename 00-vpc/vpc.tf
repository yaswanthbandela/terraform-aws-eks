# This file is used to create the VPC, subnets, route tables, and other networking resources.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"  # Pinning a specific stable version

  name = "${var.project_name}-${var.environment}-vpc"

  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = var.common_tags
}
