# Cluster EKS
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids         = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = false # Conforme manifesto eksctl
    endpoint_private_access = true  # Conforme manifesto eksctl
    # O securityGroup do eksctl config (`sg-08d6375ed1b204c1b`) é para o control plane.
    # Vamos criar um SG dedicado para o cluster e associá-lo.
    security_group_ids = [aws_security_group.cluster_sg.id]
  }

  # Habilita o OIDC para o cluster (necessário para Service Accounts como Karpenter)
  # Logs de cluster (conforme eksctl config, ou ajuste conforme a necessidade)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(var.common_tags, {
    "karpenter.sh/discovery" = var.cluster_name # Tag do manifesto eksctl
    Name                     = var.cluster_name
  })
}

# Security Group para o Cluster EKS Control Plane
resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-cluster-sg"
    # Tag obrigatória para EKS se você quiser que o cluster controle este SG.
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# Data source para obter o thumbprint do OIDC Provider do EKS cluster.
# Isso é usado para criar o provedor OIDC no IAM.
data "tls_certificate" "eks_cluster_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Cria o IAM OpenID Connect Provider na AWS para o cluster EKS.
# Essencial para IAM Roles para Service Accounts (IRSA) e para o Karpenter Controller Role.
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}