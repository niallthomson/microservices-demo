locals {
  carts_dynamo_table_name = var.carts_dynamo_create_table ? aws_dynamodb_table.carts[0].name : var.carts_dynamo_table_name
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.13.0"
  create_role                   = true
  role_name                     = "${local.full_environment_prefix}-carts-dynamo"
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

resource "aws_dynamodb_table" "carts" {
  name             = "${local.full_environment_prefix}-carts"
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  count = var.carts_dynamo_create_table ? 1 : 0
}