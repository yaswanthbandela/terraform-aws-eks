locals {
  base_name = "${var.project_name}-${var.environment}"
  vpc_id    = data.aws_ssm_parameter.vpc_id.value

  # A common map of security group rules
  sg_rules = {
    db_bastion = {
      description              = "Allow DB access from bastion"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.bastion.security_group_id
    },
    db_node = {
      description              = "Allow DB access from nodes"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.node.security_group_id
    },
    ingress_https = {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    ingress_http = {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    cluster_from_node = {
      description              = "Allow control plane traffic from nodes"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      source_security_group_id = module.node.security_group_id
    },
    cluster_from_bastion = {
      description              = "Allow cluster access from bastion"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.bastion.security_group_id
    },
    node_vpc = {
      description = "Allow all traffic within VPC"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/16"]
    },
    node_from_cluster = {
      description              = "Allow traffic from cluster"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      source_security_group_id = module.cluster.security_group_id
    },
    node_from_ingress = {
      description              = "Allow node traffic from ingress"
      from_port                = 30000
      to_port                  = 32768
      protocol                 = "tcp"
      source_security_group_id = module.ingress.security_group_id
    },
    bastion_ssh = {
      description = "Allow SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
