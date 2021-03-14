locals {
  node_pool_instance_type = var.graviton2 ? var.node_pool_instance_type_arm64 : var.node_pool_instance_type_x64
}

resource "aws_eks_node_group" "managed_workers" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.full_environment_prefix}-workers-${var.availability_zones[count.index]}"
  node_role_arn   = aws_iam_role.managed_workers.arn
  subnet_ids      = [module.vpc.private_subnets[count.index]]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  instance_types = [local.node_pool_instance_type]
  ami_type       = var.graviton2 ? "AL2_ARM_64" : "AL2_x86_64"
  labels = {
    lifecycle = "OnDemand"
    az        = var.availability_zones[count.index]
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.generated_key.key_name
    source_security_group_ids = [aws_security_group.provisioner.id]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

  lifecycle {
    create_before_destroy = true
  }

  count = length(var.availability_zones)
}

resource "aws_iam_role" "managed_workers" {
  name               = "${local.full_environment_prefix}-worker-node"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_workers.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_workers.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_workers.name
}

resource "aws_iam_role_policy_attachment" "eks-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.managed_workers.name
}