variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "karpenter_namespace" {
  description = "Namespace da Service Account do Karpenter."
  type        = string
}

variable "karpenter_service_account" {
  description = "Nome da Service Account do Karpenter."
  type        = string
}

variable "karpenter_controller_role_arn" {
  description = "ARN do IAM Role para o Karpenter Controller."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}