# terraform {
#   required_providers {
#     tls = {
#       source  = "hashicorp/tls"
#       version = ">= 2.0.0"
#     }
#   }
# }

data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

#for eks cluster services to comminocate through roles of iam
resource "aws_iam_openid_connect_provider" "this" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
    oidc_extract = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.this[0].arn}"), 1)
}
# # Output: AWS IAM Open ID Connect Provider
# output "oidc_extract" {
#   description = "AWS IAM Open ID Connect Provider extract from ARN"
#    value = local.oidc_extract
# }
