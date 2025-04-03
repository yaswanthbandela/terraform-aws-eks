module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.32"  # Recommended stable version
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
  enable_cluster_oidc_issuer_url = true

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
        SecretsManagerAccess = aws_iam_policy.secrets_access.arn
      }
      key_name = var.eks_ssh_key  # Remove if not using SSH access
    }
  }

  tags = var.common_tags
}

# Add after EKS module
resource "helm_release" "secrets_csi" {
  name       = "secrets-csi"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"

  set {
    name  = "syncSecret.enabled"
    value = "true"  # Syncs secrets to Kubernetes Secrets
  }
}

# Add IAM policy
resource "aws_iam_policy" "secrets_access" {
  name        = "secrets-access"
  description = "Allow Secrets Manager access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Resource = "arn:aws:secretsmanager:${var.region}:*:secret:*"
    }]
  })
}