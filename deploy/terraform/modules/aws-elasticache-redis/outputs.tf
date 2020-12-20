output "address" {
  value = aws_elasticache_cluster.cluster.cache_nodes[0].address
}

output "port" {
  value = aws_elasticache_cluster.cluster.port
}

output "security_group_id" {
  value = aws_security_group.redis.id
}