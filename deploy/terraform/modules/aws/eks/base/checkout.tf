module "checkout_redis" {
  source = "../../elasticache-redis"

  environment_name   = local.full_environment_prefix
  instance_name      = "checkout"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnets
  availability_zones = var.availability_zones
}

resource "aws_security_group_rule" "checkout_redis_ingress" {
  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = module.checkout_redis.port
  to_port           = module.checkout_redis.port
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  security_group_id = module.checkout_redis.security_group_id
}