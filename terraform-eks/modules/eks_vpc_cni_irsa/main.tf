# IAM Role para o VPC CNI (aws-node Service Account)
resource "aws_iam_role" "vpc_cni_role" {
  name_prefix = "${var.cluster_name}-vpc-cni-role-"
  description = "IAM role for VPC CNI addon"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-node",
            "${replace(var.oidc_provider_url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}/vpc-cni-role"
  })
}

# Anexa a política gerenciada AmazonEKS_CNI_Policy à IAM Role
resource "aws_iam_role_policy_attachment" "vpc_cni_policy_attachment" {
  role       = aws_iam_role.vpc_cni_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}