terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket         = "mtap-remote-state"
    key            = "mtap-dev/acm"
    region         = "us-east-1"
    dynamodb_table = "mtap-dev-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}