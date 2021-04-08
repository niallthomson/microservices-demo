resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name        = "${local.full_environment_prefix}-autoscaler"
  description = "EKS cluster autoscaler policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler" {
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
  role       = aws_iam_role.managed_workers.name
}

module "iam_assumable_role_cluster_autoscaler" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.13.0"
  create_role                   = true
  role_name                     = "${local.full_environment_prefix}-cluster-autoscaler"
  provider_url                  = local.eks_cluster_issuer_domain
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "${local.full_environment_prefix}-cluster-autoscaler"
  description = "EKS cluster-autoscaler policy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.cluster.id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

data "template_file" "cluster_autoscaler_values" {
  template = file("${path.module}/templates/cluster-autoscaler-values.yml")

  vars = {
    region = var.region
    role_arn = module.iam_assumable_role_cluster_autoscaler.this_iam_role_arn
    cluster_name = aws_eks_cluster.cluster.id
  }
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [null_resource.cluster_blocker]

  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.7.0"
  replace    = true

  values = [data.template_file.cluster_autoscaler_values.rendered]
}