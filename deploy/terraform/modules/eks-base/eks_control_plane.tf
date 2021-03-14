locals {
  eks_cluster_issuer_domain = replace(aws_eks_cluster.cluster.identity.0.oidc.0.issuer, "https://", "")
}

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.cluster.name
}

# EKS Control Plane security group
resource "aws_security_group_rule" "vpc_endpoint_eks_cluster_sg" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoint.id
  source_security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
  to_port                  = 443
  type                     = "ingress"
  depends_on               = [aws_eks_cluster.cluster]
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  enabled_cluster_log_types = ["api","audit"] // "authenticator","controllerManager","scheduler"
  name                      = local.full_environment_prefix
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.eks_version

  vpc_config {
    subnet_ids              = flatten([module.vpc.public_subnets, module.vpc.private_subnets])
    security_group_ids      = []
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  tags = var.tags
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cluster,
    aws_eip.nginx_ingress, 
    aws_eip.istio_ingress,
    module.vpc
  ]
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.full_environment_prefix}/cluster"
  retention_in_days = 7
}

resource "aws_iam_role" "cluster" {
  name               = "${local.full_environment_prefix}-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_kms_key" "eks" {
  description             = "KMS key for encrypting aurora"
  deletion_window_in_days = 10

  policy = <<EOF
    {
      "Version": "2012-10-17",
      "Id": "key-default-1",
      "Statement": [
        {
          "Sid": "Default IAM policy for KMS keys",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        },
        {
          "Sid": "Enable IAM user to perform kms actions as well",
          "Effect": "Allow",
          "Principal": {
            "AWS": "${data.aws_caller_identity.current.arn}"
          },
          "Action": "kms:*",
          "Resource": "*"
        }
      ]
    }
  EOF
}