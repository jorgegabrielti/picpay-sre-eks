output "node_group_name" {
  description = "O nome do Managed Node Group criado."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "O ARN do Managed Node Group criado."
  value       = aws_eks_node_group.this.arn
}