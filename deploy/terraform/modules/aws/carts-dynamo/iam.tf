module "iam_assumable_role_carts" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.13.0"
  create_role                   = true
  role_name                     = "${var.environment_name}-carts-dynamo"
  provider_url                  = local.eks_cluster_issuer_domain
  role_policy_arns              = [aws_iam_policy.carts_dynamo.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:watchn:carts"]
}

resource "aws_iam_policy" "carts_dynamo" {
  name        = "${var.environment_name}-carts-dynamo"
  path        = "/"
  description = "Dynamo policy for carts application"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllAPIActionsOnCart",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": [
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${local.carts_dynamo_table_name}",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${local.carts_dynamo_table_name}/index/*"
      ]
    }
  ]
}
EOF
}