variable "cluster_name" {
  description = "O nome do cluster EKS."
  type        = string
}

variable "oidc_provider_arn" {
  description = "O ARN do IAM OIDC provider do cluster EKS."
  type        = string
}

variable "oidc_provider_url" {
  description = "A URL do IAM OIDC provider do cluster EKS."
  type        = string
}

variable "common_tags" {
  description = "Um mapa de tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}