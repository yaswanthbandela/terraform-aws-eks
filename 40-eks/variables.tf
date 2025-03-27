variable "common_tags" {
  default = {
    Project     = "mtap"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "sg_tags" {
  default = {}
}

variable "project_name" {
  default = "mtap"
}
variable "environment" {
  default = "dev"
}

variable "cluster_service_ipv4_cidr" {
  default = "10.100.0.0/16"
}