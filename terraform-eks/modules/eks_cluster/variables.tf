variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes para o cluster EKS."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o cluster EKS será criado."
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas para o cluster EKS."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas para o cluster EKS."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN do IAM Role para o Cluster EKS."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}

variable "vpc_cni_role_arn" {
  description = "IAM Role ARN for the VPC CNI addon"
  type        = string
}