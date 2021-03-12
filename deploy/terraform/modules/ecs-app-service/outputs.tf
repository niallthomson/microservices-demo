output "service_name" {
  value = aws_ecs_service.service.name
}

output "sd_service_name" {
  value = aws_service_discovery_service.sd.name
}

output "alb_name" {
  value = aws_alb.main.name
}

output "alb_arn_suffix" {
  value = aws_alb.main.arn_suffix
}

output "alb_dns" {
  value = aws_alb.main.dns_name
}

output "alb_listener_id" {
  value = aws_alb_listener.listener.id
}

output "alb_target_group_name" {
  value = aws_alb_target_group.main.name
}

output "alb_target_group_arn_suffix" {
  value = aws_alb_target_group.main.arn_suffix
}

output "execution_role_name" {
  value = aws_iam_role.ecs_execution_role.name
}

output "task_execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}