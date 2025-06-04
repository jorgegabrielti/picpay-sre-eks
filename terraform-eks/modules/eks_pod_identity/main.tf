# Associação de Pod Identity para o Karpenter Controller
# Conforme seção podIdentityAssociations no manifesto eksctl
resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = var.karpenter_namespace
  service_account = var.karpenter_service_account
  role_arn        = var.karpenter_controller_role_arn

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-${var.karpenter_namespace}-${var.karpenter_service_account}-pod-identity"
  })
}