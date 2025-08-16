variable "env" {
  description = "Environment name."
  type        = string
}

# variable "vpc_id" {
#   description = "vpc id"
#   type        = string
# }

variable "eks_version" {
  description = "Desired Kubernetes master version."
  type        = string
}


# variable "eks_name" {
#   description = "Name of the cluster."
#   type        = string
# } 

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
} 

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones."
  type        = list(string)
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes."
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    5 = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  }
}

variable "encryption_config" {
  description = "Encryption configuration for the EKS cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

# variable "node_groups" {
#   description = "EKS node groups"
#   type        = map(any)
# }

variable "capacity_type" {
  description = "capacities"
  type        = string
  default = ""
}

# variable "cluster_version" {
#   description = "cluster_version"
#   type        = string
#   default = ""
# }


# variable "eks_addons" {
#   description = "eks_addon_name and versions"
#   type    = map(string)
# }


variable "instance_types" {
  description = "EKS instance_types"
  type        = list
  default = []
}

variable "disk_size" {
  description = "disk_size"
  type        = number
  default = null
}


variable "scaling_config" {
  description = "EKS desired_size"
  type        = map(any)
  //default = null
}

 variable "enable_key" {
  description = "keykms"
  type        = bool
  default = true
 }

# variable "min_size" {
#   description = "EKS min_size"
#   type        = any
#   default = null
# }

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "node_tags" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = map(string)
  default     = null
}



# variable "vpc-cni-version"{
#  description = "cni-version"
#  type = string
#  default = ""
# }

# variable "kube-proxy-version"{
#  description = "proxy-version"
#  type = string
#  default = ""
# }

# variable "coredns-version"{
#  description = "proxy-version"
#  type = string
#  default = ""
# }


