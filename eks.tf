resource "aws_iam_role" "eks" {
  name = "${var.env}-${var.cluster_name}-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": ["sts:AssumeRole", "sts:TagSession"]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks-vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

resource "aws_kms_key" "eks_secrets_encryption" {
  count = var.enable_key ? 1 : 0
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "eks-secrets-encryption-key"
    Environment = "dev"
  }
}

resource "aws_eks_cluster" "this" {
  name     = "${var.env}-${var.cluster_name}"
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn
  # access_config {
  #    authentication_mode = "API"
  #    //bootstrap_cluster_creator_admin_permissions = true
  #  }
  //bootstrap_self_managed_addons = true  ##for adding the default addons to your cluster cni,vpc,coredns..
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    //public_access_cidrs  = false
    # security_group_ids      = [
    #   aws_security_group.eks_cluster.id,
    #  // var.additional_security_group_ids  #helps in access cluster vis public only for certain i.p cidrs
    # ]

    subnet_ids = var.subnet_ids
  }
  # upgrade_policy {
  #   support_type = "STANDARD"
  # }
  # kubernetes_network_config {

  #   service_ipv4_cidr  = "172.20.0.0/16"
  # }

    # Enable encryption for Kubernetes secrets
  # encryption_config {
  #   //count = var.encryption_config ? 1 : 0
  #   provider {
  #     key_arn = var.encryption_config[0].provider_key_arn
  #   }
  #   resources = var.encryption_config[0].resources
  # }
  

  depends_on = [aws_iam_role.eks]
}



# locals {
#   eks_addons = {
#     "vpc-cni" = {
#       version           = var.vpc-cni-version
#       resolve_conflicts = "OVERWRITE"
#     },
#     "kube-proxy" = {
#       version           = var.kube-proxy-version
#       resolve_conflicts = "OVERWRITE"
#     },
#      "coredns" = {
#       version           = var.coredns-version
#       resolve_conflicts = "OVERWRITE"
#     }
#   }
# }

# # Creating the EKS Addons
# resource "aws_eks_addon" "eks_addons" {
#   for_each = local.eks_addons

#   cluster_name                = aws_eks_cluster.this.name
#   addon_name                  = each.key
#   addon_version               = each.value.version
#   resolve_conflicts           = each.value.resolve_conflicts
# }