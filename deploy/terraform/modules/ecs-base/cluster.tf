resource "aws_ecs_cluster" "cluster" {
  name = local.full_environment_prefix

  capacity_providers  = [aws_ecs_capacity_provider.asg_ondemand.name, "FARGATE", "FARGATE_SPOT"]
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${local.full_environment_prefix}"
  retention_in_days = 90
}