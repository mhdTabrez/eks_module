# data "aws_ami" "eks_worker" {
#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${var.cluster_version}-v*"]
#   }
#   most_recent = true
#   owners      = ["amazon"]
# }
          
          
          
          
          # # Launch template for EKS worker nodes
# resource "aws_launch_template" "eks_nodes" {
#   name_prefix   = "${var.cluster_name}-node-template"
#   description   = "EKS node group launch template"
#   image_id      = data.aws_ami.eks_worker.id
#   instance_type = var.instance_types[0]

#   vpc_security_group_ids = [aws_security_group.eks_nodes.id]

#   user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
#     cluster_name         = var.cluster_name
#     cluster_endpoint     = aws_eks_cluster.this.endpoint
#     cluster_auth_base64  = aws_eks_cluster.this.certificate_authority[0].data
#     bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=110 --kube-reserved cpu=250m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=250m,memory=0.5Gi'"
#     kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=normal,Environment=${var.env} --allowed-unsafe-sysctls=net.core.somaxconn,net.ipv4.tcp_keepalive_time"
#   }))

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = var.disk_size
#       volume_type = "gp3"
#       encrypted   = true
#       iops        = 3000
#       throughput  = 125
#     }
#   }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 2
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name                                        = "${var.cluster_name}-node"
#       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#       Environment                                 = var.env
#     }
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # EKS managed node group
# resource "aws_eks_node_group" "main" {
#   cluster_name    = aws_eks_cluster.this.name
#   node_group_name = "${var.env}-general"
#   node_role_arn   = aws_iam_role.nodes.arn
#   subnet_ids = var.subnet_ids

#   launch_template {
#     id      = aws_launch_template.eks_nodes.id
#     version = aws_launch_template.eks_nodes.latest_version
#   }

#   scaling_config {
#     desired_size = var.desired_nodes
#     max_size     = var.max_nodes
#     min_size     = var.min_nodes
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_node_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.eks_container_registry,
#   ]

#   tags = {
#     Environment = var.env
#   }
# }

# # OIDC Provider for EKS
# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
# }





                  ##########S.G FOR NODES ###########
## Security group for EKS control plane
# resource "aws_security_group" "eks_cluster" {
#   name        = "${var.cluster_name}-cluster-sg"
#   description = "Security group for EKS control plane"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.cluster_name}-cluster-sg"
#     Environment = var.environment
#   }
# }

# # Security group for EKS worker nodes
# resource "aws_security_group" "eks_nodes" {
#   name        = "${var.cluster_name}-node-sg"
#   description = "Security group for EKS worker nodes"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.cluster_name}-node-sg"
#     Environment = var.environment
#   }
# }

# # Allow worker nodes to communicate with EKS control plane
# resource "aws_security_group_rule" "nodes_to_control_plane" {
#   description              = "Allow worker nodes to communicate with control plane"
#   from_port                = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 443
#   type                     = "ingress"
# }

# # Allow EKS control plane to communicate with worker nodes
# resource "aws_security_group_rule" "control_plane_to_nodes" {
#   description              = "Allow control plane to communicate with worker nodes"
#   from_port                = 1025
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_nodes.id
#   source_security_group_id = aws_security_group.eks_cluster.id
#   to_port                  = 65535
#   type                     = "ingress"
# }

# # Security group for internal ALB
# resource "aws_security_group" "internal_alb" {
#   name        = "${var.cluster_name}-internal-alb-sg"
#   description = "Security group for internal ALB"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.cluster_name}-internal-alb-sg"
#     Environment = var.environment
#   }
# }