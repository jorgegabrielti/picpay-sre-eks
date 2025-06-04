output "cluster_role_arn" {
  description = "ARN do IAM Role para o Cluster EKS."
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  description = "ARN do IAM Role para os Managed Node Groups do EKS."
  value       = aws_iam_role.eks_node_group_role.arn
}

output "node_instance_profile_name" {
  description = "Nome do IAM Instance Profile para os Managed Node Groups do EKS."
  value       = aws_iam_instance_profile.eks_node_group_profile.name
}

output "karpenter_controller_role_arn" {
  description = "ARN do IAM Role para o Karpenter Controller."
  value       = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_node_role_arn" {
  description = "ARN do IAM Role para os nós provisionados pelo Karpenter."
  value       = aws_iam_role.karpenter_node_role.arn
}

output "karpenter_node_instance_profile_name" {
  description = "Nome do IAM Instance Profile para os nós provisionados pelo Karpenter."
  value       = aws_iam_instance_profile.karpenter_node_profile.name
}

output "karpenter_controller_policy_arn" {
  description = "ARN da política IAM para o Karpenter Controller."
  value       = aws_iam_policy.karpenter_controller_policy.arn
}