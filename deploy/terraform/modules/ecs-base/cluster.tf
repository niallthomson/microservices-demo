resource "aws_ecs_cluster" "cluster" {
  name = local.full_environment_prefix

  capacity_providers  = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.full_environment_prefix}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${local.full_environment_prefix}"
  retention_in_days = 90
}