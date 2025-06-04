# Managed Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  instance_types  = [var.instance_type]
  ami_type        = var.ami_family
  subnet_ids      = var.subnet_ids
  node_role_arn   = var.node_role_arn

  # Tags para os recursos subjacentes (Auto Scaling Group, instâncias EC2)
  tags = merge(var.common_tags, {
    "karpenter.sh/discovery" = var.cluster_name # Tag do manifesto eksctl
    Name                     = var.node_group_name
    # Tag obrigatória para Node Groups gerenciados para que o EKS os reconheça.
    "eks:cluster-name"       = var.cluster_name
  })

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }
}