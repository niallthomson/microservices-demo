output "address" {
  value = aws_elasticache_replication_group.cluster.primary_endpoint_address
}

output "reader_address" {
  value = aws_elasticache_replication_group.cluster.reader_endpoint_address
}

output "port" {
  value = aws_elasticache_replication_group.cluster.port
}

output "security_group_id" {
  value = aws_security_group.redis.id
}

output "cloudwatch_dashboard_elements" {
  value = data.template_file.cloudwatch_dashboard_elements.rendered
}