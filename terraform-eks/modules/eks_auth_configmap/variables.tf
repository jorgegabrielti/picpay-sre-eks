variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "karpenter_node_role_arn" {
  description = "ARN do IAM Role para os nós provisionados pelo Karpenter (a ser mapeado no aws-auth)."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}