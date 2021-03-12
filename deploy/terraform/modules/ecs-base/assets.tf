module "assets_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "assets"
  region                    = var.region
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [ aws_security_group.nsg_task.id ]
  lb_security_group_id      = aws_security_group.lb_sg.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 256
  memory                    = 512
  health_check_path         = "/health.html"
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
  docker_labels             = {
    "platform" = "nginx"
  }

  container_image           = "watchn/watchn-assets:${module.image_tag.image_tag}"
  environment               = [{
    name  = "PORT"
    value = "8080"
  }]

  readonly_filesystem       = false
  drop_capabilities         = false
}