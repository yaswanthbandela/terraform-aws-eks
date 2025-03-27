
module "db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.base_name}-db"
  description = "SG for DB MySQL Instances"
  vpc_id      = local.vpc_id

  # For rules that reference other SGs, continue using ingress_with_source_security_group_id.
  ingress_with_source_security_group_id = [
    local.sg_rules.db_bastion,
    local.sg_rules.db_node
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-db" }
  )
}

module "ingress" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.base_name}-ingress"
  description = "SG for Ingress Controller"
  vpc_id      = local.vpc_id

  # Use built-in ingress rule aliases. The module v5.3.0 now expects ingress_rules as a list of strings.
  ingress_rules = ["https", "http"]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-ingress" }
  )
}

module "cluster" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

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

module "node" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.base_name}-node"
  description = "SG for EKS Node"
  vpc_id      = local.vpc_id

  ingress_rules = ["ssh"]

  ingress_with_source_security_group_id = [
    local.sg_rules.node_from_cluster,
    local.sg_rules.node_from_ingress
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-node" }
  )
}

module "bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.base_name}-bastion"
  description = "SG for Bastion Instances"
  vpc_id      = local.vpc_id

  # Use custom_ingress_rules for custom objects.
  ingress_cidr_rules  = [
    local.sg_rules.bastion_ssh
  ]

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-bastion" }
  )
}

module "vpn" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.base_name}-vpn"
  description = "SG for VPN Instances"
  vpc_id      = local.vpc_id

  ingress_rules = ["ssh"]  # or any supported aliases if applicable

  tags = merge(
    var.common_tags,
    { Name = "${local.base_name}-vpn" }
  )
}

resource "aws_security_group_rule" "vpn_custom" {
  for_each = { for rule in local.vpn_rules : rule.name => rule }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = module.vpn.security_group_id
}
