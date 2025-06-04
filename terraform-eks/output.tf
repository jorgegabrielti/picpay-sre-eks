output "eks_cluster_name" {
  description = "O nome do cluster EKS."
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "O endpoint do cluster EKS."
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_kubeconfig_command" {
  description = "Comando para configurar o kubectl para o cluster EKS."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}

output "oidc_provider_arn" {
  description = "O ARN do provedor OIDC do cluster EKS."
  value       = module.eks_cluster.oidc_provider_arn
}