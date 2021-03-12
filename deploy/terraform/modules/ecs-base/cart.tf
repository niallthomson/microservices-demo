locals {
  carts_chaos_profile_map = {
    "" = []
    "errors" = ["chaos-errors"]
    "latency" = ["chaos-latency"]
  }
  carts_spring_profiles = ["prod", "dynamodb", "chaos-monkey"]
}

module "carts_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "cart"
  region                    = var.region
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [ aws_security_group.nsg_task.id ]
  lb_security_group_id      = aws_security_group.lb_sg.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 512
  memory                    = 1024
  health_check_path         = "/actuator/health"
  health_check_grace_period = 120
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
  docker_labels             = {
    "platform" = "java"
  }

  container_image           = "watchn/watchn-cart:${module.image_tag.image_tag}"
  environment               = [{
    name  = "CARTS_DYNAMODB_TABLENAME",
    value = aws_dynamodb_table.carts.name
  },{
    name  = "CARTS_DYNAMODB_CREATETABLE",
    value = "false"
  },{
    name  = "SPRING_PROFILES_ACTIVE",
    value = join(",", concat(local.carts_spring_profiles, local.carts_chaos_profile_map[var.carts_chaos]))
  },{
    name  = "JAVA_OPTS",
    value = "-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/urandom -XX:MaxMetaspaceSize=128m"
  }]
}
 
resource "aws_iam_role_policy_attachment" "carts_role_attachment" {
  role       = module.carts_service.task_execution_role_name
  policy_arn = aws_iam_policy.carts_dynamo.arn
}