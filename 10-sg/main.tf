# Security Group for DB MySQL Instances
# - Allows MySQL access from the bastion host
# - Allows MySQL access from EKS nodes
module "db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-db"
  description = "SG for DB MySQL Instances"
  vpc_id      = local.vpc_id

  ingress_with_source_security_group_id = [
    local.sg_rules.db_bastion,
    local.sg_rules.db_node
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-db" }
  )
}

# Security Group for Ingress Controller
# - Allows HTTP traffic (port 80) from anywhere
# - Allows HTTPS traffic (port 443) from anywhere
module "ingress" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-ingress"
  description = "SG for Ingress Controller"
  vpc_id      = local.vpc_id

  ingress_with_cidr_blocks = [
    local.sg_rules.ingress_http,
    local.sg_rules.ingress_https
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-ingress" }
  )
}

# Security Group for EKS Control Plane
# - Allows control plane traffic from EKS nodes
# - Allows cluster access from the bastion host
module "cluster" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-cluster"
  description = "SG for EKS Control Plane"
  vpc_id      = local.vpc_id

  ingress_with_source_security_group_id = [
    local.sg_rules.cluster_from_node,
    local.sg_rules.cluster_from_bastion
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-cluster" }
  )
}

# Security Group for EKS Nodes
# - Allows SSH access from anywhere (port 22)
# - Allows all traffic within the VPC
# - Allows NodePort range (30000-32768) from ingress controller
# - Allows all traffic from the cluster
module "node" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-node"
  description = "SG for EKS Node"
  vpc_id      = local.vpc_id

  ingress_with_cidr_blocks = [
    local.sg_rules.bastion_ssh
  ]

  ingress_with_source_security_group_id = [
    local.sg_rules.node_from_cluster,
    {
      from_port                = 30000
      to_port                  = 32768
      protocol                 = "tcp"
      source_security_group_id = module.ingress.security_group_id
      description              = "NodePort range from ingress"
    }
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-node" }
  )
}

# Security Group for Bastion Instances
# - Allows SSH access from anywhere (port 22)
module "bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-bastion"
  description = "SG for Bastion Instances"
  vpc_id      = local.vpc_id

  ingress_with_cidr_blocks = [
    local.sg_rules.bastion_ssh
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-bastion" }
  )
}

# Security Group for VPN Instances
# - Allows VPN TCP access on ports 943 and 443 from anywhere
# - Allows VPN UDP access on port 1194 from anywhere
# - Allows SSH access from anywhere (port 22)
module "vpn" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "${local.base_name}-vpn"
  description = "SG for VPN Instances"
  vpc_id      = local.vpc_id

  ingress_with_cidr_blocks = local.vpn_rules

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-vpn" }
  )
}
