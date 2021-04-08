resource "aws_iam_role" "fargate_role" {
  name               = "${local.full_environment_prefix}-fargate"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_role.name
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "${local.full_environment_prefix}-profile"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = var.kubernetes_namespace
    labels    = {
      "fargate" = "true"
    }
  }
}