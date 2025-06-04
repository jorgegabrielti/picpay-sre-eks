output "cluster_name" {
  description = "O nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "O endpoint do cluster EKS."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "A CA data do cluster EKS."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "O ARN do provedor OIDC do cluster EKS."
  value       = aws_iam_openid_connect_provider.this.arn
}

#output "cluster_security_group_id" {
#  description = "O ID do Security Group do cluster EKS."
#  value       = aws_security_group.cluster_sg.id
#}

output "cluster_security_group_id" {
  description = "O ID do Security Group principal do cluster EKS (gerenciado pelo EKS)."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_shared_node_security_group_id" {
  description = "O ID do Security Group compartilhado entre os nós do cluster."
  value       = aws_security_group.cluster_shared_node_sg.id
}