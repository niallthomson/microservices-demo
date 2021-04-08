module "assets_service" {
  source = "../services/assets"

  environment_name          = local.full_environment_prefix
  region                    = var.region
  cluster_id                = module.cluster.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  image_tag                 = module.image_tag.image_tag
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  task_sg_id                = module.cluster.task_security_group_id
  lb_security_group_id      = module.cluster.lb_security_group_id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
}