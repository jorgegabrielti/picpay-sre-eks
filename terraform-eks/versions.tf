terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Necessário para o ConfigMap aws-auth
    }
    tls = { # Necessário para obter o thumbprint do OIDC provider
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}