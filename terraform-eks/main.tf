# Arquivo: terraform-eks/main.tf
locals {
  common_tags = var.common_tags
}

# Módulo para IAM Roles do EKS Cluster, Nodes e Karpenter
# Ele precisa do ARN do OIDC Provider do cluster, então o módulo eks_cluster deve ser criado primeiro.
module "eks_iam_roles" {
  source = "./modules/eks_iam_roles"

  cluster_name      = var.cluster_name
  common_tags       = local.common_tags
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn # Recebe o ARN do OIDC do cluster
}

# Módulo para o Cluster EKS
module "eks_cluster" {
  source = "./modules/eks_cluster"

  cluster_name       = var.cluster_name
  kubernetes_version = var.eks_kubernetes_version
  vpc_id             = var.existing_vpc_id
  public_subnet_ids  = var.existing_public_subnet_ids
  private_subnet_ids = var.existing_private_subnet_ids
  cluster_role_arn   = module.eks_iam_roles.cluster_role_arn # Role do Cluster EKS
  common_tags        = local.common_tags
}


# Módulo para o Managed Node Group
module "eks_node_group" {
  source = "./modules/eks_node_group"

  cluster_name     = module.eks_cluster.cluster_name
  node_group_name  = "${var.cluster_name}-ng"
  instance_type    = var.ng_instance_type
  ami_family       = var.ng_ami_family
  desired_capacity = var.ng_desired_capacity
  min_size         = var.ng_min_size
  max_size         = var.ng_max_size
  subnet_ids       = var.existing_private_subnet_ids # Nodes gerenciados geralmente ficam em subnets privadas
  node_role_arn    = module.eks_iam_roles.node_role_arn
  common_tags      = local.common_tags
}

# Módulo para o ConfigMap aws-auth
module "eks_auth_configmap" {
  source = "./modules/eks_auth_configmap"

  cluster_name            = module.eks_cluster.cluster_name
  karpenter_node_role_arn = module.eks_iam_roles.karpenter_node_role_arn # Role dos nós do Karpenter
  common_tags             = local.common_tags
}

# Módulo para Pod Identity Associations (Karpenter)
module "eks_pod_identity" {
  source = "./modules/eks_pod_identity"

  cluster_name                  = module.eks_cluster.cluster_name
  karpenter_namespace           = var.karpenter_namespace
  karpenter_service_account     = var.karpenter_service_account_name
  karpenter_controller_role_arn = module.eks_iam_roles.karpenter_controller_role_arn # Role do Controller Karpenter
  common_tags                   = local.common_tags
}

# Módulo para Addons EKS (vpc-cni, eks-pod-identity-agent)
module "eks_addons" {
  source = "./modules/eks_addons"

  cluster_name = module.eks_cluster.cluster_name
  common_tags  = local.common_tags
}