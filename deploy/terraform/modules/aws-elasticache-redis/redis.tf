resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.environment_name}-${var.instance_name}-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.environment_name}-${var.instance_name}-aurora"
  vpc_id      = var.vpc_id

  description = "Control traffic to/from Elasticache Redis"
}

resource "aws_elasticache_cluster" "cluster" {
  cluster_id           = "${var.environment_name}-${var.instance_name}"
  engine               = "redis"
  node_type            = var.instance_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  security_group_ids   = [aws_security_group.redis.id]
}