variable "cluster_name" {
  description = "Nome do cluster EKS ao qual o Node Group será anexado."
  type        = string
}

variable "node_group_name" {
  description = "Nome do Managed Node Group."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância para os nós do Node Group."
  type        = string
}

variable "ami_family" {
  description = "Família da AMI para os nós do Node Group (e.g., AmazonLinux2, AmazonLinux2023)."
  type        = string
}

variable "desired_capacity" {
  description = "Capacidade desejada para o Node Group."
  type        = number
}

variable "min_size" {
  description = "Tamanho mínimo para o Node Group."
  type        = number
}

variable "max_size" {
  description = "Tamanho máximo para o Node Group."
  type        = number
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets onde os nós do Node Group serão provisionados."
  type        = list(string)
}

variable "node_role_arn" {
  description = "ARN do IAM Role para os nós do Node Group."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}