# Addon: VPC CNI (conforme manifesto eksctl)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  addon_version = null
  resolve_conflicts_on_create = "OVERWRITE" 
  
  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-vpc-cni-addon"
  })
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"
  addon_version = null
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-pod-identity-agent-addon"
  })

  depends_on = [
    aws_eks_addon.vpc_cni 
  ]
}