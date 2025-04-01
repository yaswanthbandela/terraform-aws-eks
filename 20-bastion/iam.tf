resource "aws_iam_role" "bastion_role" {
  name = "${var.project_name}-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Inline policy to allow full control over EKS
resource "aws_iam_policy" "bastion_cluster_admin" {
  name        = "${var.project_name}-${var.environment}-bastion-cluster-admin"
  description = "Policy to allow bastion to manage the entire EKS cluster"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "eks:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_cluster_admin_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_cluster_admin.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.project_name}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}
