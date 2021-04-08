output "service_name" {
  value = module.app_service.service_name
}

output "sd_service_name" {
  value = module.app_service.sd_service_name
}

output "alb_name" {
  value = module.app_service.alb_name
}

output "alb_arn_suffix" {
  value = module.app_service.alb_arn_suffix
}

output "alb_dns" {
  value = module.app_service.alb_dns
}

output "alb_listener_id" {
  value = module.app_service.alb_listener_id
}

output "alb_target_group_name" {
  value = module.app_service.alb_target_group_name
}

output "alb_target_group_arn_suffix" {
  value = module.app_service.alb_target_group_arn_suffix
}

output "execution_role_name" {
  value = module.app_service.execution_role_name
}

output "task_execution_role_name" {
  value = module.app_service.task_execution_role_name
}

output "cloudwatch_log_group_name" {
  value = module.app_service.cloudwatch_log_group_name
}