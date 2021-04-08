resource "aws_cloudwatch_log_group" "logs" {
  name              = "/watchn-ecs/${var.environment_name}/${var.service_name}"
  retention_in_days = 7
}