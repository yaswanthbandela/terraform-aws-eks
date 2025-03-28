variable "project_name" {
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
