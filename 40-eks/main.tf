module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"  # Recommended stable version
  cluster_endpoint_public_access = true

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids)
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  # Security groups
  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id
  create_node_security_group    = false
  node_security_group_id        = local.node_sg_id

  # Access configuration
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    green = {
      min_size      = 1
      max_size      = 5
      desired_size  = 1
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess    = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      key_name = var.eks_ssh_key  # Remove if not using SSH access
    }
  }

  tags = var.common_tags
}

# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name  # Use the name from the module
# }

# resource "aws_security_group_rule" "eks_default_ingress" {
#   security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["10.0.0.0/16"]  # Your VPC CIDR
# }