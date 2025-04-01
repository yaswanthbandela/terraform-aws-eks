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


    # ===== NEW: Add these tags for ALB auto-discovery =====
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"  # Required for public ALBs
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"  # Optional but recommended
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"  # For internal ALBs (if needed later)
  }
  
  tags = var.common_tags
}
