resource "aws_eks_node_group" "this" {
  
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.env}-general"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids = var.subnet_ids
  ami_type = "AL2_x86_64"
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  disk_size     = var.disk_size
  remote_access {
    ec2_ssh_key = "eks"
  }
  
  for_each = var.scaling_config
  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }
#  block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = 20
#       volume_type           = "gp3"
#       delete_on_termination = true
#     }
#   }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "${var.env}-general"
  }
  tags = merge ({
    "Name" = "${var.env}-general_Nodegroups"}, var.node_tags) 
    # "k8s.io/cluster-autoscaler/${include.env.locals.env}-${include.env.locals.cluster_name}" = "owned"
    # "k8s.io/cluster-autoscaler/enabled" = "TRUE"
  

  depends_on = [aws_iam_role_policy_attachment.nodes]
}





###########self-managed node group##########

# # main.tf
# resource "aws_eks_cluster" "self_managed_cluster" {
#   name     = "self-managed-eks-cluster"
#   role_arn = aws_iam_role.cluster.arn
#   vpc_config {
#     subnet_ids = module.vpc.public_subnets
#   }
# }

# Self-Managed Node Configuration
# resource "aws_launch_template" "self_managed_nodes" {
#   name          = "self-managed-node-template"
#   instance_type = "t3.medium"
#   image_id      = data.aws_ami.eks_optimized.id # Get latest EKS AMI
#   key_name      = "my-key-pair"

#   user_data = base64encode(templatefile("node_bootstrap.sh", {
#     CLUSTER_NAME = aws_eks_cluster.self_managed_cluster.name
#     ENDPOINT     = aws_eks_cluster.self_managed_cluster.endpoint
#     CERTIFICATE  = aws_eks_cluster.self_managed_cluster.certificate_authority[0].data
#   }))

#   network_interfaces {
#     associate_public_ip_address = true
#     security_groups             = [aws_security_group.self_managed_node.id]
#   }
# }

# resource "aws_autoscaling_group" "self_managed_nodes" {
#   name             = "self-managed-asg"
#   min_size         = 1
#   max_size         = 4
#   desired_capacity = 2
#   vpc_zone_identifier = module.vpc.public_subnets

#   launch_template {
#     id      = aws_launch_template.self_managed_nodes.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "kubernetes.io/cluster/${aws_eks_cluster.self_managed_cluster.name}"
#     value               = "owned"
#     propagate_at_launch = true
#   }
# }

# # Bootstrap Script (node_bootstrap.sh)
# data "template_file" "node_user_data" {
#   template = <<-EOT
#   #!/bin/bash
#   set -ex
#   /etc/eks/bootstrap.sh ${CLUSTER_NAME} \
#     --apiserver-endpoint ${ENDPOINT} \
#     --b64-cluster-ca ${CERTIFICATE}
#   EOT
# }

# # IAM Role for Self-Managed Nodes
# resource "aws_iam_role" "self_managed_node" {
#   name = "eks-self-managed-node-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "self_managed_node" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.self_managed_node.name
# }


