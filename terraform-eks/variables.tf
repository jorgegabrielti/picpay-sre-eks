variable "aws_region" {
  description = "Região da AWS onde o cluster EKS será criado."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
  default     = "picpay-sre-senior-cards" # Conforme manifesto eksctl
}

variable "eks_kubernetes_version" {
  description = "Versão do Kubernetes para o cluster EKS."
  type        = string
  default     = "1.33" # Conforme manifesto eksctl
}

# Variáveis do Projeto de Rede (terraform-network)
# IMPORTANTE: Você precisará obter esses valores dos outputs do seu projeto terraform-network.
variable "existing_vpc_id" {
  description = "O ID da VPC existente do Projeto 1."
  type        = string
}

variable "existing_public_subnet_ids" {
  description = "Lista de IDs das subnets públicas existentes do Projeto 1."
  type        = list(string)
}

variable "existing_private_subnet_ids" {
  description = "Lista de IDs das subnets privadas existentes do Projeto 1."
  type        = list(string)
}

# Tags comuns para aplicar aos recursos (conforme o Projeto de Rede)
variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default = {
    "project"     = "picpay-sre-senior-cards"
    "environment" = "dev" # Ajuste conforme seu ambiente (dev, prod, etc.)
  }
}

# Variáveis do Managed Node Group (conforme manifesto eksctl)
variable "ng_instance_type" {
  description = "Tipo de instância para o Managed Node Group."
  type        = string
  default     = "m5.large"
}

variable "ng_ami_family" {
  description = "Família da AMI para o Managed Node Group (e.g., AmazonLinux2, AmazonLinux2023)."
  type        = string
  default     = "AmazonLinux2023"
}

variable "ng_desired_capacity" {
  description = "Capacidade desejada para o Managed Node Group."
  type        = number
  default     = 2
}

variable "ng_min_size" {
  description = "Tamanho mínimo para o Managed Node Group."
  type        = number
  default     = 1
}

variable "ng_max_size" {
  description = "Tamanho máximo para o Managed Node Group."
  type        = number
  default     = 10
}

# Variáveis específicas do Karpenter (conforme manifesto eksctl e práticas)
variable "karpenter_namespace" {
  description = "Namespace para a Service Account do Karpenter Pod Identity Association."
  type        = string
  default     = "karpenter"
}

variable "karpenter_service_account_name" {
  description = "Nome da Service Account para o Karpenter Pod Identity Association."
  type        = string
  default     = "karpenter"
}