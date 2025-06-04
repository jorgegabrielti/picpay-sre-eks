# Mapeamento do IAM Role para o Kubernetes (aws-auth ConfigMap)
# O manifesto eksctl especifica o mapeamento para o KarpenterNodeRole
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    # Mapeamento para o IAM Role dos nós do Karpenter
    # Isso permite que os nós com este Role se juntem ao cluster.
    "mapRoles" = jsonencode([
      {
        "rolearn"  = var.karpenter_node_role_arn
        "username" = "system:node:{{EC2PrivateDNSName}}"
        "groups"   = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      # Você pode adicionar outros mapeamentos aqui para usuários/roles que precisam
      # acessar o cluster (e.g., administradores, CI/CD roles).
      # Exemplo:
      # {
      #   "rolearn"  = "arn:aws:iam::123456789012:role/MyAdminRole"
      #   "username" = "admin"
      #   "groups"   = ["system:masters"]
      # }
    ])
    "mapUsers" = jsonencode([]) # Não há usuários mapeados no manifesto eksctl
  }
}