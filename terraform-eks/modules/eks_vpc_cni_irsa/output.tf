output "vpc_cni_role_arn" {
  description = "O ARN da IAM Role para o VPC CNI."
  value       = aws_iam_role.vpc_cni_role.arn
}