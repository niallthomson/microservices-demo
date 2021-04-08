module "catalog_rds" {
  source = "../../rds-mysql"

  environment_name = local.full_environment_prefix
  instance_name    = "catalog"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
  db_name          = "catalog"
}

resource "aws_security_group_rule" "catalog_rds_ingress" {
  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  security_group_id = module.catalog_rds.security_group_id
}

resource "kubernetes_secret" "catalog_rds_writer" {
  metadata {
    name      = "catalog-writer-db"
    namespace = module.app_base.namespace
  }

  data = {
    endpoint = module.catalog_rds.writer_endpoint
    name     = "catalog"
    username = module.catalog_rds.username
    password = module.catalog_rds.password
  }
}

resource "kubernetes_secret" "catalog_rds_reader" {
  metadata {
    name      = "catalog-reader-db"
    namespace = module.app_base.namespace
  }

  data = {
    endpoint = module.catalog_rds.reader_endpoint
    name     = "catalog"
    username = module.catalog_rds.username
    password = module.catalog_rds.password
  }
}