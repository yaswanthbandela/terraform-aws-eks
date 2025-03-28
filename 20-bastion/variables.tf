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
variable "bastion_ssh_key" {
  default = "bastion-ssh-key"  # Change this to your actual SSH key name in AWS
}
