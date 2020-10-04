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