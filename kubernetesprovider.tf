# Datasource: 
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this.name 
}

# Terraform Kubernetes Provider for update kubeconfig file
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token 
}

