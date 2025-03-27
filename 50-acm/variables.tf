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
    Component = "ingress-alb"
  }
}

variable "zone_name" {
  default = "homelabs.me"
}

variable "zone_id" {
  default = "Z04736861DD64PA443FY9"
}