terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.57"
    }
  }
  backend "s3" {
    bucket         = "mtap-remote-state"
    key            = "mtap-dev/eks"
    region         = "us-east-1"
    dynamodb_table = "mtap-dev-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}