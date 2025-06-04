# Addon: VPC CNI (conforme manifesto eksctl)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  # O eksctl usa "latest", mas é boa prática fixar uma versão no Terraform para consistência.
  # Use uma versão compatível com a sua versão de Kubernetes (1.33 no seu caso).
  # Exemplo para EKS 1.33, você pode consultar as versões compatíveis na documentação da AWS.
  addon_version = "v1.17.0-eksbuild.1" # Exemplo: v1.17.0 é comum para k8s 1.28+. Ajuste conforme necessário.
  resolve_conflicts_on_create = "OVERWRITE" # Importante para evitar conflitos se já existir

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-vpc-cni-addon"
  })
}

# Addon: eks-pod-identity-agent (conforme manifesto eksctl)
# Requer Kubernetes 1.29 ou superior.
resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"
  # O eksctl usa "latest", fixando uma versão para consistência.
  # Exemplo: v1.2.0 é compatível com k8s 1.29+. Ajuste conforme necessário.
  addon_version = "v1.2.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-pod-identity-agent-addon"
  })

  depends_on = [
    aws_eks_addon.vpc_cni # Adiciona uma dependência para garantir ordem de instalação, se houver
  ]
}