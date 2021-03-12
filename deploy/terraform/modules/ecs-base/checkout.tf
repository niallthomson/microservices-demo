module "checkout_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "checkout"
  region                    = var.region
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [ aws_security_group.nsg_task.id, aws_security_group.checkout.id ]
  lb_security_group_id      = aws_security_group.lb_sg.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 256
  memory                    = 512
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
  docker_labels             = {
    "platform" = "node"
  }

  container_image           = "watchn/watchn-checkout:${module.image_tag.image_tag}"
  environment               = [{
    name  = "REDIS_URL",
    value = "redis://${module.checkout_redis.address}:${module.checkout_redis.port}"
  },{
    name  = "REDIS_READER_URL",
    value = "redis://${module.checkout_redis.reader_address}:${module.checkout_redis.port}"
  },{
    name  = "ENDPOINTS_ORDERS",
    value = "http://${local.orders_dns}:8080"
  }]

  cloudwatch_dashboard_elements = module.checkout_redis.cloudwatch_dashboard_elements
}

resource "aws_security_group" "checkout" {
  name_prefix = "${local.full_environment_prefix}-checkout"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for checkout service"
}

resource "aws_security_group_rule" "checkout_redis_ingress" {
  description = "Allow access from checkout ECS task"

  type                      = "ingress"
  from_port                 = module.checkout_redis.port
  to_port                   = module.checkout_redis.port
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.checkout.id
  security_group_id         = module.checkout_redis.security_group_id
}

module "checkout_redis" {
  source = "../aws-elasticache-redis"

  environment_name   = local.full_environment_prefix
  instance_name      = "checkout"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnets
  availability_zones = var.availability_zones
}