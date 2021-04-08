locals {
  carts_chaos_profile_map = {
    "" = []
    "errors" = ["chaos-errors"]
    "latency" = ["chaos-latency"]
  }
  carts_spring_profiles = ["prod", "dynamodb", "chaos-monkey"]
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
      "Action": [
        "dynamodb:BatchGet*",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:Get*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWrite*",
        "dynamodb:Create*",
        "dynamodb:Delete*",
        "dynamodb:Update*",
        "dynamodb:PutItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.carts.arn}",
        "${aws_dynamodb_table.carts.arn}/index/*"
      ]
    }
  ]
}
EOF
}

resource "aws_dynamodb_table" "carts" {
  name             = "${var.environment_name}-carts"
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
}

module "app_service" {
  source = "../../app-service"

  environment_name          = var.environment_name
  service_name              = "cart"
  region                    = var.region
  cluster_id                = var.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [ var.task_sg_id ]
  lb_security_group_id      = var.lb_security_group_id
  sd_namespace_id           = var.sd_namespace_id
  cpu                       = 512
  memory                    = 1024
  health_check_path         = "/actuator/health"
  health_check_grace_period = 120
  fargate                   = var.fargate
  ssm_kms_policy_arn        = var.ssm_kms_policy_arn
  docker_labels             = {
    "platform" = "java"
  }

  container_image           = "watchn/watchn-cart:${var.image_tag}"
  environment               = [{
    name  = "CARTS_DYNAMODB_TABLENAME",
    value = aws_dynamodb_table.carts.name
  },{
    name  = "CARTS_DYNAMODB_CREATETABLE",
    value = "false"
  },{
    name  = "SPRING_PROFILES_ACTIVE",
    value = join(",", concat(local.carts_spring_profiles, local.carts_chaos_profile_map[var.chaos_enabled]))
  },{
    name  = "JAVA_OPTS",
    value = "-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/urandom -XX:MaxMetaspaceSize=128m"
  }]

  readonly_filesystem       = false
  drop_capabilities         = false
}

resource "aws_iam_role_policy_attachment" "carts_role_attachment" {
  role       = module.app_service.task_execution_role_name
  policy_arn = aws_iam_policy.carts_dynamo.arn
}