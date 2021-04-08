module "app_service" {
  source = "../../app-service"

  environment_name          = var.environment_name
  service_name              = "assets"
  region                    = var.region
  cluster_id                = var.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [ var.task_sg_id ]
  lb_security_group_id      = var.lb_security_group_id
  sd_namespace_id           = var.sd_namespace_id
  cpu                       = 256
  memory                    = 512
  health_check_path         = "/health.html"
  fargate                   = var.fargate
  ssm_kms_policy_arn        = var.ssm_kms_policy_arn
  docker_labels             = {
    "platform" = "nginx"
  }

  container_image           = "watchn/watchn-assets:${var.image_tag}"
  environment               = [{
    name  = "PORT"
    value = "8080"
  }]

  readonly_filesystem       = false
  drop_capabilities         = false
}