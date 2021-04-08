output "service_name" {
  value = aws_ecs_service.ui.name
}

output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

output "alb_zone_id" {
  value = aws_alb.main.zone_id
}