output "eks_name" {
  value = aws_eks_cluster.this.name
}

# output "cluster_name" {
#   value = aws_eks_cluster.this.name
# }

output "eks_id" {
  value = aws_eks_cluster.this.id
}

output "eks_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "openid_provider_arn" {
  value = aws_iam_openid_connect_provider.this[0].arn
}

output "oidc_extract"{

value = element(split("oidc-provider/", aws_iam_openid_connect_provider.this[0].arn), 1)

}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks.name 
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks.arn
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.this.endpoint
}

#####for the only one node gruop output we can use this methods#######

# output "node_group_private_id" {
#   description = "Node Group 1 ID"
#   value       = aws_eks_node_group.this.id
# }

# output "node_group_private_arn" {
#   description = "Private Node Group ARN"
#   value       = aws_eks_node_group.this.arn
# }

# output "node_group_private_status" {
#   description = "Private Node Group status"
#   value       = aws_eks_node_group.this.status 
# }

# output "node_group_private_version" {
#   description = "Private Node Group Kubernetes Version"
#   value       = aws_eks_node_group.this.version
# }

#####for the only list of  node gruop output we can use this method  (for_each)#######

output "node_group_private_status" {
  value = [for key, node_group in aws_eks_node_group.this : node_group.status]
}

output "node_group_versions" {
  value = [for key, node_group in aws_eks_node_group.this : node_group.version]
}

output "node_group_private_id" {
  value = [for key, node_group in aws_eks_node_group.this : node_group.id]
}
output "node_group_private_arn" {
  value = [for key, node_group in aws_eks_node_group.this : node_group.arn]
}