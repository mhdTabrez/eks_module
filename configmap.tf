
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# terraform {
#   required_providers {
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = ">= 2.0.0"
#     }
#   }
# }

locals {
  depends_on = [aws_eks_cluster.this]
  configmap_roles = [
    {
      #rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_nodegroup_role.name}"
      rolearn =   aws_iam_role.nodes.arn  //"${aws_iam_role.nodes.arn}"      
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = aws_iam_role.eks_admin_role.arn
      username = "eks-admin" # Just a place holder name
      groups   = ["system:masters"]
    },    
    {
      rolearn  = aws_iam_role.eks_readonly_role.arn
      username = "eks-readonly" # Just a place holder name
      #groups   = [ "eks-readonly-group" ]
      # Important Note: The group name specified in clusterrolebinding and in aws-auth configmap groups should be same. 
      groups   = [kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name]
    },     
  ]
    configmap_users = [
    {
      userarn  = aws_iam_user.basic_user.arn
      username = aws_iam_user.basic_user.name
      groups   = ["system:masters"]
    },
    {
      userarn  = aws_iam_user.admin_user.arn
      username = aws_iam_user.admin_user.name
      groups   = ["system:masters"]
    },    
  ]  
}

# resource "kubernetes_config_map_v1" "aws_auth" {
#   depends_on = [
#     aws_eks_cluster.this
#     //kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding
#   ]
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#     mapRoles = yamlencode(local.configmap_roles)
#     mapUsers = yamlencode(local.configmap_users)        
#   } 
#     lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [data]
# #   }

# }