# Data source para obter o Account ID (necessário para construção de ARNs)
data "aws_caller_identity" "current" {}

# IAM Role para o Cluster EKS Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-cluster-role"
  })
}

# Anexa a política gerenciada do EKS para o Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Anexa a política de VPC CNI ao Cluster Role (opcional, mas recomendado para gerenciamento de ENIs)
resource "aws_iam_role_policy_attachment" "eks_vpc_cni_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" # Ajustado aqui
}

# IAM Role para os Managed Node Groups (Worker Nodes)
resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-node-role"
  })
}

# Anexa as políticas gerenciadas do EKS para os Node Groups
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile para o Node Group (necessário para EC2 assumir o Role)
resource "aws_iam_instance_profile" "eks_node_group_profile" {
  name = "${var.cluster_name}-node-profile"
  role = aws_iam_role.eks_node_group_role.name

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-node-profile"
  })
}

# IAM Role e Policy para Karpenter Controller (para podIdentityAssociations)
resource "aws_iam_role" "karpenter_controller_role" {
  name = "KarpenterControllerRole-${var.cluster_name}"

  # Este assume_role_policy é para ser assumido por um ServiceAccount via OIDC
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn # Usar o ARN do OIDC Provider passado como input
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub" : "system:serviceaccount:karpenter:karpenter",
            "${replace(var.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "KarpenterControllerRole-${var.cluster_name}"
  })
}

# Política para o Karpenter Controller (KarpenterControllerPolicy-picpay-sre-senior-cards)
resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "Permissões para o Karpenter Controller gerenciar nós EC2 e SGs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter", # Para buscar AMIs otimizadas, se usado
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Resource = aws_iam_role.eks_node_group_role.arn # Permite que o Karpenter passe o Node Role
        Condition = {
          StringEquals = {
            "iam:PassedToService" : "ec2.amazonaws.com"
          }
        }
      },
      {
        Action = "ec2:AssignPrivateIpAddresses"
        Effect = "Allow"
        Resource = "arn:aws:ec2:*:*:network-interface/*"
      },
      {
        Action = [
          "ec2:CreateTags"
        ]
        Effect = "Allow"
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" : [
              "CreateSecurityGroup"
            ]
          }
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "KarpenterControllerPolicy-${var.cluster_name}"
  })
}

# Anexa a política do Karpenter Controller ao seu Role
resource "aws_iam_role_policy_attachment" "karpenter_controller_policy_attachment" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# IAM Role para os nós do Karpenter (KarpenterNodeRole-picpay-sre-senior-cards)
# Este é o Role que os nós provisionados pelo Karpenter assumirão.
resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "KarpenterNodeRole-${var.cluster_name}"
  })
}

# Anexa políticas necessárias para os nós do Karpenter (semelhante aos Managed Node Groups)
resource "aws_iam_role_policy_attachment" "karpenter_node_worker_node_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr_read_only" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile para os nós do Karpenter
resource "aws_iam_instance_profile" "karpenter_node_profile" {
  name = "KarpenterNodeProfile-${var.cluster_name}"
  role = aws_iam_role.karpenter_node_role.name

  tags = merge(var.common_tags, {
    Name = "KarpenterNodeProfile-${var.cluster_name}"
  })
}