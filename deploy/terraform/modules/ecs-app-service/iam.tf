resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.environment_name}-${var.service_name}-execution"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_execution_managed_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_ssm_kms_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = var.ssm_kms_policy_arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.environment_name}-${var.service_name}-task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}