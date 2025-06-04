
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = false
    endpoint_private_access = true  
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(var.common_tags, {
    "karpenter.sh/discovery" = var.cluster_name 
    Name                     = var.cluster_name
  })
}

resource "aws_security_group" "cluster_shared_node_sg" {
  name        = "${var.cluster_name}-ClusterSharedNodeSecurityGroup"
  description = "Communication between all nodes in the cluster"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}/ClusterSharedNodeSecurityGroup" 
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}


resource "aws_security_group_rule" "ingress_default_cluster_to_node_sg" {
  security_group_id            = aws_security_group.cluster_shared_node_sg.id
  description                  = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
  from_port                    = 0
  to_port                      = 65535
  protocol                     = "-1"
  type                         = "ingress"
  source_security_group_id     = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id 
}


resource "aws_security_group_rule" "ingress_inter_node_group_sg" {
  security_group_id            = aws_security_group.cluster_shared_node_sg.id
  description                  = "Allow nodes to communicate with each other (all ports)"
  from_port                    = 0
  to_port                      = 65535
  protocol                     = "-1"
  type                         = "ingress"
  source_security_group_id     = aws_security_group.cluster_shared_node_sg.id
}


resource "aws_security_group_rule" "ingress_node_to_default_cluster_sg" {
  security_group_id            = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id # SG do Control Plane
  description                  = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port                    = 0
  to_port                      = 65535
  protocol                     = "-1"
  type                         = "ingress"
  source_security_group_id     = aws_security_group.cluster_shared_node_sg.id
}


resource "aws_security_group_rule" "cluster_shared_node_sg_egress" {
  security_group_id = aws_security_group.cluster_shared_node_sg.id
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "tls_certificate" "eks_cluster_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}