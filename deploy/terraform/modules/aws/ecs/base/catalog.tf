module "catalog_service" {
  source = "../services/catalog"

  environment_name          = local.full_environment_prefix
  region                    = var.region
  cluster_id                = module.cluster.cluster_id
  cluster_name              = module.cluster.cluster_name
  ecs_deployment_controller = var.ecs_deployment_controller
  image_tag                 = module.image_tag.image_tag
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  database_subnet_ids       = module.vpc.database_subnets
  task_sg_id                = module.cluster.task_security_group_id
  lb_security_group_id      = module.cluster.lb_security_group_id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  fargate                   = var.fargate
  ssm_key_id                = aws_kms_key.ssm_key.key_id
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
}