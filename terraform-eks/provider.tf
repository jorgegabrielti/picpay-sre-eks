provider "aws" {
  region = var.aws_region
}

# O provider Kubernetes precisa do endpoint do cluster e do CA,
# que são outputs do módulo eks_cluster.
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Data source para autenticar o provider Kubernetes com o EKS
data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_name
}