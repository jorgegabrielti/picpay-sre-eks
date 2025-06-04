variable "cluster_name" {
  description = "Nome do cluster EKS ao qual os addons serão adicionados."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para aplicar aos recursos."
  type        = map(string)
  default     = {}
}