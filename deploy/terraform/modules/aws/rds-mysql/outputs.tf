output "writer_endpoint" {
  value = aws_rds_cluster_instance.instance_primary.writer ? aws_rds_cluster.rds_cluster.endpoint : aws_rds_cluster.rds_cluster.reader_endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.rds_cluster.reader_endpoint
}

output "username" {
  value = local.rds_master_username
}

output "password" {
  value = local.rds_master_password
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "password_ssm_name" {
  value = aws_ssm_parameter.password.name
}

output "password_ssm_arn" {
  value = aws_ssm_parameter.password.arn
}

output "root_password_ssm_name" {
  value = aws_ssm_parameter.root_password.name
}

output "root_password_ssm_arn" {
  value = aws_ssm_parameter.root_password.arn
}

output "cloudwatch_dashboard_elements" {
  value = data.template_file.cloudwatch_dashboard_elements.rendered
}