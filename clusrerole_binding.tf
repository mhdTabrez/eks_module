# data "aws_caller_identity" "current" {}
# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }
# Resource: Cluster Role
resource "kubernetes_cluster_role_v1" "eksreadonly_clusterrole" {
  depends_on = [ aws_eks_cluster.this ]
  metadata {
    name = "${var.env}-eksreadonly-clusterrole"
  }
  rule {
    api_groups = [""] # These come under core APIs
    //resources  = ["nodes", "namespaces", "pods", "events", "services"]
    resources  = ["nodes", "namespaces", "pods", "events", "services", "configmaps", "serviceaccounts"] #Uncomment for additional Testing
    verbs      = ["get", "list"]    
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list"]    
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]    
  }  
}

# Resource: Cluster Role Binding
resource "kubernetes_cluster_role_binding_v1" "eksreadonly_clusterrolebinding" {
  metadata {
    name = "${var.env}-eksreadonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksreadonly_clusterrole.metadata[0].name 
  }
  subject {
    kind      = "Group"
    name      = "eks-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}
 


 //for the multiple namespace role and bindings//

#  locals {
#   namespaces = ["dev", "staging", "production"]
# }

# resource "kubernetes_role_v1" "eksdeveloper_role" {
#   for_each = toset(local.namespaces)
  
#   metadata {
#     name      = "${each.key}-eksdeveloper-role"
#     namespace = each.key
#   }

#   rule {
#     api_groups = ["", "extensions", "apps"]
#     resources  = ["*"]
#     verbs      = ["*"]
#   }
#   rule {
#     api_groups = ["batch"]
#     resources  = ["jobs", "cronjobs"]
#     verbs      = ["*"]
#   }
# }

# resource "kubernetes_role_binding_v1" "eksdeveloper_rolebinding" {
#   for_each = toset(local.namespaces)

#   metadata {
#     name      = "${each.key}-eksdeveloper-rolebinding"
#     namespace = each.key
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = kubernetes_role_v1.eksdeveloper_role[each.key].metadata[0].name  //name must be unique so that [each.key] applied.
#   }

#   subject {
#     kind      = "Group"
#     name      = "eks-developer-group"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
