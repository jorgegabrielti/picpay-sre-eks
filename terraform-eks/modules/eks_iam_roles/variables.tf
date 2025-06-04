variable "cluster_name" {
  description = "Nome do cluster EKS para usar em nomes de recursos IAM."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}

variable "oidc_provider_arn" {
  description = "ARN do provedor OIDC do cluster EKS. Necessário para o Karpenter Controller Role."
  type        = string
}