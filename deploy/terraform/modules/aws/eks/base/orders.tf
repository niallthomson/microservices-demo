module "orders_rds" {
  source = "../../rds-mysql"

  environment_name = local.full_environment_prefix
  instance_name    = "orders"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
  db_name          = "orders"
}

resource "aws_security_group_rule" "orders_rds_ingress" {
  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  security_group_id = module.orders_rds.security_group_id
}

resource "kubernetes_secret" "orders_rds_writer" {
  metadata {
    name      = "orders-writer-db"
    namespace = module.app_base.namespace
  }

  data = {
    url      = "jdbc:mysql://${module.orders_rds.writer_endpoint}:3306/orders"
    username = module.orders_rds.username
    password = module.orders_rds.password
  }
}

resource "kubernetes_secret" "orders_rds_reader" {
  metadata {
    name      = "orders-reader-db"
    namespace = module.app_base.namespace
  }

  data = {
    url      = "jdbc:mysql://${module.orders_rds.reader_endpoint}:3306/orders"
    username = module.orders_rds.username
    password = module.orders_rds.password
  }
}