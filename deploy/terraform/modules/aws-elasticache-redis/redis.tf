resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.environment_name}-${var.instance_name}-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.environment_name}-${var.instance_name}-aurora"
  vpc_id      = var.vpc_id

  description = "Control traffic to/from Elasticache Redis"
}

resource "aws_elasticache_replication_group" "cluster" {
  automatic_failover_enabled    = true
  availability_zones            = var.availability_zones
  subnet_group_name             = aws_elasticache_subnet_group.subnet_group.name
  security_group_ids            = [aws_security_group.redis.id]
  replication_group_id          = "${var.environment_name}-${var.instance_name}"
  replication_group_description = "Watchn checkout cluster"
  node_type                     = var.instance_type
  number_cache_clusters         = length(var.availability_zones)
  engine                        = "redis"
  engine_version                = "5.0.6"
  parameter_group_name          = "default.redis5.0"
  port                          = 6379
  at_rest_encryption_enabled    = true
}