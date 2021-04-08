module "mq" {
  source = "../../amazon-mq"

  environment_name = local.full_environment_prefix
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
}

resource "aws_security_group_rule" "mq_ingress" {
  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  security_group_id = module.mq.security_group_id
}